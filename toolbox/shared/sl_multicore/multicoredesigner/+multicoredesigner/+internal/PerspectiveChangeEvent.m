classdef PerspectiveChangeEvent<event.EventData




    properties
state
modelH
    end

    methods
        function this=PerspectiveChangeEvent(state,modelH)
            this.state=state;
            this.modelH=modelH;
        end
    end

end


