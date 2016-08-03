# Copyright 2016 Benjamin Barenblat
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

ugtd: ugtd.urp mdl main.urs main.ur
	urweb -ccompiler build_scripts/clang -output $@ ugtd

.PHONY: mdl
mdl: mdl/lib.urp mdl/mdl.ur
mdl/lib.urp mdl/mdl.ur: mdl/classes
	build_scripts/generate_mdl <$<

.PHONY: clean
clean:
	$(RM) mdl/lib.urp mdl/mdl.ur
	$(RM) ugtd
