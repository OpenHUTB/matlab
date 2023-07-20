classdef ChangeTrackingClearVisitor<slreq.analysis.ChangeTrackingVisitor








    properties(Constant)



        COMMENT_INDENTATION='    ';
        MACRO_UPDATE_INFO='%<updateInfo>';
    end

    properties

        ClearDestination=false;
        ClearSource=false;


        RawComments='';

        Comments='';

    end

    methods
        function this=ChangeTrackingClearVisitor()

        end

        function setClearTarget(this,value)
            switch value
            case 'Destination'
                this.ClearDestination=true;
                this.ClearSource=false;
            case 'Source'
                this.ClearSource=true;
                this.ClearDestination=false;
            case 'All'
                this.ClearDestination=true;
                this.ClearSource=true;
            end
        end

        function setComment(this,value)
            this.RawComments=value;
        end


        function visitRequirementSet(this,dataReqSet)

        end


        function visitRequirement(this,dataReq)

            [inDataLinks,outDataLinks]=dataReq.getLinks;


            this.visitLinks(inDataLinks);
            this.visitLinks(outDataLinks);
        end


        function visitLinkSet(this,dataLinkSet)
















            dataLinkSet.resetChangeInfo();

            allDataLinks=dataLinkSet.getAllLinks;
            this.visitLinks(allDataLinks);
        end


        function visitLink(this,dataLink)

            addComment=false;


            this.Comments=this.RawComments;


            this.convertRawComments(dataLink);



            if this.ClearDestination
                if dataLink.destinationChangeStatus.isFail


                    dataLink.linkedDestinationRevision=dataLink.currentDestinationRevision;


                    dataLink.linkedDestinationTimeStamp=datetime(...
                    dataLink.currentDestinationTimeStamp,...
                    'ConvertFrom','posixtime','TimeZone','UTC');
                    if slreq.utils.hasValidDest(dataLink)
                        dataLink.destinationChangeStatus=slreq.analysis.ChangeStatus.Pass;
                        destination=dataLink.dest;

                        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(destination.domain);
                        [~,info]=adapter.getRevisionInfo(destination);
                        this.removeChangedLinkAsDst(info.uuid,dataLink.getUuid);
                    else
                        dataLink.destinationChangeStatus=slreq.analysis.ChangeStatus.InvalidLink;
                    end
                    addComment=true;
                end
            end

            if this.ClearSource
                if dataLink.sourceChangeStatus.isFail
                    dataLink.linkedSourceRevision=dataLink.currentSourceRevision;


                    dataLink.linkedSourceTimeStamp=datetime(...
                    dataLink.currentSourceTimeStamp,...
                    'ConvertFrom','posixtime','TimeZone','UTC');
                    dataSource=dataLink.source;
                    if dataSource.isValid
                        dataLink.sourceChangeStatus=slreq.analysis.ChangeStatus.Pass;


                        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(dataSource.domain);
                        [~,info]=adapter.getRevisionInfo(dataSource);
                        this.removeChangedLinkAsSrc(info.uuid,dataLink.getUuid);
                    else
                        dataLink.sourceChangeStatus=slreq.analysis.ChangeStatus.InvalidLink;
                    end
                    addComment=true;
                end
            end
            if addComment
                this.addComments(dataLink);
            end
            dataLinkSet=dataLink.getLinkSet;
            dataLinkSet.updateChangedLink(dataLink);
        end


        function convertRawComments(this,dataLink)







            if contains(this.RawComments,slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO)
                if dataLink.sourceChangeStatus.isFail||dataLink.destinationChangeStatus.isFail
                    srcCommentStr=this.getSrcChangeInfoComment(dataLink);
                    dstCommentStr=this.getDstChangeInfoComment(dataLink);
                    if~isempty(srcCommentStr)||~isempty(dstCommentStr)
                        changeInfo=[srcCommentStr,dstCommentStr];
                        this.Comments=strrep(this.RawComments,slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO,changeInfo);
                    end
                end
            end
        end


        function addComments(this,dataLink)
            if~isempty(this.Comments)
                comment=dataLink.addComment;
                comment.Text=this.Comments;
            end
        end
    end

    methods(Access=private)

        function visitLinks(this,dataLinks)
            for index=1:length(dataLinks)
                cDataLink=dataLinks(index);
                this.visitLink(cDataLink);
            end
        end
    end

    methods(Static)

        function commentStr=getSrcChangeInfoComment(dataLink)






            if isequal(...
                dataLink.linkedSourceRevision,...
                dataLink.currentSourceRevision)
                revisionChange='';
            else
                revisionChange=[slreq.analysis.ChangeTrackingClearVisitor.COMMENT_INDENTATION,getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentRevisionChange',...
                dataLink.currentSourceRevision,...
                dataLink.linkedSourceRevision))];
            end

            if dataLink.currentSourceTimeStamp==0||isequal(...
                dataLink.linkedSourceTimeStamp,...
                dataLink.currentSourceTimeStamp)
                timeChange='';
            else
                timeChange=[slreq.analysis.ChangeTrackingClearVisitor.COMMENT_INDENTATION,getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentTimeStampChange',...
                slreq.utils.DefaultValues.getTimeZoneOffsetString(),...
                slreq.utils.getDateStr(dataLink.currentSourceTimeStamp),...
                slreq.utils.getDateStr(dataLink.linkedSourceTimeStamp)))];
            end

            if isempty(revisionChange)&&isempty(timeChange)
                commentStr='';
            else
                commentStr=[getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentSourceUpdated')),...
                revisionChange,timeChange];
            end
        end



        function commentStr=getDstChangeInfoComment(dataLink)




            if isequal(...
                dataLink.linkedDestinationRevision,...
                dataLink.currentDestinationRevision)
                revisionChange='';
            else
                revisionChange=[slreq.analysis.ChangeTrackingClearVisitor.COMMENT_INDENTATION,getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentRevisionChange',...
                dataLink.currentDestinationRevision,...
                dataLink.linkedDestinationRevision))];
            end

            if dataLink.currentDestinationTimeStamp==0||isequal(...
                dataLink.linkedDestinationTimeStamp,...
                dataLink.currentDestinationTimeStamp)
                timeChange='';
            else
                timeChange=[slreq.analysis.ChangeTrackingClearVisitor.COMMENT_INDENTATION,getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentTimeStampChange',...
                slreq.utils.DefaultValues.getTimeZoneOffsetString(),...
                slreq.utils.getDateStr(dataLink.currentDestinationTimeStamp),...
                slreq.utils.getDateStr(dataLink.linkedDestinationTimeStamp)))];
            end

            if isempty(revisionChange)&&isempty(timeChange)
                commentStr='';
            else
                commentStr=[getString(message(...
                'Slvnv:slreq:ClearChangeDialogCommentDestinationUpdated')),...
                revisionChange,timeChange];
            end
        end

    end
end


