module App exposing (..)

import HipstoreUI exposing (Product)
import Html exposing (Html, div, text)
import Http exposing (emptyBody, expectJson)
import Json.Decode exposing (Decoder)
import Navigation exposing (Location)
import RemoteData exposing (WebData, isLoading)
import Route exposing ((:=), match)


--- Router ---


type Page
    = Home
    | Cart
    | NotFound


routeParsers =
    { home = Home := Route.static ""
    , cart = Cart := Route.static "#cart"
    }


router : Route.Router Page
router =
    Route.router
        [ routeParsers.home
        , routeParsers.cart
        ]


routeFromLocation : Location -> Page
routeFromLocation location =
    (location.pathname ++ location.hash)
        |> match router
        |> Maybe.withDefault NotFound


navigateTo : Page -> Cmd msg
navigateTo page =
    (case page of
        Home ->
            Route.reverse routeParsers.home []

        Cart ->
            Route.reverse routeParsers.cart []

        NotFound ->
            "/"
    )
        |> Navigation.newUrl



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
    , location : Navigation.Location
    , activePage : Page
    , isLoading : Bool
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { products = RemoteData.Loading
      , cart = RemoteData.Loading
      , location = location
      , activePage = Home
      , isLoading = True
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
    | LocationChanged Location
    | NavigateTo Page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg: " msg of
        NoOp ->
            model ! []

        ProductsChanged newWebData ->
            { model
                | products = newWebData
                , isLoading = False
            }
                ! []

        CartChanged newWebData ->
            { model
                | cart = newWebData
                , isLoading = False
            }
                ! []

        AddToCart id ->
            { model | isLoading = True } ! [ addToCart id ]

        RemoveFromCart id ->
            { model | isLoading = True } ! [ removeFromCart id ]

        LocationChanged loc ->
            { model | location = loc, activePage = routeFromLocation loc } ! []

        NavigateTo page ->
            model ! [ navigateTo page ]



---- VIEW ----


uiConfig : Location -> HipstoreUI.Config Msg
uiConfig location =
    { onAddToCart = AddToCart
    , onRemoveFromCart = RemoveFromCart
    , onClickViewCart = NavigateTo Cart
    , onClickViewProducts = NavigateTo Home
    , location = location
    }


view : Model -> Html Msg
view model =
    div []
        [ case model.activePage of
            Home ->
                HipstoreUI.products (uiConfig model.location) model.isLoading model.products model.cart

            Cart ->
                HipstoreUI.cart (uiConfig model.location) model.isLoading model.cart

            NotFound ->
                div [] [ text "Sorry, nothing here :(" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program LocationChanged
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
