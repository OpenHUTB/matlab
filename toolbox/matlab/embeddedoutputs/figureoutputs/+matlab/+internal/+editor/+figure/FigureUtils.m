classdef FigureUtils<handle





    properties(Constant)
        EDITOR_ID_APP_DATA_TAG='EDITOR_ID';
        EDITOR_APP_DATA_TAG='EDITOR_APPDATA'
        EDITOR_FIGURE_SNAPSHOT_TAG='LiveEditorCachedFigure';
        EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG='EmbeddedFigure_Internal';
    end

    methods(Static)
        function editorFigure=isEditorFigure(figureHandle,editorId)

            import matlab.internal.editor.figure.FigureUtils;
            editorFigure=false(size(figureHandle));
            for k=1:length(figureHandle)
                h=figureHandle(k);
                s=FigureUtils.safeGetAppData(h,FigureUtils.EDITOR_ID_APP_DATA_TAG);
                editorFigure(k)=~isempty(s)&&(nargin<=1||isequal(s,editorId));
            end
        end


        function state=isEditorEmbeddedFigure(fig)
            import matlab.internal.editor.figure.FigureUtils;
            state=isWebFigureType(fig,'EmbeddedMorphableFigure')&&FigureUtils.isEditorFigure(fig);
        end



        function state=isEditorSnapshotFigure(fig)

            import matlab.internal.editor.figure.FigureUtils;
            state=false;
            if isempty(fig)
                return
            end
            state=any(strcmp(fig.Tag,{FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG,FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG}));
        end


        function state=isEditorSnapshotGraphicsView(fig)

            import matlab.internal.editor.figure.FigureUtils;
            state=false;
            if isempty(fig)
                return
            end
            state=strcmp(fig.Tag,FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG);
        end

        function value=safeGetAppData(h,tag,editorId)




            if nargin==2
                editorId='';
            end
            value=[];
            s=safeGetEditorData(h);
            name=[tag,editorId];
            if isfield(s,name)
                value=s.(name);
            end
        end


        function safeRemoveAppData(h,prop)

            if isprop(h,prop)
                rmprops(h,prop);
            end
        end

        function safeSetAppData(h,tag,editorId,value)




            if nargin==3
                value=editorId;
                editorId='';
            end
            s=safeGetEditorData(h);
            name=[tag,editorId];
            if isempty(s)
                s=struct(name,value);
            else
                s.(name)=value;
            end
            safeSetEditorData(h,s)
        end

        function state=isReadableProp(h,propname)
            prop=findprop(h,propname);
            state=false;
            if~isempty(prop)
                getAccess=prop.GetAccess;

                if(iscell(getAccess)&&~any(cellfun(@(h)h=="public",getAccess)))||...
                    (ischar(getAccess)&&getAccess~="public")
                    return
                end
                state=true;
            end
        end

        function state=isWritableProp(h,propname)
            prop=findprop(h,propname);
            state=false;
            if~isempty(prop)
                setAccess=prop.SetAccess;

                if(iscell(setAccess)&&~any(cellfun(@(h)h=="public",setAccess)))||...
                    (ischar(setAccess)&&setAccess~="public")
                    return
                end
                state=true;
            end
        end

        function state=isReadWriteProp(h,propname)
            import matlab.internal.editor.figure.FigureUtils;
            state=FigureUtils.isReadableProp(h,propname)&&FigureUtils.isWritableProp(h,propname);
        end

        function setFigureServerSideRendered(figureHandle)

            canvas=figureHandle.getCanvas();
            canvas.ServerSideRendering=matlab.lang.OnOffSwitchState.on;
        end
    end

end

function safeSetEditorData(h,s)

    import matlab.internal.editor.figure.FigureUtils;




    if ishandle(h)
        if~isprop(h,FigureUtils.EDITOR_APP_DATA_TAG)
            p=addprop(h,FigureUtils.EDITOR_APP_DATA_TAG);
            p.Hidden=true;
            p.Transient=true;
        end
        h.(FigureUtils.EDITOR_APP_DATA_TAG)=s;
    end
end

function val=safeGetEditorData(h)

    import matlab.internal.editor.figure.FigureUtils
    val=struct([]);
    if ishandle(h)
        if isprop(h,FigureUtils.EDITOR_APP_DATA_TAG)
            propVal=h.(FigureUtils.EDITOR_APP_DATA_TAG);
            if~isempty(propVal)
                val=propVal;
            end
        end
    end
end


