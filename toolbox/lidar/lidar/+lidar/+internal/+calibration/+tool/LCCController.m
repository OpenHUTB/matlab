classdef LCCController<handle











    properties(Access='private')
        Model;
        View;
    end

    properties(Access='private')

        LoadedIntrinsics=[];
        LoadStringForGenScript=[];


        SessionFile=[];

        SessionModifiedFromLastSave=false;
    end

    methods
        function this=LCCController()

            this.Model=lidar.internal.calibration.tool.LCCModel;
            this.View=lidar.internal.calibration.tool.LCCView;

            addDataBrowser(this.View,this.Model);
            setBgColor(this.View);


            addFileSectionListeners(this);
            addIntrinsicsSectionListeners(this);
            addDetectSectionListeners(this);
            addCalibrateSectionListerners(this);
            addDisplayOptionsListeners(this);
            addLayoutListeners(this);
            addExportSectionListeners(this);

            addEditROIListeners(this);

            addSelectCheckerboardListeners(this);


            setInitialValues(this.Model,this.View);


            this.View.AppContainer.CanCloseFcn=@(a)cbAppClose(this);

        end

        function showApp(this)
            this.View.showApp();
            if(~isempty(this.SessionFile))
                this.View.setBusy(true);
                [sessionOpened,this.Model,this.View]=lidar.internal.calibration.tool.SessionManager.loadSession(this.Model,this.View,this.SessionFile);
                if(~sessionOpened)
                    closeApp(this);
                else
                    updateAppTitle(this);
                    setImportEnabledState(this.View,false);
                end
                this.View.setBusy(false);
            end
        end

        function hideApp(this)
            this.View.hideApp();
        end

        function closeApp(this)
            if(isvalid(getAppContainer(this))&&getAppContainer(this).State~="TERMINATED")
                this.View.setBusy(false);
                this.View.closeApp();
            end
        end

    end
    methods

        function validSession=setSession(this,sessionFile)
            this.SessionFile=sessionFile;
            sessionData=lidar.internal.calibration.tool.SessionManager.validateAndLoadSessionFile(sessionFile);
            if(isempty(sessionData))
                validSession=false;
                closeApp(this);
                return;
            end
            validSession=true;
        end
        function addInputData(this,inputData)
            successFlag=lidar.internal.calibration.tool.SessionManager.addData(this.Model,this.View,inputData);
            if(successFlag)
                setImportEnabledState(this.View,false);
                this.setSessionModified(true);
            end
        end

        function[successFlag,messageId]=validateInputData(this,pathToImages,pathToPointclouds)
            [errorStatus,messageId]=addDataFiles(lidar.internal.calibration.tool.LCCModel,pathToImages,pathToPointclouds);
            successFlag=(errorStatus==0);
        end
    end

    methods(Hidden)
        function appContainer=getAppContainer(this)

            appContainer=this.View.getAppContainer();
        end

        function setAppFocus(this)
            this.View.setFocus();
        end
        function model=getModel(this)
            model=this.Model;
        end
        function view=getView(this)
            view=this.View;
        end
    end

    methods(Access='private')
        function updateAppTitle(this)
            if(~isempty(this.SessionFile))
                if(~this.hasSessionModified())
                    appendStringToAppTitle(this.View,dir(this.SessionFile).name);
                else

                    appendStringToAppTitle(this.View,string(dir(this.SessionFile).name)+"*");
                end
            end
        end

        function initializeState(this)
            this.LoadedIntrinsics=[];
            this.LoadStringForGenScript=[];
            this.SessionFile=[];
            this.setSessionModified(false);
        end
        function value=hasSessionModified(this)
            value=this.SessionModifiedFromLastSave||this.Model.SessionModifiedFromLastSave;
        end
        function setSessionModified(this,value)
            this.SessionModifiedFromLastSave=value;
            setSessionModified(this.Model,value);
            updateAppTitle(this);
        end
    end

    methods(Access='private')


        function addFileSectionListeners(this)

            this.View.CalibrationTab.FileSection.NewSessionBtn.ButtonPushedFcn=@(evnt,data)cbNewSession(this);
            this.View.CalibrationTab.FileSection.OpenSessionBtn.ButtonPushedFcn=@(evnt,data)cbOpenSession(this);
            this.View.CalibrationTab.FileSection.SaveSessionSplitBtn.ButtonPushedFcn=@(evnt,data)cbSaveSession(this);
            this.View.CalibrationTab.FileSection.SaveSessionListItem.ItemPushedFcn=@(evnt,data)cbSaveSession(this);
            this.View.CalibrationTab.FileSection.SaveSessionAsListItem.ItemPushedFcn=@(evnt,data)cbSaveSessionAs(this);
            this.View.CalibrationTab.FileSection.ImportDataListItem.ItemPushedFcn=@(evnt,data)cbAddData(this);
            this.View.CalibrationTab.FileSection.AddDataListItem.ItemPushedFcn=@(evnt,data)cbAddData(this);
        end

        function addIntrinsicsSectionListeners(this)

            this.View.CalibrationTab.IntrinsicsSection.ComputeIntrinsicsRBtn.ValueChangedFcn=@(evnt,data)cbComputeIntrinsics(this,evnt);
            this.View.CalibrationTab.IntrinsicsSection.UseFixedIntrinsicsRBtn.ValueChangedFcn=@(evnt,data)cbUseFixedIntrinsics(this,evnt);
            this.View.CalibrationTab.IntrinsicsSection.LoadIntrinsicsBtn.ButtonPushedFcn=@(evnt,data)cbLoadIntrinsics(this);
        end

        function addDetectSectionListeners(this)

            this.View.CalibrationTab.DetectSection.EditROIBtn.ButtonPushedFcn=@(evnt,data)cbEditROIBegin(this);
            this.View.CalibrationTab.DetectSection.SelectCheckerboardBtn.ButtonPushedFcn=@(evnt,data)cbSelectCheckerboardBegin(this);
            this.View.CalibrationTab.DetectSection.RemoveGroundBtn.ValueChangedFcn=@(evnt,data)cbDetectionParamChanged(this,'removeground');
            this.View.CalibrationTab.DetectSection.ClusterThrSpnr.ValueChangedFcn=@(evnt,data)cbDetectionParamChanged(this,'clusterthreshold');
            this.View.CalibrationTab.DetectSection.DimensionToleranceSpnr.ValueChangedFcn=@(evnt,data)cbDetectionParamChanged(this,'dimensiontolerance');
            this.View.CalibrationTab.DetectSection.DetectBtn.ButtonPushedFcn=@(evnt,data)cbDetect(this);
        end

        function addCalibrateSectionListerners(this)

            this.View.CalibrationTab.CalibrateSection.InitialTransformBtn.ButtonPushedFcn=@(evnt,data)cbLoadInitialTransform(this);
            this.View.CalibrationTab.CalibrateSection.CalibrateBtn.ButtonPushedFcn=@(evnt,data)cbCalibrate(this);
        end

        function addExportSectionListeners(this)

            this.View.CalibrationTab.ExportSection.ExportBtn.ButtonPushedFcn=@(src,evnt)cbExportToWS(this);
            this.View.CalibrationTab.ExportSection.ToWorkspace.ItemPushedFcn=@(src,event)cbExportToWS(this);
            this.View.CalibrationTab.ExportSection.ToFile.ItemPushedFcn=@(src,event)cbExportToFile(this);
            this.View.CalibrationTab.ExportSection.GenerateScript.ItemPushedFcn=@(src,event)cbGenerateScript(this);
        end

        function addDisplayOptionsListeners(this)

            this.View.CalibrationTab.DisplayOptionsSection.HideROIBtn.ValueChangedFcn=@(evnt,data)cbSetCuboidVisibility(this,evnt);
            this.View.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.ValueChangedFcn=@(evnt,data)cbSetSnapToROI(this,evnt,false);
        end

        function addLayoutListeners(this)

            this.View.CalibrationTab.LayoutSection.LayoutBtn.ButtonPushedFcn=@(src,event)this.View.cbRestoreDefaultLayout(this.Model);
        end

        function addDataBrowserListeners(this)
            this.View.DataBrowserItemClickCb=@(a)this.Model.cbDataBrowserItemClick(a,this.View);
        end

        function addEditROIListeners(this)

            this.View.EditROITab.ActionSection.SnapToROIBtn.ValueChangedFcn=@(evnt,data)cbSetSnapToROI(this,evnt,true);

            this.View.EditROITab.CloseSection.ApplyBtn.ButtonPushedFcn=@(evnt,data)cbEditROIEnd(this,1);
            this.View.EditROITab.CloseSection.CancelBtn.ButtonPushedFcn=@(evnt,data)cbEditROIEnd(this,0);
        end

        function addSelectCheckerboardListeners(this)

            this.View.SelectCheckerboardTab.SelectSection.SelectCheckerboardBtn.ValueChangedFcn=@(evnt,data)cbBrushMode(this,evnt);
            this.View.SelectCheckerboardTab.SelectSection.ClearSelectionBtn.ButtonPushedFcn=@(evnt,data)cbClearSelection(this);

            this.View.SelectCheckerboardTab.CloseSection.ApplyBtn.ButtonPushedFcn=@(evnt,data)cbSelectCheckerboardEnd(this,1);
            this.View.SelectCheckerboardTab.CloseSection.CancelBtn.ButtonPushedFcn=@(evnt,data)cbSelectCheckerboardEnd(this,0);
        end

    end

    methods(Access='private')


        function flag=cbAppClose(this)
            if(this.View.isBusy())

                flag=false;
                return;
            end
            if(this.Model.isNewSession()||~this.hasSessionModified())


                flag=true;
            else

                response=uiconfirm(this.View.getAppContainer(),...
                string(message('lidar:lidarCameraCalibrator:appClosePromptMsg')),...
                string(message('lidar:lidarCameraCalibrator:appClosePromptTitle')),...
                'Options',...
                [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                string(message('MATLAB:uistring:popupdialogs:No')),...
                string(message('MATLAB:uistring:popupdialogs:Cancel'))]);
                if(strcmpi(response,string(message('MATLAB:uistring:popupdialogs:Yes'))))
                    fileSaved=cbSaveSession(this);
                    flag=fileSaved;
                elseif(strcmpi(response,string(message('MATLAB:uistring:popupdialogs:No'))))
                    flag=true;
                elseif(strcmpi(response,string(message('MATLAB:uistring:popupdialogs:Cancel'))))
                    flag=false;
                end
            end
        end

        function cbSetSnapToROI(this,evnt,inEditROI)
            persistent hideCuboidState;

            if(isempty(hideCuboidState))
                hideCuboidState=~isCuboidVisible(this.View);
            end
            if(evnt.Selected)



                hideCuboidState=~isCuboidVisible(this.View);
                setCuboidVisibility(this.View,false);
                if(~inEditROI)
                    this.View.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value=hideCuboidState;
                    this.View.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled=false;
                end
            else


                setCuboidVisibility(this.View,~hideCuboidState);
                if(~inEditROI)
                    this.View.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value=hideCuboidState;
                    this.View.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled=true;
                end
            end

            setSnapToROIFlag(this.View,evnt.Selected);
            restorePointcloudView(this.View);

            this.setSessionModified(true);
        end

        function cbSetCuboidVisibility(this,evnt)
            setCuboidVisibility(this.View,~evnt.Selected);
            this.setSessionModified(true);
        end

        function cbEditROIBegin(this)
            this.View.setBusy(true);
            this.View.editROIBegin();
            this.View.setBusy(false);
        end

        function cbEditROIEnd(this,applyFlag)
            editROIEnd(this.View,applyFlag,this.Model);
            if(applyFlag)

                cbDetectionParamChanged(this,'roi');
            end
        end

        function cbSelectCheckerboardBegin(this)
            this.View.setBusy(true);
            this.View.InitialSelectedPoints=this.Model.getSelectedPoints();
            this.View.selectCheckerboardBegin();
            this.View.setBusy(false);
        end

        function cbSelectCheckerboardEnd(this,applyFlag)
            this.View.selectCheckerboardEnd(this.Model,applyFlag);
            if applyFlag
                cbDetectionParamChanged(this,'select');
            end
        end

        function cbClearSelection(this)
            index=this.View.CurrentItemIndex;
            ptCloud=this.Model.getCurrentPointcloud(index);
            this.View.clearBrushedData(this.Model,ptCloud);
        end

        function cbBrushMode(this,evnt)
            if evnt.Selected
                this.View.setBrushMode('on');
            else
                this.View.setBrushMode('off');
            end
        end

        function cbComputeIntrinsics(this,evnt)
            if(~evnt.Selected)

                return;
            end
            this.View.CalibrationTab.IntrinsicsSection.LoadIntrinsicsBtn.Enabled=false;
            cbDetectionParamChanged(this,'intrinsics');
        end

        function cbUseFixedIntrinsics(this,evnt)
            if(~evnt.Selected)

                this.View.CalibrationTab.IntrinsicsSection.LoadIntrinsicsBtn.Enabled=false;
                return;
            end



            if(isempty(this.LoadedIntrinsics))
                cbLoadIntrinsics(this);
            else
                cbDetectionParamChanged(this,'intrinsics');
            end
            if(~isempty(this.LoadedIntrinsics))
                this.View.CalibrationTab.IntrinsicsSection.LoadIntrinsicsBtn.Enabled=true;
            end
        end

        function cbLoadIntrinsics(this)


            persistent dialogOpened;
            if(isempty(dialogOpened))
                dialogOpened=true;
            else
                return;
            end

            c=onCleanup(@()setAppFocus(this));

            this.View.setBusy(true);
            try
                loadDiag=lidar.internal.calibration.tool.dialogs.LoadDataFromFileAndWSDiag(...
                string(message('lidar:lidarCameraCalibrator:loadCameraIntrinsicsDiagTitle')),["cameraParameters","cameraIntrinsics"]);

                [isWorkspace,value,wsOrFilename]=showDiag(loadDiag,this.View.getAppContainer());
            catch ME
                setAppFocus(this);
                dialogOpened=[];
                rethrow(ME);
            end

            setAppFocus(this);
            flag=true;
            if(~isempty(isWorkspace))
                if(isa(value,'cameraParameters'))
                    value=value.Intrinsics;
                    wsOrFilename=sprintf("%s.Intrinsics",wsOrFilename);
                    if(isempty(value))
                        flag=false;
                        response=uiconfirm(this.getAppContainer(),...
                        string(message('lidar:lidarCameraCalibrator:emptyIntrinsicsInCameraParameters')),...
                        string(message('lidar:lidarCameraCalibrator:loadCameraIntrinsicsDiagTitle')),...
                        'Options',...
                        {char(string(message('MATLAB:uistring:popupdialogs:OK')))},...
                        'Icon','error');
                    end
                end
                if(flag)
                    this.LoadedIntrinsics=value;
                    this.LoadStringForGenScript=wsOrFilename;
                    cbDetectionParamChanged(this,'intrinsics');
                end
            else

                if(isempty(this.LoadedIntrinsics))

                    this.View.CalibrationTab.IntrinsicsSection.ComputeIntrinsicsRBtn.Value=true;
                    this.View.CalibrationTab.IntrinsicsSection.UseFixedIntrinsicsRBtn.Value=false;
                    this.View.CalibrationTab.IntrinsicsSection.LoadIntrinsicsBtn.Enabled=false;
                end

            end
            dialogOpened=[];
        end

        function cbLoadInitialTransform(this)

            persistent dialogOpened;
            if(isempty(dialogOpened))
                dialogOpened=true;
            else
                return;
            end

            c=onCleanup(@()setAppFocus(this));
            this.View.setBusy(true);
            try
                loadDiag=lidar.internal.calibration.tool.dialogs.LoadDataFromFileAndWSDiag(...
                string(message('lidar:lidarCameraCalibrator:loadInitialTransformDiagTitle')),["rigid3d"]);

                [isWorkspace,value]=showDiag(loadDiag,this.View.getAppContainer());
            catch ME
                setAppFocus(this);
                dialogOpened=[];
                rethrow(ME);
            end

            setAppFocus(this);

            if(~isempty(isWorkspace))
                this.Model.Params.setInitialTransform(value);
            end
            dialogOpened=[];
        end

        function cbDetect(this)

            doImageFeatureDetections=hasIntrinsicsChanged(this);
            if(this.View.CalibrationTab.IntrinsicsSection.UseFixedIntrinsicsRBtn.Value)
                this.Model.Params.setCameraIntrinsics(this.LoadedIntrinsics,this.LoadStringForGenScript);
            end



            this.Model.Params.setIntrinsicsFlag(this.View.CalibrationTab.IntrinsicsSection.ComputeIntrinsicsRBtn.Value);

            this.Model.Params.setClusterThreshold(this.View.CalibrationTab.DetectSection.ClusterThrSpnr.Value);
            this.Model.Params.setDimensionTolerance(this.View.CalibrationTab.DetectSection.DimensionToleranceSpnr.Value);
            this.Model.Params.setRemoveGround(this.View.CalibrationTab.DetectSection.RemoveGroundBtn.Value);
            this.Model.Params.setROIFromCuboidPosition(this.View.CuboidPosition);


            this.View.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbDetectingFeatures')));


            detectFeatures(this.Model,doImageFeatureDetections,true,this.getAppContainer());

            this.View.update(this.Model);
            this.View.CalibrationTab.DetectSection.DetectBtn.Enabled=false;

            this.setSessionModified(true);
        end

        function cbCalibrate(this)
            c=onCleanup(@()setAppFocus(this));
            this.View.setBusy(true);
            try
                this.View.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbCalibratingData')));
                doCalibration(this.Model);

                this.View.update(this.Model);
                this.View.cbRestoreDefaultLayout(this.Model);
                this.View.DataBrowserRejected.toggleCollapse();
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end
            this.setSessionModified(true);
            this.View.setBusy(false);
        end

        function cbAddData(this)
            c=onCleanup(@()setAppFocus(this));
            firstCall=isNewSession(this.Model);
            try
                successFlag=lidar.internal.calibration.tool.SessionManager.addData(this.Model,this.View);
                if(successFlag)
                    this.LoadedIntrinsics=[];

                    if(firstCall)
                        setImportEnabledState(this.View,false);
                    end
                    this.setSessionModified(true);
                end
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end

        end


        function cbNewSession(this)
            c=onCleanup(@()setAppFocus(this));
            try
                successFlag=lidar.internal.calibration.tool.SessionManager.startNewSession(this.Model,this.View);
                if(successFlag)
                    initializeState(this)
                end
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end
        end

        function cbOpenSession(this)
            c=onCleanup(@()setAppFocus(this));
            try
                [successFlag,this.Model,this.View,sessionFile]=lidar.internal.calibration.tool.SessionManager.openSession(this.Model,this.View);
                if(successFlag)
                    this.LoadedIntrinsics=this.Model.Params.getCameraIntrinsics(false);
                    this.LoadStringForGenScript=this.Model.Params.getCameraIntrinsicsLoadStringForGenScript();
                    this.SessionFile=sessionFile;
                    updateAppTitle(this);
                    this.setSessionModified(false);
                end
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end
        end

        function fileSaved=cbSaveSession(this)
            c=onCleanup(@()setAppFocus(this));
            try
                [fileSaved,savedFilename]=lidar.internal.calibration.tool.SessionManager.saveSession(this.Model,this.View,this.SessionFile);
                if(fileSaved)
                    this.SessionFile=savedFilename;
                    this.setSessionModified(false);
                end
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end
        end

        function fileSaved=cbSaveSessionAs(this)
            c=onCleanup(@()setAppFocus(this));
            try
                [fileSaved,savedFilename]=lidar.internal.calibration.tool.SessionManager.saveSession(this.Model,this.View);
                if(fileSaved)
                    this.SessionFile=savedFilename;
                    this.setSessionModified(false);
                end
            catch ME
                this.View.setBusy(false);
                rethrow(ME);
            end
        end

        function validSession=validateSessionFile(this,sessionFile)
            sessionData=lidar.internal.calibration.tool.SessionManager.validateAndLoadSessionFile(this.Model,sessionFile);
            validSession=~isempty(sessionData);
        end

    end

    methods(Access='private')

        function setDetectBtnEnabled(this,value)
            if(value)

                this.setSessionModified(true);
            end
            this.View.CalibrationTab.DetectSection.DetectBtn.Enabled=value;
        end

        function flag=hasDetectionParamChanged(this,param)
            switch lower(param)
            case 'removeground'
                flag=~isequal(this.View.CalibrationTab.DetectSection.RemoveGroundBtn.Value,...
                this.Model.Params.getRemoveGround());
            case 'clusterthreshold'
                flag=~isequal(this.View.CalibrationTab.DetectSection.ClusterThrSpnr.Value,...
                this.Model.Params.getClusterThreshold());
            case 'dimensiontolerance'
                flag=~isequal(this.View.CalibrationTab.DetectSection.DimensionToleranceSpnr.Value,...
                this.Model.Params.getDimensionTolerance());
            case 'roi'
                flag=~isequal(this.View.CuboidPosition,...
                this.Model.Params.getCuboidPositionFromROI());
            case 'intrinsics'
                flag=hasIntrinsicsChanged(this);
            case 'select'
                if isempty(this.View.InitialSelectedPoints)




                    initPts=cell(1,this.Model.NumDatapairs);
                else
                    initPts=this.View.InitialSelectedPoints;
                end
                flag=~isequal(this.Model.getSelectedPoints(),initPts);
            otherwise
                flag=false;
            end
        end

        function flag=hasIntrinsicsChanged(this)
            if(this.View.CalibrationTab.IntrinsicsSection.ComputeIntrinsicsRBtn.Value)
                flag=~isequal(this.Model.Params.getCameraIntrinsics(true),...
                this.Model.Params.getCameraIntrinsics());
            else
                flag=~isequal(this.LoadedIntrinsics,...
                this.Model.Params.getCameraIntrinsics());
            end
        end

        function cbDetectionParamChanged(this,param)
            flag=hasDetectionParamChanged(this,'removeground')||...
            hasDetectionParamChanged(this,'clusterthreshold')||...
            hasDetectionParamChanged(this,'dimensiontolerance')||...
            hasDetectionParamChanged(this,'roi')||...
            hasDetectionParamChanged(this,'intrinsics')||...
            hasDetectionParamChanged(this,'select');
            setDetectBtnEnabled(this,flag);
        end
    end

    methods


        function cbExportToWS(this)
            loadDlg=lidar.internal.calibration.tool.dialogs.ExportParametersToWSDlg(...
            string(message('lidar:lidarCameraCalibrator:exportToWSDlgTitle')),...
            this.Model.LidarToCameraTransform,...
            this.Model.CalibrationErrors);
            this.View.setBusy(true);
            showDlg(loadDlg,this.View.getAppContainer());
            this.View.setBusy(false);
            this.View.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbExportToWorkspace')));
        end

        function cbExportToFile(this)
            tform=this.Model.LidarToCameraTransform;
            errors=this.Model.CalibrationErrors;
            this.View.setBusy(true);
            [filename,pathname]=uiputfile('*.mat',...
            string(message('lidar:lidarCameraCalibrator:exportToFileDialogTitle')),...
            'results.mat');
            try
                if~(isequal(filename,0)||isequal(pathname,0))
                    save(fullfile(pathname,filename),'tform','errors');
                    this.View.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbExportToFile',fullfile(pathname,filename))));
                end
            catch ME
                uialert(this.View.getAppContainer(),ME.message,...
                string(message('lidar:lidarCameraCalibrator:exportFailedDlgTitle')),'Icon','error');
            end
            setAppFocus(this);
            this.View.setBusy(false);
        end

        function cbGenerateScript(this)
            this.Model.generateScript();
            this.View.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbGenerateScript')));
        end
    end
end
