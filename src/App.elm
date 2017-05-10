module App exposing (..)

import HipstoreUI
import Html exposing (Html, div)
import RemoteData exposing (WebData)


---- MODEL ----


type alias Model =
    { products : WebData (List HipstoreUI.Product) }


init : ( Model, Cmd Msg )
init =
    ( { products = RemoteData.NotAsked }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


uiConfig : HipstoreUI.Config Msg
uiConfig =
    { onAddToCart = \id -> NoOp
    , onRemoveFromCart = \id -> NoOp
    , onClickViewCart = NoOp
    , onClickViewProducts = NoOp
    }


view : Model -> Html Msg
view model =
    div []
        [ HipstoreUI.products uiConfig model.products
        , HipstoreUI.cart uiConfig model.products
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
