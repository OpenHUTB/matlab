














function[refStartSeg,refStartBlk,refsysHandle]=walkToModelRefSourceOutport(refBlk,elements)

    blockType=get_param(refBlk,'BlockType');
    assert(strcmpi(blockType,'modelreference'));

    refStartSeg=[];
    refStartBlk=[];
    refsysHandle=[];

    isProtected=strcmpi(get_param(refBlk,'ProtectedModel'),'on');
    if(isProtected)
        return;
    end

    REFMODEL=get_param(refBlk,'ModelName');
    proceedWhenBDisLoaded(REFMODEL);
    refsysHandle=get_param(REFMODEL,'Handle');

    try




        segs=find_system(elements,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','line',...
        'SrcBlockHandle',refBlk);
        if(isempty(segs))

            parentBlk=get_param(refBlk,'Parent');


            outPort=find_system(elements,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Parent',parentBlk,...
            'BlockType','Outport');

            outPortName=get_param(outPort,'name');
            refStartBlk=find_system(refsysHandle,'FindAll','on',...
            'SearchDepth','1',...
            'LookUnderMasks','on',...
            'FollowLinks','on',...
            'type','block',...
            'BlockType','Outport',...
            'name',outPortName);

        else

            oport=get_param(segs(1),'SrcPortHandle');
            oportNumber=get_param(oport,'PortNumber');
            refStartBlk=find_system(refsysHandle,'FindAll','on',...
            'SearchDepth','1',...
            'LookUnderMasks','on',...
            'FollowLinks','on',...
            'type','block',...
            'BlockType','Outport',...
            'Port',num2str(oportNumber));
        end

        refStartBlk_ports=get_param(refStartBlk,'PortHandles');
        refStartBlk_inports=refStartBlk_ports.Inport;
        refStartSeg=get_param(refStartBlk_inports(1),'line');

    catch
        refStartSeg=[];
        refStartBlk=[];
        refsysHandle=[];
    end
end