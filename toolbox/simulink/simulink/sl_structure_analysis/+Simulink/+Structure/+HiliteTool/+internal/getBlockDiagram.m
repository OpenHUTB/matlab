

function BlockDiagram=getBlockDiagram(simHandle)
    try
        ParentName=get_param(simHandle,'Parent');
    catch
        error(message('Simulink:HiliteTool:ExpectedBDHandle'));
    end

    if(isempty(ParentName))
        BlockDiagram=simHandle;
        return;
    else

        ParentHandle=get_param(ParentName,'Handle');
        BlockDiagram=Simulink.Structure.HiliteTool.internal.getBlockDiagram(ParentHandle);
    end
end