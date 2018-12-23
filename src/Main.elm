port module Main exposing (main, init, saveInbox)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json

import Json.Decode as JD
import Json.Encode as JE

-- Ports
port saveInbox : Model -> Cmd msg


-- Main
main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- Model
type alias Model =
    { newTodo : String
    , todoList : List Todo
    }

type alias Todo =
    { id : Int, title : String }


init : Int -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )

initialModel : Model
initialModel =
    { newTodo = ""
    , todoList = []
    }


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- Update
type Msg
    = Change String | Delete Int | Enter Int | SaveInbox Int

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        isSpace = String.trim >> String.isEmpty
    in
        case msg of
            Change s ->
                ( { model | newTodo = s }
                , Cmd.none
                )
            Enter i ->
                if i == 13 then
                    if isSpace model.newTodo then
                        ( model, Cmd.none )
                    else
                        addTodo model
                else
                    ( model, Cmd.none )
            Delete n ->
                let
                    t = model.todoList
                in
                    ( { model | todoList = List.take n t ++ List.drop (n + 1) t }
                    , saveInbox model
                    )
            SaveInbox n ->
                ( model, saveInbox model )

onKeyPress : (Int -> Msg) -> Attribute Msg
onKeyPress tagger =
    Html.Events.on "keypress" ( Json.map tagger Html.Events.keyCode )

addTodo : Model -> ( Model, Cmd Msg )
addTodo model =
    let
        m = { model | todoList = model.todoList ++ [(Todo (List.length model.todoList + 1) model.newTodo)] , newTodo = "" }
    in
        ( m, saveInbox m )


-- View
view : Model -> Html Msg
view model =
    section [ class "uk-section uk-align-center uk-section-muted" ]
            [ div [ class "uk-container uk-width-expand" ]
                  [ input [ value model.newTodo, onInput Change, onKeyPress Enter, class "uk-input", placeholder "new task"] []
                  , table [ class "uk-table uk-table-divider uk-table-hover uk-table-small" ]
                          [ tr []
                               [ th [ class "uk-width-auto" ] [ text "Done" ]
                               , th [ class "uk-width-expand" ] [ text "Title" ]
                               , th [ class "uk-width-auto" ] [ text "Action" ]
                               ]
                          , tbody [] (viewList model.todoList)
                          ]
                  ]
            ]

-- サイドバー 現状は使用していない
viewNav =
    div [ class "uk-margin-small-left uk-grid-divider", attribute "uk-grid" "" ]
        [ div [ class "uk-width-auto" ]
              [ ul [ class "uk-nav" ]
                   [ li [ class "uk-parent" ]
                        [ text "GTD"
                        , ul [ class "uk-nav-sub" ]
                             [ li [ class "uk-active"] [ text "Inbox" ] ]
                        ]
                   ]
              ]
        ]

viewList : List Todo -> List (Html Msg)
viewList todoList =
    List.map viewTodo todoList

viewTodo : Todo -> Html Msg
viewTodo todo =
    tr []
       [ td [] [ input [ class "uk-checkbox" ] []
               ]
       , td [] [ text todo.title ]
       , td [] [ button [ onClick (Delete todo.id), class "uk-button-small uk-button-danger" ]
                        [ text "Delete" ]
               ]
       ]
