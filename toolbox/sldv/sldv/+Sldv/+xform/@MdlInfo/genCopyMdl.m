function genCopyMdl(obj,openCopyModel,copyMdlFileOpts,copyMdlParams)




    if~obj.WorkOnCopy

        return;
    end

    if isa(copyMdlFileOpts,'Sldv.Options')
        FilePathBlockReplacementModel=get(copyMdlFileOpts,'BlockReplacementModelFileName');
        MakeOutputFilesUnique=get(copyMdlFileOpts,'MakeOutputFilesUnique');

        fullPath=Sldv.utils.settingsFilename(...
        FilePathBlockReplacementModel,...
        MakeOutputFilesUnique,...
        '$ModelExt$',obj.OrigModelH,false,true,copyMdlFileOpts);

        [~,newName]=fileparts(fullPath);
        if~strcmp(get(copyMdlFileOpts,'BlockReplacement'),'on')&&...
            length(newName)>63
            tempOpts=copyMdlFileOpts.deepCopy;
            origModelName=get_param(obj.OrigModelH,'Name');
            count=1;
            while length(newName)>63
                tempOpts.BlockReplacementModelFileName=origModelName(1:end-count);
                FilePathBlockReplacementModel=get(tempOpts,'BlockReplacementModelFileName');
                fullPath=Sldv.utils.settingsFilename(...
                FilePathBlockReplacementModel,...
                'on',...
                '$ModelExt$',obj.OrigModelH,false,true,tempOpts);
                [~,newName]=fileparts(fullPath);
                count=count+1;
            end
        end

        if isempty(fullPath)
            error(message('Sldv:xform:MdlInfo:genCopyMdl:CopyModel',get_param(obj.OrigModelH,'Name')));
        end
    else
        MakeOutputFilesUnique='on';
        fullPath=copyMdlFileOpts;
    end

    [~,copymodel]=fileparts(fullPath);
    copymodel=sldvshareprivate('cmd_check_for_open_models',copymodel,MakeOutputFilesUnique,false);
    if isempty(copymodel)
        error(message('Sldv:xform:MdlInfo:genCopyMdl:CopyModelOpen',get_param(obj.OrigModelH,'Name')));
    end

    copymodelFullPath=fullPath;

    currentloc=get_param(obj.OrigModelH,'location');

    if strcmp(get_param(obj.OrigModelH,'isHarness'),'on')
        try













            ownerFilePath=get_param(obj.OrigModelH,'OwnerFileName');
            [copyHarnessDir,copyHarnessName,copyHarnessExt]=fileparts(copymodelFullPath);
            if isempty(copyHarnessExt)
                copyHarnessExt='.slx';
                copymodelFullPath=[copymodelFullPath,copyHarnessExt];
            end
            newOwnerName=[copyHarnessName,'_Owner'];
            snapshotOwnerExt='.slx';
            newOwnerFilePath=[fullfile(copyHarnessDir,newOwnerName),snapshotOwnerExt];





            if exist(newOwnerFilePath,'file')||(length(newOwnerName)<=namelengthmax&&bdIsLoaded(newOwnerName))
                switch(get(copyMdlFileOpts,'MakeOutputFilesUnique'))
                case 'on'
                    newOwnerFilePath=Sldv.utils.uniqueFileNameUsingNumbers(copyHarnessDir,[newOwnerName,snapshotOwnerExt],snapshotOwnerExt);
                    [~,newOwnerName,~]=fileparts(newOwnerFilePath);
                end
            end

            hOwnerBDName=get_param(obj.OrigModelH,'OwnerBDName');
            saveModelSnapshot(hOwnerBDName,newOwnerFilePath);

            status=fileattrib(newOwnerFilePath,'+w');
            if~status
                [~,oldOwnerName,~]=fileparts(ownerFilePath);
                error(message('Sldv:xform:MdlInfo:genCopyMdl:CopyModelOpenWrite',oldOwnerName));
            end
            Sldv.load_system_no_callbacks(newOwnerFilePath);

            hInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(obj.OrigModelH);
            newOwnerBlockPath=[newOwnerName,hInfo.ownerFullPath(length(hInfo.model)+1:end)];
            Simulink.harness.set(newOwnerBlockPath,hInfo.name,'Name',copyHarnessName);
            save_system(newOwnerName);


            origWarning=warning('off','Simulink:Harness:ExportDeleteHarnessFromSystemModel');

            Simulink.harness.export(newOwnerBlockPath,copyHarnessName,'Name',copymodelFullPath);




            Sldv.load_system(newOwnerFilePath);

            save_system(newOwnerName);
            warning(origWarning.state,origWarning.identifier);


            status=fileattrib(copymodelFullPath,'+w');
            if~status
                error(message('Sldv:xform:MdlInfo:genCopyMdl:CopyModelOpenWrite',get_param(obj.OrigModelH,'Name')));
            end

            Sldv.load_system_no_callbacks(copymodelFullPath);



            if strcmp(hInfo.ownerType,'Simulink.BlockDiagram')&&hInfo.synchronizationMode~=2


                mdlBlk=find_system(copyHarnessName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
                mdlBlk=mdlBlk{1};
                bdType=get_param(hInfo.ownerHandle,'BlockDiagramType');
                if isequal(bdType,'subsystem')



                    if strcmp(get_param(mdlBlk,'ReferencedSubsystem'),newOwnerName)
                        set_param(mdlBlk,'ReferencedSubsystem',hInfo.model);
                    end
                else
                    if strcmp(get_param(mdlBlk,'ModelNameDialog'),newOwnerName)
                        set_param(mdlBlk,'ModelNameDialog',hInfo.model);
                    end
                end
            end



            Sldv.close_system(newOwnerName,0,'SkipCloseFcn',true);
        catch Mex
            newExc=MException('Sldv:xform:MdlInfo:genCopyMdl:CopyModelLoad',...
            'The model ''%s'' cannot be copied.',...
            get_param(obj.OrigModelH,'Name'));
            newExc=newExc.addCause(Mex);
            throw(newExc);
        end
    else
        originalmdlName=get_param(obj.OrigModelH,'name');
        [~,~,ext]=fileparts(copymodelFullPath);
        slInternal(['snapshot_',ext(2:end)],originalmdlName,copymodelFullPath);

        status=fileattrib(copymodelFullPath,'+w');
        if~status
            error(message('Sldv:xform:MdlInfo:genCopyMdl:CopyModelOpenWrite',get_param(obj.OrigModelH,'Name')));
        end

        try
            Sldv.load_system_no_callbacks(copymodelFullPath);
        catch Mex
            newExc=MException('Sldv:xform:MdlInfo:genCopyMdl:CopyModelLoad',...
            'The model ''%s'' cannot be copied.',...
            get_param(obj.OrigModelH,'Name'));



            causeEx=MSLException([],Mex.identifier,Mex.message);
            newExc=newExc.addCause(causeEx);
            throw(newExc);
        end
    end

    obj.ModelH=get_param(copymodel,'Handle');

    replaceActiveConfigSetRefWithCopy(obj.ModelH);

    if~isempty(copyMdlParams)
        parametersToSet=fieldnames(copyMdlParams);
        for i=1:length(parametersToSet)
            obj.MdlOrigParams.(parametersToSet{i})=get_param(obj.ModelH,parametersToSet{i});
            set_param(obj.ModelH,parametersToSet{i},copyMdlParams.(parametersToSet{i}));
        end
    end


    set_param(obj.ModelH,'SignalLabelMismatchMsg','none');

    set_param(obj.ModelH,'location',[currentloc(1),(currentloc(2)+currentloc(4))/2,...
    currentloc(3),currentloc(4)+(currentloc(4)-currentloc(2))/2]);


    sldv.code.slcc.internal.fixReplacementCustomCodeSettings(obj.OrigModelH,obj.ModelH);

    if openCopyModel
        open_system(obj.ModelH);
    end
end

function replaceActiveConfigSetRefWithCopy(modelH)
    enableAllProps=true;
    origCS=getActiveConfigSet(modelH);

    Sldv.utils.replaceConfigSetRefWithCopy(modelH,enableAllProps);
    detachConfigSet(modelH,origCS.Name);
end

function saveModelSnapshot(hOwnerBDName,newOwnerFilePath)




    needsCleanup=...
    Simulink.harness.internal.convertToInternalHarnessesForExportToVersion(hOwnerBDName);
    harnessCleanupObj=...
    onCleanup(@()Simulink.harness.internal.postExportToVersionCleanup(hOwnerBDName,needsCleanup));
    slInternal('snapshot_slx',hOwnerBDName,newOwnerFilePath);
end


