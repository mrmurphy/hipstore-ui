module HipstoreUI exposing (Product, Config, products, cart)

import Bootstrap.CDN
import Bootstrap.Card as Card
import Html exposing (..)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..), WebData)


url : String
url =
    "http://hipstore.now.sh/"


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
    div []
        [ img [ src <| url ++ p.image ] []
        , h2 [] [ text p.displayName ]
        , em [] [ text (toString p.tacos), text "\x1F32E" ]
        , button [ onClick <| config.onAddToCart p.id ] [ text "Add to Cart \x1F6D2" ]
        ]


products : Config msg -> WebData (List Product) -> Html msg
products config productsWD =
    div []
        [ Bootstrap.CDN.stylesheet
        , Card.config []
            |> Card.block []
                [ Card.titleH4 [] [ text "Products" ]
                , case productsWD of
                    NotAsked ->
                        Card.text [] [ text "Waiting to be told to load." ]

                    Loading ->
                        Card.text [] [ text "Loading, please wait." ]

                    Failure e ->
                        Card.text [] [ text <| toString e ]

                    Success products ->
                        Card.text [] (List.map (product config) products)
                ]
            |> Card.view
        ]


productInCart : Config msg -> Product -> Html msg
productInCart config p =
    div []
        [ img [ src <| url ++ p.image ] []
        , h2 [] [ text p.displayName ]
        , em [] [ text (toString p.tacos), text "\x1F32E" ]
        , button [ onClick <| config.onRemoveFromCart p.id ] [ text "Remove from Cart \x1F6D2" ]
        ]


cart : Config msg -> WebData (List Product) -> Html msg
cart config cartWD =
    div []
        [ Bootstrap.CDN.stylesheet
        , Card.config []
            |> Card.block []
                [ Card.titleH4 [] [ text "Cart" ]
                , case cartWD of
                    NotAsked ->
                        Card.text [] [ text "Waiting to be told to load." ]

                    Loading ->
                        Card.text [] [ text "Loading, please wait." ]

                    Failure e ->
                        Card.text [] [ text <| toString e ]

                    Success products ->
                        Card.text [] (List.map (productInCart config) products)
                ]
            |> Card.view
        ]


locationBar : Location -> Html msg
locationBar loc =
    div []
        [ text <| "The current path is: " ++ loc.hash ]
