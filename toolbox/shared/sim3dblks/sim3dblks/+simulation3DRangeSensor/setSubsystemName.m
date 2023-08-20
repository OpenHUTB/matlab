function setSubsystemName(block)
    blocks=Simulink.findBlocksOfType(block,'MATLABSystem');
    for i=1:length(blocks)
        if strcmp(get_param(blocks(i),"Name"),"Simulation 3D Range Sensor")
            continue;
        end
        set_param(blocks(i),"Name",get_param(gcb,"Name"));
    end
end