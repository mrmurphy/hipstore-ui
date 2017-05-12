module HipstoreUI exposing (Product, Config, products, cart)

{-| A tiny collection of UI functions made bespoke for Splodingsocks's Elm workshop.

# Types
@docs Product, Config

# Views
@docs products, cart
-}

import Bootstrap.Button exposing (onClick)
import Bootstrap.CDN
import Bootstrap.Card as Card
import CDN
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style)
import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..), WebData, isLoading)


url : String
url =
    "https://hipstore.now.sh/"


{-| A Product isn't too complex. It's got an id, a name, an image, and it costs a few tacos. Yum, 🌮s.
-}
type alias Product =
    { id : String
    , displayName : String
    , tacos : Float
    , image : String
    }


{-| The config contains functions and messages that the UI can use to send messages to the update function,
as well as some other necessary information for rendering the rest of the UI.
-}
type alias Config msg =
    { onAddToCart : String -> msg
    , onRemoveFromCart : String -> msg
    , onClickViewCart : msg
    , onClickViewProducts : msg
    , location : Navigation.Location
    }


fakeNavBar : Navigation.Location -> Html msg
fakeNavBar location =
    div
        [ style
            [ ( "background", "#ECEFF1" )
            , ( "color", "#455A64" )
            , ( "padding", "0.5rem" )
            ]
        ]
        [ text "path and hash: ", text location.pathname, text location.hash ]


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
                [ Bootstrap.Button.attrs [ style [ ( "margin-top", "auto" ) ] ]
                , onClick <| config.onAddToCart p.id
                , Bootstrap.Button.secondary
                , Bootstrap.Button.block
                ]
                [ text "Add to Cart \x1F6D2" ]
            ]
        |> Card.view


loadingIndicator : Bool -> Html msg
loadingIndicator isLoading =
    if isLoading then
        i [ class "fa fa-spin fa-cog", style [ ( "font-size", "2em" ), ( "margin-right", "1rem" ) ] ] []
    else
        text ""


{-| This function will render a nice, full-page view of the products that are passed into it.
The second argument, the bool, represents whether or not something is currently loading (for rendering a nice loading indicator.) The third argument is a WebData of the Products, and the fourth is a WebData of the products currently in the cart.
-}
products : Config msg -> Bool -> WebData (List Product) -> WebData (List Product) -> Html msg
products config isLoading productsWD cartWD =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-rows", "min-content min-content 1fr min-content" )
            , ( "height", "100vh" )
            , ( "color", "#616161" )
            ]
        ]
        [ Bootstrap.CDN.stylesheet
        , .css CDN.fontAwesome
        , fakeNavBar config.location
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
            , loadingIndicator isLoading
            , Bootstrap.Button.button
                [ Bootstrap.Button.secondary
                , Bootstrap.Button.onClick config.onClickViewCart
                ]
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
                [ style [ ( "align-self", "center" ) ]
                ]
            , onClick <| config.onRemoveFromCart p.id
            , Bootstrap.Button.danger
            ]
            [ text "Nope" ]
        ]


{-| This function will render a nice, full-page cart view of the products that are passed into it.
The second argument, the bool, represents whether or not something is currently loading (for rendering a nice loading indicator.) The third argument is a WebData of the products currently in the cart.
-}
cart : Config msg -> Bool -> WebData (List Product) -> Html msg
cart config isLoading cartWD =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-rows", "min-content min-content 1fr min-content" )
            , ( "height", "100vh" )
            , ( "color", "#616161" )
            ]
        ]
        [ Bootstrap.CDN.stylesheet
        , .css CDN.fontAwesome
        , fakeNavBar config.location
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
            , loadingIndicator isLoading
            , Bootstrap.Button.button
                [ Bootstrap.Button.secondary
                , Bootstrap.Button.onClick config.onClickViewProducts
                ]
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
