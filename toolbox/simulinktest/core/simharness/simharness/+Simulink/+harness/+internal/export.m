function export(harnessOwner,harnessName,licenseCheckout,varargin)




    try

        [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);

        harnessStruct=Simulink.harness.internal.validateHarnessNameForOwner(systemModel,harnessOwnerHandle,harnessName);
    catch ME
        ME.throwAsCaller();
    end

    harnessName=harnessStruct.name;

    newName='';
    if nargin==5
        assert(strcmpi(varargin{1},'name'),...
        'Additional arguments to Simulink.harness.export must be name/value pair with new name');
        newName=varargin{2};
        if~ischar(newName)
            DAStudio.error('Simulink:Harness:InvalidName',harnessName);
        end
    elseif nargin~=3
        DAStudio.error('Simulink:Harness:NotEnoughInputArgs')
    end



    if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')&&strcmp(get_param(systemModel,'Dirty'),'on')
        DAStudio.error('Simulink:Harness:CannotExportWhenSystemModelDirty',...
        harnessName,systemModel);
    end

    if strcmp(harnessStruct.ownerType,'Simulink.SubSystem')&&~isempty(get_param(harnessOwnerHandle,'ReferencedSubsystem'))
        ssMdl=get_param(harnessOwnerHandle,'ReferencedSubsystem');
        if bdIsLoaded(ssMdl)&&strcmp(get_param(ssMdl,'Dirty'),'on')
            DAStudio.error('Simulink:Harness:CannotExportWhenSystemModelDirty',...
            harnessName,systemModel);
        end
    end

    if Simulink.internal.isArchitectureModel(systemModel)

        DAStudio.error('Simulink:Harness:CannotExportZCModelHarness',harnessName,systemModel);
    end

    wasOpen=harnessStruct.isOpen;
    saveExtBeforeExport=Simulink.harness.internal.isSavedIndependently(systemModel);

    outName='';
    if slsvTestingHook('UnifiedHarnessBackendMode')==0&&...
        rmidata.isExternal(systemModel)


        try
            Simulink.harness.internal.load(harnessOwner,harnessName,licenseCheckout);
            if rmidata.harnessDiagramHasLinks(harnessName)
                if~isempty(newName)
                    [destinationFolder,outName,~]=fileparts(newName);
                    if isempty(destinationFolder)

                        destinationFolder=pwd;
                    end
                else
                    outName=harnessName;
                    destinationFolder=pwd;
                end
                destinationBaseName=fullfile(destinationFolder,outName);

                rmidata.exportHarnessLinksToFile(systemModel,harnessStruct.uuid,destinationBaseName);
            end
        catch

        end
    end

    try
        Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'export',true,newName);


        Simulink.harness.internal.closeHarnessDialogs(systemModel);
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            Simulink.harness.internal.exportBDHarness(systemModel,harnessName,newName,licenseCheckout);
        else
            Simulink.harness.internal.exportBlockHarness(systemModel,harnessName,newName,...
            harnessOwnerHandle,licenseCheckout);
        end
    catch me
        if~wasOpen
            close_system(harnessName,0);
        end
        me.throwAsCaller;
    end



    Simulink.harness.internal.refreshHarnessListDlg(harnessStruct.model);


    if~isempty(outName)
        rmidata.exportHarnessLinksToFile(outName);
    end

    if saveExtBeforeExport
        Simulink.harness.internal.warn({'Simulink:Harness:IndHarnessDetachWarning',...
        harnessName,Simulink.harness.internal.getHarnessInfoFileName(systemModel)});
    else
        Simulink.harness.internal.warn({'Simulink:Harness:ExportDeleteHarnessFromSystemModel',...
        harnessName,systemModel});
    end
end
