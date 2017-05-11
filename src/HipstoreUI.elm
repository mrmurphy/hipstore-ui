module HipstoreUI exposing (Product, Config, products, cart)

import Bootstrap.Button
import Bootstrap.CDN
import Bootstrap.Card as Card
import Html exposing (..)
import Html.Attributes exposing (href, src, style)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..), WebData)


url : String
url =
    "https://hipstore.now.sh/"


type alias Product =
    { id : String
    , displayName : String
    , tacos : Float
    , image : String
    }


type alias Config msg =
    { onAddToCart : String -> msg
    , onRemoveFromCart : String -> msg
    , onClickViewCart : msg
    , onClickViewProducts : msg
    }


product : Config msg -> Product -> Html msg
product config p =
    Card.config
        []
        |> Card.block []
            [ Card.text []
                [ img [ src <| url ++ p.image, style [ ( "max-width", "100%" ), ( "border-radius", "3px" ) ] ] []
                ]
            , Card.text [] [ strong [] [ text p.displayName ] ]
            , Card.text []
                [ Html.p []
                    [ text "Costs: "
                    , text "\x1F32E"
                    , text (toString p.tacos)
                    ]
                ]
            ]
        |> Card.footer []
            [ Bootstrap.Button.button
                [ Bootstrap.Button.attrs [ onClick <| config.onAddToCart p.id, style [ ( "margin-top", "auto" ) ] ]
                , Bootstrap.Button.secondary
                , Bootstrap.Button.block
                ]
                [ text "Add to Cart \x1F6D2" ]
            ]
        |> Card.view


products : Config msg -> WebData (List Product) -> WebData (List Product) -> Html msg
products config productsWD cartWD =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-rows", "min-content 1fr min-content" )
            , ( "height", "100vh" )
            ]
        ]
        [ Bootstrap.CDN.stylesheet
        , div
            [ style
                [ ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "justify-content", "center" )
                , ( "height", "75px" )
                , ( "padding", "0 2rem" )
                ]
            ]
            [ h4 [ style [ ( "flex", "1" ) ] ] [ text "Products" ]
            , Bootstrap.Button.button [ Bootstrap.Button.secondary ]
                [ text "\x1F6D2"
                , case RemoteData.toMaybe cartWD of
                    Just cart ->
                        text <| " " ++ (toString <| List.length cart) ++ " items"

                    Nothing ->
                        text ""
                ]
            ]
        , div
            [ style
                [ ( "padding", "0 2rem" )
                , ( "overflow", "scroll" )
                , ( "padding-bottom", "2rem" )
                ]
            ]
            [ case productsWD of
                NotAsked ->
                    text "Waiting to be told to load."

                Loading ->
                    text "Loading, please wait."

                Failure e ->
                    text <| toString e

                Success products ->
                    div
                        [ style
                            [ ( "display", "grid" )
                            , ( "grid-template-columns", "1fr 1fr 1fr" )
                            , ( "grid-auto-rows", "min-content" )
                            , ( "grid-gap", "2rem" )
                            ]
                        ]
                        (List.map (product config) products)
            ]
        ]


productInCart : Config msg -> Product -> Html msg
productInCart config p =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-columns", "100px 1fr min-content min-content" )
            , ( "grid-gap", "1rem" )
            ]
        ]
        [ img
            [ src <| url ++ p.image
            , style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "border-radius", "3px" )
                ]
            ]
            []
        , strong [ style [ ( "align-self", "center" ) ] ] [ text p.displayName ]
        , span [ style [ ( "align-self", "center" ) ] ] [ text (toString p.tacos), text "\x1F32E" ]
        , Bootstrap.Button.button
            [ Bootstrap.Button.attrs
                [ onClick <| config.onRemoveFromCart p.id
                , style [ ( "align-self", "center" ) ]
                ]
            , Bootstrap.Button.danger
            ]
            [ text "Nope" ]
        ]


cart : Config msg -> WebData (List Product) -> Html msg
cart config cartWD =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-rows", "min-content 1fr min-content" )
            , ( "height", "100vh" )
            ]
        ]
        [ Bootstrap.CDN.stylesheet
        , div
            [ style
                [ ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "justify-content", "center" )
                , ( "height", "75px" )
                , ( "padding", "0 2rem" )
                ]
            ]
            [ h4 [ style [ ( "flex", "1" ) ] ] [ text "Cart" ]
            , Bootstrap.Button.button [ Bootstrap.Button.secondary ]
                [ text "Back to Products"
                ]
            ]
        , div
            [ style
                [ ( "padding", "0 2rem" )
                , ( "overflow", "scroll" )
                ]
            ]
            [ case cartWD of
                NotAsked ->
                    text "Waiting to be told to load."

                Loading ->
                    text "Loading, please wait."

                Failure e ->
                    text <| toString e

                Success products ->
                    div
                        [ style
                            [ ( "display", "grid" )
                            , ( "grid-auto-rows", "100px" )
                            , ( "grid-gap", "2rem" )
                            , ( "overflow", "scroll" )
                            ]
                        ]
                        (List.map (productInCart config) products)
            ]
        , div
            [ style
                [ ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "justify-content", "flex-end" )
                , ( "height", "75px" )
                , ( "padding", "0 2rem" )
                ]
            ]
            [ span []
                [ text "Total: "
                , case RemoteData.toMaybe cartWD of
                    Just cart ->
                        let
                            count =
                                cart
                                    |> List.map .tacos
                                    |> List.sum
                        in
                            text <| (toString count) ++ "\x1F32E"

                    Nothing ->
                        text "loading or something."
                ]
            ]
        ]


locationBar : Location -> Html msg
locationBar loc =
    div []
        [ text <| "The current path is: " ++ loc.hash ]
