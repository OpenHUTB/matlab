function varargout=insertUnitConversionBlockAtPort(blockPath,portIdx,isInputPort)




    actionPerformed=DAStudio.message('Simulink:Unit:UnitConversionBlockInserted');
    try
        portsH=get_param(blockPath,'PortHandles');
        if(isInputPort)
            portH=portsH.Inport(portIdx);
        else
            portH=portsH.Outport(portIdx);
        end

        open_system(get_param(blockPath,'Parent'));
        obj=get_param(portH,'Object');
        obj.insertUnitConversionBlockOnPort(obj);
    catch error




        rethrow(error);
    end

    if nargout>0
        varargout{1}=actionPerformed;
    end
end
