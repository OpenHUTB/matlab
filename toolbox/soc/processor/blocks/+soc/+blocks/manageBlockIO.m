function manageBlockIO(CurrentBlock)






    CurrentBlockPath=[get_param(CurrentBlock,'Parent'),'/',get_param(CurrentBlock,'Name')];

    PropNames=get_param(CurrentBlockPath,'MaskNames');

    if any(ismember(PropNames,'SimulationOutput'))

        manageSourceSystem(CurrentBlockPath);
    elseif any(ismember(PropNames,'SendSimulationInputTo'))

        manageSinkSystem(CurrentBlockPath);
    else

    end

    manageUnconnectedIO(CurrentBlock);
    manageNewlyGrownIO(CurrentBlock);

end

function manageSourceSystem(CurrentBlock)
    mdlname=bdroot(CurrentBlock);





    blkToRep=[CurrentBlock,'/Ground Sim'];
    if(strcmp(get_param(mdlname,'SimulationStatus'),'stopped')||...
        strcmp(get_param(blkToRep,'CompiledIsActive'),'on'))
        if isequal(get_param(CurrentBlock,'SimulationOutput'),'From input port')
            if isequal(get_param(blkToRep,'BlockType'),'Ground')
                replace_block(CurrentBlock,'FollowLinks','on','Name',get_param(blkToRep,'Name'),'Inport','noprompt');
            end
        else
            if isequal(get_param(blkToRep,'BlockType'),'Inport')
                replace_block(CurrentBlock,'FollowLinks','on','Name',get_param(blkToRep,'Name'),'Ground','noprompt');
            end
        end
    end

    if strcmp(get_param(mdlname,'SimulationStatus'),'stopped')
        if isequal(get_param(CurrentBlock,'SimulationOutput'),'From input port')
            try
                delete_block([CurrentBlock,'/Replace Terminator']);
            catch exc %#ok<NASGU>

            end

            lh=get_param([CurrentBlock,'/Variant Source'],'LineHandles');
            if~isempty(lh.Outport)&&~isequal(lh.Outport,-1)
                delete_line(lh.Outport);
            end
            add_line(CurrentBlock,'Variant Source/1',[get_param(CurrentBlock,'hoistedMaskSrc'),'/1']);
        else
            try

                lh=get_param([CurrentBlock,'/Variant Source'],'LineHandles');
                if~isempty(lh.Outport)&&~isequal(lh.Outport,-1)
                    delete_line(lh.Outport);
                end
                delete_block([CurrentBlock,'/Replace Terminator']);
            catch exc %#ok<NASGU>
            end

            add_block('built-in/Terminator',[CurrentBlock,'/Replace Terminator'],'Position',get_param([CurrentBlock,'/Variant Source'],'Position')+[100,0,100,0]);
            add_line(CurrentBlock,'Variant Source/1','Replace Terminator/1');
        end
    end

end

function manageSinkSystem(CurrentBlock)
    mdlname=bdroot(CurrentBlock);





    blkToRep=[CurrentBlock,'/Terminate Sim'];
    if(strcmp(get_param(mdlname,'SimulationStatus'),'stopped')||...
        strcmp(get_param(blkToRep,'CompiledIsActive'),'on'))
        if isequal(get_param(CurrentBlock,'SendSimulationInputTo'),'Output port')
            if isequal(get_param(blkToRep,'BlockType'),'Terminator')
                replace_block(CurrentBlock,'FollowLinks','on','Name',get_param(blkToRep,'Name'),'Outport','noprompt');
            end
        else
            if isequal(get_param(blkToRep,'BlockType'),'Outport')
                replace_block(CurrentBlock,'FollowLinks','on','Name',get_param(blkToRep,'Name'),'Terminator','noprompt');
            end
        end
    end

    if strcmp(get_param(mdlname,'SimulationStatus'),'stopped')
        if isequal(get_param(CurrentBlock,'SendSimulationInputTo'),'Output port')
            try
                delete_block([CurrentBlock,'/Replace Ground']);
            catch exc %#ok<NASGU>

            end

            lh=get_param([CurrentBlock,'/Variant Sink'],'LineHandles');
            if~isempty(lh.Inport)&&~isequal(lh.Inport,-1)
                delete_line(lh.Inport);
            end
            add_line(CurrentBlock,[get_param(CurrentBlock,'hoistedMaskSrc'),'/1'],'Variant Sink/1');
        else
            try

                lh=get_param([CurrentBlock,'/Variant Sink'],'LineHandles');
                if~isempty(lh.Inport)
                    delete_line(lh.Inport);
                end
                delete_block([CurrentBlock,'/Replace Ground']);
            catch exc %#ok<NASGU>
            end

            add_block('built-in/Ground',[CurrentBlock,'/Replace Ground'],'Position',get_param([CurrentBlock,'/',get_param(CurrentBlock,'hoistedMaskSrc')],'Position')+[100+60,0,100,0]);
            add_line(CurrentBlock,'Replace Ground/1','Variant Sink/1');
        end
    end

end

function manageUnconnectedIO(CurrentBlock)




    plist=find_system(CurrentBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','LoadFullyIfNeeded','on','FollowLinks','on','LookUnderMasks','on','BlockType','Inport');
    for i=1:numel(plist)
        lh=get_param(plist{i},'LineHandles');
        if isequal(lh.Outport,-1)||isequal(get_param(lh.Outport,'Connected'),'off')||isequal(get_param(lh.Inport,'DstPortHandle'),-1)

            if~isequal(lh.Outport,-1)
                delete_line(lh.Outport);
            end
            delete_block(plist{i});
        end
    end



    plist=find_system(CurrentBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','LoadFullyIfNeeded','on','FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
    for i=1:numel(plist)
        lh=get_param(plist{i},'LineHandles');
        if isequal(lh.Inport,-1)||isequal(get_param(lh.Inport,'Connected'),'off')||isequal(get_param(lh.Inport,'SrcPortHandle'),-1)

            if~isequal(lh.Inport,-1)
                delete_line(lh.Inport);
            end
            delete_block(plist{i});
        end
    end

end

function manageNewlyGrownIO(CurrentBlock)

    ActBlock=[CurrentBlock,'/',get_param(CurrentBlock,'hoistedMaskSrc')];

    ph=get_param(ActBlock,'PortHandles');

    for i=1:numel(ph.Inport)
        lh=get_param(ph.Inport(i),'Line');
        if isequal(lh,-1)||isequal(get_param(lh,'Connected'),'off')
            if~isequal(lh,-1)
                delete_line(lh);
            end

            h=add_block('built-in/Inport',[CurrentBlock,'/In'],'MakeNameUnique','on');
            add_line(CurrentBlock,[get_param(h,'Name'),'/1'],[get_param(CurrentBlock,'hoistedMaskSrc'),'/',num2str(i)]);
        end
    end

    for i=1:numel(ph.Outport)
        lh=get_param(ph.Outport(i),'Line');
        if isequal(lh,-1)||isequal(get_param(lh,'Connected'),'off')
            if~isequal(lh,-1)
                delete_line(lh);
            end

            h=add_block('built-in/Outport',[CurrentBlock,'/Out'],'MakeNameUnique','on');
            add_line(CurrentBlock,[get_param(CurrentBlock,'hoistedMaskSrc'),'/',num2str(i)],[get_param(h,'Name'),'/1']);
        end
    end
end
