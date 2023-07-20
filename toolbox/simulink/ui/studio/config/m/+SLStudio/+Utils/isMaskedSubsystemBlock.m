function res=isMaskedSubsystemBlock(block)




    res=isa(block,'Simulink.SubSystem')&&~slprivate('is_stateflow_based_block',block.Handle)&&hasmask(block.Handle)&&hasmaskdlg(block.Handle);
end
