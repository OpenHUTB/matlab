function[]=spsDrivesSetModulationType(block,driveType,averageValue);%#ok














    switch driveType
    case 'AC3'
        controlBlock='F.O.C.';
        position=[595,290,615,310];
    case 'AC4'
        controlBlock='DTC';
        position=[540,280,550,295];
    case 'AC6'
        controlBlock='VECT';
        position=[530,290,550,310];
    end

    wantAverageValueModel=averageValue==1;


    findBlock=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','Name','GroundRef');

    if wantAverageValueModel

        if isempty(findBlock)
            deletelineConnections(block,controlBlock,position);
        end

        maskEnables={...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        };
        maskVisibilities={...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        };


    elseif~wantAverageValueModel
        modulationParent=get_param(block,'modulationType');
        modulationChildren=get_param([block,'/',controlBlock],'modulationType');
        SVMmodulationType=strfind(modulationParent,'SVM');

        if~strcmp(modulationParent,modulationChildren)
            if isempty(SVMmodulationType)
                deletelineConnections(block,controlBlock,position);
            elseif~isempty(SVMmodulationType)
                addlineConnections(block,controlBlock);
            end
            set_param([block,'/',controlBlock],'modulationType',modulationParent);
        elseif strcmp(modulationParent,modulationChildren)

            if~isempty(SVMmodulationType)&&~isempty(findBlock)
                addlineConnections(block,controlBlock);
            elseif isempty(SVMmodulationType)&&isempty(findBlock)
                deletelineConnections(block,controlBlock,position);
            end

        end

        maskEnables={...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
        maskVisibilities={...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
    end
    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnables);
    end
    set_param(block,'MaskVisibilities',maskVisibilities);
end

function deletelineConnections(driveBlock,controlBlock,position)
    controller=get_param([driveBlock,'/',controlBlock],'PortHandles');
    Braking=get_param([driveBlock,'/Braking chopper'],'PortHandles');
    delete_line(driveBlock,Braking.Outport,controller.Inport(end));
    add_block('simulink/Commonly Used Blocks/Ground',[driveBlock,'/GroundRef']);
    set_param([driveBlock,'/GroundRef'],'Position',position);
    set_param([driveBlock,'/GroundRef'],'Orientation','up');
    set_param([driveBlock,'/GroundRef'],'ShowName','off');
    Ground=get_param([driveBlock,'/GroundRef'],'PortHandles');
    controller=get_param([driveBlock,'/',controlBlock],'PortHandles');
    add_line(driveBlock,Ground.Outport,controller.Inport(end),'AUTOROUTING','ON');
end

function addlineConnections(driveBlock,controlBlock)
    Ground=get_param([driveBlock,'/GroundRef'],'PortHandles');
    controller=get_param([driveBlock,'/',controlBlock],'PortHandles');
    Braking=get_param([driveBlock,'/Braking chopper'],'PortHandles');
    delete_line(driveBlock,Ground.Outport,controller.Inport(end));
    delete_block([driveBlock,'/GroundRef']);
    add_line(driveBlock,Braking.Outport,controller.Inport(end),'AUTOROUTING','ON');
end
