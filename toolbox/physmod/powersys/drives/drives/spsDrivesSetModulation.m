function[]=spsDrivesSetModulation(block,driveType,averageValue);%#ok















    switch driveType
    case 'AC3'
        controlBlock='F.O.C.';
        position=[615,293,635,313];
        position2=[375,325,395,345];

    case 'AC4'
        controlBlock='DTC';
        position=[554,284,570,294];
        position2=[380,315,400,335];
    case 'AC6'
        controlBlock='VECT';
        position=[535,180,555,200];
        position2=[345,230,365,250];

    end

    wantAverageValueModel=averageValue==1;


    findBlock=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','Name','GroundRef');

    if wantAverageValueModel

        if isempty(findBlock)
            deletelineConnections(block,controlBlock,position,position2);
        end

    elseif~wantAverageValueModel
        modulationParent=get_param(block,'modulationType');
        modulationChildren=get_param([block,'/',controlBlock],'modulationType');
        SVMmodulationType=strfind(modulationParent,'SVM');

        if~strcmp(modulationParent,modulationChildren)
            if isempty(SVMmodulationType)
                deletelineConnections(block,controlBlock,position,position2);
            elseif~isempty(SVMmodulationType)
                addlineConnections(block,controlBlock);
            end
            set_param([block,'/',controlBlock],'modulationType',modulationParent);
        elseif strcmp(modulationParent,modulationChildren)

            if~isempty(SVMmodulationType)&&~isempty(findBlock)
                addlineConnections(block,controlBlock);
            elseif isempty(SVMmodulationType)&&isempty(findBlock)
                deletelineConnections(block,controlBlock,position,position2);
            end

        end

    end

end

function deletelineConnections(driveBlock,controlBlock,position,position2)
    controller=get_param([driveBlock,'/',controlBlock],'PortHandles');
    SelectorVdcBus=get_param([driveBlock,'/Selector_VdcBus'],'PortHandles');
    delete_line(driveBlock,SelectorVdcBus.Outport,controller.Inport(end));
    add_block('simulink/Commonly Used Blocks/Ground',[driveBlock,'/GroundRef']);
    add_block('simulink/Commonly Used Blocks/Terminator',[driveBlock,'/TerminatorVbus']);
    set_param([driveBlock,'/GroundRef'],'Position',position);
    set_param([driveBlock,'/GroundRef'],'Orientation','up');
    set_param([driveBlock,'/GroundRef'],'ShowName','off');
    set_param([driveBlock,'/TerminatorVbus'],'Position',position2);
    set_param([driveBlock,'/TerminatorVbus'],'Orientation','right');
    set_param([driveBlock,'/TerminatorVbus'],'ShowName','off');
    Ground=get_param([driveBlock,'/GroundRef'],'PortHandles');
    Terminator=get_param([driveBlock,'/TerminatorVbus'],'PortHandles');
    add_line(driveBlock,Ground.Outport,controller.Inport(end),'AUTOROUTING','ON');
    add_line(driveBlock,SelectorVdcBus.Outport,Terminator.Inport,'AUTOROUTING','ON');
end

function addlineConnections(driveBlock,controlBlock)
    Ground=get_param([driveBlock,'/GroundRef'],'PortHandles');
    controller=get_param([driveBlock,'/',controlBlock],'PortHandles');
    SelectorVdcBus=get_param([driveBlock,'/Selector_VdcBus'],'PortHandles');
    Terminator=get_param([driveBlock,'/TerminatorVbus'],'PortHandles');
    delete_line(driveBlock,Ground.Outport,controller.Inport(end));
    delete_block([driveBlock,'/GroundRef']);
    delete_line(driveBlock,SelectorVdcBus.Outport,Terminator.Inport);
    delete_block([driveBlock,'/TerminatorVbus']);
    add_line(driveBlock,SelectorVdcBus.Outport,controller.Inport(end),'AUTOROUTING','ON');
end
