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

structure Classes = MdlClasses
open Classes

structure Textbox = struct
  fun make (placeholder : string) : transaction xbody =
    id <- fresh;
    return <xml>
      <div class="mdl-textfield mdl-js-textfield">
        <ctextbox class="mdl-textfield__input" id={id} />
        <label class="mdl-textfield__label" for={id}>{[placeholder]}</label>
      </div>
    </xml>
end

structure Toast = struct
  val make : transaction {Placeholder: xbody,
                          Show: string -> transaction unit} =
    id <- fresh;
    return {
      Placeholder = <xml>
        <div id={id} class="mdl-js-snackbar mdl-snackbar">
          <div class="mdl-snackbar__text" />
          <button class="mdl-snackbar__action"></button>
        </div>
      </xml>,
      Show = MdlFfi.showSnackbar (show id)
    }
end
