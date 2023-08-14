classdef(Sealed)MultiSimManager<handle







    properties(SetAccess=private)
        WindowList=MultiSim.internal.MultiSimJobViewer.empty()
        ModelToJobViewerMap=containers.Map;
        FileNameToWindowMap=containers.Map;
    end

    properties
        JobWindow=MultiSim.internal.MultiSimJobViewer.empty()
    end

    methods(Access=private)

        function obj=MultiSimManager
        end
    end

    methods(Static)

        function singleObj=getMultiSimManager
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=MultiSim.internal.MultiSimManager;
            end
            singleObj=localObj;
        end
    end

    methods
        function set.JobWindow(obj,windowObj)
            currentJobWindow=obj.JobWindow;

            if isempty(windowObj)||~isvalid(windowObj)
                obj.JobWindow=MultiSim.internal.MultiSimJobViewer.empty();
            elseif isempty(currentJobWindow)||currentJobWindow~=windowObj
                if isvalid(currentJobWindow)
                    currentJobWindow.ReuseWindowForNextJob=false;
                end
                windowObj.ReuseWindowForNextJob=true;
                obj.JobWindow=windowObj;
            end
        end

        function jobViewer=addJob(obj,simMgr)
            if~isempty(obj.JobWindow)
                if obj.JobWindow.Job.IsRunning
                    error(message('multisim:SimulationManager:CannotReuseWindowJobRunning'));
                end
                obj.JobWindow.updateJob(simMgr);
                jobViewer=obj.JobWindow;
            else
                job=MultiSim.internal.MultiSimJob(simMgr);

                modelName=simMgr.ModelName;
                if bdIsLoaded(modelName)
                    modelHandle=get_param(modelName,"Handle");
                    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();

                    if Simulink.BlockDiagramAssociatedData.isRegistered(modelHandle,dataId)
                        bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
                        if isfield(bdData,"JobViewer")
                            delete(bdData.JobViewer)
                            bdData.IsSimulationJobActive=false;
                        end
                        Simulink.BlockDiagramAssociatedData.set(modelHandle,dataId,bdData);
                    end
                end
                jobViewer=MultiSim.internal.MultiSimJobViewer(job);
            end
        end

        function viewer=getViewerForModel(obj,modelName)
            viewer=[];
            if isKey(obj.ModelToJobViewerMap,modelName)
                viewer=obj.ModelToJobViewerMap(modelName);
            end
        end

        function linkViewerToModel(obj,windowObj,modelName)
            obj.ModelToJobViewerMap(modelName)=windowObj;
        end

        function unlinkViewerForModel(obj,modelName)
            obj.ModelToJobViewerMap.remove(modelName);
        end

        function registerWindow(obj,windowObj)
            obj.WindowList(end+1)=windowObj;
        end

        function deregisterWindow(obj,windowObj)
            if windowObj==obj.JobWindow
                obj.JobWindow=[];
            end
            obj.disassociateWindowFromFile(windowObj);
            obj.WindowList(obj.WindowList==windowObj)=[];
        end

        function associateWindowWithFile(obj,windowObj,fileName)
            obj.disassociateWindowFromFile(windowObj);
            obj.FileNameToWindowMap(fileName)=windowObj;
            windowObj.publishFileName(fileName);
        end

        function disassociateWindowFromFile(obj,windowObj)
            for k=keys(obj.FileNameToWindowMap)
                fileNameKey=k{1};
                if obj.FileNameToWindowMap(fileNameKey)==windowObj
                    remove(obj.FileNameToWindowMap,fileNameKey);
                end
            end
        end

        function windowObj=getWindowForFile(obj,fileName)
            windowObj=[];
            if isKey(obj.FileNameToWindowMap,fileName)
                windowObj=obj.FileNameToWindowMap(fileName);
            end
        end
    end
end