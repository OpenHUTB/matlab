




classdef VSSToVASConverter<handle

    properties(Access='private')
m_vssBlkHandle



        m_folderPathUserInput;
        m_folderAbsPathToKeepNewSSRefFiles;

        m_modelChoiceBlkHandles=[];
        m_modelChoiceBlkLinkedFileNames={};

        m_ssRefChoiceBlkHandles=[];
        m_ssRefChoiceBlkLinkedFileNames={};

        m_ssChoiceBlkHandles=[];

        m_activeVariantBlkHandle=-1;
    end

    methods(Static,Access='public')



        function err=convertToVariantAssemblyInternal(vssBlkPathOrHandle,folderPathToKeepNewSSRefFiles)

            if ischar(vssBlkPathOrHandle)
                vssBlkHandle=getSimulinkBlockHandle(vssBlkPathOrHandle);
            else
                vssBlkHandle=vssBlkPathOrHandle;
            end

            if~isscalar(vssBlkHandle)||~ishandle(vssBlkHandle)
                err=MSLException(message('Simulink:Variants:InvalidBlockPathOrHandle'));
                return;
            end




            if~strcmp(get_param(vssBlkHandle,'BlockType'),'SubSystem')||...
                strcmp(get_param(vssBlkHandle,'Variant'),'off')||...
                ~isempty(get_param(vssBlkHandle,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName')))
                err=MSLException(message('Simulink:Variants:ConvertSuppForVSSOnly'));
                return;
            end



            if strcmpi(get_param(vssBlkHandle,'SimulinkSubDomain'),'architecture')||...
                strcmpi(get_param(vssBlkHandle,'SimulinkSubDomain'),'softwarearchitecture')
                err=MSLException(message('Simulink:Variants:ConvertNotSuppForSysArch'));
                return;
            end



            if nargin==1
                folderPathToKeepNewSSRefFiles=0;
            elseif nargin==2
                if~ischar(folderPathToKeepNewSSRefFiles)

                    err=MSLException(message('Simulink:Variants:InvalidFolderPath'));
                    return;
                end
            end

            obj=Simulink.variant.vas.VSSToVASConverter(vssBlkHandle,folderPathToKeepNewSSRefFiles);

            ex=MSLException(message('Simulink:Variants:UnableToConvert',getfullname(vssBlkHandle)));

            err=obj.validateVSSBlockForConversion();
            if~isempty(err)
                err=ex.addCause(err);
                return;
            end

            err=obj.convertSSChoicesToSSRef();
            if~isempty(err)
                err=ex.addCause(err);
                return;
            end

            err=obj.setVariantChoicesSpecifierAndResetActiveVariant();
            if~isempty(err)
                err=ex.addCause(err);
                return;
            end
        end


    end

    methods(Access='public')


        function obj=VSSToVASConverter(vssBlkHandle,folderPathToKeepNewSSRefFiles)
            obj.m_vssBlkHandle=vssBlkHandle;
            choices=get_param(obj.m_vssBlkHandle,'Variants');
            for idx=1:length(choices)
                choiceBlkHandle=get_param(choices(idx).BlockName,'Handle');
                switch get_param(choiceBlkHandle,'BlockType')
                case 'SubSystem'
                    if isempty(get_param(choiceBlkHandle,'ReferencedSubsystem'))
                        obj.m_ssChoiceBlkHandles=[obj.m_ssChoiceBlkHandles;choiceBlkHandle];
                    else
                        obj.m_ssRefChoiceBlkHandles=[obj.m_ssRefChoiceBlkHandles;choiceBlkHandle];
                    end
                case 'ModelReference'
                    obj.m_modelChoiceBlkHandles=[obj.m_modelChoiceBlkHandles;choiceBlkHandle];
                otherwise
                    error('Invalid variant choice type');
                end
            end

            obj.m_folderPathUserInput=folderPathToKeepNewSSRefFiles;


            if ischar(folderPathToKeepNewSSRefFiles)&&...
                slInternal('VASFilesystemHelper_IsRelativePath',folderPathToKeepNewSSRefFiles)
                folderPathToKeepNewSSRefFiles=fullfile(pwd,folderPathToKeepNewSSRefFiles);
            end
            obj.m_folderAbsPathToKeepNewSSRefFiles=folderPathToKeepNewSSRefFiles;




            if(~isempty(choices))
                activeVariantBlkPath=get_param(obj.m_vssBlkHandle,'ActiveVariantBlock');
                obj.m_activeVariantBlkHandle=get_param(activeVariantBlkPath,'Handle');
            end
        end







        function err=validateVSSBlockForConversion(this)
            err=validateVSSNotInsideLockedLib(this);
            if~isempty(err)
                return;
            end

            err=validateVSSNotLinkedToLib(this);
            if~isempty(err)
                return;
            end

            err=validateVariantControlMode(this);
            if~isempty(err)
                return;
            end

            err=validateModelVariantChoices(this);
            if~isempty(err)
                return;
            end

            err=validateSubsysRefVariantChoices(this);
            if~isempty(err)
                return;
            end

            err=validateNonRefSubsysVariantChoices(this);
            if~isempty(err)
                return;
            end

            err=validateUserInputOfFolderPathToKeepNewSSRefFiles(this);
            if~isempty(err)
                return;
            end

            err=validateNoSubsysRefLoadedWithSameSubsysBlkName(this);
        end







        function err=convertSSChoicesToSSRef(this)
            err='';
            ssChoiceBlkHandles=this.m_ssChoiceBlkHandles;
            for idx=1:length(ssChoiceBlkHandles)
                ssChoiceBlkHandle=ssChoiceBlkHandles(idx);
                ssRefFileName=Simulink.variant.vas.VASUtils.getAllowedName(get_param(ssChoiceBlkHandle,'Name'));
                ssRefFileAbsPath=fullfile(this.m_folderAbsPathToKeepNewSSRefFiles,ssRefFileName);
                try
                    [status,msg]=SubsystemReferenceConverter.createSubsystemReference(ssChoiceBlkHandle,ssRefFileAbsPath,1);
                    if~status
                        error(msg);
                    end
                catch ex
                    err=ex;
                    return;
                end
            end
        end










        function err=setVariantChoicesSpecifierAndResetActiveVariant(this)
            err=this.updateChoiceBlkNameAndVariantControlWithLinkedFileName();
            if~isempty(err)
                return;
            end

            err=this.setVariantChoicesSpecifier();
            if~isempty(err)
                warndlg(Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(err),...
                DAStudio.message('Simulink:VariantBlockPrompts:WarnSetParamVCS'),'modal');
                err='';
                return;
            end

            err=this.resetActiveVariant();
        end


    end

    methods(Access='private')


        function err=validateVSSNotInsideLockedLib(this)
            err='';
            bdName=bdroot(this.m_vssBlkHandle);
            if strcmp(get_param(bdName,'BlockDiagramType'),'library')&&...
                strcmp(get_param(bdName,'Lock'),'on')
                err=MSLException(message('Simulink:Variants:VSSInsideLockedLib'));
            end
        end




        function err=validateVSSNotLinkedToLib(this)
            err='';
            if~strcmp(get_param(this.m_vssBlkHandle,'LinkStatus'),'none')
                err=MSLException(message('Simulink:Variants:VSSBlkLinkedToLib'));
            end
        end




        function err=validateVariantControlMode(this)
            err='';
            if~strcmp(get_param(this.m_vssBlkHandle,'VariantControlMode'),'label')
                err=MSLException(message('Simulink:Variants:VCMNotLabel'));
            end
        end




        function err=validateModelVariantChoices(this)
            this.m_modelChoiceBlkLinkedFileNames=get_param(this.m_modelChoiceBlkHandles,'ModelName');
            err=this.CheckIfMultipleChoiceBlksLinkedToSameFile(...
            this.m_modelChoiceBlkHandles,this.m_modelChoiceBlkLinkedFileNames,'Model');
        end




        function err=validateSubsysRefVariantChoices(this)
            this.m_ssRefChoiceBlkLinkedFileNames=get_param(this.m_ssRefChoiceBlkHandles,'ReferencedSubsystem');
            err=this.CheckIfMultipleChoiceBlksLinkedToSameFile(...
            this.m_ssRefChoiceBlkHandles,this.m_ssRefChoiceBlkLinkedFileNames,'Subsystem Reference');
        end




        function err=validateNonRefSubsysVariantChoices(this)
            err=validateNonRefSubsysForConvertToSubsysRef(this);
            if~isempty(err)
                return;
            end

            err=validateNonRefSubsysForUniqueModifiedBlockName(this);
        end




        function err=validateNonRefSubsysForConvertToSubsysRef(this)
            err='';
            nSSChoices=length(this.m_ssChoiceBlkHandles);
            unsupSSChoiceBlkHandles=zeros(nSSChoices,1);
            unsupSSChoiceCounter=0;
            for idx=1:nSSChoices
                choiceBlkHandle=this.m_ssChoiceBlkHandles(idx);
                [stat,~]=SSRefUtil.passesSSRefChecksForConversion(choiceBlkHandle);
                if~stat
                    unsupSSChoiceCounter=unsupSSChoiceCounter+1;
                    unsupSSChoiceBlkHandles(unsupSSChoiceCounter)=choiceBlkHandle;
                end
            end
            unsupSSChoiceBlkHandles(unsupSSChoiceCounter+1:end)=[];

            if~isempty(unsupSSChoiceBlkHandles)
                err=MSLException(message('Simulink:Variants:CannotConvertSSToSSRef',...
                this.getListOfBlockPathsAsCharVector(unsupSSChoiceBlkHandles)));
            end
        end






        function err=validateNonRefSubsysForUniqueModifiedBlockName(this)
            err='';
            ssChoiceBlkNames=get_param(this.m_ssChoiceBlkHandles,'Name');
            if ischar(ssChoiceBlkNames)
                ssChoiceBlkNames={ssChoiceBlkNames};
            end
            newSSRefFileNames=cellfun(@(name)Simulink.variant.vas.VASUtils.getAllowedName(name),...
            ssChoiceBlkNames,'UniformOutput',false);

            [uniqueSSRefFileNames,~,idxActual]=unique(newSSRefFileNames);
            if length(uniqueSSRefFileNames)~=length(newSSRefFileNames)
                for idx=1:length(uniqueSSRefFileNames)
                    choiceBlkHandlesWithSameModifiedName=this.m_ssChoiceBlkHandles(idxActual==idx);
                    ssRefFileName=uniqueSSRefFileNames{idx};
                    if length(choiceBlkHandlesWithSameModifiedName)>1
                        break;
                    end
                end
                err=MSLException(message('Simulink:Variants:SSWithSameModifiedName',...
                ssRefFileName,this.getListOfBlockPathsAsCharVector(choiceBlkHandlesWithSameModifiedName)));
            end
        end




        function err=validateUserInputOfFolderPathToKeepNewSSRefFiles(this)
            err='';
            folderAbsPath=this.m_folderAbsPathToKeepNewSSRefFiles;

            if isempty(this.m_ssChoiceBlkHandles)
                if ischar(folderAbsPath)

                    DAStudio.warning('Simulink:Variants:FolderPathUnused',...
                    this.m_folderPathUserInput,getfullname(this.m_vssBlkHandle));
                end
                return;
            end



            if~folderAbsPath

                err=MSLException(message('Simulink:Variants:FolderPathReq'));
                return;
            end



            if~isfolder(folderAbsPath)
                try
                    mkdir(folderAbsPath);
                    addpath(folderAbsPath);
                catch ex
                    err=ex;
                    return;
                end
            end
        end





        function err=validateNoSubsysRefLoadedWithSameSubsysBlkName(this)
            err='';
            for i=1:length(this.m_ssChoiceBlkHandles)
                choiceBlkName=Simulink.variant.vas.VASUtils.getAllowedName(get_param(this.m_ssChoiceBlkHandles(i),'Name'));
                [isLoaded,loadedFilePath]=SRDialogHelper.findLoadedFile(choiceBlkName);
                if isLoaded&&...
                    ~strcmp(loadedFilePath,fullfile(this.m_folderAbsPathToKeepNewSSRefFiles,[choiceBlkName,'.',get_param(0,'ModelFileFormat')]))
                    err=MSLException(message('Simulink:Variants:ModelWithSubsysBlkNameLoaded',...
                    getfullname(this.m_ssChoiceBlkHandles(i)),choiceBlkName,loadedFilePath));
                    return;
                end
            end
        end




        function err=updateChoiceBlkNameAndVariantControlWithLinkedFileName(this)
            err='';
            choiceBlkHandles=[this.m_modelChoiceBlkHandles;this.m_ssRefChoiceBlkHandles;this.m_ssChoiceBlkHandles];
            for idx=1:length(choiceBlkHandles)
                choiceBlkHandle=choiceBlkHandles(idx);
                if strcmp(get_param(choiceBlkHandle,'BlockType'),'ModelReference')
                    fileName=get_param(choiceBlkHandle,'ModelName');
                else
                    assert(strcmp(get_param(choiceBlkHandle,'BlockType'),'SubSystem'))
                    fileName=get_param(choiceBlkHandle,'ReferencedSubsystem');
                    assert(~isempty(fileName));
                end

                try
                    set_param(choiceBlkHandle,'VariantControl',fileName)
                    set_param(choiceBlkHandle,'Name',fileName)
                catch ex
                    err=ex;
                end
            end
        end




        function err=setVariantChoicesSpecifier(this)
            err='';
            choiceBlkHandles=[this.m_modelChoiceBlkHandles;this.m_ssRefChoiceBlkHandles;this.m_ssChoiceBlkHandles];
            choiceBlkNames=get_param(choiceBlkHandles,'Name');
            if~iscell(choiceBlkNames)
                assert(ischar(choiceBlkNames));
                choiceBlkNames={choiceBlkNames};
            end
            choiceBlkNames=sort(choiceBlkNames);
            choiceBlkNames=cellfun(@(choiceBlkName)['''',choiceBlkName,''''],...
            choiceBlkNames,'UniformOutput',false);
            choiceSelectorToSet=join(choiceBlkNames,', ');
            choiceSelectorToSet=['{',choiceSelectorToSet{:},'}'];

            try
                slInternal('SetParamChoiceSelectorForConversion',getfullname(this.m_vssBlkHandle),choiceSelectorToSet);
            catch ex
                err=ex;
            end
        end




        function err=resetActiveVariant(this)
            err='';
            try






                if(this.m_activeVariantBlkHandle~=-1)
                    activeVariantBlkName=get_param(this.m_activeVariantBlkHandle,'Name');
                    set_param(this.m_vssBlkHandle,'LabelModeActiveChoice',activeVariantBlkName)
                end
            catch ex
                err=ex;
            end
        end




        function err=CheckIfMultipleChoiceBlksLinkedToSameFile(this,choiceBlkHandles,choiceBlksLinkedFileNames,refBlkTypeName)
            err='';
            if ischar(choiceBlksLinkedFileNames)
                choiceBlksLinkedFileNames={choiceBlksLinkedFileNames};
            end
            [uniqueLinkedFileNames,~,idxActual]=unique(choiceBlksLinkedFileNames);
            if length(uniqueLinkedFileNames)~=length(choiceBlksLinkedFileNames)
                for idx=1:length(uniqueLinkedFileNames)
                    choiceBlkHandlesLinkedToSameFilename=choiceBlkHandles(idxActual==idx);
                    [~,fileName,~]=fileparts(uniqueLinkedFileNames{idx});
                    if length(choiceBlkHandlesLinkedToSameFilename)>1
                        break;
                    end
                end
                err=MSLException(message('Simulink:Variants:MultiChoiceLinkedToSameFile',...
                refBlkTypeName,fileName,this.getListOfBlockPathsAsCharVector(choiceBlkHandlesLinkedToSameFilename)));
            end
        end




        function listOfBlkPathsChar=getListOfBlockPathsAsCharVector(~,blkHandles)
            blkPaths=cell(size(blkHandles));
            for idx=1:length(blkHandles)
                blkPaths{idx}=getfullname(blkHandles(idx));
            end
            listOfBlkPathsChar=join(sort(blkPaths),[', ',newline]);
            listOfBlkPathsChar=[newline,listOfBlkPathsChar{:}];
        end


    end

end


