function[]=spsDrivesBridgeFiringUnitDcCbak(block,cbakMode)


    internalBlock=[block,'/Bridge firing unit'];
    detailLevel=get_param(block,'detailLevel');
    nbPhases=get_param(block,'nbPhases');
    numQuad=get_param(block,'numQuad');
    dcMode=strcmp('PMIOPort',get_param([block,'/A+'],'BlockType'));
    twoQuadrantMode=(strcmp('Outport',get_param([block,'/a'],'BlockType')));
    variant=[detailLevel,'_',nbPhases,'ph_',numQuad,'q'];

    switch cbakMode
    case 'change parameter'

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end
    case 'init'

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end

        switch dcMode
        case 1

            switch nbPhases
            case '3'
                load_system('spsGroundLib');
                replace_block(block,'FollowLinks','on','Name','A+','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/A+'],'Position');
                set_param([block,'/A+'],'Orientation','Left','Position',pos);
                replace_block(block,'FollowLinks','on','Name','A-','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/A-'],'Position');
                set_param([block,'/A-'],'Orientation','Left','Position',pos);
                load_system('nesl_utility');
                replace_block(block,'FollowLinks','on','Name','A','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/A'],'Position');
                set_param([block,'/A'],'Side','Left','Orientation','Right','Position',pos);
                replace_block(block,'FollowLinks','on','Name','B','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/B'],'Position');
                set_param([block,'/B'],'Side','Left','Orientation','Right','Position',pos);
                replace_block(block,'FollowLinks','on','Name','C','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/C'],'Position');
                set_param([block,'/C'],'Side','Left','Orientation','Right','Position',pos);
            case '1'

            end

        case 0

            switch nbPhases
            case '3'

            case '1'
                load_system('nesl_utility');
                replace_block(block,'FollowLinks','on','Name','A+','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/A+'],'Position');
                set_param([block,'/A+'],'Side','Left','Orientation','Right','Position',pos);
                replace_block(block,'FollowLinks','on','Name','A-','Parent',block,'nesl_utility/Connection Port','noprompt');
                pos=get_param([block,'/A-'],'Position');
                set_param([block,'/A-'],'Side','Left','Orientation','Right','Position',pos);
                load_system('spsGroundLib');
                replace_block(block,'FollowLinks','on','Name','A','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/A'],'Position');
                set_param([block,'/A'],'Orientation','Left','Position',pos);
                replace_block(block,'FollowLinks','on','Name','B','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/B'],'Position');
                set_param([block,'/B'],'Orientation','Left','Position',pos);
                replace_block(block,'FollowLinks','on','Name','C','Parent',block,'spsGroundLib/Ground','noprompt');
                pos=get_param([block,'/C'],'Position');
                set_param([block,'/C'],'Orientation','Left','Position',pos);
            end
        end

        switch twoQuadrantMode
        case 1

            switch numQuad
            case '2'

            case '4'
                replace_block(block,'FollowLinks','on','Name','Alpha','Parent',block,'Ground','noprompt');
                blk=replace_block(block,'FollowLinks','on','Name','Alpha_1','Parent',block,'Inport','noprompt');
                set_param(blk{1},'ForegroundColor','blue');
                blk=replace_block(block,'FollowLinks','on','Name','Alpha_2','Parent',block,'Inport','noprompt');
                set_param(blk{1},'ForegroundColor','blue');
                replace_block(block,'FollowLinks','on','Name','a','Parent',block,'Terminator','noprompt');
                a1=replace_block(block,'FollowLinks','on','Name','a1','Parent',block,'Outport','noprompt');
                a2=replace_block(block,'FollowLinks','on','Name','a2','Parent',block,'Outport','noprompt');
                set_param(a1{1},'ShowName','off','ForegroundColor','blue');
                set_param(a2{1},'ShowName','off','ForegroundColor','blue');
            end
        case 0

            switch numQuad
            case '2'
                blk=replace_block(block,'FollowLinks','on','Name','Alpha','Parent',block,'Inport','noprompt');
                set_param(blk{1},'ForegroundColor','blue');
                replace_block(block,'FollowLinks','on','Name','Alpha_1','Parent',block,'Ground','noprompt');
                replace_block(block,'FollowLinks','on','Name','Alpha_2','Parent',block,'Ground','noprompt');
                a=replace_block(block,'FollowLinks','on','Name','a','Parent',block,'Outport','noprompt');
                set_param(a{1},'ShowName','off','ForegroundColor','blue');
                replace_block(block,'FollowLinks','on','Name','a1','Parent',block,'Terminator','noprompt');
                replace_block(block,'FollowLinks','on','Name','a2','Parent',block,'Terminator','noprompt');
            case '4'

            end
        end
    end
end