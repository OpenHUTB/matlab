function retVal=getMdlrefIsCodeVariant(mdlBlk)





    try
        retVal=strcmp(get_param(mdlBlk,'HasVariants'),'on')==1;

    catch exception
        switch exception.identifier
        case{'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
            DAStudio.error('Simulink:tools:GetMdlRefVariantInfoWrongBlockType',mfilename);
        otherwise
            rethrow(exception);
        end
    end

