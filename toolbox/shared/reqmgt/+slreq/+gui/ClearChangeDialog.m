classdef ClearChangeDialog<handle




    properties(Access=private)
        NumOfLinksToBeCleared=0;
        NumOfIssuesToBeCleared=0;
        TargetWithChangeIssue;
        FieldWithChangeIssue='';
        IncludeMetaData=true;
        DialogTitle;
    end


    methods

        function this=ClearChangeDialog(dasLinkOrLinkSet,fieldWithChangeIssue)



            if isa(dasLinkOrLinkSet,'slreq.das.LinkSet')
                this.NumOfLinksToBeCleared=length(unique(...
                [dasLinkOrLinkSet.ChangedSource.keys,...
                dasLinkOrLinkSet.ChangedDestination.keys]));
                this.NumOfIssuesToBeCleared=...
                dasLinkOrLinkSet.NumberOfChangedSource+...
                dasLinkOrLinkSet.NumberOfChangedDestination;
                this.FieldWithChangeIssue='LinkSet';
            elseif isa(dasLinkOrLinkSet,'slreq.das.Link')
                this.NumOfLinksToBeCleared=0;
                this.NumOfIssuesToBeCleared=0;
                this.FieldWithChangeIssue=fieldWithChangeIssue;
            else

                error('Wrong Object is Given');
            end
            this.TargetWithChangeIssue=dasLinkOrLinkSet;
            setDialogTitle(this);
        end



        function setDialogTitle(this)
            if isa(this.TargetWithChangeIssue,'slreq.das.LinkSet')
                this.DialogTitle=getString(...
                message('Slvnv:slreq:ClearChangeDialogTitleForLinkSet',...
                this.NumOfIssuesToBeCleared));
            elseif isa(this.TargetWithChangeIssue,'slreq.das.Link')
                this.DialogTitle=getString(...
                message('Slvnv:slreq:ClearChangeDialogTitleForLink'));
            else

            end
        end


        function dlgstruct=getDialogSchema(this)




            commentEditArea=getCommentEditArea(this);



            bottomPart=getBottemButtonPart(this);

            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.DialogTag='slreq_clearchange';
            dlgstruct.CloseMethod='callBackCancelButton';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};
            dlgstruct.Sticky=true;



            if isa(this.TargetWithChangeIssue,'slreq.das.LinkSet')



                notePanel=getNoteArea(this);
                dlgstruct.DialogTitle=this.DialogTitle;
                dlgstruct.LayoutGrid=[3,1];
                dlgstruct.RowStretch=[1,0,0];

                dlgstruct.Items={commentEditArea,...
                notePanel,bottomPart};
            else
                dlgstruct.DialogTitle=this.DialogTitle;
                dlgstruct.LayoutGrid=[2,1];
                dlgstruct.RowStretch=[1,0];
                dlgstruct.Items={commentEditArea,bottomPart};
            end
        end


        function show(this)
            dlg=findDDGByTag('slreq_clearchange');



            if ishandle(dlg)
                dlg.show;
            else
                DAStudio.Dialog(this);
            end
        end


        function commentArea=getCommentEditArea(this)
            commentValue=struct('Type','editarea','PreferredSize',[600,200],...
            'RowSpan',[2,2],'ColSpan',[1,1],...
            'Tag','editarea_slreqClearChangeCommentArea','WidgetId','CommentText');

            commentValue.Value=this.getDefaultCommentValue;
            commentValue.ToolTip=getString(message('Slvnv:slreq:ClearChangeDialogEditAreaToolTip'));
            commentValue.Graphical=true;
            commentValue.Mode=true;


            commentArea.Type='group';
            commentArea.Tag='slreq_clearchangeCommentAreaGroup';
            commentArea.Name=getString(message('Slvnv:slreq:ClearChangeDialogCommentTitile'));
            commentArea.LayoutGrid=[2,2];

            commentArea.Items={commentValue};
            commentArea.Enabled=true;
        end


        function defaultComment=getDefaultCommentValue(this)
            changeDetails=this.getChangeDetailsForComment();
            defaultComment=changeDetails;
        end


        function noteArea=getNoteArea(this)









            expTimeChange=getString(message(...
            'Slvnv:slreq:ClearChangeDialogCommentTimeStampChange',slreq.utils.DefaultValues.getTimeZoneOffsetString(),...
            datestr(now),...
            slreq.utils.getDateStr(this.TargetWithChangeIssue.CreatedOn)));

            exampleStr=[getString(message(...
            'Slvnv:slreq:ClearChangeDialogCommentSourceUpdated')),...
            '',expTimeChange];
            note.WordWrap=true;
            note.Type='text';
            note.Alignment=2;
            note.Name=getString(message('Slvnv:slreq:ClearChangeDialogNoteContent',slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO,exampleStr));
            note.Tag='text_slreqClearchangeNote';
            note.RowSpan=[1,1];
            note.ColSpan=[1,1];

            noteArea.Type='group';
            noteArea.Tag='slreq_clearchangeNoteArea';
            noteArea.Name=getString(message('Slvnv:slreq:Note'));
            noteArea.LayoutGrid=[1,1];
            noteArea.Items={note};
            noteArea.Enabled=true;
        end


        function bottomPart=getBottemButtonPart(this)
            if isa(this.TargetWithChangeIssue,'slreq.das.LinkSet')
                clearIssueButton.Name=getString(message('Slvnv:slreq:ChangeInfoPanelClearAll'));
            else
                clearIssueButton.Name=getString(message('Slvnv:slreq:ChangeInfoPanelClear'));
            end
            clearIssueButton.Tag='slreq_clearchangeClearIssueButton';
            clearIssueButton.Type='pushbutton';
            clearIssueButton.RowSpan=[1,1];
            clearIssueButton.ColSpan=[2,2];
            clearIssueButton.ObjectMethod='callBackClearIssue';
            clearIssueButton.MethodArgs={'%dialog'};
            clearIssueButton.ArgDataTypes={'handle'};
            clearIssueButton.ToolTip='';

            cancelButton.Name=getString(message('Slvnv:slreq:Cancel'));
            cancelButton.Tag='slreq_clearchangeCancelButton';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[3,3];
            cancelButton.ObjectMethod='callBackCancelButton';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};










            bottomPart.Tag='slreq_clearChangeButtonGroup';
            bottomPart.LayoutGrid=[1,4];
            bottomPart.Name='';
            bottomPart.Type='panel';
            bottomPart.ColStretch=[1,0,0,0];
            bottomPart.Items={clearIssueButton,cancelButton};
            bottomPart.Enabled=true;
        end

    end

    methods(Access=public)

        function callBackCancelButton(~,dlg)
            dlg.delete();
        end


        function callBackClearIssue(this,dlg)
            if isa(this.TargetWithChangeIssue,'slreq.das.LinkSet')
                this.TargetWithChangeIssue.clearAllChangeIssues(...
                dlg.getWidgetValue('editarea_slreqClearChangeCommentArea'));
            elseif isa(this.TargetWithChangeIssue,'slreq.das.Link')
                if isscalar(this.TargetWithChangeIssue)
                    if strcmpi(this.FieldWithChangeIssue,'source')
                        this.TargetWithChangeIssue.clearLinkedSourceIssue(...
                        dlg.getWidgetValue('editarea_slreqClearChangeCommentArea'));
                    elseif strcmpi(this.FieldWithChangeIssue,'destination')
                        this.TargetWithChangeIssue.clearLinkedDestinationIssue(...
                        dlg.getWidgetValue('editarea_slreqClearChangeCommentArea'));
                    else
                        error('invalid change type');
                    end
                elseif numel(this.TargetWithChangeIssue)>1

                    appmgr=slreq.app.MainManager.getInstance();
                    appmgr.notify('SleepUI');
                    clp=onCleanup(@()postUpdate(appmgr));

                    comment=dlg.getWidgetValue('editarea_slreqClearChangeCommentArea');
                    for n=1:length(this.TargetWithChangeIssue)
                        dasLink=this.TargetWithChangeIssue(n);
                        if dasLink.hasChangedSource
                            dasLink.clearLinkedSourceIssue(comment);
                        end
                        if dasLink.hasChangedDestination
                            dasLink.clearLinkedDestinationIssue(comment);
                        end
                    end
                end
            else

            end
            dlg.delete();
        end


        function metaData=getChangeDetailsForComment(this)
            if strcmpi(this.FieldWithChangeIssue,'LinkSet')||numel(this.TargetWithChangeIssue)>1
                metaData=slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO;
            elseif strcmpi(this.FieldWithChangeIssue,'source')
                metaData=slreq.analysis.ChangeTrackingClearVisitor.getSrcChangeInfoComment(this.TargetWithChangeIssue.dataModelObj);
            elseif strcmpi(this.FieldWithChangeIssue,'destination')
                metaData=slreq.analysis.ChangeTrackingClearVisitor.getDstChangeInfoComment(this.TargetWithChangeIssue.dataModelObj);
            else
                error('Wrong type is given');
            end
        end
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.changeTracker.updateViews();
end
