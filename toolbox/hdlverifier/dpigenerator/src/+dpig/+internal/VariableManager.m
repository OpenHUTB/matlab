


classdef VariableManager<handle
    properties
moduleName
dpigSubsystemPath
dpigSubsystemName
isCodeGenDone
dpig_build
dpig_config
TestPointContainer
InputAndOutputSamplePeriods
IsTSVerifyPresentInMdlRef
    end
    methods(Access=private)
        function obj=VariableManager
            obj.init;
        end
    end

    methods
        function init(obj)
            obj.dpigSubsystemPath='';
            obj.dpigSubsystemName='';
            obj.isCodeGenDone=false;
            obj.TestPointContainer=containers.Map({''},[0]);
            obj.InputAndOutputSamplePeriods=[];
            obj.IsTSVerifyPresentInMdlRef=false;
        end
    end

    methods(Static)
        function obj=getInstance
            mlock;
            persistent localObj
            if isempty(localObj)
                localObj=dpig.internal.VariableManager;
            end
            obj=localObj;
        end
    end
end