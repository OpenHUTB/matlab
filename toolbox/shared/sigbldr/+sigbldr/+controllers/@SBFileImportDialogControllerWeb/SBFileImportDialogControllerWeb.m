

classdef SBFileImportDialogControllerWeb<handle
    properties(GetAccess=public,SetAccess=private)
        parentUserData;
        importDialog;
        dataManager=[];
        importManager=[];
    end

    properties(Access=private)
        eventListeners=[];
        dataPlacement='';
        changesApplied=false;
        cancelBlocked=false;
    end

    methods(Access=public)
        function obj=SBFileImportDialogControllerWeb(userData)
            if~(isstruct(userData)&&isfield(userData,'dialog')&&isfield(userData,'sbobj')&&isfield(userData,'simulink'))

                DAStudio.error('Sigbldr:import:InvalidUserData',userData);
            end
            obj.parentUserData=userData;
            obj.importDialog=sigbldr_import.ui.importdialog.ImportDialog();


            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'cancelButtonClicked',@obj.handleCancelButtonCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'helpButtonClicked',@obj.handleHelpButtonCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'browseButtonClicked',@obj.handleBrowseButtonCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'textFieldEdited',@obj.handleTextFieldCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'comboBoxSelected',@obj.handleComboBoxCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'confirmButtonClicked',@obj.handleConfirmButtonCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'applyButtonClicked',@obj.handleApplyButtonCallback)];
            obj.eventListeners=[obj.eventListeners;addlistener(obj.importDialog,'okButtonClicked',@obj.handleOkButtonCallback)];
        end

        function show(obj)
            obj.importDialog.show();
            if isvalid(obj.parentUserData.dialog)
                obj.parentUserData.dialog.Visible='off';
            end
        end

        function dispose(obj)
            if isvalid(obj.parentUserData.dialog)
                obj.parentUserData.dialog.Visible='on';
            end
            obj.importDialog.dispose();
            delete(obj.eventListeners);
            obj.importDialog=[];
            obj.importManager=[];
            obj.dataManager=[];
            delete(obj);
        end
    end

    methods(Access=private)
        function handleCancelButtonCallback(obj,~,~)

            if~obj.cancelBlocked
                obj.dispose();
            end
        end

        function handleHelpButtonCallback(obj,~,~)

            helpview('simulink','SIGNALBUILDER_DATAIMPORT');


            obj.importDialog.bringToFront();
        end

        function handleBrowseButtonCallback(obj,~,~)

            filter_options={...
            '*.xls;*.xlsx',DAStudio.message('Sigbldr:import:ExcelFiles');...
            '*.csv',DAStudio.message('Sigbldr:import:TextFiles');...
            '*.mat',DAStudio.message('Sigbldr:import:MATFiles');...
            '*.*',DAStudio.message('Sigbldr:import:AllFiles');...
            };
            title=DAStudio.message('Sigbldr:import:importFileBrowseTitle');
            [filename,filepath]=uigetfile(filter_options,title);


            obj.importDialog.bringToFront();

            if isequal(filename,0)
                return;
            end


            if~obj.checkSupportedFileType(filename)
                return;
            end

            fileToImport=fullfile(filepath,filename);


            obj.importDialog.setTextField(fileToImport);


            obj.disableDialog();
            obj.processDataFile(fileToImport);
            obj.enableDialog();
        end

        function enableDialog(obj)
            obj.cancelBlocked=false;
            obj.importDialog.disableGlassPane();
        end

        function disableDialog(obj)
            obj.cancelBlocked=true;
            obj.importDialog.enableGlassPane();
        end

        function handleTextFieldCallback(obj,src,~)
            givenFile=src.textFieldValue;


            if~isfile(givenFile)
                message=DAStudio.message('Sigbldr:sigbldr:invalidFile',givenFile);
                title=DAStudio.message('Sigbldr:import:importFileError');
                errordlg(message,title,'modal');
                return;
            end


            if~obj.checkSupportedFileType(givenFile)
                return;
            end


            obj.processDataFile(givenFile);
        end

        function handleComboBoxCallback(obj,src,~)

            obj.dataPlacement=src.dataPlacement;
        end

        function handleConfirmButtonCallback(obj,src,~)








            if isempty(src.selectedData)
                return;
            end


            groups=fieldnames(src.selectedData);
            groupList=zeros(1,length(groups));
            signalList=cell(1,length(groups));
            for i=1:length(groups)
                groupList(i)=str2double(erase(groups{i},'g'));
                signal_count=length(src.selectedData.(groups{i}));
                signals=zeros(1,signal_count);
                for j=1:signal_count
                    signals(j)=str2double(src.selectedData.(groups{i}){j});
                end
                signalList{i}=signals;
            end


            try
                copySBObj=obj.parentUserData.sbobj.copyObj;
                obj.importManager=sigbldr.ui.importdialog.ImportManager(copySBObj);
                obj.importManager.startImport(obj.dataManager.getImportData.getSBObj,obj.dataPlacement,groupList,signalList);
            catch e
                title=DAStudio.message('Sigbldr:import:importFileError');
                message=DAStudio.message('Sigbldr:import:ValidationError',e.message);
                errordlg(message,title,'modal');
                obj.importManager=[];
                obj.importDialog.disableOkandApplyButtons();
                return;
            end


            obj.importDialog.enableOkandApplyButtons();
        end

        function handleApplyButtonCallback(obj,~,~)
            if isempty(obj.dataPlacement)
                return;
            end

            newSBObj=obj.importManager.getSBObj;
            switch obj.dataPlacement
            case{'ASA','ASD'}
                obj.parentUserData=signal_append(obj.parentUserData,newSBObj);
            case 'AGR'
                obj.parentUserData=group_append(obj.parentUserData,newSBObj);
            case 'RED'

                question=DAStudio.message('Sigbldr:import:ReplaceExistingDataDialog');
                title=DAStudio.message('Sigbldr:import:RESTitle');
                yesStr=DAStudio.message('Sigbldr:import:RESYes');
                noStr=DAStudio.message('Sigbldr:import:RESNo');
                cancelStr=DAStudio.message('Sigbldr:sigbldr:Cancel');
                answer=questdlg(question,title,yesStr,noStr,cancelStr,cancelStr);
                success=true;
                if strcmp(answer,yesStr)

                    success=obj.saveModel();
                elseif strcmp(answer,cancelStr)

                    return;
                end


                if success
                    obj.parentUserData=replace_existing_data(obj.parentUserData,newSBObj);
                end
            otherwise

                DAStudio.error('Sigbldr:import:UnexpectedDataPlacementValue',obj.dataPlacement);
            end


            obj.importDialog.disableApplyButton();
            obj.changesApplied=true;
        end

        function handleOkButtonCallback(obj,src,data)

            if~obj.changesApplied
                obj.handleApplyButtonCallback(src,data);
            end
            obj.dispose();
        end

        function supported=checkSupportedFileType(~,filename)


            [~,~,ext]=fileparts(filename);
            supported=ismember(ext,sigbldr.extdata.SBImportData.SUPPORTED_EXTENSIONS);
            if~supported
                message=DAStudio.message('Sigbldr:import:noSupportForCustomFile',filename);
                title=DAStudio.message('Sigbldr:import:importFileError');
                errordlg(message,title,'modal');
            end
        end

        function processDataFile(obj,filename)

            try
                obj.dataManager=sigbldr.extdata.DataManager(filename);
            catch e
                if strfind(e.identifier,'ReadingCancel')

                    title=DAStudio.message('Sigbldr:import:PBReadingCancelTitle');
                    message=DAStudio.message('Sigbldr:import:PBReadingCancel');
                    helpdlg(message,title);
                else
                    title=DAStudio.message('Sigbldr:import:importFileError');
                    message=DAStudio.message('Sigbldr:import:ParseError',e.message);
                    errordlg(message,title,'modal');
                end

                obj.importManager=[];
                obj.dataManager=[];
                return;
            end


            obj.importDialog.setDataTree(obj.dataManager.getImportData.getSBObj.Groups);
        end

        function res=saveModel(obj)

            res=false;
            modelName=get_param(obj.parentUserData.simulink.modelH,'Name');
            dialogLoop=true;

            while dialogLoop
                [file,~]=Simulink.SaveDialog(modelName,false);
                if file
                    [pathName,fileName,ext]=fileparts(file);
                    if strcmp(fileName,modelName)

                        title=DAStudio.message('Sigbldr:sigbldr:SaveMDLFileDialogTitle');
                        message=DAStudio.message('Sigbldr:import:RESDuplicateName',fileName);
                        errordlg(message,title,'modal');
                    else
                        currDir=pwd;
                        cd(pathName);
                        try

                            new_system(fileName);
                            load_system(fileName);
                            currentName=get_param(obj.parentUserData.simulink.subsysH,'Name');
                            subsysName=getfullname(obj.parentUserData.simulink.subsysH);
                            add_block(subsysName,[fileName,'/',currentName]);
                            save_system(fileName,[fileName,ext]);
                            close_system(fileName);
                            res=true;
                            dialogLoop=false;
                        catch e
                            title=DAStudio.message('Sigbldr:sigbldr:SaveMDLFileDialogTitle');
                            message=e.message;
                            errordlg(message,title,'modal');
                        end
                        cd(currDir);
                    end
                else
                    dialogLoop=false;
                end
            end
        end
    end
end
