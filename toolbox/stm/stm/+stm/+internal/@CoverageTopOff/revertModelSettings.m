
function revertModelSettings(cmds)
    for k=length(cmds):-1:1
        params=cmds{k}.params;
        switch cmds{k}.cmd
        case 'close_system'
            if~strcmpi(get_param(params{1},'Dirty'),'on')
                close_system(params{1});
            end
        case 'set_param'
            set_param(params{1},params{2},params{3});
        case 'sltest.harness.open'
            sltest.harness.open(params{1},params{2});
        case 'sltest.harness.load'
            sltest.harness.load(params{1},params{2});
        case 'sltest.harness.close'
            sltest.harness.close(params{1},params{2});
        case 'sltest.harness.set'
            sltest.harness.set(params{1},params{2},params{3},params{4});
        case 'stm.internal.util.loadHarness'
            stm.internal.util.loadHarness(params{1},params{2},params{3});
        end
    end
end