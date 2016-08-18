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

open Mdl

table nextAction : {
  Nam : string,
  Done : bool,
}

(* Forces JavaScript to be enabled on the given page, so as to pull in external
scripts specified in the .urp file. *)
val forceJavaScript = <xml><script code={return ()} /></xml>

fun renderNextAction action =
  c <- fresh;
  done <- source action.Done;
  return <xml>
    <li class="mdl-list__item">
      <span class="mdl-list__item-primary-content">
        <span class="mdl-list__item-icon">
          <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for={c}>
            <ccheckbox id={c} source={done} class="mdl-checkbox__input" />
          </label>
        </span>
        {[action.Nam]}
      </span>
    </li>
  </xml>


val main =
  actionItems <- queryX1' (SELECT * FROM nextAction) renderNextAction;
  setHeader (blessResponseHeader "X-UA-Compatible") "IE=edge";
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
    </head>
    <body>
      <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
        <div class="mdl-layout__header mdl-layout__header--waterfall mdl-layout__header--waterfall-hide-top">
          <div class="mdl-layout__header-row">
            <span class="mdl-layout-title">Next actions</span>
          </div>
        </div>
        <div class="mdl-layout__content">
          <ul class="mdl-list">
            {actionItems}
          </ul>
        </div>
      </div>
    </body>
  </xml>
