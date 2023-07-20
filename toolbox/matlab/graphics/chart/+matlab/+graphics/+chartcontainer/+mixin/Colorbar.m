classdef Colorbar<matlab.graphics.chartcontainer.mixin.Mixin






    properties(Dependent)
        ColorbarVisible matlab.lang.OnOffSwitchState='on';%#ok<MDEPIN>
    end


    properties(Hidden,Transient,NonCopyable,Access=private)
        ColorbarObj matlab.graphics.illustration.ColorBar
    end


    methods(Hidden,Access=protected)
        function cb=createColorbar(obj)
            ax=obj.getAxes;
            cb=matlab.graphics.illustration.ColorBar('Axes',ax(1));


            cb.UIContextMenu=[];
        end
    end

    methods(Access=protected)
        function c=getColorbar(obj)
            obj.initColorbar();
            c=obj.ColorbarObj;
        end
    end


    methods
        function obj=Colorbar()
            obj.ColorbarVisible=matlab.lang.OnOffSwitchState.on;
        end

        function set.ColorbarVisible(obj,val)
            if val=="on"
                obj.initColorbar();
                obj.ColorbarObj.Visible=val;

            else
                if~isempty(obj.ColorbarObj)&&isvalid(obj.ColorbarObj)
                    obj.ColorbarObj.Visible=val;
                    delete(obj.ColorbarObj);
                    obj.ColorbarObj=matlab.graphics.illustration.ColorBar.empty;
                end
            end
        end

        function v=get.ColorbarVisible(obj)
            if~isempty(obj.ColorbarObj)&&isvalid(obj.ColorbarObj)
                v=obj.ColorbarObj.Visible;
            else
                v=matlab.lang.OnOffSwitchState.off;
            end
        end
    end

    methods(Access=private)
        function initColorbar(obj)
            if isempty(obj.ColorbarObj)||~isvalid(obj.ColorbarObj)
                obj.ColorbarObj=obj.createColorbar();
            end
        end
    end
end


