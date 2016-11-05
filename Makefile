# Copyright 2016 Benjamin Barenblat
# Copyright 2016 Chelsea Voss
#
# Licensed under the Apache License, Version 2.0 (the “License”); you may not
# use this file except in compliance with the License.  You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

MDL_GENERATED = mdl/mdlClasses.urp mdl/mdlClasses.ur

.PHONY: all
all: ugtd ugtd.db

ugtd initialize.sql: \
  ugtd.urp \
    ugtd.css \
    history/lib.urp \
      history/historyFfi.urs history/historyFfi.js \
      history/history.urs history/history.ur \
    mdl/lib.urp \
      mdl/mdlFfi.urs mdl/mdlFfi.js \
      mdl/mdlClasses.urp \
        mdl/mdlClasses.ur \
      mdl/mdl.ur \
    main.urs main.ur
	urweb -ccompiler build_scripts/clang -output ugtd ugtd

ugtd.db: initialize.sql prepopulate.sql
	printf "" >$@
	sqlite3 $@ <initialize.sql
	sqlite3 $@ <prepopulate.sql

mdl/mdlClasses.urp mdl/mdlClasses.ur: mdl/classes
	build_scripts/generate_mdl <$<

.PHONY: clean
clean:
	$(RM) $(MDL_GENERATED)
	$(RM) ugtd.db
	$(RM) ugtd initialize.sql
