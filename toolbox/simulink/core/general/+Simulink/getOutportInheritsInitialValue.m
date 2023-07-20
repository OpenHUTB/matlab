function retVal=getOutportInheritsInitialValue(outportBlk)






    try
        if(~strcmp(get_param(outportBlk,'BlockType'),'Outport'))
            retVal=false;
        else
            retVal=strcmp(get_param(outportBlk,'InheritsInitialValueAfterUpdateDiagram'),'on');
        end
    catch exception
        switch exception.identifier
        case{'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
            DAStudio.error('Simulink:tools:GetOutportInfoWrongBlockType',mfilename);
        otherwise
            rethrow(exception);
        end
    end
