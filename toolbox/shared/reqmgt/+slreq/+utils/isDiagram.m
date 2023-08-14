function[out,isnonvalidtrans]=isDiagram(objectInfo)




    isnonvalidtrans=false;
    out=objectInfo.isDiagram;
    if strcmpi(objectInfo.type,'Transition')
        transID=double(Stateflow.resolver.asId(objectInfo));
        [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(transID);
        if~isempty(transInfo)
            out=viewerInfo.isInTopView&&~viewerInfo.isInSourceView;
            if~viewerInfo.isInTopView&&~viewerInfo.isInSourceView
                isnonvalidtrans=true;
            end
        else
            out=objectInfo.isDiagram;
        end


    end

end
