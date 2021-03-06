// Copyright 2015 Google Inc.
// Copyright 2016 Benjamin Barenblat
// Copyright 2016 Chelsea Voss
//
// Licensed under the Apache License, Version 2.0 (the “License”); you may not
// use this file except in compliance with the License.  You may obtain a copy
// of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations under
// the License.

"use strict";

(function() {
  var mdlFfi = {
    showSnackbar:
        function(id, text) {
          document.querySelector('#' + id)
              .MaterialSnackbar.showSnackbar({message: text});
        },
  };

  try {
    UrWeb.MdlFfi = mdlFfi;
  } catch (ReferenceError) {
    console.log("asdf");
    window.UrWeb = {MdlFfi: mdlFfi};
    console.log("hjkl");
  }
})();  // UrWeb.MdlFfi
