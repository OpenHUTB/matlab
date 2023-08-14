classdef PerspectiveChangeEvent<event.EventData




    properties
state
modelH
CanvasModelH
studio
    end

    methods
        function this=PerspectiveChangeEvent(state,modelH,canvasModelH,cStudio)
            this.state=state;
            this.modelH=modelH;
            this.CanvasModelH=canvasModelH;
            if nargin<4
                cStudio=[];
            end
            this.studio=cStudio;
        end
    end

end

