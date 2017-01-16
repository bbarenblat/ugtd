(* Copyright 2016, 2017 Benjamin Barenblat

Licensed under the Apache License, Version 2.0 (the “License”); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License. *)

table nextAction : {
  Id : int,
  Nam : string,
  Done : bool,
} PRIMARY KEY Id

sequence nextActionId

fun markNextActionStatus id done =
  dml (UPDATE nextAction SET Done = {[done]} WHERE Id = {[id]})

fun renderNextAction action : transaction xbody =
  c <- Material.Checkbox.make action.Done
    (fn b => rpc (markNextActionStatus action.Id b));
  return (Material.List.SingleLine.item {
    Icon = c,
    Content = cdata action.Nam
  })

val renderNextActions =
  queryX1' (SELECT * FROM nextAction WHERE nextAction.Done = FALSE) renderNextAction

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
  floatingActionButton <- Material.FloatingActionButton.make "add";
  return (Material.page {
    Head = <xml>
      (* TODO(bbaren): Write a meta-description tag. *)
      <title>Next actions</title>

      (* TODO(bbaren): Support homescreen tiles for Chrome on Android, Safari on
      iOS, and Windows 8. *)

      <link rel="stylesheet" href="/ugtd.css" />
    </xml>,
    Body = <xml>
      <div dynClass={
        currentMode <- signal mode;
        return (case currentMode of
                    NewNextAction => visible
                  | _ => hidden)
      }>
        {Material.AppBar.make "New action"}
      </div>
      <div dynClass={
        currentMode <- signal mode;
        return (case currentMode of
                    NextActions => visible
                  | _ => hidden)
      }>
        {Material.AppBar.make "Next actions"}
        {Material.List.SingleLine.make <xml>
          <dyn signal={signal actionItems} />
        </xml>}
        {floatingActionButton}
      </div>
    </xml>
  })
