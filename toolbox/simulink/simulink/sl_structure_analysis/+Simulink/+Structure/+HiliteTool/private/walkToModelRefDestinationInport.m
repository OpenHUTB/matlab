













function[refStartSegs,refStartBlks,refsysHandle]=walkToModelRefDestinationInport(refBlk,elements)

    blockType=get_param(refBlk,'BlockType');
    assert(strcmpi(blockType,'modelreference'));

    refStartSegs=[];
    refStartBlks=[];
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
        'SearchDepth','1',...
        'type','line',...
        'DstBlockHandle',refBlk);

        if(isempty(segs))


            parentBlk=get_param(refBlk,'Parent');
            inPortBlks=find_system(elements,'FindAll','on',...
            'SearchDepth','1',...
            'LookUnderMasks','on',...
            'FollowLinks','on',...
            'Parent',parentBlk,...
            'BlockType','Inport');
            if isa(inPortBlks,'cell')
                inPortBlks=cell2mat(inPortBlks);
            end


            inPortBlks=unique(inPortBlks);
            refStartBlks=zeros(1,length(inPortBlks));
            refStartSegs=refStartBlks;

            for i=1:length(refStartBlks)
                inPortBlkName=get_param(inPortBlks(i),'name');
                refStartBlk=find_system(refsysHandle,'FindAll','on',...
                'SearchDepth','1',...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'type','block',...
                'BlockType','Inport',...
                'name',inPortBlkName);

                refStartBlk_ports=get_param(refStartBlk,'PortHandles');
                refStartBlk_outports=refStartBlk_ports.Outport;
                refStartBlks(i)=refStartBlk;
                refStartSegs(i)=get_param(refStartBlk_outports(1),'line');
            end
        else
            iports=get_param(segs,'DstPortHandle');
            if isa(iports,'cell')
                iports=cell2mat(iports);
            end
            iportNumbers=get_param(iports,'PortNumber');
            if isa(iportNumbers,'cell')
                iportNumbers=cell2mat(iportNumbers);
            end


            iportNumbers=unique(iportNumbers);
            refStartBlks=zeros(1,length(iportNumbers));
            refStartSegs=refStartBlks;

            for i=1:length(refStartBlks)
                refStartBlk=find_system(refsysHandle,'FindAll','on',...
                'SearchDepth','1',...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'type','block',...
                'BlockType','Inport',...
                'Port',num2str(iportNumbers(i)));

                refStartBlk_ports=get_param(refStartBlk,'PortHandles');
                refStartBlk_outports=refStartBlk_ports.Outport;
                refStartBlks(i)=refStartBlk;
                refStartSegs(i)=get_param(refStartBlk_outports(1),'line');
            end
        end
    catch
        refStartSegs=[];
        refStartBlks=[];
        refsysHandle=[];
    end
end