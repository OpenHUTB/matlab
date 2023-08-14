function move(harnessOwner,harnessName,varargin)

    narginchk(2,inf);

    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        ME.throwAsCaller();
    end

    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);



    if harnessStruct.isOpen
        DAStudio.error('Simulink:Harness:CannotMoveWhenHarnessIsOpen',harnessName);
    end


    if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
        &&activeHarness.ownerHandle~=harnessStruct.ownerHandle
        DAStudio.error('Simulink:Harness:CannotMoveWhenATestingHarnessIsActive',harnessName);
    end


    if harnessStruct.canBeOpened==false&&harnessStruct.isOpen==false
        DAStudio.error('Simulink:Harness:CannotMoveWhenSystemIsBusy',harnessName);
    end





    newName='';
    destHandle=-1;
    if numel(varargin)==1
        destHandle=get_param(varargin{1},'Handle');
    elseif numel(varargin)>1
        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;

        p.addParameter('Name',newName,@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addParameter('DestinationOwner',destHandle,@(x)validateattributes(x,{'char'},{'real'}));
        p.parse(varargin{:});
        newName=p.Results.Name;




        if strcmp(harnessName,newName)
            newName='';
        end
        if~isempty(newName)
            Simulink.harness.internal.validateHarnessName(harnessStruct.model,harnessStruct.ownerFullPath,newName);
        end

        if p.Results.DestinationOwner~=-1

            destHandle=get_param(p.Results.DestinationOwner,'Handle');
        elseif~isempty(newName)


            destHandle=harnessStruct.ownerHandle;
        else

            destHandle=-1;
        end
    end

    if destHandle==-1&&strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        DAStudio.error('Simulink:Harness:CannotMoveBDHarness',harnessName);
    end



    if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))
        DAStudio.error('Simulink:Harness:CannotMoveHarnessWhenLibIsLocked',systemModel);
    end

    Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'move',true);



    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
        Simulink.harness.internal.moveHarness(systemModel,harnessStruct.name,-1,destHandle,newName);
    else
        Simulink.harness.internal.moveHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,destHandle,newName);
    end


    if destHandle~=-1
        destMdl=Simulink.harness.internal.getBlockDiagram(destHandle);
        Simulink.harness.internal.refreshHarnessListDlg(destMdl);
    end
    Simulink.harness.internal.refreshHarnessListDlg(harnessStruct.model);
end
