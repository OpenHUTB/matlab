function fmu_make_rtw_hook_fcn(hookPoint,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok














    modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;

    switch hookPoint
    case 'error'







        try

            restoreModelSetting(modelName);
        catch ex
        end

        try

            cdOC=[];
            if modelSettingBackup.isKey([modelName,'.RemoveGeneratedFile'])
                currDir=cd(modelSettingBackup([modelName,'.RemoveGeneratedFile']));
                cdOC=onCleanup(@()cd(currDir));
                clean_up(modelName,true);
            end
        catch
            if~isempty(cdOC)
                cdOC.delete;
            end
        end

        try

            idxToRemove=startsWith(modelSettingBackup.keys,[modelName,'.']);
            keys=modelSettingBackup.keys;
            modelSettingBackup.remove(keys(idxToRemove));
        catch
        end

    case 'entry'




        backupModelSetting(modelName);


        check_expiration_date();


        check_licenses(modelName);

    case 'before_tlc'




    case 'before_codegen'


    case 'after_codegen'


    case 'after_tlc'





        modelSettingBackup([modelName,'.RemoveGeneratedFile'])=pwd;

    case 'before_make'




        [~,lModelReferenceTargetType]=findBuildArg(buildInfo,'MODELREF_TARGET_TYPE');

        if strcmpi(lModelReferenceTargetType,'NONE')
            assert(~isempty(buildInfo.BuildTools),...
            'The FMU target does not support template makefile builds')
            setBuildVariant(buildInfo.BuildTools,...
            coder.make.enum.BuildVariant.SHARED_LIBRARY_TARGET);
        end


        if(strcmpi(lModelReferenceTargetType,'RTW'))
            buildInfo.addIncludePaths(fullfile(matlabroot,'toolbox','shared','simulink','fmuexport','fmi2_noprefix'));
            return;
        end

        updateProgressBarInfo(...
        getString(message('FMUExport:FMU:FMU2ExpCSStatusSetupBuild')),45);





        if(isunix)

            buildInfo.addSysLibs('m');
        end



        buildInfo.addCompileFlags({'-DRT -DUSE_RTMODEL'});






        if(isunix&&~ismac)
            buildInfo.addLinkFlags('-Wl,-Bsymbolic');
        end





        if strcmp(buildInfo.BuildTools.Toolchain,'Microsoft Visual C++ 2015 v14.0 | nmake (64-bit Windows)')


            buildInfo.addLinkFlags('legacy_stdio_definitions.lib');
        end

        if strcmp(buildInfo.BuildTools.Toolchain,'LCC-win64 v2.4.1 | gmake (64-bit Windows)')
            buildInfo.addCompileFlags({'-fno-inline'});
        end





        l_removeFileFromBuildInfo(buildInfo);


        buildInfo.addIncludePaths(fullfile(matlabroot,'toolbox','shared','simulink','fmuexport','fmi2_noprefix'));


        raccelFMUPath=fullfile(matlabroot,'rtw','c','src','rapid','fmu');
        pathUtilIncludeFile='RTWCG_FMU_util.h';
        pathUtilFile='RTWCG_FMU_util.c';
        fmu2csGroup='fmu2cs';
        buildInfo.addIncludeFiles(pathUtilIncludeFile,raccelFMUPath,fmu2csGroup);
        buildInfo.addSourceFiles(pathUtilFile,raccelFMUPath,fmu2csGroup);
        buildInfo.addIncludePaths(raccelFMUPath);


        wrapperWriter=coder.internal.fmuexport.FMUWrapper(modelName,buildOpts,buildInfo);
        modelSettingBackup([modelName,'.FMUWrapperWriter'])=wrapperWriter;
        wrapperWriter.generateWrapper;
        buildInfo.addSourceFiles(wrapperWriter.getFMUCInterfaceFileName);


        if(ispc)
            generate_pc_files(modelName,buildInfo);
        end


        buildInfo.addMakeVars('RELATIVE_PATH_TO_ANCHOR','.');


        saveSourceCodeToFMU=...
        strcmpi(get_param(modelName,'SaveSourceCodeToFMU'),'on');

        if saveSourceCodeToFMU
            checkUnsupportSourceCodeFormat(modelName,buildInfo);
        else
            obfuscate_code(modelName);
        end

    case 'after_make'




        [~,lModelReferenceTargetType]=findBuildArg(buildInfo,'MODELREF_TARGET_TYPE');
        if(strcmpi(lModelReferenceTargetType,'RTW'));return;end

        updateProgressBarInfo(...
        getString(message('FMUExport:FMU:FMU2ExpCSStatusPackageFMU',modelName)),70);


        saveSourceCodeToFMU=...
        strcmpi(get_param(modelName,'SaveSourceCodeToFMU'),'on');


        package(modelName,buildInfo,buildOpts,saveSourceCodeToFMU);

        updateProgressBarInfo(...
        getString(message('FMUExport:FMU:FMU2ExpCSStatusMoveFMUToDestination',modelName)),75);


        current_directory=fileparts(pwd);
        SaveDirectory=get_param(modelName,'SaveDirectory');
        if(~strcmpi(current_directory,SaveDirectory))
            relative_to_current=fullfile(current_directory,SaveDirectory);
            if(exist(relative_to_current,'dir')==7)
                actual_save_dir=relative_to_current;
            elseif(exist(SaveDirectory,'dir')==7)
                actual_save_dir=SaveDirectory;
            else
                throw(MSLException([],...
                message('FMUExport:FMU:FMU2ExpCSNonexistingDirectory',SaveDirectory)));
            end
            fmu_fullname=fullfile(actual_save_dir,[modelName,'.fmu']);
            movefile(fullfile(current_directory,[modelName,'.fmu']),fmu_fullname,'f');
        else
            fmu_fullname=fullfile(current_directory,[modelName,'.fmu']);
        end




        if(strcmp(get_param(modelName,'CreateModelAfterGeneratingFMU'),'on'))||...
            strcmp(get_param(modelName,'ExportedContent'),'project')

            updateProgressBarInfo(...
            getString(message('FMUExport:FMU:FMU2ExpCSStatusCreateModel',modelName)),80);

            [harnessModelFile,MATFilePath]=create_model_after_generating_FMU(modelName,fmu_fullname,buildOpts);



            if(strcmp(get_param(modelName,'AddNativeSimulinkBehavior'),'on'))
                solverName=get_param(modelName,'SolverName');
                create_test_harness_model(harnessModelFile,solverName);
            end
        end


        if strcmp(get_param(modelName,'ExportedContent'),'project')&&...
            ~isempty(harnessModelFile)
            ProjectName=get_param(modelName,'ProjectName');

            updateProgressBarInfo(...
            getString(message('FMUExport:FMU:FMU2ExpCSStatusCreateArchivedProject',ProjectName,modelName)),85);

            create_project_after_generating_FMU(harnessModelFile,...
            MATFilePath,fmu_fullname,ProjectName);
        end

    case 'exit'





        try

            restoreModelSetting(modelName);
        catch
        end

        try

            [~,lModelReferenceTargetType]=findBuildArg(buildInfo,'MODELREF_TARGET_TYPE');
            if~strcmpi(lModelReferenceTargetType,'RTW')



                if modelSettingBackup.isKey([modelName,'.RemoveGeneratedFile'])
                    assert(strcmpi(pwd,modelSettingBackup([modelName,'.RemoveGeneratedFile'])));
                    clean_up(modelName,true);
                end
            else





                cgMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);
                topModel=cgMgr.MdlRefBuildArgs.TopOfBuildModel;



                if~strcmpi(get_param(topModel,'SaveSourceCodeToFMU'),'on')&&...
                    isempty(get_param(gcs,'ProtectedModelCreator'))&&...
                    modelSettingBackup.isKey([modelName,'.RemoveGeneratedFile'])
                    assert(strcmpi(pwd,modelSettingBackup([modelName,'.RemoveGeneratedFile'])));
                    clean_up(modelName,false);
                end
            end
        catch
        end
        try



            keys=modelSettingBackup.keys;


            exceptions=strcat(modelName,{'.ProgressBarHandle','.HarnessModelName','.ProjectName','.CallSite'});
            idxToRemove=startsWith(keys,[modelName,'.'])&~cellfun(@(x)ismember(x,exceptions),keys);
            modelSettingBackup.remove(keys(idxToRemove));
        catch
        end

    end




    function backupParameter(modelName,param,newValue)
        if(~isequal(get_param(modelName,param),newValue))
            modelSettingBackup([modelName,'.',param])=get_param(modelName,param);

            paramEnabledOC=[];
            configLockOC=[];
            try

                configSet=getActiveConfigSet(modelName);
                if~configSet.getPropEnabled(param)
                    configSet.setPropEnabled(param,'on');
                    paramEnabledOC=onCleanup(@()configSet.setPropEnabled(param,'off'));
                end
                if configSet.isLockedForSim
                    configSet.unlock;
                    configLockOC=onCleanup(@()configSet.lock);
                end
            catch
            end
            msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterTurnedOff',param);
            coder.internal.fmuexport.reportMsg(['### ',msg],'Info',modelName);
            set_param(modelName,param,newValue);
            try
                if~isempty(paramEnabledOC)
                    paramEnabledOC.delete;
                end
                if~isempty(configLockOC)
                    configLockOC.delete;
                end
            catch
            end
        end
    end

    function restoreParameter(modelName,param)
        if modelSettingBackup.isKey([modelName,'.',param])
            paramEnabledOC=[];
            configLockOC=[];
            try

                configSet=getActiveConfigSet(modelName);
                if~configSet.getPropEnabled(param)
                    configSet.setPropEnabled(param,'on');
                    paramEnabledOC=onCleanup(@()configSet.setPropEnabled(param,'off'));
                end
                if configSet.isLockedForSim
                    configSet.unlock;
                    configLockOC=onCleanup(@()configSet.lock);
                end
            catch
            end
            set_param(modelName,param,modelSettingBackup([modelName,'.',param]));
            try
                if~isempty(paramEnabledOC)
                    paramEnabledOC.delete;
                end
                if~isempty(configLockOC)
                    configLockOC.delete;
                end
            catch
            end
        end
    end

    function backupWarning(modelName,warn)
        warnState=warning('off',warn);
        modelSettingBackup([modelName,'.',warn])=warnState.state;
    end

    function restoreWarning(modelName,warn)
        if modelSettingBackup.isKey([modelName,'.',warn])
            warning(modelSettingBackup([modelName,'.',warn]),warn);
        end
    end

    function backupModelSetting(modelName)










        backupParameter(modelName,'GenerateReport','off');
        backupParameter(modelName,'LaunchReport','off');
        backupParameter(modelName,'GenerateComments','off');
        backupParameter(modelName,'SimulinkBlockComments','off');
        backupParameter(modelName,'MATLABSourceComments','off');
        backupParameter(modelName,'ShowEliminatedStatement','off');
        backupParameter(modelName,'ForceParamTrailComments','off');
        backupParameter(modelName,'TLCDebug','off');




        if~isempty(get_param(modelName,'ProtectedModelCreator'))
            configSet=getActiveConfigSet(modelName);
            hardware=configSet.getComponent('Hardware Implementation');
            origHardware=copy(hardware);
            modelSettingBackup([modelName,'.HardwareImplementation'])=origHardware;
            slprivate('setHardwareDevice',hardware,'Target','MATLAB Host');
            msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterResetHWDevice',modelName);
            coder.internal.fmuexport.reportMsg(['### ',msg],'Info',modelName);
        end

        backupWarning(modelName,'RTW:makertw:hardwareUnspecified');
        backupWarning(modelName,'Simulink:Engine:CombineOutputUpdateFcnMinorTimeSteps');
    end

    function restoreModelSetting(modelName)
        restoreWarning(modelName,'RTW:makertw:hardwareUnspecified');
        restoreWarning(modelName,'Simulink:Engine:CombineOutputUpdateFcnMinorTimeSteps');



        restoreParameter(modelName,'GenerateReport');
        restoreParameter(modelName,'LaunchReport');
        restoreParameter(modelName,'GenerateComments');
        restoreParameter(modelName,'SimulinkBlockComments');
        restoreParameter(modelName,'MATLABSourceComments');
        restoreParameter(modelName,'ShowEliminatedStatement');
        restoreParameter(modelName,'ForceParamTrailComments');
        restoreParameter(modelName,'TLCDebug');


        if~isempty(get_param(modelName,'ProtectedModelCreator'))
            if modelSettingBackup.isKey([modelName,'.HardwareImplementation'])
                configSet=getActiveConfigSet(modelName);
                configSet.attachComponent(modelSettingBackup([modelName,'.HardwareImplementation']));
            end
        end







    end

    function add_icon(modelName)

        addIcon=get_param(modelName,'AddIcon');
        if(strcmp(addIcon,'off'))
            return;
        elseif(strcmp(addIcon,'snapshot'))
            filename='model.png';
            print(['-s',modelName],'-dpng','-r90',filename);
            image_file=fullfile(pwd,filename);
        elseif(exist(addIcon,'file')==2)
            image_file=addIcon;
        elseif(strcmp(addIcon,'sl_signature'))
            image_file=fullfile(matlabroot,'toolbox','shared','simulink','fmuexport','sl_logos','Simulink_Logo_trans.png');
        else
            throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptions')));
        end

        [A,~,transparency]=imread(image_file);
        new_location=fullfile('fmuWorkingDir','model.png');
        if(isempty(transparency))
            imwrite(A,new_location,'png');
        else
            imwrite(A,new_location,'png','Alpha',transparency);
        end
        if(~exist(new_location,'file')==2)
            throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSCannotAddIcon')));
        end
        image_file=new_location;

        if(strcmp(addIcon,'snapshot'))

            [im,~,alpha]=imread(image_file);

            if size(im,1)>8192||size(im,2)>8192
                im=imresize(im,min(4096./size(im,1:2)));
                alpha=imresize(alpha,min(4096./size(alpha,1:2)));
            end

            padsize=round(0.15*size(im,1));
            im2=255*ones(size(im,1)+2*padsize,size(im,2)+2*padsize,size(im,3),class(im));
            im2((padsize+1):(padsize+size(im,1)),(padsize+1):(padsize+size(im,2)),:)=im;
            alpha2=zeros(size(alpha,1)+2*padsize,size(alpha,2)+2*padsize,size(alpha,3),class(alpha));
            alpha2((padsize+1):(padsize+size(alpha,1)),(padsize+1):(padsize+size(alpha,2)),:)=alpha;



            fileattrib(image_file,'+w');
            imwrite(im2,image_file,'png','Alpha',alpha2);
        end
    end

    function check_expiration_date()









    end

    function check_licenses(modelName)


        [m,errmsg]=builtin('license','checkout','Simulink_Compiler');
        if~m
            ex=MSLException([],...
            message('Simulink:utility:invalidSimulinkCompilerLicenseForFMU'));
            ex=ex.addCause(MException('SimulinkCompiler:LicenseCheckoutError','%s',errmsg));
            throwAsCaller(ex);
        end

        if strcmpi(get_param(modelName,'SaveSourceCodeToFMU'),'on')



            [m,errmsg]=builtin('license','checkout','Real-Time_Workshop');
            if~m
                ex=MSLException([],...
                message('FMUExport:FMU:RTWCoderLicenseRequired'));
                ex=ex.addCause(MException('SimulinkCompiler:LicenseCheckoutError','%s',errmsg));
                throwAsCaller(ex);
            end
        end
    end


    function clean_up(modelName,isTopModel)



        if isTopModel
            if~endsWith(pwd,'fmu2cs_rtw'),return;end
        else
            if~endsWith(pwd,fullfile('slprj','fmu2cs',modelName)),return;end
        end

        recycle_origval=recycle('off');
        recycle_cleanup=onCleanup(@()recycle(recycle_origval));
        files=dir;
        filenames={files.name};
        filenames{1}='';
        filenames{2}='';
        if isTopModel
            except=strcmp(filenames,'buildInfo.mat');
        else
            except=~endsWith(filenames,{'.c','.cpp','.mk'});
        end
        if(any(except));filenames(except)=[];end
        for i=1:numel(filenames)
            if(isempty(filenames{i}));continue;end
            if(exist(filenames{i})==2)
                delete(filenames{i});
            elseif(exist(filenames{i})==7)
                rmdir(filenames{i},'s');
            else
                assert(false);
            end
        end
        if(any(except))
            assert(numel(dir)==3);
        else
            assert(numel(dir)==2);
        end
    end

    function[harnessModelFile,MATFilePath]=create_model_after_generating_FMU(modelName,fmu_fullname,buildOpts)

        tmpModelName=[char(randi([65,90],1,6)),'_fmu'];
        new_system(tmpModelName,'model');
        Cl1=onCleanup(@()bdclose(tmpModelName));
        set_param(tmpModelName,'StartTime',get_param(modelName,'StartTime'));
        set_param(tmpModelName,'StopTime',get_param(modelName,'StopTime'));


        set_param(tmpModelName,'DataDictionary',get_param(modelName,'DataDictionary'));

        newBlockName=[tmpModelName,'/Generated FMU Block'];
        try
            currdir=cd('..');
            currdir_cleanup=onCleanup(@()cd(currdir));
            [fmu_path,fmu_name,~]=fileparts(fmu_fullname);
            addpath(fmu_path);
            add_block('built-in/FMU',newBlockName,'FMUName',fmu_name,'Position',[50,50,200,200]);
            if(strcmp(buildOpts.sysTargetFile,'fmu2cs.tlc')&&...
                ~strcmp(get_param(modelName,'FixedStep'),'auto'))
                set_param(newBlockName,'FMUSampleTime',get_param(modelName,'FixedStep'));
            end


            updateBusInfoAtPorts(newBlockName,'FMUInportInfoStruct',...
            'FMUInputBusStruct',...
            'FMUInputBusObjectName');
            updateBusInfoAtPorts(newBlockName,'FMUOutportInfoStruct',...
            'FMUOutputBusStruct',...
            'FMUOutputBusObjectName');

            warningIdToSuppress={'Simulink:Harness:ExportDeleteHarnessFromSystemModel',...
            'Simulink:Engine:InputNotConnected',...
            'Simulink:Engine:OutputNotConnected',...
            'Simulink:SampleTime:SourceInheritedTS'};

            WarningId=cellfun(@(x)warning('off',x),warningIdToSuppress,'un',0);
            Cl2=onCleanup(@()cellfun(@(x)warning(x),WarningId,'un',0));

            harnessModelName=generateHarnessModelName(fmu_path,modelName);

            if modelSettingBackup.isKey([modelName,'.HarnessModelName'])
                modelSettingBackup([modelName,'.HarnessModelName'])=[harnessModelName,'.slx'];
            end

            harnessModelFile=fullfile(fmu_path,[harnessModelName,'.slx']);


            harnessInfo=Simulink.harness.internal.create(newBlockName,false,false,'Name',harnessModelName);

            Simulink.harness.internal.export(newBlockName,harnessInfo.name,false,'Name',harnessModelFile);


            open_system(harnessModelFile);

            [IsMATFileGenerated,MATFilePath]=createMATFile(harnessModelName,fmu_path);
            if IsMATFileGenerated
                [~,MATFileName,Ext]=fileparts(MATFilePath);
                command=sprintf('load(''%s'')',[MATFileName,Ext]);
                set_param(harnessModelName,'PreLoadfcn',command);
            end




            set_param(harnessModelName,'DataDictionary','');




            trim_blockName(harnessModelName,'Inport');

            trim_blockName(harnessModelName,'Outport');

            if modelSettingBackup.isKey([modelName,'.CallSite'])&&...
                strcmp(modelSettingBackup([modelName,'.CallSite']),'CL')
                save_system(harnessModelFile);
                bdclose(harnessModelFile);
            end

            clear('currdir_cleanup');
        catch ME

            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:HarnessCreationErrorWrapper',ME.getReport()),'Warning',modelName);
            harnessModelFile='';
            MATFilePath='';
        end
    end
    function create_test_harness_model(harnessModelFile,solverName)

        [fPath,mdlName,~]=fileparts(harnessModelFile);
        assert(isfolder(fPath));
        currentPath=pwd;
        cd(fPath);
        w=onCleanup(@()cd(currentPath));
        open_system(mdlName);


        addAnnotationAndLogSDI(mdlName);


        set_param(mdlName,'SigSpecEnsureSampleTimeMsg','None');
        set_param(mdlName,'SolverName',solverName);
        set_param(mdlName,'ZoomFactor','FitSystem');
        save_system(mdlName);
    end
    function addAnnotationAndLogSDI(mdlName)

        outputPortCell=find_system(mdlName,'SearchDepth',1,'BlockType','Outport');
        for Count=1:length(outputPortCell)
            outputPort=outputPortCell{Count};
            portHandle=get_param(outputPort,'PortHandles');
            lineHandle=get_param(portHandle.Inport(1),'Line');
            Simulink.sdi.markSignalForStreaming(lineHandle,'on');
        end


        clickAnnotation=Simulink.Annotation([mdlName,'/PlotResult'],'Text','Compare FMU output with Model');


        FMUBlock=find_system(mdlName,'SearchDepth',1,'BlockType','FMU');
        offsetPosition=get_param(FMUBlock{1},'Position');
        topPos=offsetPosition(4)+60;
        leftPos=((offsetPosition(1)+offsetPosition(3))/2)-15;
        rightPos=leftPos+50;
        bottomPos=topPos+60;
        clickAnnotation.position=[leftPos,topPos,rightPos,bottomPos];


        ImgPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','plotCompare_fmu_24.png');
        setImage(clickAnnotation,ImgPath);


        clickTextCell=cell(0);
        clickTextCell{end+1}='Simulink.sdi.clear';
        clickTextCell{end+1}='OriginalRunNamingRule = Simulink.sdi.getRunNamingRule;';
        clickTextCell{end+1}='Simulink.sdi.setSubPlotLayout(1,1)';
        clickTextCell{end+1}='FMUBlocks = find_system(bdroot,''BlockType'',''FMU'');';
        clickTextCell{end+1}='baselineFile = [''baseline_'' get_param(bdroot,''Name'') ''.mldatx''];';
        clickTextCell{end+1}='if (exist(baselineFile,''file'')==2)';
        clickTextCell{end+1}='Simulink.sdi.load(baselineFile);';
        clickTextCell{end+1}='else';
        clickTextCell{end+1}='cellfun(@(x)set_param(x,''SimulateUsing'',''Native Simulink Behavior''),FMUBlocks)';
        clickTextCell{end+1}=['Simulink.sdi.setRunNamingRule(''',getString(message('FMUExport:FMU:FMU2ExpCSNativeSimulinkOutput')),''')'];
        clickTextCell{end+1}='sim(bdroot);';
        clickTextCell{end+1}='Simulink.sdi.save(baselineFile);';
        clickTextCell{end+1}='end';
        clickTextCell{end+1}='cellfun(@(x)set_param(x,''SimulateUsing'',''FMU''),FMUBlocks)';
        clickTextCell{end+1}=['Simulink.sdi.setRunNamingRule(''',getString(message('FMUExport:FMU:FMU2ExpCSExportedCoSimFMUOutput')),''')'];
        clickTextCell{end+1}='sim(bdroot);';
        clickTextCell{end+1}='runIDs = Simulink.sdi.getAllRunIDs;';
        clickTextCell{end+1}='OriginalModelRun = runIDs(end-1);';
        clickTextCell{end+1}='FMUOutputRun = runIDs(end);';
        clickTextCell{end+1}='Simulink.sdi.view;';
        clickTextCell{end+1}='noTolDiffResult = Simulink.sdi.compareRuns(OriginalModelRun,FMUOutputRun);';
        clickTextCell{end+1}='Simulink.sdi.setRunNamingRule(OriginalRunNamingRule)';
        clickTextCell{end+1}='clear OriginalRunNamingRule';
        clickAnnotation.clickFcn=strjoin(clickTextCell,'\n');

        baseline=Simulink.Annotation(mdlName,getString(message('FMUExport:FMU:CompareFMUOutputWithNativeSimulink')));
        baseline.Position=[leftPos-140,topPos+30,leftPos-80+28,topPos+60];
        baseline.clickFcn=strjoin(clickTextCell,'\n');
    end

    function[harnessModelName]=generateHarnessModelName(fmu_path,modelName)
        if length(modelName)>40
            harnessModelName=[modelName(1:40),'_harness'];
        else
            harnessModelName=[modelName,'_harness'];
        end
        harnessModelName=check_existing_harness_model(fmu_path,harnessModelName,'');
    end

    function harnessModelName=check_existing_harness_model(fmu_path,harnessModelName,harnessModelIndex)
        if(exist(fullfile(fmu_path,[harnessModelName,harnessModelIndex,'.slx']),'file')==4)
            if isempty(harnessModelIndex)
                harnessModelIndex='0';
            else
                harnessModelIndex=num2str(str2double(harnessModelIndex)+1);
            end
            harnessModelName=check_existing_harness_model(fmu_path,harnessModelName,harnessModelIndex);
        else
            harnessModelName=[harnessModelName,harnessModelIndex];
        end
    end

    function trim_blockName(mdlName,BlockType)
        blockCell=find_system(mdlName,'SearchDepth','1','BlockType',BlockType);
        blockNames=cellfun(@(x)get_param(x,'Name'),blockCell,'un',0);
        for Count=1:length(blockNames)
            nameStrCell=strsplit(blockNames{Count},'_');
            set_param(blockCell{Count},'Name',nameStrCell{end});
        end
    end

    function create_project_after_generating_FMU(generatedModelPath,...
        MATFilePath,...
        fmu_fullname,...
        ProjectName)

        [filePath]=fileparts(fmu_fullname);
        filesToAdd={fmu_fullname,generatedModelPath,MATFilePath};

        filesToAdd=filesToAdd(cellfun(@(x)~isempty(x),filesToAdd));


        [~,harnessModelName]=fileparts(generatedModelPath);
        if bdIsLoaded(harnessModelName)

            save_system(generatedModelPath);
            bdclose(generatedModelPath);
        end


        mlprojFullPath=fullfile(filePath,[ProjectName,'.mlproj']);
        matlab.internal.project.archive.createArchive(mlprojFullPath,filePath,filesToAdd);



        if modelSettingBackup.isKey([modelName,'.ProjectName'])
            modelSettingBackup([modelName,'.ProjectName'])=[ProjectName,'.mlproj'];
        end

        filesToAdd=setdiff(filesToAdd,{fmu_fullname});

        cellfun(@(x)delete(x),filesToAdd);

    end


    function[isMATFileGenerated,MATFilePath]=createMATFile(modelName,saveDirectory)
        MATFilePath='';
        isMATFileGenerated=false;


        Variables=Simulink.findVars(modelName);
        if~isempty(Variables)
            CurrentDir=pwd;
            Cl1=onCleanup(@()cd(CurrentDir));
            cd(saveDirectory);
            MATFileName=[modelName,'_fmu_base.mat'];
            VariablesStr=strjoin({Variables(:).Name},' ');
            Simulink.data.evalinGlobal(modelName,...
            ['save ',MATFileName,' ',VariablesStr]);
            isMATFileGenerated=true;
            MATFilePath=which(MATFileName);
        end
    end

    function generate_pc_files(modelName,buildInfo)

        def_src=fullfile(matlabroot,...
        'toolbox','shared','simulink','fmuexport','template.def');
        def_src_fid=fopen(def_src,'r');
        def_dest=fullfile(pwd,[modelName,'.def']);
        if exist(def_dest,'file')
            delete(def_dest);
        end
        def_dest_fid=fopen(def_dest,'w');
        def_line_count=0;
        while(~feof(def_src_fid))
            def_line_count=def_line_count+1;
            def_line=fgetl(def_src_fid);
            if(def_line_count==1)
                fprintf(def_dest_fid,['LIBRARY ',modelName,'_win64\n']);
            else
                fprintf(def_dest_fid,'%s\n',def_line);
            end
        end
        fclose(def_src_fid);
        fclose(def_dest_fid);

        lnk_file=[modelName,'.lnk'];
        lnk_fullfile=fullfile(pwd,lnk_file);
        if exist(lnk_fullfile,'file')
            delete(lnk_fullfile);
        end
        lnk_fid=fopen(lnk_fullfile,'w');
        fprintf(lnk_fid,'lccstub.obj\n');
        for m=1:length(buildInfo.Src.Files)
            [~,src_filename,~]=fileparts(buildInfo.Src.Files(m).FileName);
            fprintf(lnk_fid,[src_filename,'.obj\n']);
        end
        fclose(lnk_fid);
    end

    function list_source_files(modelName,buildInfo)
        coder.internal.fmuexport.reportMsg('Generated source and header files:','Info',modelName);
        for m=1:length(buildInfo.Src.Files)
            coder.internal.fmuexport.reportMsg(buildInfo.Src.Files(m).FileName,'Info',modelName);
        end
        for m=1:length(buildInfo.Inc.Files)
            coder.internal.fmuexport.reportMsg(buildInfo.Inc.Files(m).FileName,'Info',modelName);
        end
    end

    function l_removeFileFromBuildInfo(buildInfo)
        rmIndex=[];
        for m=1:length(buildInfo.Src.Files)
            fname=buildInfo.Src.Files(m).FileName;
            if strcmp(fname,'rt_main.c')||strcmp(fname,'rt_malloc_main.c')
                rmIndex(end+1)=m;%#ok<AGROW>
            end
        end
        if~isempty(rmIndex)
            buildInfo.Src.Files(rmIndex)=[];
        end
    end



    function obfuscate_code(modelName)
        obfuscate('.','.',modelName,0,false);
        obf_files=dir('*_ofc.*');
        for i=1:numel(obf_files)
            obf_filename=obf_files(i).name;
            ofc_place=strfind(obf_filename,'_ofc');
            filename=[obf_filename(1:ofc_place-1),obf_filename(ofc_place+4:end)];
            movefile(obf_filename,filename,'f');
        end
    end

    function package(modelName,buildInfo,buildOpts,saveSourceCodeToFMU)
        mkdir('fmuWorkingDir');
        dir_cleanup=onCleanup(@()rmdir('fmuWorkingDir','s'));

        assert(strcmp(get_param(modelName,'GenCodeOnly'),'off'));
        mkdir(fullfile('fmuWorkingDir','binaries'));
        shlibExt=buildInfo.getBuildToolInfo('ToolchainInfo').BuildTools.getValue('Linker').getFileExtension('Shared Library');
        shlibPlatform=computer('arch');
        if isunix
            if~ismac
                shlibPlatform=strrep(shlibPlatform,'glnxa','linux');
            else
                shlibPlatform=strrep(shlibPlatform,'maci','darwin');
            end
        end

        if(ispc&&strcmp(buildInfo.BuildTools.Toolchain,'MSVC 32 Bit Toolchain for FMU Export'))
            shlibPlatform=strrep(shlibPlatform,'64','32');
        end

        mkdir(fullfile('fmuWorkingDir','binaries',shlibPlatform));
        if ispc
            try
                movefile([modelName,'_',computer('arch'),shlibExt],[modelName,shlibExt]);
            catch


            end
        end
        if exist([modelName,shlibExt],'file')==0

            throw(MSLException('FMUExport:FMU:FMU2ExpCSToolchainNoBinary'));
        else
            copyfile([modelName,shlibExt],fullfile('fmuWorkingDir','binaries',shlibPlatform));
        end






        if strcmpi(shlibExt,'.dll')&&~ismember(shlibPlatform,{'win32','win64'})||...
            strcmpi(shlibExt,'.dylib')&&~strcmp(shlibPlatform,'darwin64')||...
            strcmpi(shlibExt,'.so')&&~strcmp(shlibPlatform,'linux64')
            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:BinaryExtensionFolderMismatch',...
            shlibExt,shlibPlatform),'Warning',modelName);
        end

        [sharedLibraryPath,sharedLibraryNameWithVersion]=getLocationOfFilePath(buildInfo,shlibExt);


        [~,~,LibraryIndex]=unique(sharedLibraryNameWithVersion.');





        [UniqueLibraryIndex,UniqueIndex]=unique(LibraryIndex,'first');
        IndexToSkip=zeros(size(LibraryIndex));
        IndexToSkip(UniqueIndex)=UniqueLibraryIndex;
        IndexToCopy=find(IndexToSkip>0);
        copiedFileStatus=arrayfun(@(x)copyfile(sharedLibraryPath{x},...
        fullfile('fmuWorkingDir','binaries',shlibPlatform)),...
        IndexToCopy);


        if~isempty(copiedFileStatus)&&all(copiedFileStatus)
            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:ThirdPartyLibraryCopied',...
            modelName),'Warning',modelName);
        end




        mdlrefblks=find_mdlrefs(modelName,'FollowLinks',true,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'IncludeProtectedModels',true);

        protectedMdls={};
        modelRefs={};
        for mi=1:length(mdlrefblks)
            if endsWith(mdlrefblks{mi},'.slxp')
                protectedMdls{end+1}=mdlrefblks{mi};
            else
                modelRefs{end+1}=mdlrefblks{mi};
            end
        end

        for mi=1:length(modelRefs)


            if~bdIsLoaded(modelRefs{mi})
                continue;
            end


            fmuBlocks=find_system(modelRefs{mi},'FollowLinks','on',...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookInsideSubsystemReference','on',...
            'LookUnderReadProtectedSubsystems','on',...
            'BlockType','FMU');
            if~isempty(fmuBlocks)&&~exist(fullfile('fmuWorkingDir','resources'),'dir')
                mkdir(fullfile('fmuWorkingDir','resources'));
            end
            for bi=1:length(fmuBlocks)
                FMUPath=get_param(fmuBlocks{bi},'FMUWorkingDirectory');
                splitPath=regexp(FMUPath,filesep,'split');
                dirUID=splitPath{length(splitPath)-1};
                copyfile(FMUPath,fullfile('fmuWorkingDir','resources',dirUID));
            end
        end

        if~isempty(protectedMdls)
            cgfolder=RTW.getBuildDir(modelName).CodeGenFolder;
            pmfmupath=fullfile(cgfolder,'slprj','_fmu');
            if exist(pmfmupath,"dir")&&~exist(fullfile('fmuWorkingDir','resources'),'dir')
                mkdir(fullfile('fmuWorkingDir','resources'));
            end
            uidfolder=dir(pmfmupath);


            uidfolder=uidfolder(~ismember({uidfolder.name},{'.','..'}));
            for pi=1:length(uidfolder)
                if(uidfolder(pi).isdir)


                    fmufolder=dir(fullfile(uidfolder(pi).folder,uidfolder(pi).name));
                    fmufolder=fmufolder(~ismember({fmufolder.name},{'.','..','help_page'}));
                    assert(length(fmufolder)==1);
                    if~exist(fullfile('fmuWorkingDir','resources',uidfolder(pi).name),'dir')
                        copyfile(fullfile(fmufolder.folder,fmufolder.name),fullfile('fmuWorkingDir','resources',uidfolder(pi).name));
                    end
                end
            end
        end


        if(saveSourceCodeToFMU)
            if~isempty(protectedMdls)

                pmStaticLib=getProtectedModelStaticLibrary(buildInfo);

                if~isempty(pmStaticLib)
                    if~exist(fullfile('fmuWorkingDir','resources'),'dir')
                        mkdir(fullfile('fmuWorkingDir','resources'));
                    end
                    for p=1:length(pmStaticLib)
                        copyfile(pmStaticLib{p},fullfile('fmuWorkingDir','resources'));
                    end
                end
            end
            zipFileName=[modelName,'_FlatList'];
            destinationLocation=fullfile('fmuWorkingDir','sources');
            zipFileLocation=fullfile(pwd,'..',zipFileName);
            try
                packNGo(buildInfo,'packType','flat','fileName',zipFileName,'minimalHeaders',true)
                deleteZipFile=onCleanup(@()delete([zipFileLocation,'.zip']));
            catch Excep
                if strcmpi(Excep.identifier,'RTW:buildInfo:duplicateFilesForPackNGo')
                    ex=MSLException('FMUExport:FMU:DuplicateFileForPackaging');
                    ex=ex.addCause(Excep);
                    throw(ex);
                else
                    rethrow(Excep);
                end
            end

            fileNames=unzip(zipFileLocation,destinationLocation);
            [~,fileName,ext]=cellfun(@(x)fileparts(x),fileNames,'UniformOutput',false);

            cFiles=fileName(cellfun(@(x)strcmpi(x,'.c'),ext));
            cellfun(@(x)buildInfo.addSourceFiles(strcat(x,'.c')),cFiles,'un',0);

            save_source_code_to_fmu(modelName,fileNames);


            wrapperWriter=modelSettingBackup([modelName,'.FMUWrapperWriter']);
            wrapperWriter.generateDoc(buildInfo);
            save_doc_to_fmu('index.html');

            clear deleteZipFile
        end


        if strcmpi(get_param(modelName,'AddNativeSimulinkBehavior'),'on')
            savedSlxpName=[modelName,'_tempname.slxp'];
            slxpName=[modelName,'.slxp'];
            savedSlxpFileLocation=fullfile('..',savedSlxpName);
            protectedMdlDirPath=fullfile('fmuWorkingDir','resources','models');
            if~exist(protectedMdlDirPath,'dir')
                mkdir(protectedMdlDirPath)
            end
            [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSNativeSimulinkArtifactError');
            [is_moved,~,~]=movefile(savedSlxpFileLocation,fullfile(protectedMdlDirPath,slxpName),'f');
            assert(is_moved,id,msg);


            buildInfo.addNonBuildFiles(slxpName,...
            [protectedMdlDirPath,filesep,slxpName],...
            'protectedModel');
        end


        wrapperWriter=modelSettingBackup([modelName,'.FMUWrapperWriter']);
        wrapperWriter.generateXML(buildInfo);
        copyfile(wrapperWriter.getFMUXMLInterfaceFileName,'fmuWorkingDir');

        add_icon(modelName);

        if modelSettingBackup.isKey([modelName,'.Package'])
            resourcesToPackage=modelSettingBackup([modelName,'.Package']);

            for Count=1:length(resourcesToPackage)
                entity=resourcesToPackage(Count);

                if strcmpi(entity.FileType,'folder')
                    destinationFolder=fullfile('fmuWorkingDir',...
                    entity.DestinationFolder,entity.FileName);
                else
                    destinationFolder=fullfile('fmuWorkingDir',entity.DestinationFolder);
                end



                if~exist(destinationFolder,'dir')
                    mkdir(destinationFolder);
                end



                if exist(fullfile(destinationFolder,entity.FileName))>0 %#ok<EXIST> 
                    coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
                    fullfile(entity.SourceFolder,entity.FileName),...
                    fullfile(entity.DestinationFolder,entity.FileName)),'Warning',modelName);
                end


                copyfile(fullfile(entity.SourceFolder,entity.FileName),destinationFolder,'f');
            end
        end

        zip(modelName,'*','fmuWorkingDir');
        movefile([modelName,'.zip'],fullfile('..',[modelName,'.fmu']),'f');
        clear('dir_cleanup');
    end

    function save_source_code_to_fmu(modelName,FileNames)
        SourcesFolder=fullfile('fmuWorkingDir','sources');
        wrapperWriter=modelSettingBackup([modelName,'.FMUWrapperWriter']);
        wrapperWriter.modifySourceFiles(SourcesFolder,FileNames);
    end

    function save_doc_to_fmu(docFilePath)
        DocFolder=fullfile('fmuWorkingDir','documentation');
        mkdir(DocFolder);
        copyfile(docFilePath,DocFolder)
    end

    function updateBusInfoAtPorts(newBlockName,fmuPortInfoStructName,...
        fmuBusStructName,fmuBusObjectName)
        busStruct=get_param(newBlockName,fmuBusStructName);
        portInfoStruct=get_param(newBlockName,fmuPortInfoStructName);
        busCell=eval(busStruct);

        portInfoStruct(1)='[';portInfoStruct(end)=']';
        portInfo=eval(portInfoStruct);
        if(~isempty(busCell))

            portInfoCell=cellfun(@(x)portInfo(arrayfun(@(y)strcmpi(y.uniqueName,x.name),portInfo)),busCell,'un',false);




            portInfoCell=portInfoCell(cellfun(@(x)~isempty(x),portInfoCell));
            busTypeCell=cellfun(@(x)x.dataType,portInfoCell,'UniformOutput',false);
            set_param(newBlockName,fmuBusObjectName,busTypeCell);
        end
    end

    function checkUnsupportSourceCodeFormat(modelName,buildInfo)

        [~,~,ext]=arrayfun(@(x)fileparts(x.FileName),...
        buildInfo.Src.Files,'un',0);
        cFileIndex=cellfun(@(x)strcmpi(x,'.c'),ext);
        if any(~cFileIndex)

            nonCSrcFileStruct=...
            buildInfo.Src.Files(~cFileIndex);

            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:UnsupportedSourceCodeFormat',...
            strjoin({nonCSrcFileStruct(:).FileName},', ')),'Warning',modelName);
        end
    end

    function staticLibs=getProtectedModelStaticLibrary(buildInfo)

        staticLibs={};
        specDirs=buildInfo.Settings.getSpecialDirsAndTokens;
        for i=1:length(buildInfo.ModelRefs)
            pmPath=buildInfo.ModelRefs(i).Path;
            toks=regexptranslate('escape',specDirs.toks);
            dirs=regexptranslate('escape',specDirs.dirs);
            pmPath=regexprep(pmPath,toks,dirs);
            pmBuildInfo=load(fullfile(pmPath,'buildInfo.mat')).buildInfo;


            missingFile=cleanupProtectedModelBuildInfo(fullfile(pmPath,'buildInfo.mat'));
            if missingFile
                mdlLibIdx=find(contains(pmBuildInfo.BuildArgs.get('Key'),'MODELLIB'));
                staticLibs{end+1}=fullfile(pmPath,[pmBuildInfo.BuildArgs(mdlLibIdx).Value,'.*']);
            end
            staticLibs=[staticLibs;getProtectedModelStaticLibrary(pmBuildInfo)];
        end
    end

    function missingFile=cleanupProtectedModelBuildInfo(buildInfoMat)


        buildInfoStruct=load(buildInfoMat);
        sources=buildInfoStruct.buildInfo.getSourceFiles(true,true);
        removedSrcs={};
        missingFile=false;
        for i=1:length(sources)
            if~exist(sources{i},'file')
                [~,name,ext]=fileparts(sources{i});
                removedSrcs{end+1}=[name,ext];
                missingFile=true;
            end
        end
        buildInfoStruct.buildInfo.removeSourceFiles(removedSrcs);
        includes=buildInfoStruct.buildInfo.getIncludeFiles(true,true);
        removedIncsIdx=false(size(buildInfoStruct.buildInfo.Inc.Files));
        for i=1:length(includes)
            if~exist(includes{i},'file')
                removedIncsIdx(i)=true;
                missingFile=true;
            end
        end
        buildInfoStruct.buildInfo.Inc.Files(removedIncsIdx)=[];
        save(buildInfoMat,'-struct','buildInfoStruct');
    end

    function[sharedLibraryPath,sharedLibraryNameWithVersion]=getLocationOfFilePath(buildInfo,shlibExt)



        specDirs=buildInfo.Settings.getSpecialDirsAndTokens;
        toks=regexptranslate('escape',specDirs.toks);
        dirs=regexptranslate('escape',specDirs.dirs);
        [sharedLibraryPath,sharedLibraryNameWithVersion]=arrayfun(@(x)getSharedLibraryPath(x,shlibExt,toks,dirs),buildInfo.Other.Files,'un',0);
        sharedLibraryPath=sharedLibraryPath(~cellfun(@isempty,sharedLibraryPath));
        sharedLibraryNameWithVersion=sharedLibraryNameWithVersion(~cellfun(@isempty,sharedLibraryPath));
        for i=1:length(buildInfo.ModelRefs)
            mdlRefPath=buildInfo.ModelRefs(i).Path;
            mdlRefPath=regexprep(mdlRefPath,toks,dirs);
            mBuildInfo=load(fullfile(mdlRefPath,'buildInfo.mat')).buildInfo;
            [mSharedLibraryPath,mSharedLibraryNameWithVersion]=getLocationOfFilePath(mBuildInfo,shlibExt);
            if(~isempty(mSharedLibraryPath)&&~isempty(mSharedLibraryNameWithVersion))
                sharedLibraryPath=[sharedLibraryPath(:),mSharedLibraryPath(:)];
                sharedLibraryNameWithVersion=[sharedLibraryNameWithVersion(:),mSharedLibraryNameWithVersion(:)];
            end
        end
    end
    function[sharedLibraryPath,sharedLibraryNameWithVersion]=getSharedLibraryPath(fileInfo,shlibExt,toks,dirs)
        sharedLibraryPath='';
        sharedLibraryNameWithVersion=fileInfo.FileName;

        sharedLibraryName=regexpi(fileInfo.FileName,['([\w-]*).',shlibExt],'match');
        sharedLibraryFolder=regexprep(fileInfo.Path,toks,dirs);
        tempSharedLibraryPath=fullfile(sharedLibraryFolder,sharedLibraryNameWithVersion);
        if(~isempty(sharedLibraryName)&&exist(tempSharedLibraryPath,'file'))
            sharedLibraryPath=tempSharedLibraryPath;
        end
    end
    function updateProgressBarInfo(messageStr,percentCompletion)


        if modelSettingBackup.isKey([modelName,'.ProgressBarHandle'])
            setProgressBarInfo(modelSettingBackup([modelName,'.ProgressBarHandle']),...
            messageStr,percentCompletion);
        end
    end
end
