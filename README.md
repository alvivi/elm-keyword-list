
# elm-nested-list

A list of values of any type, which can also be lists.

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

Using `NestedList`, the above code will look like this:

    myView : Bool -> Html msg
    myView isHidden =
        Html.div []
            (NestedList.fromMany
                [ NestedList.one (Html.text "Always visible")
                , NestedList.one (Html.text "Always visible")
                , NestedList.ifTrue isHidden (Html.text "Maybe visible")
                , NestedList.ifFalse isHidden (Html.text "Maybe not visible")
                , NestedList many
                    [ Html.text "Even nested list, without calling again fromMany"
                    ]
                ]
            )


## A Note About Performance

This library optimizes converting `NestedList` back to a list in linear
time. Here is a benchmark comparing using `NestedList` against using `List` and
`List.concat`.

![Benchmark](https://raw.githubusercontent.com/alvivi/elm-nested-list/master/assets/elm-nested-list-benchmark.png)
