classdef AnalyzingNodeEvent<event.EventData




    properties(GetAccess=public,SetAccess=immutable)
        Node;
        Remaining;
    end

    methods

        function event=AnalyzingNodeEvent(node,remaining)
            event.Node=node;
            event.Remaining=remaining;
        end

    end

end

