classdef ReqItemPart<slreq.report.ReportPart


    properties

        ReqInfo;
        Level;
AllCustomAttributes
    end

    methods

        function part=ReqItemPart(p1,level,reqInfo)

            if isempty(reqInfo.description)
                partName='SLReqReqEmptyPart';
            else
                partName='SLReqReqPart';
            end
            part=part@slreq.report.ReportPart(p1,partName);
            part.Level=level;
            part.ReqInfo=reqInfo;
            part.AllCustomAttributes=p1.AllCustomAttributes;
        end


        function fill(this)
            slreq.utils.updateProgress(this.ShowUI,...
            'update',...
            getString(message('Slvnv:slreq:ReportGenProgressBarFillBodyReqItem')));
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'title'
                    headingStr=sprintf('%s %s',this.ReqInfo.index,this.ReqInfo.summary);
                    reqBookMark=slreq.report.utils.getAnchorString(this.ReqInfo);
                    text=mlreportgen.dom.Heading(this.Level,...
                    mlreportgen.dom.LinkTarget(reqBookMark));
                    text.append(headingStr);
                    text.Style={mlreportgen.dom.CounterInc('subsection'),...
                    mlreportgen.dom.WhiteSpace('preserve'),...
                    mlreportgen.dom.OuterMargin('0in','0pt','0pt','0pt'),...
                    mlreportgen.dom.LineSpacing(1)};
                    text.StyleName=['SLReqReqTitle',num2str(this.Level)];
                    if~isempty(text)
                        append(this,text);
                    end

                case 'requirementtypename'
                    str=getString(message('Slvnv:slreq:ReportContentRequirementType'));
                    text=mlreportgen.dom.Text(str,'SLReqReqTypeName');
                    append(this,text);

                case 'customidname'
                    str=getString(message('Slvnv:slreq:ReqID'));
                    text=mlreportgen.dom.Text(str,'SLReqReqCustomIDName');
                    if~isempty(text)
                        append(this,text);
                    end
                case 'customidvalue'
                    str=this.ReqInfo.id;
                    text=mlreportgen.dom.Text(str,'SLReqReqCustomIDValue');
                    if~isempty(text)
                        append(this,text);
                    end

                case 'requirementtypevalue'
                    if this.ReqInfo.isJustification
                        typevalue='N/A';
                    elseif this.ReqInfo.isChildOfInformationalType()
                        typevalue=slreq.app.RequirementTypeManager.getDisplayName('Informational');
                    else
                        typevalue=slreq.app.RequirementTypeManager.getDisplayName(this.ReqInfo.typeName);
                    end
                    text=mlreportgen.dom.Text(typevalue,'SLReqReqTypeValue');
                    append(this,text);

                case 'descriptionname'
                    str=getString(message('Slvnv:slreq:Description'));
                    text=mlreportgen.dom.Text(str,'SLReqReqDescriptionName');
                    if~isempty(text)
                        append(this,text);
                    end
                case 'descriptionvalue'
                    try
                        tReqSet=this.ReqInfo.getReqSet;
                        dasDescription=tReqSet.unpackImages(this.ReqInfo.description);
                        text=slreq.report.utils.createDOMForRichText(dasDescription,this.ReqInfo.external,this.Type);
                    catch ex %#ok<NASGU>



                        partname=getString(message('Slvnv:slreq:Description'));
                        rmiut.warnNoBacktrace('Slvnv:slreq:ReportGenWarnInvalidHTML',partname,this.ReqInfo.id,this.ReqInfo.getReqSet.name);
                        errorMsg=getString(message('Slvnv:slreq:ReportInvalidContent'));
                        text=mlreportgen.dom.Text(errorMsg);
                        text.StyleName='SLReqReqDescriptionValueError';
                    end

                    if isempty(text)
                        text=mlreportgen.dom.Text('   ','SLReqReqDescriptionValue');
                        append(this,text);
                    else
                        append(this,text);
                    end

                end

                moveToNextHole(this);
            end

            if this.ReportOptions.includes.rationale
                this.fillRationale();
            end

            if this.ReportOptions.includes.keywords
                this.fillKeywords();
            end

            if this.ReportOptions.includes.revision
                this.fillAttributes();
            end

            if this.ReportOptions.includes.customAttributes
                this.fillCustomAttributes();
            end

            if this.ReportOptions.includes.links
                if this.ReportOptions.includes.changeInformation
                    this.fillChangeInfo();
                end
                this.fillLinks();

            end

            if this.ReportOptions.includes.implementationStatus
                this.fillImplementationStatus();
            end

            if this.ReportOptions.includes.verificationStatus
                this.fillVerificationStatus();
            end

            if this.ReportOptions.includes.comments
                this.fillComments();
            end

            this.fillChildren();
        end


        function fillRationale(this)
            rationale=this.ReqInfo.rationale;
            if isempty(rationale)&&~this.ReportOptions.includes.emptySections
                return;
            end

            part=slreq.report.ReqRationalePart(this);
            part.fill();
            append(this,part);
        end


        function fillKeywords(this)
            keyWords=this.ReqInfo.keywords;
            if isempty(keyWords)&&~this.ReportOptions.includes.emptySections
                return;
            end
            part=slreq.report.ReqKeywordsPart(this);
            part.fill();
            append(this,part);
        end


        function fillChangeInfo(this)

            if this.ReqInfo.changedLinkAsSrc.Count>0...
                ||this.ReqInfo.changedLinkAsDst.Count>0
                hasChangeIssue=true;
            else
                hasChangeIssue=false;
            end
            part=slreq.report.ReqChangeInfoPart(this,hasChangeIssue,'req');
            part.fill();
            append(this,part);
        end


        function fillAttributes(this)
            attpart=slreq.report.ReqRevisionPart(this);
            attpart.fill();
            append(this,attpart);
        end


        function fillCustomAttributes(this)
            if isempty(this.AllCustomAttributes)&&~this.ReportOptions.includes.emptySections
                return;
            end
            attpart=slreq.report.ReqCustomAttributesPart(this);
            attpart.fill();
            append(this,attpart);
        end


        function fillLinks(this)

            if strcmp(this.ReportOptions.includes.groupLinksBy,'Artifact')
                [outMap,grouplist,totallinks]=slreq.report.utils.groupLinks(this.ReqInfo,'linkartifact');
                groupByArtifact=true;
            else
                [outMap,grouplist,totallinks]=slreq.report.utils.groupLinks(this.ReqInfo,'linktype');
                groupByArtifact=false;
            end

            if isempty(totallinks)&&~this.ReportOptions.includes.emptySections
                return;
            end
            linkInfo.outMap=outMap;
            linkInfo.grouplist=grouplist;
            linkInfo.totallinks=totallinks;
            linkInfo.groupByArtifact=groupByArtifact;
            linkspart=slreq.report.ReqLinksPart(this,linkInfo);

            linkspart.fill();
            append(this,linkspart);
        end


        function fillImplementationStatus(this)
            impStatus=slreq.report.utils.getReqStatus(...
            this.ReqInfo,'implementationstatus',false);
            if impStatus(1)==0&&~this.ReportOptions.includes.emptySections
                return;
            end
            part=slreq.report.ReqImplementationPart(this,impStatus,'item');
            part.fill
            append(this,part);
        end


        function fillVerificationStatus(this)
            verStatus=slreq.report.utils.getReqStatus(...
            this.ReqInfo,'verificationstatus',false);

            if verStatus(1)==0&&~this.ReportOptions.includes.emptySections
                return;
            end

            part=slreq.report.ReqVerificationPart(this,verStatus,'item');
            part.fill;
            append(this,part);
        end


        function fillComments(this)
            allComments=this.ReqInfo.comments;

            if isempty(allComments)&&~this.ReportOptions.includes.emptySections
                return;
            end

            part=slreq.report.ReqCommentsPart(this,allComments);
            part.fill;
            append(this,part);
        end


        function fillChildren(this)
            for childindex=1:length(this.ReqInfo.children)
                reqInfo=this.ReqInfo.children(childindex);
                reqItem=slreq.report.ReqItemPart(...
                this,min(this.Level+1,6),reqInfo);
                reqItem.fill();
                append(this,reqItem);
            end
        end
    end

    methods(Access=private)

        function tf=exportEmptyPart(this,sectionName)
            switch lower(sectionName)
            case 'links'
                tf=this.ReportOptions.includes.emptySections...
                ||~hasNoLinks(this.ReqInfo);
            case 'comments'
                tf=this.ReportOptions.includes.emptySections...
                ||~isempty(this.ReqInfo.comments);
            case 'content'
                tf=this.ReportOptions.includes.emptySections...
                ||~isempty(this.ReqInfo.description);
            case 'teststatus'
                tf=this.ReportOptions.includes.emptySections;
            otherwise
                error('unknown cases.')
            end

        end
    end
end


function out=hasNoLinks(reqitem)
    [incominglinks,outgoinglinks]=reqitem.getLinks();
    out=isempty(incominglinks)&&isempty(outgoinglinks);
end
