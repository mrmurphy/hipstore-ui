module App exposing (..)

import HipstoreUI exposing (Product)
import Html exposing (Html, div)
import Http exposing (emptyBody, expectJson)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)


--- Decoders ---


decodeProduct : Decoder Product
decodeProduct =
    Json.Decode.map4 Product
        (Json.Decode.at [ "id" ] Json.Decode.string)
        (Json.Decode.at [ "name" ] Json.Decode.string)
        (Json.Decode.at [ "price" ] Json.Decode.float)
        (Json.Decode.at [ "image" ] Json.Decode.string)



---- Requests ----


getProducts : Cmd Msg
getProducts =
    Http.get "https://hipstore.now.sh/api/products" (Json.Decode.list decodeProduct)
        |> RemoteData.sendRequest
        |> Cmd.map ProductsChanged


getCart : Cmd Msg
getCart =
    Http.request
        { method = "get"
        , headers = []
        , url = ("https://hipstore.now.sh/api/cart")
        , body = emptyBody
        , expect = expectJson (Json.Decode.list decodeProduct)
        , timeout = Nothing
        , withCredentials = True
        }
        |> RemoteData.sendRequest
        |> Cmd.map CartChanged


addToCart : String -> Cmd Msg
addToCart id =
    Http.request
        { method = "post"
        , headers = []
        , url = ("https://hipstore.now.sh/api/cart/" ++ id)
        , body = emptyBody
        , expect = expectJson (Json.Decode.list decodeProduct)
        , timeout = Nothing
        , withCredentials = True
        }
        |> RemoteData.sendRequest
        |> Cmd.map CartChanged


removeFromCart : String -> Cmd Msg
removeFromCart id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = ("https://hipstore.now.sh/api/cart/" ++ id)
        , body = emptyBody
        , expect = expectJson (Json.Decode.list decodeProduct)
        , timeout = Nothing
        , withCredentials = True
        }
        |> RemoteData.sendRequest
        |> Cmd.map CartChanged



---- MODEL ----


type alias Model =
    { products : WebData (List HipstoreUI.Product)
    , cart : WebData (List HipstoreUI.Product)
    }


init : ( Model, Cmd Msg )
init =
    ( { products = RemoteData.Loading
      , cart = RemoteData.Loading
      }
    , Cmd.batch [ getProducts, getCart ]
    )



---- UPDATE ----


type Msg
    = NoOp
    | ProductsChanged (WebData (List Product))
    | CartChanged (WebData (List Product))
    | AddToCart String
    | RemoveFromCart String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ProductsChanged newWebData ->
            { model | products = newWebData } ! []

        CartChanged newWebData ->
            { model | cart = newWebData } ! []

        AddToCart id ->
            model ! [ addToCart id ]

        RemoveFromCart id ->
            model ! [ removeFromCart id ]



---- VIEW ----


uiConfig : HipstoreUI.Config Msg
uiConfig =
    { onAddToCart = AddToCart
    , onRemoveFromCart = RemoveFromCart
    , onClickViewCart = NoOp
    , onClickViewProducts = NoOp
    }


view : Model -> Html Msg
view model =
    div []
        [ HipstoreUI.products uiConfig model.products model.cart
        , HipstoreUI.cart uiConfig model.cart
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
