classdef SessionManager<handle








    methods(Static)
        function[status,model,view]=startNewSession(model,view)

            status=false;
            if(model.isNewSession())

                return;
            end

            response=uiconfirm(view.getAppContainer(),...
            string(message('lidar:lidarCameraCalibrator:newSessionPromptMsg')),...
            string(message('lidar:lidarCameraCalibrator:newSessionPromptTitle')),...
            'Options',...
            [string(message('MATLAB:uistring:popupdialogs:Yes')),...
            string(message('MATLAB:uistring:popupdialogs:No'))]);
            if(strcmpi(response,string(message('MATLAB:uistring:popupdialogs:Yes'))))
                view.setBusy(true);
                model.initializeState();

                view.initializeState();
                setInitialValues(model,view);
                createStartupText(view.DataBrowserAccepted);
                status=true;
                view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbNewSession')));
                setImportEnabledState(view,true);
                view.setBusy(false);
            end
        end

        function[fileSaved,sessionFile]=saveSession(model,view,sessionFile)
            persistent lastUsedDirectory;


            fileSaved=false;

            if(model.isNewSession())

                return;
            end
            if(~exist('sessionFile','var'))
                sessionFile=[];
            end
            if(isempty(sessionFile))
                view.setBusy(true);
                if(isempty(lastUsedDirectory)||~isfolder(lastUsedDirectory))
                    lastUsedDirectory=pwd;
                end
                [filename,pathname]=uiputfile(fullfile(lastUsedDirectory,'lccSession.mat'),'Save as');
                if isequal(filename,0)||isequal(pathname,0)

                    view.setBusy(false);
                    return;
                end
                view.setBusy(false);
                sessionFile=fullfile(pathname,filename);
                lastUsedDirectory=pathname;
            end

            statusFlag=lidar.internal.calibration.tool.SessionManager.saveSessionDataToFile(model,view,sessionFile);
            fileSaved=statusFlag;
            if(fileSaved)
                view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbSessionSaved',sessionFile)));
            end
        end

        function statusFlag=saveSessionDataToFile(model,view,sessionFile)
            try
                calibrationSession=lidar.internal.calibration.tool.Session(model,view);
                save(sessionFile,'calibrationSession');
            catch ME
                statusFlag=false;
                uialert(view.getAppContainer(),ME.message(),...
                string(message('lidar:lidarCameraCalibrator:saveSessionBtnName')));
                return;
            end
            statusFlag=true;
        end

        function[sessionOpened,model,view,sessionFile]=openSession(model,view)
            persistent lastUsedDirectory;
            sessionOpened=false;
            sessionFile=[];
            if(~model.isNewSession())

                response=uiconfirm(view.getAppContainer(),...
                string(message('lidar:lidarCameraCalibrator:openSessionPromptMsg')),...
                string(message('lidar:lidarCameraCalibrator:openSessionPromptTitle')),...
                'Options',...
                [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                string(message('MATLAB:uistring:popupdialogs:No'))]);
                if(~strcmpi(response,string(message('MATLAB:uistring:popupdialogs:Yes'))))
                    return;
                end
            end

            view.setBusy(true);
            if(isempty(lastUsedDirectory)||~isfolder(lastUsedDirectory))
                lastUsedDirectory=pwd;
            end
            [filename,pathname]=uigetfile(fullfile(lastUsedDirectory,'*.mat'),"MultiSelect","off");
            if isequal(filename,0)||isequal(pathname,0)

                view.setBusy(true);
                return;
            end
            setFocus(view);

            sessionFile=fullfile(pathname,filename);
            lastUsedDirectory=pathname;
            [sessionOpened,model,view]=lidar.internal.calibration.tool.SessionManager.loadSession(model,view,sessionFile);
            if(sessionOpened)
                setImportEnabledState(view,false);
                view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbSessionOpened',sessionFile)));
            end
        end

        function[sessionOpened,model,view]=loadSession(model,view,sessionFile)
            sessionOpened=false;
            view.setBusy(true);
            try

                sessionData=lidar.internal.calibration.tool.SessionManager.validateAndLoadSessionFile(sessionFile);

                if(~isempty(sessionData))
                    validSession=loadSession(model,sessionData);
                else
                    validSession=false;
                end
            catch ME
                setFocus(view);
                rethrow(ME);
            end

            if(~validSession)

                view.setBusy(false);
                uialert(view.getAppContainer(),...
                string(message('lidar:lidarCameraCalibrator:invalidSessionFile')),...
                string(message('lidar:lidarCameraCalibrator:appTitle')));
                return;
            end

            view.setBusy(true);


            view.initializeState();


            view.setEnabledState(true);
            view.setBusy(false);

            view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbLoadingData')));
            loadData(model,view.AppContainer);
            view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbDetectingFeatures')));
            view.setBusy(true);

            view.update(model);
            loadSession(view,sessionData.ViewState);

            view.setBusy(false);
            sessionOpened=true;
        end

        function successFlag=addData(model,view,inputData)

            successFlag=false;
            if~exist('inputData','var')
                inputData=[];
            end
            if(isempty(inputData))

                disableCBOptions=false;


                if(~model.isNewSession())

                    disableCBOptions=true;
                end
                appContainer=view.getAppContainer();

                view.setBusy(true);
                if(isImportBtnEnabled(view))
                    dialogTitle=string(message('lidar:lidarCameraCalibrator:importDataDialogTitle'));
                else
                    dialogTitle=string(message('lidar:lidarCameraCalibrator:addDataDialogTitle'));
                end

                dlg=lidar.internal.calibration.tool.dialogs.ImportDataDialog();

                [inputPaths,cbSettings]=dlg.showDiag(...
                dialogTitle,...
                view.getAppContainer(),...
                disableCBOptions,...
                getCheckerboardSettings(model));
                setFocus(view);

                if(isempty(inputPaths))
                    return;
                end

            else
                inputPaths=struct('ImagesPath',inputData.ImagesPath,'PointCloudsPath',inputData.PointCloudsPath);
                cbSettings=struct('Units','millimeters',...
                'Squaresize',inputData.CheckerboardSquaresize,...
                'Padding',inputData.CheckerboardPadding);
            end


            [errorStatus,messageId]=addDataFiles(model,inputPaths.ImagesPath,inputPaths.PointCloudsPath);
            if(errorStatus==1)

                response=uiconfirm(appContainer,...
                string(message(messageId)),...
                string(message('lidar:lidarCameraCalibrator:addDataPromptTitle')),...
                'Options',...
                {char(string(message('MATLAB:uistring:popupdialogs:OK')))},...
                'Icon','warning');
            elseif(errorStatus==2)

                uialert(appContainer,string(message(messageId)),...
                string(message('lidar:lidarCameraCalibrator:addDataPromptTitle')));
                return;
            end

            model.setCheckerboardSettings(cbSettings);

            model.Params.setCameraIntrinsics([]);

            view.setEnabledState(true);
            view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbLoadingData')));
            loadData(model,view.AppContainer);
            view.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbDetectingFeatures')));
            doDetection(model,view.AppContainer);
            view.update(model);
            setFocus(view);
            successFlag=true;
        end

        function sessionData=validateAndLoadSessionFile(sessionFile)
            sessionData=[];
            try
                sessionData=load(sessionFile);
            catch
                return;
            end

            if(~isfield(sessionData,'calibrationSession')||~isa(sessionData.calibrationSession,'lidar.internal.calibration.tool.Session'))
                sessionData=[];
            elseif(~sessionData.calibrationSession.validate())
                sessionData=[];
            else
                sessionData=sessionData.calibrationSession;
            end

        end
    end

end
