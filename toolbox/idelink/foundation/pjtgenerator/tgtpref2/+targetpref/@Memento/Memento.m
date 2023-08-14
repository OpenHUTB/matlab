classdef Memento<handle





    properties(Access='protected')
        mBlock=[];
        mCurUserData=[];
    end


    methods(Access='protected')
        function ret=isBlockInLibrary(~,configSet)
            ret=isequal(get_param(configSet.getModel(),'BlockDiagramType'),'library');
        end
    end


    methods(Access='public',Static)
        function updateOldStruct(configSet,block,registry)
            if~isempty(block)
                targetInfo=get_param(block,'UserData');
                if isfield(targetInfo,'modelname')
                    thisModelName=get_param(configSet.getModel(),'Name');
                    if configSet.isValidParam('TargetHardwareResources')&&...
                        isequal(thisModelName,targetInfo.modelname)
                        targetInfo=get_param(configSet,'TargetHardwareResources');
                    else
                        try
                            find_system(targetInfo.modelname,'SearchDepth',0);
                            modelName=targetInfo.modelname;
                        catch ex %#ok<NASGU>
                            modelName=get_param(configSet.getModel(),'Name');
                        end
                        targetInfo=get_param(modelName,'TargetHardwareResources');
                    end
                elseif isfield(targetInfo,'chipInfo')

                elseif isa(targetInfo,'Simulink.ConfigSet')

                    targetInfo=get_param(targetInfo,'TargetHardwareResources');
                else
                    assert(false,'Target Preferences block contains invalid data.');
                end
            elseif configSet.isValidParam('TargetHardwareResources')
                targetInfo=get_param(configSet,'TargetHardwareResources');
            else
                targetInfo=[];
            end

            if isempty(targetInfo)
                return;
            end

            if(registry.isProcRegistered(targetInfo.chipInfo.deviceID))
                procInfo=registry.getProcInfo(targetInfo.chipInfo.deviceID);
                targetpref.checkAndOverWriteOldStruct(configSet,targetInfo,procInfo);
            end
        end
    end


    methods(Access='public')
        function h=Memento(varargin)
            if(nargin<2)
                return;
            end
            configSet=varargin{1};
            h.mBlock=varargin{2};
            if~isempty(h.mBlock)
                h.mCurUserData=get_param(h.mBlock,'UserData');
                if isfield(h.mCurUserData,'modelname')
                    thisModelName=get_param(configSet.getModel(),'Name');
                    if configSet.isValidParam('TargetHardwareResources')&&...
                        isequal(thisModelName,h.mCurUserData.modelname)
                        h.mCurUserData=get_param(configSet,'TargetHardwareResources');
                    else
                        try
                            find_system(h.mCurUserData.modelname,'SearchDepth',0);
                            modelName=h.mCurUserData.modelname;
                        catch ex %#ok<NASGU>
                            modelName=get_param(configSet.getModel(),'Name');
                        end
                        h.mCurUserData=get_param(modelName,'TargetHardwareResources');
                    end
                elseif isfield(h.mCurUserData,'chipInfo')

                elseif isa(h.mCurUserData,'Simulink.ConfigSet')
                    h.mCurUserData=get_param(h.mCurUserData,'TargetHardwareResources');
                else
                    assert(false,'Target Preferences block contains invalid data.');
                end
            elseif configSet.isValidParam('TargetHardwareResources')
                h.mCurUserData=get_param(configSet,'TargetHardwareResources');
            else
                assert(false,'Memento contains invalid data.');
            end
        end

        function curData=getCurData(h)
            curData=h.mCurUserData;
        end

        function saveData(h,configSet,newData)
            if~h.isBlockInLibrary(configSet)
                set_param(configSet,'TargetHardwareResources',newData);
                h.mCurUserData=newData;

                if h.isTPBlockValid()
                    set_param(h.mBlock,'UserData',h.mCurUserData);
                end
            end
        end

        function ret=isTPBlockValid(h)
            ret=false;
            try
                ret=~isfield(get_param(h.mBlock,'UserData'),'modelname');
            catch ME %#ok<NASGU>


            end
        end
    end
end
