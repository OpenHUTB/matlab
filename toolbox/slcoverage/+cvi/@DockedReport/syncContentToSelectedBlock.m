
function syncContentToSelectedBlock(this,isInit)





    if nargin<2
        isInit=false;
    end
    sb=[];
    activeEditor=this.hStudio.App.getActiveEditor();
    if isInit

        m=activeEditor.getDiagram;
        sb=SLM3I.Util.getSelectedBlocksFromEditor(activeEditor,m.model);
    else
        s=activeEditor.getSelection;
        if(s.size>0)
            sb=s.front;
        end
    end
    hasSelection=~isempty(sb);

    [activeModelH,sfLibIdStack]=this.getSfLibInstanceParentModel(~hasSelection);
    if isempty(activeModelH)
        activeModelH=activeEditor.blockDiagramHandle;
    end
    if hasSelection

        selectionH=resolveFromGLUE2DiagramElement(sb);
    elseif~isempty(sfLibIdStack)
        selectionH=sfLibIdStack;
    else
        selectionH=SLM3I.SLCommonDomain.getSLHandleForHID(activeEditor.getHierarchyId);
    end

    [urlStr,htmlStr]=this.getContent(activeModelH,selectionH,true);
    this.url=urlStr;
    this.html=htmlStr;


    if activeModelH~=get_param(this.rootModel,'Handle')
        obj=get_param(activeModelH,'Object');
        obj.registerDAListeners;
    end
end

function out=resolveFromGLUE2DiagramElement(in)
    out=[];
    switch class(in)
    case 'SLM3I.Diagram'
        out=get_param(in.getFullName(),'Handle');

    case{'SLM3I.Block'}
        out=in.handle;

    case{'StateflowDI.Subviewer','StateflowDI.State','StateflowDI.Transition'}
        out=in.backendId;
    end
end
