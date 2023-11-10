classdef(Hidden)ToolStripManager<handle

    methods(Static,Access=public)

        function nextComment(cbinfo)
            studio=cbinfo.studio;
            model=get_param(studio.App.blockDiagramHandle,'Name');
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(~dr.getCommentsManager(model).isFilterComments())
                simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
                simulink.designreview.CommentsApi.nextComment(model);
            end
        end

        function previousComment(cbinfo)
            studio=cbinfo.studio;
            model=get_param(studio.App.blockDiagramHandle,'Name');
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(~dr.getCommentsManager(model).isFilterComments())
                simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
                simulink.designreview.CommentsApi.previousComment(model);
            end
        end

        function addCommentRefresher(~,cbinfo)
            studio=simulink.designreview.Util.getActiveStudio();
            editor=studio.App.getActiveEditor;
            cbinfo.enabled=false;
            if(simulink.designreview.Util.isCommentsSupportedInEditor(editor))
                if(strcmp(editor.getType,'StateflowDI:Editor')...
                    &&simulink.designreview.Util.isValidSFElementSelected(editor))
                    cbinfo.enabled=true;
                elseif(simulink.designreview.check_block_selection_cb()=="true")
                    cbinfo.enabled=true;
                end
            end
        end

        function enableButtonRefresher(~,cbinfo)
            studio=simulink.designreview.Util.getActiveStudio();
            dr=simulink.designreview.DesignReviewApp.getInstance();
            model=get_param(studio.App.blockDiagramHandle,'Name');
            editor=studio.App.getActiveEditor;
            cbinfo.enabled=false;
            if(simulink.designreview.Util.isCommentsSupportedInEditor(editor))
                cbinfo.enabled=true;
                if(dr.getCommentsManager(model).isFilterComments())
                    cbinfo.enabled=false;
                end
            end
        end

        function showApp(studio)
            appCxtMgr=studio.App.getAppContextManager;
            context=simulink.designreview.drCommentsAppContext;
            dr=simulink.designreview.DesignReviewApp.getInstance();
            model=get_param(studio.App.blockDiagramHandle,'Name');

            dr.perspectiveManager.enablePerspective(model);

            dr.getCommentsManager(model).handleAppOpen(studio);
            customContext=appCxtMgr.getCustomContext('drCommentsApp');
            if isempty(customContext)

                appCxtMgr.activateApp(context);
            else

                ts=studio.getToolStrip;
                ts.ActiveTab=customContext.DefaultTabName;
            end
        end

        function hideApp(studio)
            app=studio.App;
            appCxtMgr=app.getAppContextManager;
            appCxtMgr.deactivateApp('drCommentsApp');
            dr=simulink.designreview.DesignReviewApp.getInstance();
            model=get_param(studio.App.blockDiagramHandle,'Name');

            dr.perspectiveManager.disablePerspective(model);

            dr.getCommentsManager(model).handleAppClose(studio);
        end

        function processCommentList(cbinfo)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            model=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
            if(cbinfo.EventData)
                dr.getCommentsManager(model).showUI(cbinfo.studio);
            else
                dr.getCommentsManager(model).hideUI(cbinfo.studio);
            end
        end

        function showCommentListRefresher(~,cbinfo)
            studio=simulink.designreview.Util.getActiveStudio();
            model=get_param(studio.App.blockDiagramHandle,'Name');
            if~isempty(model)
                dr=simulink.designreview.DesignReviewApp.getInstance();
                if(dr.getCommentsManager(model).isCommentListOpen())
                    cbinfo.selected=true;
                else
                    cbinfo.selected=false;
                end
            end
        end

        function showResolvedComments(cbinfo)
            model=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
            simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(cbinfo.EventData)
                dr.getCommentsManager(model).setRemoveResolvedComments(true);
                simulink.designreview.CommentsApi.showResolvedComments(model,true);
            else
                dr.getCommentsManager(model).setRemoveResolvedComments(false);
                simulink.designreview.CommentsApi.showResolvedComments(model,false);
            end
        end

        function showResolvedCommentsRefresher(~,cbinfo)
            studio=simulink.designreview.Util.getActiveStudio();
            model=get_param(studio.App.blockDiagramHandle,'Name');
            if~isempty(model)
                dr=simulink.designreview.DesignReviewApp.getInstance();
                if(dr.getCommentsManager(model).isRemoveResolvedComments())
                    cbinfo.selected=true;
                else
                    cbinfo.selected=false;
                end
            end
        end

        function filterComments(cbinfo)
            model=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
            simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
            dr=simulink.designreview.DesignReviewApp.getInstance();
            ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('drCommentsApp');
            if(cbinfo.EventData)
                ctx.isNavigationEnabled=false;
                editor=cbinfo.studio.App.getActiveEditor();
                diagram=editor.getDiagram();
                dr.getCommentsManager(model).setFilterComments(true);
                currentPath=regexprep(diagram.getFullName(),'[\n\r]+',' ');
                simulink.designreview.CommentsApi.filterComments(model,true,currentPath);
            else
                ctx.isNavigationEnabled=true;
                dr.getCommentsManager(model).setFilterComments(false);
                simulink.designreview.CommentsApi.filterComments(model,false,model);
            end
        end

        function filterCommentsRefresher(~,cbinfo)
            studio=simulink.designreview.Util.getActiveStudio();
            model=get_param(studio.App.blockDiagramHandle,'Name');
            if~isempty(model)
                dr=simulink.designreview.DesignReviewApp.getInstance();
                cbinfo.selected=false;
                if(dr.getCommentsManager(model).isFilterComments())
                    cbinfo.selected=true;
                end
            end
        end


        function removeResolvedComments(cbinfo)
            buttonName=questdlg(DAStudio.message('designreview_comments:Command:DeleteResolvedQuestion'),...
            DAStudio.message('designreview_comments:Command:DeleteResolvedQuestionTitle'),...
            DAStudio.message('designreview_comments:Command:DeleteResolvedYes'),...
            DAStudio.message('designreview_comments:Command:DeleteResolvedNo'),...
            DAStudio.message('designreview_comments:Command:DeleteResolvedNo'));

            if strcmp(buttonName,DAStudio.message('designreview_comments:Command:DeleteResolvedYes'))
                model=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
                simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
                simulink.designreview.CommentsApi.removeResolvedComments(model)
            end
        end

        function addComment(cbinfo)
            blk=simulink.designreview.UriProvider.getTargetUri(cbinfo.studio.App.getActiveEditor);
            model=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
            simulink.designreview.ToolStripManager.showCommentListIfClosed(model);


            comp=cbinfo.studio.getComponent('GLUE2:DDG Component','COMMENTS');
            cbinfo.studio.setActiveComponent(comp);
            dlg=comp.getDialog();
            dlg.setFocus('DDGWebBrowser');

            designReviewAddCommentFromUI(blk,model);
        end

        function processClosableApp(~,cbinfo)
            if isempty(cbinfo.EventData)
                simulink.designreview.ToolStripManager.showApp(cbinfo.studio);
            else
                simulink.designreview.ToolStripManager.hideApp(cbinfo.studio);
            end
        end

        function showCommentListIfClosed(model)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            if(~dr.getCommentsManager(model).isCommentListOpen())
                simulink.designreview.ToolStripManager.executeCommentListAction(true);
            end
        end

        function executeCommentListAction(show)
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(studios)
                studio=studios(1);
                ts=studio.getToolStrip();
                as=ts.getActionService();
                as.executeAction('drCommentsCommentListShowCommentsPanelAction',show);
            end
        end
    end
end
