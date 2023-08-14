function ReplaceContinuousIntegrator(block,h)





    if~doUpdate(h)

        modelVersion=num2str(get_param(bdroot(block),'VersionLoaded'));
        isR14sp3OrPlus=strncmp(modelVersion,'6.3',3);
        isR2006aOrPlus=strncmp(modelVersion,'6.4',3);
        usingLevelReset=strcmp(get_param(block,'ExternalReset'),'level');

        if(isR14sp3OrPlus||isR2006aOrPlus)&&usingLevelReset

            reason=DAStudio.message('SimulinkBlocks:upgrade:levelResetContIntegrator');
            appendTransaction(h,block,reason,{});
        end
    end

end
