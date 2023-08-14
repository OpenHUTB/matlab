function alignBlocksPostRebuild(harnessStruct)

    try
        inputConvSSH=harnessStruct.InputConversionSubsystem;
        outputConvSSH=harnessStruct.OutputConversionSubsystem;
        cutBlkH=harnessStruct.HarnessCUT;
        harnessName=get_param(harnessStruct.HarnessModel,'Name');
        hInfo=Simulink.harness.find(harnessStruct.Owner,'Name',harnessName);
        srcType=hInfo.origSrc;
        sinkType=hInfo.origSink;

        blkHandles={};

        if strcmp(srcType,'Signal Builder')

            sigbBlk=find_system(harnessStruct.HarnessModel,...
            'SearchDepth',1,'BlockType',...
            'SubSystem','MaskType','Sigbuilder block');
            if~isempty(sigbBlk)
                sigbBlkH=get_param(sigbBlk,'Handle');
                blkHandles{1}=sigbBlkH;
            end
        end


        ICSPos=get_param(inputConvSSH,'Position');


        sizeTypeBlk=find_system(harnessStruct.HarnessModel,...
        'SearchDepth',1,'BlockType','SubSystem','Name','Size-Type');
        if~isempty(sizeTypeBlk)
            sizeTypeBlkH=get_param(sizeTypeBlk,'Handle');
            blkHandles{end+1}=sizeTypeBlkH;
            sizeTypeBlkPos=get_param(sizeTypeBlkH,'Position');
        else


            alignConversionSubsystemInputsAndOutputs(inputConvSSH,srcType);
        end

        blkHandles{end+1}=inputConvSSH;


        blkHandles{end+1}=cutBlkH;

        blkHandles{end+1}=outputConvSSH;

        if~isempty(sizeTypeBlk)


            if(sizeTypeBlkPos(1)>ICSPos(1))
                icsx1=sizeTypeBlkPos(1);
                icsx2=icsx1+5;
                sizeTypex1=ICSPos(1);
                sizeTypex2=sizeTypex1+5;
                newICSPos=[icsx1,sizeTypeBlkPos(2),icsx2,sizeTypeBlkPos(4)];
                newSizeTypePos=[sizeTypex1,sizeTypeBlkPos(2),sizeTypex2,sizeTypeBlkPos(4)];

                set_param(inputConvSSH,'Position',range_check_position(newICSPos));
                set_param(sizeTypeBlkH,'Position',range_check_position(newSizeTypePos));
            end
        end



        alignConversionSubsystemInputsAndOutputs(outputConvSSH,sinkType);

        align_top_bottom(blkHandles{1},blkHandles{2:end});

    catch

    end

end

function alignConversionSubsystemInputsAndOutputs(convSSH,type)


    if~strcmpi(type,'Inport')&&~strcmpi(type,'Outport')&&~strcmpi(type,'Constant')&&...
        ~strcmpi(type,'FromWorkspace')&&~strcmpi(type,'FromFile')&&...
        ~strcmpi(type,'Ground')&&~strcmpi(type,'ToWorkspace')&&...
        ~strcmpi(type,'ToFile')&&~strcmpi(type,'Terminator')
        return;
    end

    CSPos=get_param(convSSH,'Position');
    portHandles=get_param(convSSH,'PortHandles');
    if strcmp(get_param(convSSH,'Tag'),'__SLT_ICS__')
        ports=portHandles.Inport;
        handleToGet='SrcBlockHandle';
        x1=CSPos(1)-50;
    else
        ports=portHandles.Outport;
        handleToGet='DstBlockHandle';
        x1=CSPos(3)+50;
    end

    for i=1:length(ports)
        ph=ports(i);
        line=get_param(ph,'Line');
        if~isempty(line)
            block=get_param(line,handleToGet);
            portPos=get_param(ph,'Position');
            pos=get_param(block,'Position');
            width=pos(3)-pos(1);
            height=pos(4)-pos(2);
            x2=x1+width;
            y1=portPos(2)-height/2;
            y2=portPos(2)+height/2;
            set_param(block,'Position',range_check_position([x1,y1,x2,y2]));
        end
    end
end

function align_top_bottom(block1,varargin)
    startPos=get_param(block1,'Position');
    top=startPos(2);
    bottom=startPos(4);

    for idx=1:length(varargin)
        bh=varargin{idx};
        if~isempty(bh)
            bPos=get_param(bh,'Position');
            blockPos=[bPos(1),top,bPos(3),bottom];
            set_param(bh,'Position',range_check_position(blockPos));
        end
    end
end

function pos=range_check_position(inPos)

    pos=min(inPos,32767);

    if pos(1)>pos(3)
        pos(1)=pos(3);
    end

    if pos(2)>pos(4)
        pos(2)=pos(4);
    end
end
