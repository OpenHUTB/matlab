classdef(Hidden)CommentsApi

    properties
    end

    methods(Static,Access=public)

        function addCommentForSingleSelect(model,blk)
            if(simulink.designreview.DesignReviewApp.getInstance.isReadOnlyFolder(model))
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('designreview_comments:Command:ReadOnlyError'),DAStudio.message('designreview_comments:Command:Error'),true);
            else
                simulink.designreview.ToolStripManager.showCommentListIfClosed(model);
                designReviewAddCommentFromUI(blk,model);
            end
        end

        function ret=addCommentUsingUri(uri,model,txt)
            ret="Design review application is not initialized";
            if(slfeature('DesignReview_Comments')>0)
                ret=designReviewAddComment(uri,model,txt);
            end
        end

        function ret=addComment(blk,txt)
            ret="Design review application is not initialized";
            if(slfeature('DesignReview_Comments')>0)
                uri=Simulink.ID.getSID(blk);
                model=extractBefore(uri,":");
                uri=['simulink:',get_param(blk,'SID')];
                ret=designReviewAddComment(uri,model,txt);
            end
        end

        function ret=addReply(clientId,commentId,txt)
            ret="Design review application is not initialized";
            if(slfeature('DesignReview_Comments')>0)
                ret=designReviewAddReply(clientId,commentId,txt);
            end
        end

        function ret=getCommentsOnlyWithUri(clientId,uri)
            ret="Design review application is not initialized";
            if(slfeature('DesignReview_Comments')>0)
                ret=designReviewGetCommentsByUri(clientId,uri);
            end
        end

        function ret=getCommentsByUri(clientId,uri)
            ret="Design review application is not initialized";
            if(slfeature('DesignReview_Comments')>0)
                uri=['simulink:',extractAfter(uri,":")];
                ret=designReviewGetCommentsByUri(clientId,uri);
            end
        end

        function resolveComment(clientId,commentId)
            if(slfeature('DesignReview_Comments')>0)
                designReviewChangeCommentStatus(clientId,commentId,'resolve');
            end
        end

        function reopenComment(clientId,commentId)
            if(slfeature('DesignReview_Comments')>0)
                designReviewChangeCommentStatus(clientId,commentId,'open');
            end
        end

        function removeResolvedComments(clientId)
            if(slfeature('DesignReview_Comments')>0)
                designReviewRemoveResolvedComments(clientId);
            end
        end

        function showResolvedComments(clientId,showFlag)
            if(slfeature('DesignReview_Comments')>0)
                designReviewShowResolvedComments(clientId,showFlag);
            end
        end

        function nextComment(clientId)
            if(slfeature('DesignReview_Comments')>0)
                message.publish(['/designReview/',simulink.designreview.Util.getModelUid(clientId),'/navigate'],'Next');
            end
        end

        function previousComment(clientId)
            if(slfeature('DesignReview_Comments')>0)
                message.publish(['/designReview/',simulink.designreview.Util.getModelUid(clientId),'/navigate'],'Previous');
            end
        end

        function editComment(clientId,commentId,txt)
            if(slfeature('DesignReview_Comments')>0)
                designReviewEditComment(clientId,commentId,txt);
            end
        end

        function deleteComment(clientId,commentId)
            if(slfeature('DesignReview_Comments')>0)
                builtin('_designReviewDeleteComment',clientId,commentId);
            end
        end

        function deleteReply(clientId,commentId,replyId)
            if(slfeature('DesignReview_Comments')>0)
                builtin('_designReviewDeleteReply',clientId,commentId,replyId);
            end
        end

        function filterComments(clientId,isFilterEnabled,currentPath)
            if(slfeature('DesignReview_Comments')>0&&slfeature('DesignReviewFilterComments')>0)
                builtin('_designReviewFilterComments',clientId,isFilterEnabled,currentPath);
            end
        end

    end
end
