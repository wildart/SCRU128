using SCRU128
using Test

@testset "SCRU128" begin

    MAX_UINT48 = 2^48 - 1
    MAX_UINT24 = 2^24 - 1
    MAX_UINT32 = 2^32 - 1

    @testset "Edge" for (id, s) in [
            ((0, 0, 0, 0), "0000000000000000000000000"),
            ((MAX_UINT48, 0, 0, 0), "F5LXX1ZZ5K6TP71GEEH2DB7K0"),
            ((MAX_UINT48, 0, 0, 0), "f5lxx1zz5k6tp71geeh2db7k0"),
            ((0, MAX_UINT24, 0, 0), "0000000005GV2R2KJWR7N8XS0"),
            ((0, MAX_UINT24, 0, 0), "0000000005gv2r2kjwr7n8xs0"),
            ((0, 0, MAX_UINT24, 0), "00000000000000JPIA7QL4HS0"),
            ((0, 0, MAX_UINT24, 0), "00000000000000jpia7ql4hs0"),
            ((0, 0, 0, MAX_UINT32), "0000000000000000001Z141Z3"),
            ((0, 0, 0, MAX_UINT32), "0000000000000000001z141z3"),
            (
                (MAX_UINT48, MAX_UINT24, MAX_UINT24, MAX_UINT32),
                "F5LXX1ZZ5PNORYNQGLHZMSP33",
            ),
            (
                (MAX_UINT48, MAX_UINT24, MAX_UINT24, MAX_UINT32),
                "f5lxx1zz5pnorynqglhzmsp33",
            ),
        ]
        v = SCRU128Id(UInt(id[1]), UInt32(id[2]), UInt32(id[3]), UInt32(id[4]))
        @test string(v) == uppercase(s)
    end

    @testset "Invalid" for id in [
            "",
            " 036Z8PUQ4TSXSIGK6O19Y164Q",
            "036Z8PUQ54QNY1VQ3HCBRKWEB ",
            " 036Z8PUQ54QNY1VQ3HELIVWAX ",
            "+036Z8PUQ54QNY1VQ3HFCV3SS0",
            "-036Z8PUQ54QNY1VQ3HHY8U1CH",
            "+36Z8PUQ54QNY1VQ3HJQ48D9P",
            "-36Z8PUQ5A7J0TI08OZ6ZDRDY",
            "036Z8PUQ5A7J0T_08P2CDZ28V",
            "036Z8PU-5A7J0TI08P3OL8OOL",
            "036Z8PUQ5A7J0TI08P4J 6CYA",
            "F5LXX1ZZ5PNORYNQGLHZMSP34",
            "ZZZZZZZZZZZZZZZZZZZZZZZZZ",
        ]
        @test_throws ArgumentError SCRU128Id(id)
    end

    @testset "Generator" begin
        g = scru128()
        id = first(g)
        ts = SCRU128.timestamp(id)
        for v in Iterators.take(scru128(), 10)
            @test ts <= SCRU128.timestamp(v)
        end
    end
end

