classdef TopAOIAnalyzer<plccore.visitor.ContextAnalyzer


    properties(Access=protected)
TopAOIName
TopAOI
    end

    properties(Access=private)
    end

    methods
        function obj=TopAOIAnalyzer(ctx,top_aoi_name)
            obj@plccore.visitor.ContextAnalyzer(ctx);
            obj.Kind='TopAOIAnalyzer';
            obj.TopAOIName=top_aoi_name;
        end

        function ret=topAOIName(obj)
            ret=obj.TopAOIName;
        end

        function ret=topAOI(obj)
            gscope=obj.ctx.configuration.globalScope;
            if~gscope.hasSymbol(obj.TopAOIName)
                plccore.common.plcThrowError(...
                'plccoder:plccore:AOINotFound',...
                obj.TopAOIName);
            end
            ret=obj.ctx.configuration.globalScope.getSymbol(obj.TopAOIName);
            if~isa(ret,'plccore.common.FunctionBlock')
                plccore.common.plcThrowError(...
                'plccoder:plccore:SymbolNotAOI',...
                obj.TopAOIName);
            end
        end

        function doit(obj)
            obj.showDebugMsg;
            obj.analyzeContext;
            obj.analyzeTypeDependence;
        end
    end

    methods(Access=protected)
        function analyzeContext(obj)
            if obj.debug
                fprintf('\n\nAnalyze top aoi: %s\n',obj.topAOIName);
            end

            obj.checkFunctionBlock(obj.topAOI);
        end
    end

    methods(Access=private)
    end
end


