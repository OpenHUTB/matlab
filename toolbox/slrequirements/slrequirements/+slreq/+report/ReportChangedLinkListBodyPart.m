classdef ReportChangedLinkListBodyPart<slreq.report.ReportPart


    properties
        LinkOrderNum;
        LinkInfo;
        NeedStyle=true;
    end

    methods

        function part=ReportChangedLinkListBodyPart(p1,linkInfo,linkOrderNum)
            part=part@slreq.report.ReportPart(p1,'SLReqChangedLinkListBodyPart');
            part.LinkOrderNum=linkOrderNum;
            part.LinkInfo=linkInfo;
            if strcmpi(p1.Type,'docx')||strcmpi(p1.Type,'pdf')
                part.NeedStyle=true;
            else
                part.NeedStyle=false;
            end
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'linknumvalue'
                    fillnum(this);
                case 'linkicon'
                    filltype(this);
                case 'linknamevalue'
                    fillname(this);
                case 'changedtargetvalue'
                    fillchangedtarget(this);
                case 'changedtargettypevalue'
                    fillchangedtargettype(this);
                case 'storedinfovalue'
                    fillstoredinfo(this);
                case 'actualinfovalue'
                    fillactualinfo(this);
                end
                moveToNextHole(this);
            end
        end


        function fillnum(this)
            orderNum=mlreportgen.dom.Text(this.LinkOrderNum);
            if this.NeedStyle
                orderNum.StyleName='SLReqChangedLinkListNumValue';
            end
            append(this,orderNum);
        end


        function filltype(this)
            linkIcon=this.LinkInfo.LinkIcon;
            if this.NeedStyle
                linkIcon.StyleName='SLReqChangedLinkListItemValue';
            end
            append(this,linkIcon);
        end

        function fillname(this)
            content=mlreportgen.dom.Text(this.LinkInfo.LinkStr);

            if strcmpi(this.Type,'pdf')
                topcontent=mlreportgen.dom.CustomElement('span');
                topcontent.StyleName='SLReqChangedLinkListLinkItemValue';
                linkIcon=this.LinkInfo.LinkIcon;

                append(topcontent,linkIcon);
                append(topcontent,content);
            else
                topcontent=content;
                if this.NeedStyle
                    topcontent.StyleName='SLReqChangedLinkListItemValue';
                end
            end
            append(this,topcontent);
        end


        function fillchangedtargettype(this)
            content=mlreportgen.dom.Text(this.LinkInfo.ChangedTargetType);
            if this.NeedStyle
                content.StyleName='SLReqChangedLinkListChangedTargetValue';
            end
            append(this,content);
        end


        function fillchangedtarget(this)
            bookmarkstr=slreq.report.utils.getLinkTargetString(this.LinkInfo.ChangedTarget);
            content=mlreportgen.dom.InternalLink(bookmarkstr,this.LinkInfo.ChangedTarget);

            if strcmpi(this.Type,'pdf')

                topcontent=mlreportgen.dom.CustomElement('span');
                topcontent.append(content);
                content=mlreportgen.dom.Text(['(',this.LinkInfo.ChangedTargetType,')']);

                topcontent.append(content);
                topcontent.StyleName='SLReqChangedLinkListChangedTargetContent';
            else

                topcontent=content;
                if this.NeedStyle
                    topcontent.StyleName='SLReqChangedLinkListChangedTargetValue';
                end
            end
            append(this,topcontent);
        end


        function fillstoredinfo(this)
            content=mlreportgen.dom.Text(this.LinkInfo.StoredInfo);
            if this.NeedStyle
                content.StyleName='SLReqChangedLinkListStoredInfoValue';
            end
            append(this,content);
        end


        function fillactualinfo(this)
            content=mlreportgen.dom.Text(this.LinkInfo.ActualInfo);
            if this.NeedStyle
                content.StyleName='SLReqChangedLinkListActualInfoValue';
            end
            append(this,content);
        end
    end
end
