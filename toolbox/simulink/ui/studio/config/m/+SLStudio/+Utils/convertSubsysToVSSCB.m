function convertSubsysToVSSCB(cbinfo)



    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blockH=block.handle;
        clear block;

        if ishandle(blockH)
            myException='';


            SubsysToVariantStage=Simulink.output.Stage(DAStudio.message('Simulink:Variants:ConvertToVariant'),...
            'ModelName',get_param(bdroot(blockH),'Name'),'UIMode',true);%#ok<NASGU>

            try
                Simulink.VariantManager.convertToVariant(blockH);
            catch myException
            end

            if~isempty(myException)
                slprivate('pushExceptionOnNagController',myException,...
                '',...
                get_param(bdroot(blockH),'Name'),...
                true);

            end

            clear SubsysToVariantStage;
        end
    end
end