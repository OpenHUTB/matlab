function portsToIgnoreTerm=rewireVariantSink(variantBlock,portsToDel,calledFromReducer)







    portsToIgnoreTerm=[];

    portHandles=get_param(variantBlock,'PortHandles');

    variantControls=get_param(variantBlock,'VariantControls');
    outPortHandles=portHandles.Outport;


    portsToRetain=setdiff(1:numel(outPortHandles),portsToDel);



    portNamesToRetain=get_param(outPortHandles(portsToRetain),'Name');
    portNamesToRetain=Simulink.variant.utils.mat2cell(portNamesToRetain);

    numToRetain=numel(portsToRetain);
    lineHand=get(outPortHandles(portsToRetain),'Line');

    lineHand=Simulink.variant.utils.i_cell2mat(lineHand);


    activeInPort=[];
    activeOutPort=[];

    for iter2=1:numToRetain
        if lineHand(iter2)~=-1
            activeDestinationPort=get(lineHand(iter2),'DstPortHandle');



            activeDestinationPort=activeDestinationPort(activeDestinationPort~=-1);
            if~isempty(activeDestinationPort)
                activeOutPort=[activeOutPort;activeDestinationPort];%#ok<AGROW>

                activeSourcePort=repmat(outPortHandles(iter2),numel(activeDestinationPort),1);
                activeInPort=[activeInPort;activeSourcePort];%#ok<AGROW>
            end


            delete_line(lineHand(iter2));
        end
    end



    lineHandToDel=get(outPortHandles(portsToDel),'Line');
    lineHandToDel=Simulink.variant.utils.i_cell2mat(lineHandToDel);
    delete_line(setdiff(lineHandToDel,-1));

    if calledFromReducer

        nSegments=numel(outPortHandles)+1;
        nSegmentsToRetain=numToRetain+1;
        if(nSegments~=nSegmentsToRetain)
            Simulink.variant.reducer.utils.resizeIVBlock(variantBlock,nSegments,nSegmentsToRetain);
        end
    end

    for ii=1:numToRetain
        set_param(outPortHandles(ii),'Name',portNamesToRetain{ii});
    end


    varBlockPath=get_param(variantBlock,'Parent');


    add_line(varBlockPath,activeInPort,activeOutPort,'autorouting','on');


    variantControls(portsToDel)=[];

    isResolvedLinkBlock=false;
    if calledFromReducer
        isResolvedLinkBlock=strcmp('resolved',get_param(variantBlock,'StaticLinkStatus'));
    end

    if isResolvedLinkBlock


        portsToIgnoreTerm=outPortHandles(end+1-numel(portsToDel):end);
    else
        set_param(variantBlock,'VariantControls',variantControls);
    end




end
