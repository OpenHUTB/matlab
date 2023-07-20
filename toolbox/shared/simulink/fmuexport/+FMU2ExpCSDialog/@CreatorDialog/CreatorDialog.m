classdef CreatorDialog<handle




    properties(Hidden)
        ModelName='';
        ParentModel='';
        paramListSource=[];
        ivListSource=[];
        packageList=[];

    end

    properties(Hidden,Transient)
        hModelCloseListener;
    end

    properties(Constant)
        DefaultOptions=struct(...
        'ExportedContent',0,...
        'CreateModelAfterGeneratingFMU',true,...
        'SaveSourceCodeToFMU',false,...
        'AddIcon',0,...
        'AddIconPath',pwd,...
        'AddNativeSimulinkBehavior',false,...
        'PackagePath',pwd,...
        'ProjectName','',...
        'Generate32BitDLL',false,...
        'Package',[]);
    end

    methods(Static)
        function mapObj=getOptionsMap()
            mlock;
            persistent localMapObj;
            if isempty(localMapObj)||~isvalid(localMapObj)
                localMapObj=containers.Map;
            end
            mapObj=localMapObj;
        end
    end

    methods
        function opt=getOptions(obj)
            assert(~isempty(obj.ModelName));
            optMap=FMU2ExpCSDialog.CreatorDialog.getOptionsMap;
            if~optMap.isKey(obj.ModelName)

                opt=FMU2ExpCSDialog.CreatorDialog.DefaultOptions;
                opt.PackagePath=pwd;
                opt.ProjectName=[obj.ModelName,'_fmu'];


                if isfile(getCachedMATFilePath(obj.ModelName))


                    matFilePath=getCachedMATFilePath(obj.ModelName);
                    matObj=matfile(matFilePath);
                    optStruct=whos('-file',matFilePath);
                    optName=arrayfun(@(x)x.name,optStruct,'un',0);
                    for Count=1:length(optName)
                        opt.(optName{Count})=matObj.(optName{Count});
                    end
                end
            else
                opt=optMap(obj.ModelName);
            end
        end

        function setOptions(obj,opt)
            assert(~isempty(obj.ModelName));
            optMap=FMU2ExpCSDialog.CreatorDialog.getOptionsMap;
            if isempty(opt)

                optMap.remove(obj.ModelName);
            else

                optMap(obj.ModelName)=opt;
            end
        end





        function obj=CreatorDialog(input)
            narginchk(1,1);


            if(ishandle(input))
                object=get_param(input,'Object');
                name=object.getFullName;
                clear('object');
            elseif(ischar(input))
                name=input;
            else
                errmsg=DAStudio.message('FMUExport:FMU:FMU2ExpCSUnverifiedInputToCreatorDialog');
                assert(false,errmsg);
            end


            if(strcmp(get_param(input,'Type'),'block_diagram'))
                assert(bdIsLoaded(input),'Input to CreatorDialog was not a model');
                obj.ParentModel=name;
                obj.ModelName=name;
            elseif(strcmp(get_param(input,'Type'),'block'))
                obj.ParentModel=bdroot(name);
                obj.ModelName=get_param(name,'ModelName');
            else
                errmsg=DAStudio.message('FMUExport:FMU:FMU2ExpCSUnrecognizedInputToCreatorDialog');
                assert(false,errmsg);
            end


            if~bdIsLoaded(obj.ModelName)
                load_system(obj.ModelName);
                closeModelOnCleanup=onCleanup(@()close_system(obj.ModelName,0));
            end


            optMap=FMU2ExpCSDialog.CreatorDialog.getOptionsMap;



            modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
            modelSettingBackup([obj.ModelName,'.CallSite'])='UI';
            callsiteOC=onCleanup(@()modelSettingBackup.remove([obj.ModelName,'.CallSite']));


            loadParameterList(obj)


            loadInternalVarList(obj);


            setupPackageList(obj)



            callsiteOC.delete;
        end


        out=getDialogSchema(obj);





        function browsePackagePath(~,dlg)
            SaveDirectory=uigetdir('',DAStudio.message('FMUExport:FMU:FMU2ExpCSBrowseDialogTitle'));
            if SaveDirectory~=0
                dlg.setWidgetValue('fmu2expcs_PackagePath',SaveDirectory);
            end
        end



        function help(~)
            try
                helpview(fullfile(docroot,'slcompiler','helptargets.map'),'export-simulink-models-to-fmu');
            catch ME
                errordlg(ME.message);
            end
        end



        function cancel(obj,dlg)
            unhiliteFcn(obj);
            delete(dlg);
        end



        function generate(obj,dlg)



            opt=obj.getOptions;
            opt=obj.overrideOptionsFromDialog(opt,dlg);

            saveOptionsToMATFile(obj.ModelName,opt);

            obj.setOptions(opt);

            if slfeature('FMUExportParameterConfiguration')>0

                options.ExportedParameters={};
                options.ExportedParameterNames={};
                for idx=1:length(obj.paramListSource.valueStructure)
                    if obj.paramListSource.valueStructure(idx).IsRoot&&strcmp(obj.paramListSource.valueStructure(idx).exported,'on')
                        options.ExportedParameters=[options.ExportedParameters,obj.paramListSource.valueStructure(idx).Name];
                        options.ExportedParameterNames=[options.ExportedParameterNames,obj.paramListSource.valueStructure(idx).exportedName];
                    end
                end
                if isempty(options.ExportedParameters)&&~isempty(obj.paramListSource.valueStructure)

                    options.ExportedParameters={''};
                    options.ExportedParameterNames={''};
                end
            end

            if slfeature('FMUExportInternalVarConfiguration')>0

                options.ExportedInternals={};
                options.ExportedInternalNames={};
                for idx=1:length(obj.ivListSource.valueStructure)
                    if obj.ivListSource.valueStructure(idx).IsRoot&&strcmp(obj.ivListSource.valueStructure(idx).exported,'on')
                        options.ExportedInternals=[options.ExportedInternals,obj.ivListSource.valueStructure(idx).Name];
                        options.ExportedInternalNames=[options.ExportedInternalNames,obj.ivListSource.valueStructure(idx).exportedName];
                    end
                end
                if isempty(options.ExportedInternals)&&~isempty(obj.ivListSource.valueStructure)

                    options.ExportedInternals={''};
                    options.ExportedInternalNames={''};
                end
            end

            SaveDirectory=dlg.getWidgetValue('fmu2expcs_PackagePath');
            options.SaveDirectory=SaveDirectory;
            options.ProjectName=dlg.getWidgetValue('fmu2expcs_ProjectName');

            switch(opt.ExportedContent)
            case 0
                options.ExportedContent='project';
            otherwise
                options.ExportedContent='off';
            end


            if(opt.CreateModelAfterGeneratingFMU)
                options.CreateModelAfterGeneratingFMU='on';
            else
                options.CreateModelAfterGeneratingFMU='off';
            end


            if(opt.SaveSourceCodeToFMU)
                options.SaveSourceCodeToFMU='on';
            else
                options.SaveSourceCodeToFMU='off';
            end


            if(opt.Generate32BitDLL)
                options.Generate32BitDLL='on';
            else
                options.Generate32BitDLL='off';
            end


            if(opt.AddIcon==0)
                options.AddIcon='snapshot';
            elseif(opt.AddIcon==1)
                options.AddIcon=dlg.getWidgetValue('fmu2expcs_AddIconPath');
            else
                options.AddIcon='off';
            end

            if(opt.AddNativeSimulinkBehavior)
                options.AddNativeSimulinkBehavior='on';
            else
                options.AddNativeSimulinkBehavior='off';
            end

            if~isempty(opt.Package)

                options.Package=opt.Package;
            else
                options.Package=[];
            end

            unhiliteFcn(obj);
            delete(dlg);
            stage=sldiagviewer.createStage(getString(message('FMUExport:FMU:FMU2ExpCSCodeGenStage')),'ModelName',obj.ModelName);
            try
                exportToFMU2CS_fcn(obj.ModelName,'UI',options);
            catch ex
                sldiagviewer.reportError(ex);
            end
            stage.delete;
        end


        function installModelCloseListener(obj,dlg)


            blkDiagram=get_param(obj.ParentModel,'Object');
            obj.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(src,evt)FMU2ExpCSDialog.CreatorDialog.removeDlg(dlg));



            opt=obj.getOptions;
            opt.mdlCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,ev)closeModelHandler(obj));
            opt.modelRenameListener=Simulink.listener(blkDiagram,'PostSaveEvent',@(hSrc,ev)renameModelHandler(obj,ev));
            setOptions(obj,opt);
        end

        function opt=overrideOptionsFromDialog(obj,opt,dlg)
            opt.SaveSourceCodeToFMU=dlg.getWidgetValue('fmu2expcs_SaveSourceCodeToFMU');
            opt.CreateModelAfterGeneratingFMU=dlg.getWidgetValue('fmu2expcs_CreateModelAfterGeneratingFMU');
            opt.ExportedContent=dlg.getWidgetValue('fmu2expcs_ExportedContent');
            opt.AddIcon=dlg.getWidgetValue('fmu2expcs_AddIconDropdown');
            opt.AddIconPath=dlg.getWidgetValue('fmu2expcs_AddIconPath');
            opt.PackagePath=dlg.getWidgetValue('fmu2expcs_PackagePath');
            opt.ProjectName=dlg.getWidgetValue('fmu2expcs_ProjectName');
            opt.Generate32BitDLL=dlg.getWidgetValue('fmu2expcs_Generate32BitDLL');
            opt.Package=...
            internal.packageConfig.spreadSheetSource.getResourcesToPackage(obj.packageList);
            if slfeature('FMUNativeSimulinkBehavior')>0
                opt.AddNativeSimulinkBehavior=dlg.getWidgetValue('fmu2expcs_AddNativeSimulinkBehavior');
            end
            if slfeature('FMUExportParameterConfiguration')>0
                opt.paramListSource=obj.paramListSource;
            end
            if slfeature('FMUExportInternalVarConfiguration')>0
                opt.ivListSource=obj.ivListSource;
            end
        end

        function closeModelHandler(obj)


            opt=obj.getOptions;
            saveOptionsToMATFile(obj.ModelName,opt);

            obj.setOptions([]);
        end

        function renameModelHandler(obj,ev)
            oldName=obj.ModelName;
            assert(~isempty(oldName));
            newName=ev.Source.Name;
            assert(~isempty(newName));
            if strcmp(newName,oldName);return;end


            dlgs=DAStudio.ToolRoot.getOpenDialogs;
            pmDlgs=dlgs.find('dialogTag','fmu2expcs_dialog');
            dlg=[];
            for i=1:length(pmDlgs)
                currentDlg=pmDlgs(i);
                if strcmp(obj.ModelName,...
                    currentDlg.getDialogSource.ModelName)
                    dlg=currentDlg;
                    break;
                end
            end


            copyParamConfigMATfile(obj,newName)


            opt=obj.getOptions;
            obj.setOptions([]);
            obj.ModelName=newName;

            opt.ProjectName=[obj.ModelName,'_fmu'];

            loadParameterList(obj)

            loadInternalVarList(obj);

            obj.setOptions(opt);


            if~isempty(dlg)
                dlg.refresh;
                dlg.show;
            end
        end


        function OM_ExportedContent(obj,dlg)
            if(dlg.getWidgetValue('fmu2expcs_ExportedContent')==0)
                dlg.setWidgetValue('fmu2expcs_CreateModelAfterGeneratingFMU',true);
                dlg.setEnabled('fmu2expcs_CreateModelAfterGeneratingFMU',false);
                dlg.setEnabled('fmu2expcs_ProjectName',true);
                dlg.setWidgetValue('fmu2expcs_ProjectName',[obj.ModelName,'_fmu']);
            else
                dlg.setWidgetValue('fmu2expcs_CreateModelAfterGeneratingFMU',false);
                dlg.setEnabled('fmu2expcs_CreateModelAfterGeneratingFMU',true);
                dlg.setWidgetValue('fmu2expcs_ProjectName','');
                dlg.setEnabled('fmu2expcs_ProjectName',false);
            end
        end

        function OM_CreateModelAfterGeneratingFMU(obj,dlg)

        end

        function OM_SaveSourceCodeToFMU(obj,dlg)






            if~isempty(obj.packageList.mData)
                UIDArray=[obj.packageList.mData(:).UID];
                updatePackageListSpreadSheet(obj,dlg,UIDArray);
            end
        end



        function OM_Generate32BitDLL(obj,dlg)





            if~isempty(obj.packageList.mData)
                UIDArray=[obj.packageList.mData(:).UID];
                updatePackageListSpreadSheet(obj,dlg,UIDArray);
            end
        end


        function OM_AddIcon(obj,dlg)
            if(dlg.getWidgetValue('fmu2expcs_AddIconDropdown')==1)
                dlg.setEnabled('fmu2expcs_AddIconPath',true);
                dlg.setEnabled('fmu2expcs_AddIconBrowse',true);
            else
                dlg.setEnabled('fmu2expcs_AddIconPath',false);
                dlg.setEnabled('fmu2expcs_AddIconBrowse',false);
            end
        end


        function OM_AddNativeSimulinkBehavior(obj,dlg)
        end


        function browseImage(~,dlg)
            [fileName,pathName]=uigetfile(...
            {'*.png','(*.png)';...
            '*.*',DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconBrowseAllFiles')},...
            DAStudio.message('FMUExport:FMU:FMU2ExpCSAddIconBrowseDialogTitle'));
            image_file=fullfile(pathName,fileName);
            if(exist(image_file,'file')==2)
                setWidgetValue(dlg,'fmu2expcs_AddIconPath',image_file);
            end
        end



        function reset_List(obj,dlg,tag)
            switch tag
            case 'fmu2expcs_reset_paramList'
                for i=1:length(obj.paramListSource.valueStructure)
                    obj.paramListSource.valueStructure(i).exported='on';
                    obj.paramListSource.valueStructure(i).exportedName=obj.paramListSource.valueStructure(i).Name;
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_paramList');
                spSheet.update(true);
            case 'fmu2expcs_reset_ivList'
                for i=1:length(obj.ivListSource.valueStructure)
                    obj.ivListSource.valueStructure(i).exported='off';
                    obj.ivListSource.valueStructure(i).exportedName=obj.ivListSource.valueStructure(i).Name;
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_ivList');
                spSheet.update(true);
            end
        end


        function selectAll(obj,dlg,tag)
            switch tag
            case 'fmu2expcs_selectAll'
                for i=1:length(obj.paramListSource.valueStructure)
                    obj.paramListSource.valueStructure(i).exported='on';
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_paramList');
                spSheet.update(true);
            case 'fmu2expcs_iv_selectAll'
                for i=1:length(obj.ivListSource.valueStructure)
                    obj.ivListSource.valueStructure(i).exported='on';
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_ivList');
                spSheet.update(true);
            end
        end


        function unselectAll(obj,dlg,tag)
            switch tag
            case 'fmu2expcs_unselectAll'
                for i=1:length(obj.paramListSource.valueStructure)
                    obj.paramListSource.valueStructure(i).exported='off';
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_paramList');
                spSheet.update(true);
            case 'fmu2expcs_iv_unselectAll'
                for i=1:length(obj.ivListSource.valueStructure)
                    obj.ivListSource.valueStructure(i).exported='off';
                end

                spSheet=dlg.getWidgetInterface('fmu2expcs_ivList');
                spSheet.update(true);
            end
        end

        function openModelDataEditorCB(obj,dlg)
            editor=GLUE2.Util.findAllEditors(obj.ModelName);
            studio=editor.getStudio;
            DataView.showModelData(studio,...
            'ModelData',...
            'Signals',...
            DAStudio.message('Simulink:studio:DataViewPerspective_Design'));
        end

        function unhiliteFcn(obj)
            if~isempty(obj.ivListSource)
                if~isempty(obj.ivListSource.highlights)
                    for i=1:length(obj.ivListSource.highlights)
                        hilite_system(obj.ivListSource.highlights(i),'none');
                    end
                end
                obj.ivListSource.highlights=[];
            end
        end



        function loadParameterList(obj)
            if slfeature('FMUExportParameterConfiguration')

                obj.paramListSource=FMU2ExpCSDialog.getParamListSource(obj.ModelName);
                if~isempty(obj.paramListSource.valueStructure)
                    baseDir=internal.packageConfig.utility.getCachedMATFolderPath;
                    filename=[obj.ModelName,'_ParamConfig.mat'];
                    if exist(fullfile(baseDir,filename),"file")&&...
                        ~isempty(whos('-file',fullfile(baseDir,filename),...
                        'var','paramListSource'))
                        load(fullfile(baseDir,filename),'paramListSource');
                        if~isempty(paramListSource.valueStructure)


                            [~,ia,ib]=intersect({paramListSource.valueStructure.Name},{obj.paramListSource.valueStructure.Name});
                            for i=1:length(ib)
                                obj.paramListSource.valueStructure(ib(i)).exported=paramListSource.valueStructure(ia(i)).exported;
                                obj.paramListSource.valueStructure(ib(i)).exportedName=paramListSource.valueStructure(ia(i)).exportedName;
                            end
                        end
                    end
                end
            end
        end

        function copyParamConfigMATfile(obj,newModelName)

            if slfeature('FMUExportParameterConfiguration')
                baseDir=internal.packageConfig.utility.getCachedMATFolderPath;
                filename=[obj.ModelName,'_ParamConfig.mat'];
                if exist(fullfile(baseDir,filename),"file")
                    status=copyfile(fullfile(baseDir,filename),fullfile(baseDir,[newModelName,'_ParamConfig.mat']));
                    assert(status);
                end
            end
        end
        function loadInternalVarList(obj)
            if slfeature('FMUExportInternalVarConfiguration')

                obj.ivListSource=FMU2ExpCSDialog.getInternalVarListSource(obj.ModelName);
                if~isempty(obj.ivListSource.valueStructure)
                    baseDir=internal.packageConfig.utility.getCachedMATFolderPath;
                    filename=[obj.ModelName,'_ParamConfig.mat'];
                    if exist(fullfile(baseDir,filename),"file")&&...
                        ~isempty(whos('-file',fullfile(baseDir,filename),...
                        'var','ivListSource'))
                        load(fullfile(baseDir,filename),'ivListSource');
                        if~isempty(ivListSource.valueStructure)


                            [~,ia,ib]=intersect({ivListSource.valueStructure.Name},{obj.ivListSource.valueStructure.Name});
                            for i=1:length(ib)
                                obj.ivListSource.valueStructure(ib(i)).exported=ivListSource.valueStructure(ia(i)).exported;
                                obj.ivListSource.valueStructure(ib(i)).exportedName=ivListSource.valueStructure(ia(i)).exportedName;

                            end
                        end
                    end
                end
            end
        end


        function package_selectAll(obj,dlg)
            packageSpreadSheetRow=arrayfun(@(x)x,...
            obj.packageList.mData,'un',0);
            spSheet=dlg.getWidgetInterface('fmu2expcs_packageList');
            spSheet.select(packageSpreadSheetRow);
            spSheet.update(num2cell(obj.packageList.mData.'));
        end


        function setupPackageList(obj)
            obj.packageList=FMU2ExpCSDialog.getPackageListSource(obj.ModelName);
        end


        function remove_packageList(obj,dlg)
            spSheet=dlg.getWidgetInterface('fmu2expcs_packageList');
            selected=spSheet.getSelection();
            if~isempty(selected)
                obj.packageList=internal.packageConfig.spreadSheetSource.removeSelection(obj.packageList,selected);
                spSheet.update(true);
            end
        end



        function add_packageList(obj,dlg,~,action)
            switch action
            case 'folderButtonAction'
                [pathName]=uigetdir('',...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageUIFolderLabel')));
                fileName='';
            case 'fileButtonAction'
                [fileName,pathName]=uigetfile(...
                '*.*',...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageUIFileLabel')),...
                'MultiSelect','on');
            end

            if isequal(fileName,0)
                return
            elseif~iscell(fileName)
                fileName={fileName};
            end

            if isequal(pathName,0)
                return
            elseif~iscell(pathName)
                pathName={pathName};
            end

            obj.packageList=FMU2ExpCSDialog.addToPackageList(obj.packageList,fileName,pathName);

            spSheet=dlg.getWidgetInterface('fmu2expcs_packageList');
            spSheet.update(true);
        end


        function packageList_spreadSheetValue(obj,~,sels,name,~,dlg)

            if strcmpi(name,getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder')))
                UIDArray=cellfun(@(x)x.UID,sels);
                updatePackageListSpreadSheet(obj,dlg,UIDArray);
            end
        end




        function spSheet=updatePackageListSpreadSheet(obj,dlg,UIDArray)
            if(~isempty(obj.packageList.mData))
                if nargin==2
                    UIDArray=[obj.packageList.mData(:).UID];
                end
                saveSourceCodeToFMU=dlg.getWidgetValue('fmu2expcs_SaveSourceCodeToFMU');
                generate32BitDLL=dlg.getWidgetValue('fmu2expcs_Generate32BitDLL');
                packagePath=dlg.getWidgetValue('fmu2expcs_PackagePath');
                obj.packageList=...
                internal.packageConfig.spreadSheetSource.updatePackageSpreadSheetInfo(obj.packageList,...
                saveSourceCodeToFMU,generate32BitDLL,packagePath,UIDArray);

                spSheet=dlg.getWidgetInterface('fmu2expcs_packageList');
                spSheet.update(num2cell(obj.packageList.mData.'));
            end
        end
    end

    methods(Static=true,Hidden=true)



        function removeDlg(dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end
    end
end
function saveOptionsToMATFile(model,opt)
    cachedMATFilePath=generateCachedMATFilePath(model);



    if~isfile(cachedMATFilePath)
        matObj=matfile(cachedMATFilePath);
    else
        matObj=matfile(cachedMATFilePath,'Writable',true);
    end

    FNames=fieldnames(opt);
    FNames=setdiff(FNames,{'mdlCloseListener','modelRenameListener'});

    defaultOptions=FMU2ExpCSDialog.CreatorDialog.DefaultOptions;

    for fieldName=FNames.'


        if~isfield(defaultOptions,fieldName{1})||~isequal(defaultOptions.(fieldName{1}),opt.(fieldName{1}))
            matObj.(fieldName{1})=opt.(fieldName{1});
        end
    end
end
function cachedMATFilePath=getCachedMATFilePath(model)

    cachedMATFilePath=fullfile(internal.packageConfig.utility.getCachedMATFolderPath,...
    [model,'_ParamConfig.mat']);
end
function cachedMATFilePath=generateCachedMATFilePath(model)


    fileDir=internal.packageConfig.utility.getCachedMATFolderPath;

    if~isfolder(fileDir)
        mkdir(fileDir);
    end
    cachedMATFilePath=getCachedMATFilePath(model);
end

