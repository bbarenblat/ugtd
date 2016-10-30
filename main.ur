(* Copyright 2015 Google Inc.
Copyright 2016 Benjamin Barenblat

Licensed under the Apache License, Version 2.0 (the “License”); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License. *)

open Mdl.Classes

table nextAction : {
  Id : int,
  Nam : string,
  Done : bool,
} PRIMARY KEY Id

sequence nextActionId

(* Forces JavaScript to be enabled on the given page, so as to pull in external
scripts specified in the .urp file. *)
val forceJavaScript = <xml><script code={return ()} /></xml>

fun markNextActionStatus id done =
  dml (UPDATE nextAction SET Done = {[done]} WHERE Id = {[id]})

fun renderNextAction action =
  c <- fresh;
  done <- source action.Done;
  return <xml>
    <li class="mdl-list__item">
      <span class="mdl-list__item-primary-content">
        <span class="mdl-list__item-icon">
          <label class="mdl-checkbox" for={c}>
            <ccheckbox id={c} source={done} class="mdl-checkbox__input"
              onchange={
                b <- get done;
                rpc (markNextActionStatus action.Id b)
              } />
          </label>
        </span>
        {[action.Nam]}
      </span>
    </li>
  </xml>

val renderNextActions = queryX1' (SELECT * FROM nextAction) renderNextAction

fun newNextAction name =
  id <- nextval nextActionId;
  dml (INSERT INTO nextAction (Id, Nam, Done) VALUES ({[4 + id]}, {[name]}, FALSE));
  renderNextActions


style hidden
style visible

datatype mode = NextActions | NewNextAction

val main =
  actionItems <- bind renderNextActions source;
  mode <- source NextActions;
  newNextActionDescription <- Mdl.Textbox.make "Description";
  return <xml>
    <head>
      (* TODO(bbaren): Write a meta-description tag. *)
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Next actions</title>

      (* Disable tap highlight on IE. *)
      <meta name="msapplication-tap-highlight" content="no" />

      (* TODO(bbaren): Support homescreen tiles for Chrome on Android, Safari on
      iOS, and Windows 8. *)

      (* Color the status bar on mobile devices. *)
      <meta name="theme-color" content="#9c27b0" />

      (* Material Design Lite *)
      <link rel="stylesheet" href="https://code.getmdl.io/1.1.3/material.purple-orange.min.css" />
      <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
      {forceJavaScript}

      <link rel="stylesheet" href="/ugtd.css" />
    </head>
    <body>
      <div dynClass={
        currentMode <- signal mode;
        return (case currentMode of
                    NewNextAction => visible
                  | _ => hidden)
      }>
        <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
          <header class="mdl-layout__header">
            <button class="mdl-layout__drawer-button" onclick={fn _ => set mode NextActions}>
              <i class="material-icons">close</i>
            </button>
            <div class="mdl-layout__header-row">
              <span class="mdl-layout-title">New action</span>
              <div class="mdl-layout-spacer" />
              <button class="mdl-button mdl-js-button" value="Save" onclick={fn _ =>
                name <- get newNextActionDescription.Source;
                bind (rpc (newNextAction name)) (set actionItems);
                sleep 0;
                set mode NextActions;
                set newNextActionDescription.Source ""
              } />
            </div>
          </header>
          <div class="mdl-layout__content">
            {newNextActionDescription.Xml}
          </div>
        </div>
      </div>
      <div dynClass={
        currentMode <- signal mode;
        return (case currentMode of
                    NextActions => visible
                  | _ => hidden)
      }>
        <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
          <div class="mdl-layout__header mdl-layout__header--waterfall mdl-layout__header--waterfall-hide-top">
            <div class="mdl-layout__header-row">
              <span class="mdl-layout-title">Next actions</span>
            </div>
          </div>
          <div class="mdl-layout__content">
            <ul class="mdl-list">
              <dyn signal={signal actionItems} />
            </ul>
            <button class="mdl-button mdl-js-button mdl-button--fab mdl-button--colored" onclick={fn _ => set mode NewNextAction}>
              <i class="material-icons">add</i>
            </button>
          </div>
        </div>
      </div>
    </body>
  </xml>
