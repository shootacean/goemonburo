module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- Main
main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


-- Model
type alias Model =
    { newTodo : String
    , todoList : List String
    }

init : Model
init =
    { newTodo = ""
    , todoList = []
    }


-- Update
type Msg
    = Change String | Add | Delete Int

update : Msg -> Model -> Model
update msg model =
    let
        isSpace = String.trim >> String.isEmpty
    in
        case msg of
            Change s ->
                { model | newTodo = s }
            Add ->
                if isSpace model.newTodo then
                    model
                else
                    { model | todoList = model.newTodo :: model.todoList
                    , newTodo = "" }
            Delete n ->
                let
                    t = model.todoList
                in
                    { model | todoList = List.take n t ++ List.drop (n + 1) t}


-- View
view : Model -> Html Msg
view model =
    section [ class "uk-section uk-align-center"]
            [ div [ class "uk-container uk-width-expand"]
                  [ input [ value model.newTodo, onInput Change, onSubmit Add, class "uk-input", placeholder "new task"] []
                  , button [ onClick Add, class "uk-button uk-button-primary" ] [text "add todo"]
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

viewList : List String -> List (Html Msg)
viewList =
    let
        tasks = List.indexedMap Tuple.pair
        column ( n, s ) = tr []
                             [ td [] [ input [ class "uk-checkbox" ] []
                                     ]
                             , td [] [ text s ]
                             , td [] [ button [ onClick (Delete n), class "uk-button-small uk-button-danger" ]
                                              [ text "Delete" ]
                                     ]
                             ]
    in
        tasks >> List.map column