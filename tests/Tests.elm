module Tests exposing (suite)

import Test as T exposing (Test)
import Fuzz as F exposing (Fuzzer)
import Expect as E
import KeywordList exposing (KeywordList)


suite : Test
suite =
    T.describe "Nested List"
        [ T.describe "toList"
            [ T.test "empty lists" <|
                \_ ->
                    E.equal (KeywordList.toList KeywordList.zero) []
            , T.test "singleton lists" <|
                \_ ->
                    E.equal (KeywordList.toList <| KeywordList.one 9001) [ 9001 ]
            , T.fuzz listOfZeros "list of zeros" <|
                \list ->
                    E.equal (KeywordList.toList list) []
            , T.fuzz (flatPair F.int) "list of flat values" <|
                \( nested, list ) ->
                    E.equal (KeywordList.toList nested) list
            , T.test "nested lists values" <|
                \_ ->
                    let
                        input =
                            KeywordList.group
                                [ KeywordList.zero
                                , KeywordList.one 9001
                                , KeywordList.many []
                                , KeywordList.group
                                    [ KeywordList.zero
                                    , KeywordList.one 9001
                                    , KeywordList.many []
                                    , KeywordList.group
                                        [ KeywordList.zero
                                        , KeywordList.one 9001
                                        ]
                                    ]
                                ]
                    in
                        E.equal (KeywordList.toList input) [ 9001, 9001, 9001 ]
            ]
        ]


listOfZeros : Fuzzer (KeywordList a)
listOfZeros =
    F.map KeywordList.group (F.list <| F.constant KeywordList.zero)


flatPair : Fuzzer a -> Fuzzer ( KeywordList a, List a )
flatPair =
    F.list
        >> F.map (\v -> ( List.map KeywordList.one v, v ))
        >> F.map (Tuple.mapFirst KeywordList.group)
