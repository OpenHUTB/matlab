classdef(Hidden)FigurePoolManager<handle






    properties(Constant)
        FIGURE_POOL_SIZE=10;
    end

    properties(Hidden,SetAccess=private)
        FigurePool=gobjects(0);
    end

    properties(Hidden,SetAccess={?tFigurePoolManager})
        OpenedLiveScripts={}
    end

    methods(Static)
        function obj=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=matlab.internal.editor.figure.FigurePoolManager();
            end
            obj=instance;
        end

        function createPoolWhenMLIsIdle(editorId)
            cmd=sprintf('matlab.internal.editor.figure.FigurePoolManager.createPool(''%s'')',editorId);
            internal.matlab.datatoolsservices.executeCmd(cmd);
        end


        function createPool(varargin)
            if~matlab.internal.editor.FigureManager.useEmbeddedFigures
                return
            end

            import matlab.internal.editor.figure.FigurePoolManager;

            fpm=FigurePoolManager.getInstance;

            if~isempty(varargin)

                fpm.OpenedLiveScripts=[fpm.OpenedLiveScripts,varargin{1}];
            end
            fpm.FigurePool(~isvalid(fpm.FigurePool))=[];



            matlab.internal.editor.figure.FigurePoolManager.cleanUpPreviouslyUsedFigures();

            if numel(fpm.FigurePool)>=FigurePoolManager.FIGURE_POOL_SIZE

                return
            end

            import matlab.internal.editor.figure.FigureUtils;

            for i=1:(FigurePoolManager.FIGURE_POOL_SIZE-numel(fpm.FigurePool))
                hFig=matlab.internal.editor.figure.FigurePoolManager.createEmbeddedFigure();
                fpm.FigurePool=[fpm.FigurePool,hFig];
            end
        end


        function hFig=getFigure(editorID)
            hFig=matlab.ui.Figure.empty;
            fpm=matlab.internal.editor.figure.FigurePoolManager.getInstance;
            if~isempty(fpm.FigurePool)
                fpm.FigurePool(~isvalid(fpm.FigurePool))=[];
            end


            figCandidate=findobj(fpm.FigurePool,'flat','Visible','off','editorID',editorID);


            if isempty(figCandidate)
                figCandidate=findobj(fpm.FigurePool,'flat','Visible','off','editorID','');
            end

            if~isempty(figCandidate)
                hFig=figCandidate(1);
                hFig.editorID=editorID;
                fpm.FigurePool(fpm.FigurePool==hFig)=[];
            end
        end


        function hFig=createEmbeddedFigure()

            hFig=matlab.ui.internal.embeddedfigure('Visible','on');
            matlab.internal.editor.figure.FigurePoolManager.setFigureProperties(hFig);

            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacketForLiveEditor(hFig);
            p=addprop(hFig,'Packet');
            p.Transient=1;
            hFig.Packet=efPacket;
            p1=addprop(hFig,'editorID');
            p1.Transient=1;
            hFig.Visible='off';
            p3=addprop(hFig,'LiveEditorVisListener');
            p3.Transient=1;


            setappdata(hFig,'IgnoreCloseAll',2);
            if~isprop(hFig,'CallbackNotSupportedWarning')
                callbackWarningProp=addprop(hFig,'CallbackNotSupportedWarning');
                callbackWarningProp.Transient=1;
                callbackWarningProp.Hidden=1;
            end
            hFig.CallbackNotSupportedWarning=false;


            if~isprop(hFig,'IsForcedSSR')
                isForcedSSRProp=addprop(hFig,'IsForcedSSR');
                isForcedSSRProp.Transient=1;
                isForcedSSRProp.Hidden=1;
            end
            hFig.IsForcedSSR=false;







            hFig.LiveEditorVisListener=event.proplistener(hFig,findprop(hFig,'Visible'),'PostSet',@(e,d)visibilityChanged(e,d));
        end

        function editorClosed(editorID)

            fpm=matlab.internal.editor.figure.FigurePoolManager.getInstance;


            index=find(strcmpi(fpm.OpenedLiveScripts,editorID));

            if isempty(index)


                return
            end

            fpm.OpenedLiveScripts(index)=[];

            if isempty(fpm.OpenedLiveScripts)
                matlab.internal.editor.figure.FigurePoolManager.destroyPool();
                matlab.internal.editor.figure.FigurePoolManager.destroyOrphanFigures();
                return
            end

            matlab.internal.editor.figure.FigurePoolManager.cleanUpEditorFigures(editorID);
        end

        function cleanUpEditorFigures(editorID)

            import matlab.internal.editor.figure.FigurePoolManager;
            fpm=FigurePoolManager.getInstance;
            ind2Delete=arrayfun(@(x)isvalid(x)&&strcmpi(x.editorID,editorID),fpm.FigurePool);
            if~isempty(ind2Delete)
                delete(fpm.FigurePool(ind2Delete));
                fpm.FigurePool(~isvalid(fpm.FigurePool))=[];
            end

            delete(findobjinternal('type','figure','editorID',editorID,'Tag',...
            matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG));
        end

        function cleanUpPreviouslyUsedFigures()

            import matlab.internal.editor.figure.FigurePoolManager;
            fpm=FigurePoolManager.getInstance;
            ind2Delete=arrayfun(@(x)~isempty(x.editorID),fpm.FigurePool);
            if~isempty(ind2Delete)
                delete(fpm.FigurePool(ind2Delete));
                fpm.FigurePool(~isvalid(fpm.FigurePool))=[];
            end
        end


        function destroyPool()
            import matlab.internal.editor.figure.FigurePoolManager;
            fpm=FigurePoolManager.getInstance;
            delete(fpm.FigurePool);
            fpm.FigurePool=gobjects(0);
        end



        function destroyOrphanFigures()
            delete(findobjinternal('type','figure','Tag',...
            matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG));
        end


        function ret=isFigureRecyclable(hFig)


            import matlab.internal.editor.EODataStore

            editorExists=isempty(hFig.editorID)||~isempty(matlab.internal.editor.EODataStore.getEditorMap(hFig.editorID));
            ret=editorExists&&isequal(hFig.Tag,matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG)&&...
            ~matlab.internal.editor.figure.FigurePoolManager.isForcedSSRFigure(hFig);
        end

        function ret=isForcedSSRFigure(hFig)

            ret=isprop(hFig,'IsForcedSSR')&&hFig.IsForcedSSR;
        end


        function setFigureProperties(hFig)
            set(hFig,'HandleVisibility','callback',...
            'Toolbar','none',...
            'MenuBar','none',...
            'AutoResizeChildren','off',...
            'Color',[1,1,1],...
            'Tag',matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG);
        end
    end
end


function visibilityChanged(~,d)
    fpm=matlab.internal.editor.figure.FigurePoolManager.getInstance;
    f=d.AffectedObject;

    if strcmpi(f.Visible,'off')
        if matlab.internal.editor.figure.FigurePoolManager.isFigureRecyclable(f)&&numel(fpm.FigurePool)<fpm.FIGURE_POOL_SIZE


            if isprop(f,'PlotSelectListener')
                delete(f.PlotSelectListener)
                f.PlotSelectListener=[];
            end
            clf(f,'reset');
            matlab.internal.editor.figure.FigurePoolManager.setFigureProperties(f);

            f.Visible_I='off';



            f.Internal=true;
            f.Position=get(0,'defaultFigurePosition');

            if isprop(f,'CallbackNotSupportedWarning')
                f.CallbackNotSupportedWarning=false;
            end
            fpm.FigurePool=[fpm.FigurePool,f];
        else
            delete(f);
        end
    end
end