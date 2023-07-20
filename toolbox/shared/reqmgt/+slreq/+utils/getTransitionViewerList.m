function[out,viewerInfo]=getTransitionViewerList(transitionID)
    if isnumeric(transitionID)
        transitionID=double(transitionID);
    else
        out=[];
        viewerInfo=[];
        return;
    end

    sr=sfroot;
    transitionObj=sr.idToHandle(transitionID);
    if~isa(transitionObj,'Stateflow.Transition')
        out=[];
        viewerInfo=[];
        return;
    end

    transitionID=transitionObj.Id;
    topViewerID=[];
    realViewerID=[];
    sourceViewerID=[];

    out=struct('subtranID',{},'viewerID',{},'srcID',{},'dstID',{});
    viewerToSubtranID=containers.Map('KeyType','double','ValueType','Double');
    subtranToViewerID=containers.Map('KeyType','double','ValueType','Double');



    if sf('get',transitionID,'trans.type')==1

        tempID=transitionID;

        parentID=sf('get',tempID,'.subLink.parent');
        parentViewer=sf('get',parentID,'.subviewer');


        while~isempty(sf('get',tempID,'.subLink.next'))
            tempInfo.viewerID=sf('get',tempID,'.subviewer');
            tempInfo.subtranID=tempID;
            viewerToSubtranID(tempInfo.viewerID)=tempInfo.subtranID;
            subtranToViewerID(tempInfo.subtranID)=tempInfo.viewerID;
            tempInfo.srcID=sf('get',tempID,'.src.id');
            tempInfo.dstID=sf('get',tempID,'.dst.id');

            if isempty(topViewerID)&&tempInfo.viewerID~=tempInfo.dstID


                topViewerID=tempInfo.viewerID;
            end

            if isempty(sourceViewerID)
                sourceViewerID=tempInfo.viewerID;
            end

            if tempInfo.subtranID==transitionID
                realViewerID=tempInfo.viewerID;
            end
            out(end+1)=tempInfo;
            tempID=sf('get',tempID,'.subLink.next');
        end

        destinationViewerID=tempInfo.viewerID;
    else
        viewerInfo=[];
        return;
    end

    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    currentDiagram=allStudios(1).App.getActiveEditor.getDiagram;

    try
        currentViewerID=double(currentDiagram.backendId);
    catch ME %#ok<NASGU>
        viewerInfo=[];
        return;
    end

    viewerInfo.viewerToSubtranID=viewerToSubtranID;
    viewerInfo.subtranToViewerID=subtranToViewerID;
    viewerInfo.topViewerID=topViewerID;
    viewerInfo.currentViewerID=currentViewerID;
    viewerInfo.realViewerID=realViewerID;
    viewerInfo.parentID=parentID;
    viewerInfo.parentViewer=parentViewer;
    viewerInfo.destinationViewerID=destinationViewerID;
    viewerInfo.sourceViewerID=sourceViewerID;

    if viewerInfo.parentViewer==currentViewerID
        viewerInfo.isInTopView=true;
    else
        viewerInfo.isInTopView=false;
    end

    if viewerInfo.sourceViewerID==currentViewerID
        viewerInfo.isInSourceView=true;
    else
        viewerInfo.isInSourceView=false;
    end

    if viewerInfo.destinationViewerID==currentViewerID
        viewerInfo.isInDesitnationViewer=true;
    else
        viewerInfo.isIndestinationViewer=false;
    end
end