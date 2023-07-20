

function rowInfo=getSignalRows(mdl,widgetID,currSelectedBlks,currSelectedSegments,boundElem,widgetType)




    slSigStruct=utils.getSLSignals(boundElem,currSelectedBlks,currSelectedSegments);
    srcBlockorSFSigNames=[slSigStruct.srcBlockorSFSigNames];%#ok<AGROW>
    srcBlockHs=[slSigStruct.srcBlockHs];%#ok<AGROW>
    srcPortNums=[slSigStruct.srcPortNums];%#ok<AGROW>
    signalLabels=[slSigStruct.signalLabels];%#ok<*AGROW>
    sigBndStatus=[slSigStruct.sigBndStatus];
    sigCtrlBndSrcs=[slSigStruct.sigCtrlBndSrcs];
    sigCtrlBndUUIDs=[slSigStruct.sigCtrlBndUUIDs];
    sigTypes=[slSigStruct.sigTypes];
    isElemSelected=[slSigStruct.isElemSelected];


    srcBlockHs=cellfun(@(x)num2str(x,64),srcBlockHs,'UniformOutput',false);
    bAddBoundElement=isBoundElementInSelection(sigBndStatus);

    if~isempty(boundElem)&&bAddBoundElement&&utils.isValidBinding(boundElem)
        blk=boundElem.BlockPath.getBlock(1);
        blkh=get_param(blk,'handle');

        srcBlockorSFSigNames{end+1}=get_param(blk,'Name');

        srcBlockHs{end+1}=num2str(blkh,64);
        srcPortNums{end+1}=boundElem.OutputPortIndex;
        signalLabels{end+1}=utils.getBoundSignalDisplayName(boundElem);
        sigBndStatus{end+1}='default';
        sigCtrlBndSrcs{end+1}={};
        sigCtrlBndUUIDs{end+1}={};

        domainType='';
        if isprop(boundElem,'DomainType_')
            domainType=boundElem.DomainType_;
        end
        if strcmp(domainType,'sf_state')
            sigTypes{end+1}='SFSTATE';
        elseif strcmp(domainType,'sf_data')
            sigTypes{end+1}='SFDATA';
        elseif strcmp(domainType,'sf_chart')
            sigTypes{end+1}='SFCHART';
        else
            sigTypes{end+1}='SLSIGNAL';
        end
        isElemSelected{end+1}=false;
    end
    selectionText=utils.getInitialTextForWidget(widgetType);
    rowInfo={mdl,widgetID,srcBlockorSFSigNames,srcBlockHs,...
    srcPortNums,signalLabels,sigBndStatus,sigCtrlBndSrcs,...
    sigCtrlBndUUIDs,sigTypes,isElemSelected,selectionText};
end

function bAddBoundElement=isBoundElementInSelection(sigBndStatus)
    bAddBoundElement=true;
    for i=1:length(sigBndStatus)
        if~isempty(sigBndStatus{i})&&strcmp(sigBndStatus{i},'default')
            bAddBoundElement=false;
        end
    end
end



