module KeywordList
    exposing
        ( KeywordList
        , zero
        , one
        , many
        , group
        , fromMany
        , toList
        , ifTrue
        , ifFalse
        , maybe
        , maybeMap
        )

{-| A list of values of any type, which can also be lists.

The main use case of this library is managing list of optional and nested
values, for example, like `Html` nodes or `Html.Attribute`s. Usually, we can
solve this issue using `List (List any)` or `List (Maybe any)`, like this:

    myView : Bool -> Html msg
    myView isHidden =
        Html.div []
            (List.concat
                [ [ Html.text "Always visible"
                  , Html.text "Also always visible"
                  ]
                , if isHidden then
                    []
                  else
                    [ Html.text "Maybe visible" ]
                , if not isHidden then
                    [ Html.text "Maybe not visible" ]
                  else
                    []
                ]
            )

Using `KeywordList`, the above code will look like this:

    myView : Bool -> Html msg
    myView isHidden =
        Html.div []
            (KeywordList.fromMany
                [ KeywordList.one (Html.text "Always visible")
                , KeywordList.one (Html.text "Always visible")
                , KeywordList.ifTrue isHidden (Html.text "Maybe visible")
                , KeywordList.ifFalse isHidden (Html.text "Maybe not visible")
                , KeywordList many
                    [ Html.text "Even nested list, without calling again fromMany"
                    ]
                ]
            )


## A Note About Performance

This library optimizes converting `KeywordList` back to a list in linear
time. Here is a benchmark comparing using `KeywordList` against using `List` and
`List.concat`.

![Benchmark](https://raw.githubusercontent.com/alvivi/elm-keyword-list/master/assets/elm-keyword-list-benchmark.png)


# Creating Keyword Lists

@docs KeywordList, zero, one, many, group


# Conversion to Lists

@docs fromMany, toList


# Helpful Functions

@docs ifTrue, ifFalse, maybe, maybeMap

-}

-- Creating Keyword List --


{-| A list of values or nested values.
-}
type KeywordList a
    = One a
    | Many (List a)
    | Group (List (KeywordList a))


{-| Returns an empty [`KeywordList`](#KeywordList), **O(1)**.
-}
zero : KeywordList a
zero =
    Many []


{-| Returns a singleton [`KeywordList`](#KeywordList), i.e. a list with only
one element, **O(1)**.
-}
one : a -> KeywordList a
one =
    One


{-| Transform a `List` of values into [`KeywordList`](#KeywordList) value,
**O(1)**.
-}
many : List a -> KeywordList a
many =
    Many


{-| Groups a `List` of [`KeywordList`](#KeywordList) of values into
[`KeywordList`](#KeywordList) value, **O(1)**.
-}
group : List (KeywordList a) -> KeywordList a
group =
    Group



-- Conversion to Lists --


{-| Converts a `List` of [`KeywordList`](#KeywordList) into a `List`, **O(n)**.
Same than `KeywordList.many >> KeywordList.toList`.
-}
fromMany : List (KeywordList a) -> List a
fromMany =
    Group >> toList


{-| Converts a [`KeywordList`](#KeywordList) into a `List`, **O(n)**.
-}
toList : KeywordList a -> List a
toList list =
    case list of
        One value ->
            [ value ]

        Many list ->
            list

        Group [] ->
            []

        Group ((One value) :: (One value2) :: (One value3) :: tail) ->
            value :: value2 :: value3 :: toList (Group tail)

        Group ((One value) :: (One value2) :: tail) ->
            value :: value2 :: toList (Group tail)

        Group ((One value) :: tail) ->
            value :: toList (Group tail)

        Group ((Many flatTail) :: tail) ->
            flatTail ++ toList (Group tail)

        Group ((Group []) :: tail) ->
            toList (Group tail)

        Group ((Group ((One value) :: more)) :: tail) ->
            value :: (toList (Group (Group more :: tail)))

        Group ((Group ((Many flatList) :: more)) :: tail) ->
            flatList ++ toList (Group (Group more :: tail))

        Group ((Group ((Group more) :: evenMore)) :: tail) ->
            toList (Group (Group more :: Group evenMore :: tail))



-- Helpful Functions --


{-| Given a predicate, return an empty [`KeywordList`](#KeywordList) if the
predicates is true, or singleton [`KeywordList`](#KeywordList) otherwise.
**O(1)**.
-}
ifTrue : Bool -> a -> KeywordList a
ifTrue pred value =
    if pred then
        One value
    else
        Many []


{-| Given a predicate, return an empty [`KeywordList`](#KeywordList) if the
predicates is false, or singleton [`KeywordList`](#KeywordList) if it is true.
**O(1)**.
-}
ifFalse : Bool -> a -> KeywordList a
ifFalse pred value =
    if not pred then
        One value
    else
        Many []


{-| Converts a `Maybe` into a singleton [`KeywordList`](#KeywordList),
**O(1)**.
-}
maybe : Maybe a -> KeywordList a
maybe maybeValue =
    case maybeValue of
        Nothing ->
            Many []

        Just value ->
            One value


{-| Transforms a `Maybe` value given a function and then transforms that `Maybe`
into a [`KeywordList`](#KeywordList), **O(1)**. Like `Maybe.map fn >> maybe`.
-}
maybeMap : (b -> a) -> Maybe b -> KeywordList a
maybeMap fn =
    Maybe.map fn >> maybe
