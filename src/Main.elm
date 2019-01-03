port module Main exposing (main, init, saveInbox, loadInbox)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


-- Ports Out
port saveInbox : Model -> Cmd msg
port openTodoDetail : Int -> Cmd msg

-- Ports In
port loadInbox : (List Todo -> msg) -> Sub msg


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
    { id : Int, title : String, context : String }


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
    Sub.batch [ loadInbox LoadInbox ]


-- Update
type Msg
    = SaveInbox Int | LoadInbox (List Todo) | Change String | Enter Int | Delete Int | OpenTodoDetail Int

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        isSpace = String.trim >> String.isEmpty
    in
        case msg of
            LoadInbox todos ->
                ( { model | todoList = todos }
                , Cmd.none
                )
            SaveInbox n ->
                ( model, saveInbox model )
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
                deleteTodo n model
            OpenTodoDetail n ->
                ( model, openTodoDetail n )


onKeyPress : (Int -> Msg) -> Attribute Msg
onKeyPress tagger =
    Html.Events.on "keypress" ( Json.map tagger Html.Events.keyCode )

addTodo : Model -> ( Model, Cmd Msg )
addTodo model =
    let
        m = { model | todoList = model.todoList ++ [(Todo (List.length model.todoList) model.newTodo "")]
            , newTodo = ""
            }
    in
        ( m, saveInbox m )

deleteTodo : Int -> Model -> ( Model, Cmd Msg )
deleteTodo n model =
    let
        t = model.todoList
        m = { model | todoList = List.take n t ++ List.drop (n + 1) t }
    in
        ( m, saveInbox m )


-- View
view : Model -> Html Msg
view model =
    div [ class "uk-grid-small uk-margin-small-top", attribute "uk-grid" "" ]
        [ viewNav
        , viewInbox model
        , viewTodoDetail 0
        ]

-- サイドナビゲーション
viewNav =
    div [ class "uk-margin-small-left"]
        [ div [ class "uk-width-1-5" ]
              [ ul [ class "uk-nav" ]
                   [ li [ class "uk-parent" ]
                        [ text "GTD"
                        , ul [ class "uk-nav-sub" ]
                             [ li [ class "uk-active"] [ text "Inbox" ] ]
                        ]
                   ]
              ]
        ]

viewInbox : Model -> Html Msg
viewInbox model =
    section [ class "uk-section uk-align-center uk-width-expand" ]
            [ div [ class "uk-container" ]
                  [ input [ value model.newTodo, onInput Change, onKeyPress Enter, class "uk-input", placeholder "new task"] []
                  , table [ class "uk-table uk-table-divider uk-table-hover uk-table-small" ]
                          [ tr []
                               [ th [ class "uk-width-auto" ] [ text "Done" ]
                               , th [ class "uk-width-expand" ] [ text "Title" ]
                               , th [ class "uk-width-auto" ] [ text "Context" ]
                               , th [ class "uk-width-auto" ] [ text "Action" ]
                               ]
                          , tbody [] (viewList model.todoList)
                          ]
                  ]
            ]

viewList : List Todo -> List (Html Msg)
viewList =
    let
        todos = List.indexedMap Tuple.pair
    in
        todos >> List.map viewTodo

viewTodo : (Int, Todo) -> Html Msg
viewTodo (n, todo) =
    tr []
       [ td [] [ input [ class "uk-checkbox" ] [] ]
       , td [ onClick ( OpenTodoDetail n ) ] [ text todo.title ]
       , td [] [ span [ class "uk-badge" ] [ text todo.context ] ]
       , td [] [ button [ onClick (Delete n), class "uk-button-small uk-button-danger" ]
                        [ text "Delete" ]
               ]
       ]

viewTodoDetail : Int -> Html Msg
viewTodoDetail n =
    section [ id "todo-detail", class "uk-width-2-5", attribute "hidden" "" ]
            [ text "detail" ]
