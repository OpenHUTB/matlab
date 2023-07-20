function clone(harnessOwner,harnessName,varargin)

    narginchk(2,inf);

    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        ME.throwAsCaller();
    end


    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);


    if harnessStruct.isOpen
        DAStudio.error('Simulink:Harness:CannotCloneAsTestHarnessIsOpen',harnessName);
    end


    if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
        &&activeHarness.ownerHandle~=harnessStruct.ownerHandle
        DAStudio.error('Simulink:Harness:CannotCloneWhenATestingHarnessIsActive',harnessName);
    end


    if harnessStruct.canBeOpened==false&&harnessStruct.isOpen==false
        DAStudio.error('Simulink:Harness:CannotCloneWhenSystemIsBusy',harnessName);
    end




    newName='';
    destPath=-1;
    if numel(varargin)==1
        newName=varargin{1};
        destPath=-1;
        Simulink.harness.internal.validateHarnessName(harnessStruct.model,harnessStruct.ownerFullPath,newName);
    elseif numel(varargin)>1
        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;

        p.addParameter('Name',newName,@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addParameter('DestinationOwner',destPath,@(x)validateattributes(x,{'char'},{'real'}));
        p.parse(varargin{:});
        if p.Results.DestinationOwner~=-1
            destPath=get_param(p.Results.DestinationOwner,'Handle');
        else
            destPath=-1;
        end
        newName=p.Results.Name;
        if~isempty(newName)
            Simulink.harness.internal.validateHarnessName(harnessStruct.model,harnessStruct.ownerFullPath,newName);
        end
    end


    if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))
        DAStudio.error('Simulink:Harness:CannotCloneHarnessWhenLibIsLocked',systemModel);
    end

    Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'clone',false);


    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        Simulink.harness.internal.cloneHarness(systemModel,-1,harnessStruct.name,destPath,newName);
    else
        Simulink.harness.internal.cloneHarness(systemModel,harnessStruct.ownerHandle,harnessStruct.name,destPath,newName);
    end


    if destPath==-1
        destMdl=harnessStruct.model;
    else
        destMdl=Simulink.harness.internal.getBlockDiagram(destPath);
    end
    Simulink.harness.internal.refreshHarnessListDlg(destMdl);

end
