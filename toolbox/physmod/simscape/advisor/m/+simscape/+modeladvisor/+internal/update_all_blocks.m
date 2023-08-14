function update_all_blocks(system)



    blocks=simscape.modeladvisor.internal.findBlocks(system);

    for idx=1:numel(blocks)
        simscape.modeladvisor.internal.update_block(Simulink.ID.getSID(blocks{idx}));
    end
end