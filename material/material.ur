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
    val make : int (* radius *)
               -> transaction { Placeholder : xbody,
                                Trigger : { X : int, Y : int }
                                          -> transaction unit }
end = struct
    style ink

    fun inkStyle radius xy =
        let
            fun p a b = value (property a) (atom (show b ^ "px"))
            val diameter = 2 * radius
        in
            oneProperty
                (oneProperty
                     (oneProperty
                          (oneProperty noStyle
                                       (p "width" diameter))
                          (p "height" diameter))
                     (p "left" (xy.X - radius)))
                (p "top" (xy.Y - radius))
        end

    fun inkAnimation radius s = <xml>
      <dyn signal={v <- signal s;
                   return (case v of
                               None => <xml></xml>
                             | Some xy =>
                               <xml>
                                 <span class={ink}
                                       style={inkStyle radius xy}>
                                 </span>
                               </xml>)} />
    </xml>

    fun make radius =
        center <- source None;
        return {Placeholder = inkAnimation radius center,
                Trigger = fn xy => set center (Some xy)}
end

(* TODO(bbaren): Support attributes in the arguments. *)
fun page p = <xml>
  <head>
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/icon?family=Material+Icons" />
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
        ink <- Ripple.make (width / 2);
        return (inNewStackingContext <xml>
          <div class={container}>
            {ink.Placeholder}
            <span dynClass={c <- signal s;
                            return (classes checkbox
                                            (if c then checked else null))}
                  onclick={fn click =>
                              ink.Trigger {X = click.ClientX,
                                           Y = click.ClientY};
                              c <- get s;
                              let
                                  val c' = not c
                              in
                                  set s c';
                                  onChange c'
                              end}></span>
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

    fun make s clickHandler =
        ink <- Ripple.make (width / 2);
        return <xml>
          <div class={container}>
            <button class={element}
                    onclick={fn click =>
                                ink.Trigger {X = click.ClientX,
                                             Y = click.ClientY};
                                clickHandler click}>
              {icon s}
            </button>
            {ink.Placeholder}
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
