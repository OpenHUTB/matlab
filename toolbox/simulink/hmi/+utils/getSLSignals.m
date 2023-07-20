function sigStruct=getSLSignals(boundElem,blks,segHs)




    blockPortSegHs=utils.getSignalsForSelectedBlocks(blks);

    segHs=[segHs',blockPortSegHs];

    segHs=segHs((segHs~=-1));
    if length(segHs)>1
        srcPortHs=get(segHs,'SrcPortHandle');
        [~,IA]=unique([srcPortHs{:}]);
        segHs=segHs(IA);
    end
    srcPortH={};
    sigStruct=utils.initializeSigStruct();
    for segIdx=1:length(segHs)
        seg=segHs(segIdx);
        signalPort=get_param(seg,'SrcPortHandle');
        if(signalPort==-1||...
            ~strcmpi(get(signalPort,'PortType'),'outport'))

            continue;
        end
        srcBlockH=get(seg,'SrcBlockHandle');
        srcBlockorSFSigName=get(srcBlockH,'Name');
        portH=get(seg,'SrcPortHandle');
        portIdx=get(portH,'PortNumber');
        sigStruct.srcBlockHs{end+1}=srcBlockH;
        sigStruct.srcBlockorSFSigNames{end+1}=srcBlockorSFSigName;
        srcPortH{end+1}=portH;%#ok
        sigStruct.srcPortNums{end+1}=portIdx;
        sigStruct.signalLabels{end+1}=get(seg,'Name');
        [bStatus,ctrls,UUIDs]=utils.getBoundControlsAndStatus(boundElem,...
        srcBlockH,srcBlockorSFSigName,portIdx);
        sigStruct.sigCtrlBndSrcs{end+1}=ctrls;
        sigStruct.sigCtrlBndUUIDs{end+1}=UUIDs;
        sigStruct.sigBndStatus{end+1}=bStatus;
        sigStruct.sigTypes{end+1}='SLSIGNAL';
        sigStruct.isElemSelected{end+1}=true;


        if isempty(sigStruct.signalLabels{end})
            sigStruct.signalLabels{end}=...
            [sigStruct.srcBlockorSFSigNames{end},':'...
            ,num2str(sigStruct.srcPortNums{end})];
        end
    end
end

