classdef BaseAdapter<handle




    properties(GetAccess=public,SetAccess=protected)
        domain='';
        currentArtifact='';
    end

    methods(Abstract)


        tf=isResolved(this,artifactUri,artifactId)


        out=getSummary(this,artifactUri,artifactId)


        out=getIcon(this,artifactUri,artifactId)


        out=getTooltip(this,artifactUri,artifactId)


        out=getSourceObject(this,artifactUri,artifactId)




        success=select(this,artifactUri,artifactId,editor)



        success=highlight(this,artifactUri,artifactId,editor)


        success=onClickHyperlink(this,artifactUri,artifactId);




        str=getClickActionCommandString(this,artifactUri,artifactId,caller);





        fullPath=getFullPathToArtifact(~,artifact,refPath);
    end

    methods(Access=public)
        function artifactUri=getArtifactUri(this,obj)
            if isa(obj,'slreq.data.SourceItem')
                artifactUri=this.getArtifactUriFromSourceItem(obj);
            elseif isa(obj,'slreq.data.Requirement')
                artifactUri=this.getArtifactUriFromReq(obj);
            else
                assert(false,'Unexpected input specified')
            end
        end

        function artifactId=getArtifactId(this,obj)
            if isa(obj,'slreq.data.SourceItem')
                artifactId=this.getArtifactIdFromSourceItem(obj);
            elseif isa(obj,'slreq.data.Requirement')
                artifactId=this.getArtifactIdFromReq(obj);
            else
                assert(false,'Unexpected input specified')
            end
        end

        function artifactUri=getArtifactUriFromReq(this,dataReq)%#ok<INUSL>
            artifactUri=dataReq.artifactUri;
        end

        function artifactUri=getArtifactUriFromSourceItem(this,srcItem)%#ok<INUSL>
            artifactUri=srcItem.artifactUri;
        end

        function artifactId=getArtifactIdFromReq(this,dataReq)%#ok<INUSL>
            artifactId=dataReq.artifactId;
        end

        function artifactId=getArtifactIdFromSourceItem(this,srcItem)%#ok<INUSL>
            artifactId=srcItem.id;
        end

        function str=getLinkLabel(this,artifact,id)





            itemName=this.getSummary(artifact,id);
            shortFilename=slreq.uri.getShortNameExt(artifact);
            str=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',itemName,shortFilename));
        end

        function str=getGlobalUniqueId(~,artifact,id)





            if nargin<3||isempty(id)
                str=artifact;
                return;
            end
            str=sprintf('%s:%s',artifact,id);
        end

        function navCmd=getExternalNavCmd(this,artifactUri,artifactId)



            navCmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''')',this.domain,artifactUri,artifactId);
        end

        function str=getURL(this,artifactUri,artifactId)






            navCmd=this.getExternalNavCmd(artifactUri,artifactId);
            str=rmiut.cmdToUrl(navCmd,false);
        end

        function[icon,summary,tooltip]=getIconSummaryTooltipFromReq(this,dataReq,artifactUri,artifactId)%#ok<INUSL>

            icon=this.getIcon(artifactUri,artifactId);
            summary=this.getSummary(artifactUri,artifactId);
            tooltip=this.getTooltip(artifactUri,artifactId);
        end

        function[icon,summary,tooltip]=getIconSummaryTooltipFromSourceItem(this,srcItem,artifactUri,artifactId)%#ok<INUSL>

            icon=this.getIcon(artifactUri,artifactId);
            summary=this.getSummary(artifactUri,artifactId);
            tooltip=this.getTooltip(artifactUri,artifactId);
        end



        function refreshLinkOwner(this,linkedArtifact,linkedId,oldDestInfo,newDestInfo)%#ok<INUSD>

        end





        function tf=isImplementingSaveAs(~)
            tf=false;
        end


        function postSaveAsReset(this,artifactName)%#ok<INUSD>

        end


        function postSaveAsUpdate(~,dataObj)%#ok<INUSD>

        end

        function linkType=getDefaultLinkType(this,artifactUri,artifactId)%#ok<INUSD>
            linkType=slreq.custom.LinkType.Relate;
        end

        function tf=isUpdateNotificationAvailable(this)%#ok<MANU>


            tf=false;
        end

        function updatedLabel=updateLabelOnArtifactRename(~,origLabel,oldArtifactName,newArtifactName)










            oldNameButNotPartOfALongerWord=['(^|\W)',oldArtifactName,'(\W|$)'];
            replacement=['$1',newArtifactName,'$2'];
            updatedLabel=regexprep(origLabel,oldNameButNotPartOfALongerWord,replacement);
        end






        function preSave(~,dataLinkSet)%#ok<INUSD>

        end



        function postSave(~,dataLinkSet,destinationArtifactFilePathIfDifferent)%#ok<INUSD>

        end




        function tfArray=isHiddenLink(~,dataLinks)
            tfArray=false(size(dataLinks));
        end






        function[status,revisionInfo]=getRevisionInfo(~,~)
            status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
            revisionInfo=slreq.utils.DefaultValues.getRevisionInfo();
        end

    end

end
