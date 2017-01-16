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

style materialIcon
style stackingContext

fun icon s = <xml><i class={materialIcon}>{[s]}</i></xml>

fun inNewStackingContext x = <xml><div class={stackingContext}>{x}</div></xml>

structure Ripple : sig
  val inkAnimation : int -> int -> source (option {X : int, Y : int}) -> xbody
end = struct
  style ink

  fun inkStyle width height xy =
    let
      fun p a b = value (property a) (atom (show b ^ "px"))
    in
      oneProperty
        (oneProperty
           (oneProperty
              (oneProperty noStyle
                           (p "width" width))
              (p "height" height))
           (p "left" (xy.X - width / 2)))
        (p "top" (xy.Y - height / 2))
    end

  fun inkAnimation width height s =
    <xml>
      <dyn
        signal={
          v <- signal s;
          return (case v of
                      None => <xml></xml>
                    | Some xy => <xml>
                        <span class={ink} style={inkStyle width height xy}>
                        </span>
                      </xml>)
        }
      />
    </xml>
end

(* TODO(bbaren): Support attributes in the arguments. *)
fun page p = <xml>
  <head>
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
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

  (* Pixel dimensions of the checkbox.  If you update these, you must also
  update the CSS file. *)
  val width = 24
  val height = 24

  val make c onChange =
    s <- source c;
    inkCenter <- source None;
    return (inNewStackingContext <xml>
      <div class={container}>
        {Ripple.inkAnimation width height inkCenter}
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
      </div>
      </xml>)
end

structure FloatingActionButton = struct
  style container
  style element

  (* Pixel dimensions of the button.  If you update these, you must also
  update the CSS file. *)
  val width = 56
  val height = 56

  fun make s =
    inkCenter <- source None;
    return <xml>
      <div class={container}>
        <button
          class={element}
          onclick={fn click =>
             set inkCenter (Some {X = click.ClientX, Y = click.ClientY})
          }
        >
          {icon s}
        </button>
        {Ripple.inkAnimation width height inkCenter}
      </div>
    </xml>
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
