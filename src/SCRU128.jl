module SCRU128

using Random

import Base: iterate, convert, string, UInt128, isless, length

export scru128, SCRU128Id

const MaxCounter = 0xff_ffff

"""
    scru128([rng::AbstractRNG])

Create SCRU128 generator object
"""
struct scru128
    rng::AbstractRNG
    function scru128(rng::AbstractRNG = Random.default_rng())
        new(rng)
    end
end
length(iter::scru128) = typemax(UInt)

function milliseconds()
    tvr = Ref{Base.Libc.TimeVal}()
    st = ccall(:jl_gettimeofday, Cint, (Ref{Base.Libc.TimeVal},), tvr)
    return UInt(tvr[].sec*1000 + div(tvr[].usec,1000))
end

function iterate(iter::scru128,
                 state=(zero(UInt), zero(UInt), zero(UInt32), zero(UInt32)))
    ts, ts_up, count_up, count_lo = state
    curr = milliseconds()
    if iszero(ts)
        ts = curr
        count_up = rand(iter.rng, UInt32) & MaxCounter
        count_lo = rand(iter.rng, UInt32) & MaxCounter
    else
        if curr > ts
            ts = curr
            count_lo = rand(iter.rng, UInt32) & MaxCounter
        elseif curr + 10_000 > ts
            count_lo += one(UInt32)
            if count_lo > MaxCounter
                count_lo = zero(UInt32)
                count_up += one(UInt32)
                if count_up > MaxCounter
                    count_up = zero(UInt32)
                    ts += one(UInt)
                    count_lo = rand(iter.rng, UInt32) & MaxCounter
                end
            end
        else
            ts_up = zero(UInt)
            ts = curr
            count_lo = rand(iter.rng, UInt32) & MaxCounter
        end

        if ts - ts_up >= 1000
            ts_up = ts
            count_up = rand(iter.rng, UInt32) & MaxCounter
        end
    end

    id = SCRU128Id(ts, count_up, count_lo, rand(iter.rng, UInt32))
    return id, (ts, ts_up, count_up, count_lo)
end

struct SCRU128Id
    id::UInt128
end

function SCRU128Id(ts::UInt, up::UInt32, lo::UInt32, rn::UInt32)
    id = UInt128(ts) << 80 | UInt128(up) << 56 |
         UInt128(lo) << 32 | UInt128(rn)
    return SCRU128Id(id)
end
function SCRU128Id(s::String)
    if match(r"^[0-9A-Za-z]{25}$", s) === nothing
        throw(ArgumentError("invalid string representation"))
    end
    id = try
        parse(UInt128, s, base=36)
    catch e
        throw(ArgumentError("invalid string representation"))
    end
    return SCRU128Id()
end
SCRU128Id() = first(scru128())

UInt128(v::SCRU128Id) = v.id
convert(::Type{UInt128}, v::SCRU128Id) = UInt128(v)
isless(v1::SCRU128Id, v2::SCRU128Id) = v1.id < v2.id

timestamp(v::SCRU128Id) = UInt( v.id >> 80 )
entropy(v::SCRU128Id) = UInt32( v.id & UInt128(typemax(UInt32)) )
counter_hi(v::SCRU128Id) = UInt32( v.id >> 56 & MaxCounter )
counter_lo(v::SCRU128Id) = UInt32( v.id >> 32 & MaxCounter )

const DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function string(v::SCRU128Id)
    idx = zeros(UInt8, 25)
    n = v.id
    for i in 25:-1:1
        idx[i] = (n % 36) + 1
        n = div(n, 36)
    end
    return DIGITS[idx]
end


end # module
