function selectionRows=getUnconnectedPortRowsInSelection(selectionHandles,varargin)






    upStruct.sourceBlockPath={};
    upStruct.inportNumber={};
    upStruct.portType={};

    totalNumRows=0;

    if(nargin==2)
        doNotBindLinkedLibraryBlocks=varargin{1};
    else
        doNotBindLinkedLibraryBlocks=false;
    end

    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)==0)
            continue;
        end
        type=get_param(selectionHandles(idx),'Type');
        if(~strcmp(type,'block'))
            continue;
        end

        if doNotBindLinkedLibraryBlocks
            linkStatus=get_param(selectionHandles(idx),'StaticLinkStatus');
            isNotLibrary=isequal(linkStatus,'none')...
            ||isequal(linkStatus,'resolved')...
            ||isequal(linkStatus,'inactive');
            if~isNotLibrary
                continue;
            end
        end

        sourceBlockPath=getfullname(selectionHandles(idx));


        unconnectedPorts=getUnconnectedPort(selectionHandles(idx));
        if iscell(unconnectedPorts)
            unconnectedPorts=cell2mat(unconnectedPorts);
        end


        portType=get_param(unconnectedPorts,'PortType');


        if~iscell(portType)
            portType={portType};
        end



        if~isempty(unconnectedPorts)
            for j=1:numel(unconnectedPorts)
                upStruct.inportNumber{end+1}=get_param(unconnectedPorts(j),'PortNumber');
                upStruct.sourceBlockPath{end+1}=sourceBlockPath;
                upStruct.portType{end+1}=portType{j};
                totalNumRows=totalNumRows+1;
            end
        end
    end

    selectionRows=[];

    if totalNumRows>0
        selectionRows=cell(1,totalNumRows);

        for idx=1:totalNumRows
            connectStatus=false;

            metaData=BindMode.SLPortMetaData(upStruct.sourceBlockPath{idx},upStruct.portType{idx},upStruct.inportNumber{idx});
            selectionRows{idx}=BindMode.BindableRow(connectStatus,BindMode.BindableTypeEnum.SLPORT,...
            metaData.name,metaData);
        end
        selectionRows=selectionRows(~cellfun('isempty',selectionRows));
    end
end

function ports=getUnconnectedPort(blockHandle)




    args={blockHandle,'LookUnderMasks','off','FollowLinks','off',...
    'SearchDepth',0};



    ports1=find_system(args{1:7},'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'PortType','inport',...
    'Line',-1);

    ports2=find_system(args{1:7},'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'PortType','enable',...
    'Line',-1);

    ports3=find_system(args{1:7},'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'PortType','trigger',...
    'Line',-1);

    unconn=find_system(args{1:7},'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','line',...
    'SegmentType','trunk',...
    'SrcBlockHandle',-1);
    ports4=get_param(unconn,'DstPortHandle');
    if~iscell(ports4)
        ports4={ports4};
    end
    if iscell(ports4)
        ports4=cell2mat(ports4);
    end
    ports4=ports4(ports4>0);

    ports=[ports1(:);ports2(:);ports3(:);ports4(:)];

end
