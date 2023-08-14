classdef RulerPan<matlab.graphics.interaction.uiaxes.AxisPan




    properties(SetAccess=private,Hidden)
        rulerenum;
    end

    methods
        function hObj=RulerPan(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.AxisPan(ax,obj,down,move,up);
        end
    end

    methods(Access=protected)
        function dim=getDimension(hObj)
            dim=hObj.rulerenum;
        end

        function ret=validate(hObj,o,e)
            ret=false;
            def=hObj.strategy.isValidMouseEvent(hObj,o,e);

            ruler=matlab.graphics.interaction.uiaxes.RulerPan.hitRulerOnGivenAxes(e,hObj.Axes);
            if def&&~isempty(ruler)
                switch(ruler.Axis)
                case 0
                    rulere='x';
                case 1
                    rulere='y';
                case 2
                    rulere='z';
                end
                if hObj.Dimensions.contains(rulere)
                    hObj.rulerenum=rulere;
                    ret=true;
                end
            end
        end

        function i=getdduxinteractionname(~)
            i='rulerpan';
        end
    end

    methods(Static)
        function ruler=hitRulerOnGivenAxes(e,ax)
            ruler=[];
            r=matlab.graphics.interaction.internal.hitRuler(e);
            axfound=ancestor(r,'axes');
            if~isempty(axfound)&&(axfound==ax)
                ruler=r;
            end
        end
    end
end
