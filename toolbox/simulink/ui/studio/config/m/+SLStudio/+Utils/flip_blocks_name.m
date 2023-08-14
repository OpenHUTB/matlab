function flip_blocks_name(blocks)





    for i=1:length(blocks)
        block=blocks(i);
        nameLocation=get_param(block,'NameLocation');
        switch nameLocation
        case 'bottom'
            set_param(block,'NameLocation','top');
        case 'top'
            set_param(block,'NameLocation','bottom');
        case 'right'
            set_param(block,'NameLocation','left');
        case 'left'
            set_param(block,'NameLocation','right');
        end
    end
end
