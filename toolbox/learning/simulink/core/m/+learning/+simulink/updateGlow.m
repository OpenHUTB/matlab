function updateGlow(block)

    bh=getSimulinkBlockHandle(block);

    pass_status=str2double(get_param(block,'pass'));
    glow_event=learning.simulink.glowEnum(pass_status);
    learning.simulink.glowGrader.setGlow(bh,glow_event,'GlowGrader');
end
