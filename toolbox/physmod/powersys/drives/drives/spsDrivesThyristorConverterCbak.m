function[]=spsDrivesThyristorConverterCbak(block,cbakMode)


    detailLevel=get_param(block,'detailLevel');
    supplyType=get_param(block,'supplyType');
    numQuad=get_param(block,'numQuad');
    internalBlock=[block,'/Thyristor converter'];
    singlePhaseMode=strcmp('PMIOPort',get_param([block,'/A+'],'BlockType'));
    maskObj=Simulink.Mask.get(block);
    machineGroup=maskObj.getDialogControl('machineGroup');
    converterGroup=maskObj.getDialogControl('converterGroup');

    switch detailLevel
    case 'Detailed'

        converterGroup.Visible='on';


        machineGroup.Visible='off';

        maskVisibilities={...
        'on',...
        'on',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        };

    case 'Average'

        converterGroup.Visible='on';


        machineGroup.Visible='on';

        switch numQuad
        case '2'
            maskVisibilities={...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'off',...
            'on',...
            'on',...
            'on',...
            'on',...
            'off',...
            'on',...
            'on',...
            };
        case '4'
            maskVisibilities={...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'on',...
            'off',...
            'on',...
            'on',...
            'on',...
            'off',...
            'on',...
            'on',...
            'on',...
            };
        end
    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,detailLevel,'Model detail level'));
    end
    set_param(block,'MaskVisibilities',maskVisibilities);

    switch cbakMode
    case 'init'
        switch supplyType
        case 'Single-phase'
            supplyAcronym='sph';
        case 'Three-phase'
            supplyAcronym='tph';
        otherwise
            error(message('physmod:powersys:common:InvalidParameter',block,supplyType,'Supply'));
        end

        switch detailLevel
        case 'Detailed'
            variant=[supplyAcronym,'_detailed'];
        case 'Average'
            variant=[supplyAcronym,'_average_',numQuad,'q'];
        end

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end

        switch singlePhaseMode
        case 1

            switch supplyType
            case 'Three-phase'
                disconnect(internalBlock,5,[block,'/C'],1,block,'L');
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
                connect(internalBlock,5,[block,'/C'],1,block,'R');
            case 'Single-phase'

            otherwise
                error(message('physmod:powersys:common:InvalidParameter',block,supplyType,'Supply'));
            end
        case 0

            switch supplyType
            case 'Three-phase'

            case 'Single-phase'
                disconnect(internalBlock,5,[block,'/C'],1,block,'R');
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
                connect(internalBlock,5,[block,'/C'],1,block,'L');
            otherwise
                error(message('physmod:powersys:common:InvalidParameter',block,supplyType,'Supply'));
            end
        end

    end
end
function[]=connect(block1,port_number1,block2,port_number2,parent,side)
    Block1PortHandles=get_param(block1,'PortHandles');
    Block2PortHandles=get_param(block2,'PortHandles');
    switch side
    case 'L'
        add_line(parent,Block1PortHandles.LConn(port_number1),Block2PortHandles.LConn(port_number2));
    case 'R'
        add_line(parent,Block1PortHandles.LConn(port_number1),Block2PortHandles.RConn(port_number2));
    end
end

function[]=disconnect(block1,port_number1,block2,port_number2,parent,side)
    Block1PortHandles=get_param(block1,'PortHandles');
    Block2PortHandles=get_param(block2,'PortHandles');
    switch side
    case 'L'
        delete_line(parent,Block1PortHandles.LConn(port_number1),Block2PortHandles.LConn(port_number2));
    case 'R'
        delete_line(parent,Block1PortHandles.LConn(port_number1),Block2PortHandles.RConn(port_number2));
    end
end