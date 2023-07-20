




classdef HighlightSignal<handle

    methods(Static)

        function highlight(hiliteInfo,bdHandle)
            hiliteMap=hiliteInfo.graphHighlightMap;
            participatingGraphHandles=[hiliteMap{:,1}];
            allElements=[];
            for i=1:length(participatingGraphHandles)

                if(loc_ShowGraphContents(participatingGraphHandles(i)))
                    allElements=[allElements,hiliteMap{i,2}];%#ok<AGROW>
                end
            end
            SLStudio.EmphasisStyleSheet.applyStyler(bdHandle,allElements);
        end

        function HighlightSignalToSource(segmentHandle,bdHandle)
            seg=SLM3I.SLDomain.handle2DiagramElement(segmentHandle);
            if(seg.isvalid()&&isa(seg,'SLM3I.Segment'))
                highlightInfo=SLM3I.SLDomain.getHighlightToSrcInfo(seg);
                SLStudio.HighlightSignal.highlight(highlightInfo,bdHandle)
            end
        end

        function HighlightSignalToDestination(segmentHandle,bdHandle)
            seg=SLM3I.SLDomain.handle2DiagramElement(segmentHandle);
            if(seg.isvalid()&&isa(seg,'SLM3I.Segment'))
                highlightInfo=SLM3I.SLDomain.getHighlightToDestInfo(seg);
                SLStudio.HighlightSignal.highlight(highlightInfo,bdHandle)
            end
        end

        function removeHighlighting(bdHandle)
            slprivate('remove_hilite',bdHandle);
            SLM3I.SLDomain.removeBdFromHighlightMode(bdHandle);
            SLStudio.EmphasisStyleSheet.removeStyler(bdHandle);
        end

    end
end

function ret=loc_ShowGraphContents(graphHandle)
    ret=true;


    if(~strcmpi(get(graphHandle,'Type'),'block'))
        return;
    end



    if(strcmpi(get(graphHandle,'MaskHideContents'),'on'))
        ret=false;
    end
end