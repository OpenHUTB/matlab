classdef ChartAccessor<matlab.plottools.service.accessor.BaseAccessor



    methods
        function obj=ChartAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAccessor();
        end

        function id=getIdentifier(~)
            id='matlab.graphics.chart.Chart';
        end
    end


    methods(Access='protected')
        function result=supportsTitle(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'title');
        end

        function result=supportsXLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'xlabel');
        end

        function result=supportsYLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'ylabel');
        end

        function result=supportsZLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'zlabel');
        end

        function result=supportsGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'grid');
        end

        function result=supportsLegend(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'legend');
        end

        function result=supportsColorbar(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'colorbar');
        end

        function result=supportsCameraTools(~)
            result=false;
        end
    end


    methods(Access='protected')
        function title=getTitle(obj)
            title=obj.ReferenceObject.getTitleHandle();
        end

        function label=getXLabel(obj)
            label=obj.ReferenceObject.getXlabelHandle();
        end

        function label=getYLabel(obj)
            label=obj.ReferenceObject.getYlabelHandle();
        end

        function label=getZLabel(obj)
            label=obj.ReferenceObject.getZlabelHandle();
        end

        function result=getGrid(obj)
            result=obj.ReferenceObject.GridVisible;
        end

        function legend=getLegend(obj)
            legend=obj.ReferenceObject.LegendVisible;
        end

        function result=getColorbar(obj)
            result=obj.ReferenceObject.ColorbarVisible;
        end
    end


    methods(Access='protected')
        function setTitle(obj,value)
            obj.ReferenceObject.Title=value;
        end

        function setXLabel(obj,value)
            obj.ReferenceObject.XLabel=value;
        end

        function setYLabel(obj,value)
            obj.ReferenceObject.YLabel=value;
        end

        function setZLabel(obj,value)
            obj.ReferenceObject.ZLabel=value;
        end

        function setGrid(obj,value)
            obj.ReferenceObject.GridVisible=value;
        end

        function setLegend(obj,value)
            obj.ReferenceObject.LegendVisible=value;
        end

        function setColorbar(obj,value)
            obj.ReferenceObject.ColorbarVisible=value;
        end
    end
end

