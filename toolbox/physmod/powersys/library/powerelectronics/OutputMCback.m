function OutputMCback(block)





    switch get_param(bdroot(block),'SimulationStatus')
    case{'stopped'}
        if strcmp(get_param(block,'MaskType'),'Diode')
            if strcmp(get_param(block,'Measurements'),'on')
                set_param(block,'MaskIconFrame','on');
                set_param(block,'MaskIconOpaque','off');
            else
                set_param(block,'MaskIconFrame','off');
                set_param(block,'MaskIconOpaque','on');
            end
        end
    end