classdef ScenarioCanvasModel<handle


    properties(Dependent,Transient)
CanvasMode
TooltipString
XYCanvasCenter
XYCanvasUnitsPerPixel
TZEnable
TZCanvasCenter
TZCanvasUnitsPerPixel
TableEnable
TableEditEnable
    end

    properties(Access=protected)



        pCanvasMode='Explore';
        pTooltipString=''
        pXYCanvasCenter=[0,0,100]
        pXYCanvasUnitsPerPixel=1
        pTZEnable logical=false
        pTZCanvasCenter=[200,-45,0]
        pTZCanvasUnitsPerPixel=[1,1]
        pTableEnable logical=false
        pTableEditEnable logical=true
    end

    events
CanvasModeChanged
TooltipChanged
XYLimitsChanged
TZLimitsChanged
TZEnableChanged
TableEnableChanged
TableEditEnableChanged
    end

    methods
        function value=get.CanvasMode(this)
            value=this.pCanvasMode;
        end

        function set.CanvasMode(this,value)
            this.pCanvasMode=value;
            notify(this,'CanvasModeChanged');
        end


        function value=get.TooltipString(this)
            value=this.pTooltipString;
        end

        function set.TooltipString(this,value)
            this.pTooltipString=value;
            notify(this,'TooltipChanged');
        end


        function center=get.XYCanvasCenter(this)
            center=this.pXYCanvasCenter;
        end

        function set.XYCanvasCenter(this,center)
            this.pXYCanvasCenter=center;
            notify(this,'XYLimitsChanged');
        end


        function units=get.XYCanvasUnitsPerPixel(this)
            units=this.pXYCanvasUnitsPerPixel;
        end

        function set.XYCanvasUnitsPerPixel(this,unitsPerPixel)
            this.pXYCanvasUnitsPerPixel=unitsPerPixel;
            notify(this,'XYLimitsChanged');
        end

        function enable=get.TZEnable(this)
            enable=this.pTZEnable;
        end

        function set.TZEnable(this,value)
            this.pTZEnable=value;
            notify(this,'TZEnableChanged');
        end

        function center=get.TZCanvasCenter(this)
            center=this.pTZCanvasCenter;
        end

        function set.TZCanvasCenter(this,center)
            this.pTZCanvasCenter=center;
            notify(this,'TZLimitsChanged');
        end


        function units=get.TZCanvasUnitsPerPixel(this)
            units=this.pTZCanvasUnitsPerPixel;
        end

        function set.TZCanvasUnitsPerPixel(this,unitsPerPixel)
            this.pTZCanvasUnitsPerPixel=unitsPerPixel;
            notify(this,'TZLimitsChanged');
        end

        function value=get.TableEnable(this)
            value=this.pTableEnable;
        end

        function set.TableEnable(this,value)
            this.pTableEnable=value;
            notify(this,'TableEnableChanged');
        end

        function value=get.TableEditEnable(this)
            value=this.pTableEditEnable;
        end

        function set.TableEditEnable(this,value)
            this.pTableEditEnable=value;
        end
    end

    methods(Hidden)
        function setXYCenterAndUnitsPerPixel(this,center,unitsPerPixel)
            this.pXYCanvasCenter=center;
            this.pXYCanvasUnitsPerPixel=unitsPerPixel;
            notify(this,'XYLimitsChanged');
        end

        function setTZCenterAndUnitsPerPixel(this,center,unitsPerPixel)
            this.pTZCanvasCenter=center;
            this.pTZCanvasUnitsPerPixel=unitsPerPixel;
            notify(this,'TZLimitsChanged');
        end

        function enableTableEdit(this)
            this.TableEditEnable=true;
        end

        function disableTableEdit(this)
            this.TableEditEnable=false;
        end
    end
end
