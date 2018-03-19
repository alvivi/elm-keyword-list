module Benchmarks exposing (main)

import Benchmark as B exposing (Benchmark)
import Benchmark.Runner as B exposing (BenchmarkProgram)
import KeywordList as K exposing (KeywordList)


suite : Benchmark
suite =
    let
        size =
            512

        value =
            9001

        flatKeywordListSample =
            value
                |> List.repeat size
                |> List.map K.one
                |> K.group

        flatListOfListsSample =
            value
                |> List.repeat size
                |> List.map List.singleton

        heterogeneousKeywordListSample =
            heterogeneousKeywordListStep
                |> List.repeat size
                |> List.map K.one
                |> K.group

        heterogeneousListOfListsSample =
            heterogeneousListOfListsStep
                |> List.repeat size
                |> List.map List.singleton

        heterogeneousKeywordListStep =
            K.group
                [ K.zero
                , K.one value
                , K.many [ value, value ]
                , K.many [ value, value, value ]
                , K.many [ value, value ]
                , K.one value
                , K.zero
                ]

        heterogeneousListOfListsStep =
            [ []
            , [ value ]
            , [ value, value ]
            , [ value, value, value ]
            , [ value, value ]
            , [ value ]
            , []
            ]
    in
        B.describe "Keyword List"
            [ B.describe "Converting Back to a List"
                [ B.compare "Flat Data"
                    "Keyword List"
                    (\_ -> K.toList heterogeneousKeywordListSample)
                    "List of Lists"
                    (\_ -> List.concat heterogeneousListOfListsSample)
                , B.compare "Heterogeneous Data"
                    "Keyword List"
                    (\_ -> K.toList heterogeneousKeywordListSample)
                    "List of Lists"
                    (\_ -> List.concat heterogeneousListOfListsSample)
                ]
            ]


main : BenchmarkProgram
main =
    B.program suite
