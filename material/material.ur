(* Copyright 2015 Google Inc.
Copyright 2016, 2017 Benjamin Barenblat

Licensed under the Apache License, Version 2.0 (the “License”); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License. *)

style stackingContext

fun inNewStackingContext x = <xml><div class={stackingContext}>{x}</div></xml>

(* TODO(bbaren): Support attributes in the arguments. *)
fun page p = <xml>
  <head>
    <link rel="stylesheet" href="/material.css" />

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    (* Disable tap highlight on IE. *)
    <meta name="msapplication-tap-highlight" content="no" />

    (* Color the status bar on mobile devices. *)
    <meta name="theme-color" content="#9c27b0" />

    {p.Head}
  </head>
  <body>{p.Body}</body>
</xml>

structure AppBar = struct
  style bar
  style title

  fun make t = <xml>
    <header class={bar}>
      <h1 class={title}>{[t]}</h1>
    </header>
  </xml>
end

structure Checkbox = struct
  style checkbox
  style checked
  style container
  style ink

  (* Pixel dimensions of the checkbox.  If you update these, you must also
  update the CSS file. *)
  val width = 24
  val height = 24

  fun centeredAtXY x y : css_style =
    let
      val x' = x - width / 2
      val y' = y - width / 2
    in
      oneProperty (oneProperty
                     noStyle
                     (value (property "left") (atom (show x' ^ "px"))))
                  (value (property "top") (atom (show y' ^ "px")))
    end

  fun inkAnimation (s : source (option {X : int, Y : int})) =
    <xml>
      <dyn
        signal={
          v <- signal s;
          return (case v of
                      None => <xml></xml>
                    | Some xy => <xml>
                        <span class={ink} style={centeredAtXY xy.X xy.Y}></span>
                      </xml>)
        }
      />
    </xml>

  val make c onChange =
    s <- source c;
    inkCenter <- source None;
    return (inNewStackingContext <xml>
      {inkAnimation inkCenter}
      <span
        dynClass={
          c <- signal s;
          return (classes checkbox (if c then checked else null))
        }
        onclick={fn click =>
          set inkCenter (Some {X = click.ClientX, Y = click.ClientY});
          c <- get s;
          let
            val c' = not c
          in
            set s c';
            onChange c'
          end
        }
      >
      </span>
      </xml>)
end

structure List = struct
  structure SingleLine = struct
    style element
    style icon
    style list

    fun make es = <xml><ul class={list}>{es}</ul></xml>

    fun item i = <xml>
      <li class={element}>
        <span class={icon}>{i.Icon}</span>
        {i.Content}
      </li>
    </xml>
  end
end
