classdef SBioDataInterface<handle&matlab.mixin.SetGet

    properties(GetAccess=public,SetAccess=protected)
data


        dataSource=SimBiology.internal.plotting.data.DataSource.empty;
    end

    methods(Access=public)
        function dataType=getDataType(obj)

            dataType=class(obj.data);
        end
    end




    methods(Static,Access=public)
        function obj=createSBioDataInterface(dataSource,varargin)

            switch class(dataSource)
            case{'SimData'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForSimData(dataSource,varargin{:});
            case{'groupedData','table'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData(dataSource,varargin{:});
            case{'SimBiology.Scenarios'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForScenarios(dataSource,varargin{:});
            case{'SimBiology.fit.OptimResults','SimBiology.fit.NLMEResults','SimBiology.fit.NLINResults'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForFitResults(dataSource,varargin{:});
            case{'SimBiology.fit.ParameterConfidenceInterval','SimBiology.fit.PredictionConfidenceInterval'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForConfidenceIntervals(dataSource,varargin{:});
            case{'SimBiology.gsa.MPGSA','SimBiology.gsa.Sobol','SimBiology.gsa.ElementaryEffects'}
                obj=SimBiology.internal.plotting.data.SBioDataInterfaceForGSAResults(dataSource,varargin{:});
            otherwise

                obj=dataSource;
            end
        end
    end
end