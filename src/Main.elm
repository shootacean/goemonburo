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
    section [ class "uk-section"]
            [ div []
                  [ input [ placeholder "input your title", value model.newTodo, onInput Change, onSubmit Add ] []
                  , button [ onClick Add ] [text "add todo"]
                  , div [] (viewList model.todoList)
                  ]
            ]

viewList : List String -> List (Html Msg)
viewList =
    let
        todos = List.indexedMap Tuple.pair
        column ( n, s ) = div []
                              [ text s
                              , button [ onClick (Delete n) ] [ text "x" ]
                              ]
    in
        todos >> List.map column