function[]=spsDrivesChopperCbak(block,cbakMode)


    detailLevel=get_param(block,'detailLevel');
    numQuad=get_param(block,'numQuad');
    internalBlock=[block,'/Chopper'];
    fourQuadrant=strcmp('PMIOPort',get_param([block,'/B'],'BlockType'));

    switch cbakMode
    case 'parameter change'

    case 'init'
        switch fourQuadrant
        case 1

            switch numQuad
            case '1'
                load_system('spsGroundLib');
                replace_block(block,'FollowLinks','on','Name','B','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/B'],'Position');
                set_param([block,'/B'],'Orientation','Right','Position',pos);
            case '2'
                load_system('spsGroundLib');
                replace_block(block,'FollowLinks','on','Name','B','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/B'],'Position');
                set_param([block,'/B'],'Orientation','Right','Position',pos);
            case '4'
            end
        case 0

            switch numQuad
            case '1'
            case '2'
            case '4'
                load_system('nesl_utility');
                replace_block(block,'FollowLinks','on','Name','B','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/B'],'Position');
                set_param([block,'/B'],'Side','Right','Orientation','Left','Position',pos);
            end
        end
    end
    switch detailLevel
    case 'Detailed'
        maskVisibilities={...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'off',...
        };

    case 'Average'
        maskVisibilities={...
        'on',...
        'on',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'on',...
        'off',...
        };
    end

    maskEnables=maskVisibilities;

    variant=[detailLevel,'_',numQuad,'q'];
    if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
        set_param(internalBlock,'LabelModeActiveChoice',variant);
    end

    set_param(block,'MaskVisibilities',maskVisibilities);
    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnables);
    end
end
