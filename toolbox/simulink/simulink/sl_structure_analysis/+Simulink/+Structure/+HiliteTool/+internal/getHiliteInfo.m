function hiliteInfo=getHiliteInfo(isHiliteToSrc,Segment,varargin)

    import Simulink.Structure.HiliteTool.internal.*

    if(~isValidSegment(Segment))
        error('Simulink:HiliteTool:TerminateTrace','');
    else


        CurrentGraph=get_param(get_param(Segment,'Parent'),'handle');
        seg=SLM3I.SLDomain.handle2DiagramElement(Segment);
    end

    CurrentBlockDiagram=getBlockDiagram(CurrentGraph);


    if(~isempty(varargin))
        isTraceAll=varargin{1};
        assert(islogical(isTraceAll));
    else
        isTraceAll=false;
    end

    if nargin>3
        hiliteInfo=getHiliteInfoFromDiagramElement(seg,isHiliteToSrc,CurrentBlockDiagram,isTraceAll,varargin{2});
    else
        hiliteInfo=getHiliteInfoFromDiagramElement(seg,isHiliteToSrc,CurrentBlockDiagram,isTraceAll);
    end

end



function hiliteInfo=getHiliteInfoFromDiagramElement(seg,isHiliteToSrc,CurrentBlockDiagram,isTraceAll,varargin)
    if(seg.isvalid()&&isa(seg,'SLM3I.Segment'))
        oldState=warning('off','backtrace');
        x=onCleanup(@()warning(oldState.state,'backtrace'));
        if(isHiliteToSrc)
            if(isTraceAll)
                if~isempty(varargin)

                    hiliteInfo=SLM3I.SLDomain.getHighlightToAllSrcAdv(seg,0,varargin{1});
                else
                    hiliteInfo=SLM3I.SLDomain.getHighlightToAllSrcsInfo(seg);
                end
            else
                hiliteInfo=SLM3I.SLDomain.getHighlightToSrcInfo(seg);
            end
        else
            if(isTraceAll)
                if~isempty(varargin)

                    hiliteInfo=SLM3I.SLDomain.getHighlightToAllDestAdv(seg,0,varargin{1});
                else
                    hiliteInfo=SLM3I.SLDomain.getHighlightToAllDestsInfo(seg);
                end
            else
                hiliteInfo=SLM3I.SLDomain.getHighlightToDestInfo(seg);
            end
        end

        hiliteInfo.traceBD=CurrentBlockDiagram;

        slprivate('remove_hilite',CurrentBlockDiagram);
        SLM3I.SLDomain.removeBdFromHighlightMode(CurrentBlockDiagram);
    else
        error(message('Simulink:HiliteTool:InvalidSegHandleSLM3I'));
    end

end


