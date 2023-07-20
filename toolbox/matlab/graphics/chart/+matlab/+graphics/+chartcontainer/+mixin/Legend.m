classdef(Abstract)Legend<matlab.graphics.chartcontainer.mixin.Mixin




















    properties(Dependent)
        LegendVisible matlab.lang.OnOffSwitchState='on';%#ok<MDEPIN>
    end

    properties(Hidden,Transient,NonCopyable,Access=private,UsedInUpdate=false)
        LegendObj matlab.graphics.illustration.Legend
    end


    methods(Hidden,Access=protected)
        function leg=createLegend(obj)

            ax=obj.getAxes;
            leg=matlab.graphics.illustration.Legend('Axes',ax(1));


            leg.UIContextMenu=[];
        end
    end

    methods(Access=protected)
        function leg=getLegend(obj)
            obj.initLegend();
            leg=obj.LegendObj;
        end
    end


    methods
        function obj=Legend()
            obj.LegendVisible=matlab.lang.OnOffSwitchState.on;
        end

        function set.LegendVisible(obj,val)
            if val=="on"
                obj.initLegend;
                obj.LegendObj.Visible=val;
            else
                if~isempty(obj.LegendObj)&&isvalid(obj.LegendObj)
                    obj.LegendObj.Visible=val;
                end
            end
        end

        function v=get.LegendVisible(obj)
            if~isempty(obj.LegendObj)&&isvalid(obj.LegendObj)
                v=obj.LegendObj.Visible;
            else
                v=matlab.lang.OnOffSwitchState.off;
            end
        end
    end

    methods(Access=private)
        function initLegend(obj)
            if isempty(obj.LegendObj)||~isvalid(obj.LegendObj)
                obj.LegendObj=obj.createLegend;
            end
        end
    end
end
