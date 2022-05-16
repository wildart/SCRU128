# SCRU128: Sortable, Clock and Random number-based Unique identifier

SCRU128 ID is a supersede [UUID] that has the following features:

- 128-bit unsigned integer type
- Sortable by generation time (as integer and as text)
- 25-digit case-insensitive textual representation (Base36)
- 48-bit millisecond Unix timestamp that ensures useful life until year 10889
- Up to 281 trillion time-ordered but unpredictable unique IDs per millisecond
- 80-bit three-layer randomness for global uniqueness

```julia
julia> using SCRU128

julia> id = SCRU128Id()
SCRU128Id(0x0180cf01d7e41f149affea220e4508d2)

julia> string(id) # convert id to string
"037BY37CNY3426KUV0W41B0LU"

julia> UInt128(id) # conver id to UInt128
0x0180cf01d7e41f149affea220e4508d2

julia> string.(Iterators.take(scru128(), 5)) # using generator
5-element Vector{String}:
 "037BY3BUQ8S8MJGZTTYTEAZQ7"
 "037BY3BUQ633D5J0F29AKK9N8"
 "037BY3BUQ633D5J0F2AFNCYDD"
 "037BY3BUQ633D5J0F2D872JKS"
 "037BY3BUQ633D5J0F2EZS5UY4"

julia> SCRU128Id("037BY3BUQ633D5J0F2EZS5UY4") # convert string to id
SCRU128Id(0x0180cf032af79b0eca5bd659931a5d7b)
```

See [SCRU128 Specification] for details.

[uuid]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[scru128 specification]: https://github.com/scru128/spec

