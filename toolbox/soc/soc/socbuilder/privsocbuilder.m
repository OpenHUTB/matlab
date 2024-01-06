function privsocbuilder(varargin)

    try
        narginchk(1,1);
        sys=varargin{1};
    catch
        error(message('soc:workflow:Launch_InvalidInput'));
    end


    soc.internal.validateModelName(sys);
    if isstring(sys)
        sys=char(sys);
    end
    if~bdIsLoaded(sys)
        load_system(sys);
    end


    hwBoard=get_param(sys,'HardwareBoard');
    hwObj=codertarget.targethardware.getTargetHardware(hwBoard);
    switch hwBoard
    case codertarget.internal.getTargetHardwareNamesForSoC
        workflow=soc.ui.SoCGenWorkflow(varargin{:});
        fmcIOBlks=workflow.getFMCIOBlocks(workflow.sys,workflow.FPGAModel);
        if~isempty(fmcIOBlks)

            if~strcmpi(soc.internal.getFamily(sys),'rfsoc')&&...
                strcmp(libinfo(fmcIOBlks{1},'searchdepth',0).ReferenceBlock,'xilinxrfsoclib/RF Data Converter')
                error(message('soc_shared:msgs:FMCIONotSupportedForGen',hwBoard,fmcIOBlks{1}));

            elseif strcmpi(soc.internal.getFamily(sys),'rfsoc')&&...
                ~strcmp(libinfo(fmcIOBlks{1},'searchdepth',0).ReferenceBlock,'xilinxrfsoclib/RF Data Converter')
                error(message('soc_shared:msgs:FMCIONotSupportedForGen',hwBoard,fmcIOBlks{1}));
            end
        end
    case codertarget.internal.getCustomHardwareBoardNamesForSoC

        if hwObj.SupportsOnlySimulation
            error(message('soc_shared:msgs:SimOnlyBoardNotSupportedForGen',hwBoard));
        end
        workflow=soc.ui.SoCGenWorkflow(varargin{:});


        fmcIOBlks=workflow.getFMCIOBlocks(workflow.sys,workflow.FPGAModel);
        if~isempty(fmcIOBlks)
            if~strcmpi(soc.internal.getFamily(sys),'rfsoc')||...
                ~strcmp(libinfo(fmcIOBlks{1},'searchdepth',0).ReferenceBlock,'xilinxrfsoclib/RF Data Converter')
                error(message('soc_shared:msgs:FMCIONotSupportedForGen',hwBoard,fmcIOBlks{1}));
            end
        end
    case 'Custom Hardware Board'
        error(message('soc:msgs:CustomHardwareBoardNotSupportedForGen'));
    case 'STM32 Nucleo F767ZI'
        error(message('soc:msgs:UsebaremetalBuilder'));
    otherwise
        error(message('soc:msgs:BoardNotSupported',hwBoard));
    end
    launch(workflow);
end