classdef(Sealed)MasterInferenceManager<handle




    methods(Access=private)
        function obj=MasterInferenceManager
            obj.MasterInferenceObj=eml.MasterInferenceReport;
            obj.MatlabIdCount=0;
            obj.HoldMaster=false;
            obj.LastMap=[];
        end
    end

    properties(SetAccess=private)



        MasterInferenceReport;
    end


    properties(Dependent=true)
        CurrentMap;
    end

    properties(Access=private)
        MatlabIdCount;
        LastMap;
        HoldMaster;
        MasterInferenceObj;
    end

    methods
        function value=get.CurrentMap(obj)
            value=obj.LastMap;
        end
    end

    methods

        function masterInference=setCurrentInferenceReport(obj,inferenceReport,varargin)
            if~isempty(varargin)
                obj.LastMap=obj.MasterInferenceObj.getInferenceReportMap(inferenceReport,varargin{1});
            else
                obj.LastMap=obj.MasterInferenceObj.getInferenceReportMap(inferenceReport);
            end
            obj.updateMasterInferenceReport();
            masterInference=obj.MasterInferenceReport;
        end

        function releaseMasterInferenceReport(obj)
            obj.HoldMaster=false;
            if(obj.MatlabIdCount==0)
                obj.MasterInferenceObj.clear;
            end
            obj.MasterInferenceReport=[];
        end

        function y=isMapEmpty(obj)
            y=isempty(obj.MasterInferenceReport);
        end
    end

    methods(Access=private)
        function updateMasterInferenceReport(obj)
            obj.MasterInferenceReport.RootFunctionIDs=obj.MasterInferenceObj.RootFunctionIDs;
            obj.MasterInferenceReport.Functions=obj.MasterInferenceObj.Functions;
            obj.MasterInferenceReport.Scripts=obj.MasterInferenceObj.Scripts;
            obj.MasterInferenceReport.MxInfos=obj.MasterInferenceObj.MxInfos;
            obj.MasterInferenceReport.MxArrays=obj.MasterInferenceObj.MxArrays;
            obj.MasterInferenceReport.CurrentMap=obj.CurrentMap;
        end
    end

    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=coder.internal.MasterInferenceManager;
            end
            singleObj=localObj;
        end
    end
end
