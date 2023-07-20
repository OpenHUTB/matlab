






classdef LVModel<handle

    properties(Access=private)

        DataModel lidar.internal.lidarViewer.lidarViewerIO.LVIOModel


        EditModeManager lidar.internal.lidarViewer.edits.EditModeManager



        EditsManager lidar.internal.lidarViewer.edits.EditsManager
    end

    events


PointCloudChanging



PointCloudChanged


ExternalTrigger
    end

    methods



        function this=LVModel()
            this.setUp();
        end


        function clear(this)


            this.EditModeManager.deleteEditStack();
            this.DataModel.clear();
            this.EditsManager.clear();

        end


        function wireUpEditsManager(this)

            this.EditsManager=lidar.internal.lidarViewer.edits.EditsManager();


            addlistener(this.EditsManager,'PointCloudChanging',@(~,evt)notify(this,'PointCloudChanging',evt));
            addlistener(this.EditsManager,'PointCloudChanged',@(~,evt)notify(this,'PointCloudChanged',evt));
            addlistener(this.EditsManager,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
        end


        function wireUpEditModeManager(this)

            this.EditModeManager=lidar.internal.lidarViewer.edits.EditModeManager();
            addlistener(this.EditModeManager,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
        end


        function wireUpDataModel(this)

            this.DataModel=lidar.internal.lidarViewer.lidarViewerIO.LVIOModel();
        end
    end




    methods

        function applyEditsOnAllFrames(this)





            edits=this.EditModeManager.getEditsOnCurrentFrame(true);



            numFrames=this.EditModeManager.NumFrames;
            currentFrameIdx=this.EditModeManager.CurrentIndex;
            iter=[1:currentFrameIdx-1,currentFrameIdx+1:numFrames];

            for frameId=iter




                updatedEdit=edits{1};
                [~,pointCloudIn]=this.readFrameFromEditStack(frameId,true);
                updatedEdit.PointCloudIn=pointCloudIn;
                this.EditModeManager.EditStack{frameId}{end+1}=updatedEdit;
            end

            this.readFrameFromEditStack(currentFrameIdx,true);
        end


        function TF=isAnyDataEdited(this,dataName)



            editStatus=this.DataModel.getEditStatus();

            if isempty(dataName)


                TF=any(editStatus);
            else

                dataId=this.DataModel.getDataIdFromName(dataName);
                TF=editStatus(dataId);
            end
        end


        function reset(this)



            this.clear();


            this.setUp();
        end


        function scalars=getScalars(this,dataName)


            dataIdx=this.DataModel.getDataIdFromName(dataName);
            scalars=this.DataModel.getListOfScalars(dataIdx);
        end


        function generateScript(this)



            editStack=this.EditModeManager.getEditsOnCurrentFrame(false);



            generateScript(this.EditsManager,editStack);
        end
    end




    methods

        function dataModelObj=getDataModel(this)

            dataModelObj=this.DataModel;
        end


        function dataAdded=getDataAdded(this)

            numData=this.DataModel.NumData();
            dataAdded=this.DataModel.getDataInfo(numData);
        end


        function info=getDataInfo(this,dataId)




            dataInfo=this.DataModel.getDataInfo(dataId);
            dataName=dataInfo.DataName{1};
            if isempty(dataInfo.TimeVectors{1})
                numFrames=1;
            else
                numFrames=numel(dataInfo.TimeVectors{1});
            end
            info=struct;
            info.Name=dataName;
            info.NumFrames=numFrames;
            info.SourceName=dataInfo.SourceName{1};
        end


        function timeVector=getTimeVectors(this,dataId)


            timeVector=this.DataModel.getTimeVectors(dataId);
        end


        function TF=getHasTimingInfoFlag(this,dataId)


            TF=this.DataModel.getHasTimingInfoFlag(dataId);
        end


        function index=getDataIndex(this,dataName,ts)



            index=this.DataModel.getDataIndexFromTimestamp(dataName,ts);
        end


        function count=getDataCount(this)

            count=this.DataModel.NumData;
        end


        function signalId=getDataIdFromName(this,name)

            signalId=this.DataModel.getDataIdFromName(name);
        end


        function limits=getGlobalLimits(this,dataId)

            dataInfo=this.DataModel.getDataInfo(dataId);
            limits=dataInfo.GlobalLimits{1};
        end


        function editStatus=getSignalEditStatus(this)

            editStatus=this.DataModel.getEditStatus;
        end


        function markDataAsEdited(this,dataIdx)

            this.DataModel.markDataAsEdited(dataIdx);
        end
    end




    methods

        function createEditStack(this,dataName,numFrames,index)


            ptCldArray=this.DataModel.getPtCldData(dataName);
            this.EditModeManager.createEditStack(...
            dataName,numFrames,index,ptCldArray);
        end


        function createMeasurementStack(this,dataName,numFrames,index)


            ptCldArray=this.DataModel.getPtCldData(dataName);
            this.EditModeManager.createEditStack(...
            dataName,numFrames,index,ptCldArray);
        end


        function deleteEditStack(this,toSave,dataIdx)


            if toSave
                this.saveDataInEditMode(dataIdx);
            end
            this.EditModeManager.deleteEditStack();
        end


        function pointCloudOut=getCurrentPointCloudInEditMode(this,varargin)







            isTemporal=false;
            if nargin>1
                isTemporal=varargin{1};
            end

            if~isTemporal
                pointCloudOut=this.EditModeManager.CurrentPointCloud;
            else

                pointCloudOut=[];
                numFrames=this.EditModeManager.NumFrames;
                for i=1:numFrames
                    [~,ptCloud]=this.readFrameFromEditStack(i,true);
                    pointCloudOut=[pointCloudOut;ptCloud];
                end
            end
        end


        function data=revertAllEditsOnCurrentFrame(this)

            data=this.EditModeManager.revertAllEditsOnCurrentFrame();
        end


        function updateCurrentPointCloudInEditMode(this,pointCloudIn)


            this.EditModeManager.updateCurrentPointCloudInEditMode(pointCloudIn);
        end


        function[isValid,pointCloudOut]=readFrameFromEditStack(this,currentTime,toUpdate)


            dataName=this.EditModeManager.DataName;
            if isa(currentTime,'double')
                currentIndex=currentTime;
            else
                currentIndex=this.getDataIndex(dataName,currentTime);
            end

            if toUpdate

                this.EditModeManager.updateCurrentIndex(currentIndex);
            end

            editStack=this.EditModeManager.getEditsOnCurrentFrame(false);

            if isempty(editStack)
                pointCloudOut=this.EditModeManager.CurrentPointCloud;
                isValid=true;
                return;
            end




            isValid=true;
            lastOp=numel(editStack);
            editOp=editStack{lastOp};
            [isValidL,pointCloudOut,~]=this.applyEdits(...
            editOp.Name,editOp.AlgoParams,editOp.PointCloudIn);
            isValid=isValid&&isValidL;
            if~isValid


                this.EditModeManager.revertAllEditsOnCurrentFrame();
                pointCloudOut=this.getCurrentPointCloudInEditMode();
            end


            if numel(pointCloudOut)>1
                pointCloudOut=pointCloudOut(currentIndex);
            end
            this.updateCurrentPointCloudInEditMode(pointCloudOut);
        end


        function saveEditParams(this,editData)


            this.EditModeManager.saveEditParams(editData);
        end


        function editStack=getEditsOnCurrentFrame(this)

            editStack=this.EditModeManager.getEditsOnCurrentFrame(false);
        end
    end




    methods

        function setUpEditOperation(this,editName,editPanel,isTemporal,dispObjAxes,figToDisplayDialogs)




            ptCldIn=this.getCurrentPointCloudInEditMode(isTemporal);


            numFrames=this.EditModeManager.NumFrames;
            this.EditsManager.setUpEditOperation(editName,ptCldIn,isTemporal,dispObjAxes,figToDisplayDialogs,numFrames);



            setUpAlgorithmConfigurePanel(this,editName,editPanel,isTemporal)
        end


        function setUpAlgorithmConfigurePanel(this,editName,editPanel,isTemporal)


            this.EditsManager.setUpAlgorithmConfigurePanel(editName,editPanel,isTemporal)
        end


        function[isValid,pointCloudOut,selectedFrames]=applyEdits(this,editName,algoParams,pointCloudIn,varargin)



            try
                [pointCloudOut,selectedFrames]=this.EditsManager.applyEdits...
                (editName,pointCloudIn,algoParams);
                numFrames=this.EditModeManager.NumFrames;
                if~all(ismember(selectedFrames,1:numFrames))||(numel(pointCloudIn)>1&&isempty(selectedFrames))
                    if numFrames>1
                        error(getString(message('lidar:lidarViewer:ErrorForSelectedFrames',numFrames)));
                    else
                        error(getString(message('lidar:lidarViewer:ErrorForOneSelectedFrames')));
                    end
                end

                if~(numel(pointCloudOut)==numel(pointCloudIn))
                    error(getString(message('lidar:lidarViewer:OutputPointCloudArrayError')))
                end

                if~isa(pointCloudOut,'pointCloud')
                    error(getString(message('lidar:lidarViewer:InvalidEditPointCloudObjError')));
                end
                isValid=true;
            catch ME
                isValid=false;
                pointCloudOut=pointCloud(ones(0,3));
                selectedFrames=[];

                warningMessage=ME.message;
                warningTitle=getString(message('lidar:lidarViewer:Error'));
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);
            end











        end

        function pointCloudIn=getPointCloudArrayInEditMode(this)
            pointCloudIn=[];
            numFrames=this.EditModeManager.NumFrames;
            for i=1:numFrames
                [~,ptCloud]=this.readFrameFromEditStack(i,true);
                pointCloudIn=[pointCloudIn;ptCloud];
            end
        end


        function[toUpdate,spatialEditNames,temporalEditNames,customSpatialFuncNames,...
            customTemporalFuncNames]=updateEdits(this,evt,fig)

            toUpdate=false;
            switch evt.Operation
            case 1

                toUpdate=this.EditsManager.updateEditMap();
            case 2

                if evt.IsClassBased

                    toUpdate=this.EditsManager.importCustomEdit(fig,evt.IsTemporal);
                else

                    numFrames=this.EditModeManager.NumFrames;
                    toUpdate=this.EditsManager.importCustomFunction(evt.IsTemporal,numFrames);
                end
            case 3

                this.EditsManager.openTemplateEditor(evt.IsTemporal,evt.IsClassBased);
            otherwise

            end

            if toUpdate

                [spatialEditNames,temporalEditNames]=this.EditsManager.getEditNames();
                [customSpatialFuncNames,customTemporalFuncNames]=this.EditsManager.getCustomFuncNames();
            else
                spatialEditNames={};
                temporalEditNames={};
                customSpatialFuncNames={};
                customTemporalFuncNames={};
            end

        end
    end




    methods

        function ptCldOut=doUndo(this,currentTime)



            [originalPtCld,editStack]=this.EditModeManager.doUndo();




            lastOp=numel(editStack);
            if~lastOp
                ptCldOut=originalPtCld.PointCloud;
            else
                editOp=editStack{lastOp};
                [ptCldOut,~]=this.EditsManager.applyEdits...
                (editOp.Name,editOp.PointCloudIn,editOp.AlgoParams);

                dataName=this.EditModeManager.DataName;
                currentIndex=this.getDataIndex(dataName,currentTime);


                if numel(ptCldOut)>1
                    ptCldOut=ptCldOut(currentIndex);
                end
            end


            updateCurrentPointCloudInEditMode(this,ptCldOut);
        end


        function[editOp,ptCldOut]=doRedo(this,currentTime)



            editOp=this.EditModeManager.doRedo();



            [ptCldOut,~]=this.EditsManager.applyEdits...
            (editOp.Name,editOp.PointCloudIn,editOp.AlgoParams);

            dataName=this.EditModeManager.DataName;
            currentIndex=this.getDataIndex(dataName,currentTime);


            if numel(ptCldOut)>1
                ptCldOut=ptCldOut(currentIndex);
            end


            updateCurrentPointCloudInEditMode(this,ptCldOut);
        end


        function TF=isEditUndoStackEmpty(this)


            frameIdx=this.EditModeManager.CurrentIndex;
            TF=isempty(this.EditModeManager.EditStack{frameIdx});
        end


        function TF=isEditRedoStackEmpty(this)


            frameIdx=this.EditModeManager.CurrentIndex;
            TF=isempty(this.EditModeManager.EditRedoStack{frameIdx});
        end


        function TF=isAnyFrameEdited(this)



            TF=any(~cellfun(@isempty,...
            this.EditModeManager.EditStack));
        end
    end




    methods(Access=private)
        function setUp(this)

            wireUpDataModel(this);
            wireUpEditsManager(this);
            wireUpEditModeManager(this);
        end


        function saveDataInEditMode(this,dataIdx)


            [ptCldArray,editStack]=this.EditModeManager.getDataFromESM();
            try
                for i=1:numel(ptCldArray)


                    tempPtCld=ptCldArray{i}.PointCloud;
                    lastOp=numel(editStack{i});
                    if lastOp
                        editOp=editStack{i}{lastOp};
                        [tempPtCld,~]=this.EditsManager.applyEdits...
                        (editOp.Name,editOp.PointCloudIn,editOp.AlgoParams);
                    end
                    if numel(tempPtCld)>1
                        tempPtCld=tempPtCld(i);
                    end
                    ptCldArray{i}.PointCloud=tempPtCld;
                end
            catch







                warningMessage=getString(message('lidar:lidarViewer:ErrorOnAcceptingEdits'));
                warningTitle='Error';
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);

                return;
            end
            this.DataModel.updateData(dataIdx,ptCldArray);
        end
    end
end


