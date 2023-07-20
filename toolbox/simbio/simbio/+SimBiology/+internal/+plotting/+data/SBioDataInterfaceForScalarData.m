classdef SBioDataInterfaceForScalarData<SimBiology.internal.plotting.data.SBioDataInterface




    methods(Abstract,Access=public)
        paramTable=getIndependentParameterTable(obj);
        paramTable=getDependentParameterTable(obj);
        paramNames=getIndependentParameterNames(obj);
        paramNames=getDependentParameterNames(obj);
    end




    methods(Access=public)
        function flag=supportsPlotMatrixPlot(obj)
            flag=true;
        end
    end

    methods(Access=public)
        function flag=hasSingleInput(obj)
            flag=true;
        end
    end
end