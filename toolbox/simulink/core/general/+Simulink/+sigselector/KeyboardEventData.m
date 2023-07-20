classdef KeyboardEventData<event.EventData








    properties
Widget
Modifier
Character
    end

    methods
        function this=KeyboardEventData(ed)

            this.Widget=char(ed.Widget);
            this.Modifier=char(ed.Modifier);
            this.Character=char(ed.Character);
        end
    end

end


