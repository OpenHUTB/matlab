function flag=isOutputPortReal(blockH)



    flag=false;

    oSigType=get_param(blockH,'OutputSignalType');
    if strcmp(oSigType,'real')
        flag=true;
    elseif strcmp(oSigType,'auto')
        portHs=get_param(blockH,'PortHandles');
        flag=~get_param(portHs.Outport,'CompiledPortComplexSignal');
    end
end