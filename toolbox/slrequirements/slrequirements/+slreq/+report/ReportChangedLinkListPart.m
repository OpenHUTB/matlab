classdef ReportChangedLinkListPart<slreq.report.ReportPart


    properties
        LinkList;
    end

    methods

        function part=ReportChangedLinkListPart(p1,linkList)
            part=part@slreq.report.ReportPart(p1,'SLReqChangedLinkListPart');
            part.LinkList=linkList;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'changedlinklisttitle'
                    filltitle(this);
                case 'changedlinklist'
                    filllist(this);
                end
                moveToNextHole(this);
            end
            endpart=slreq.report.ReqDummyPart(this);
            endpart.fill();
            append(this,endpart);
        end


        function filltitle(this)
            titleBookmark=mlreportgen.dom.LinkTarget(slreq.report.Report.CHANGED_LINK_LIST_TARGET);
            linkTableTitle=mlreportgen.dom.Heading(2,titleBookmark);
            titleStr=getString(message('Slvnv:slreq:ReportContentChangedLinkListTitle'));
            linkTableTitle.append(titleStr);

            linkTableTitle.StyleName='SLReqChangedLinkListTitle';
            linkTableTitle.Style={mlreportgen.dom.CounterInc('subsection'),...
            mlreportgen.dom.WhiteSpace('preserve'),...
            mlreportgen.dom.OuterMargin('0in','0pt','0pt','0pt'),...
            mlreportgen.dom.LineSpacing(1),...
            mlreportgen.dom.PageBreakBefore(true)};
            append(this,linkTableTitle);
        end


        function filllist(this)

            if strcmpi(this.Type,'pdf')
                fillChangedLinkListForPDF(this)
                return;
            end
            headerPart=slreq.report.ReportChangedLinkListHeaderPart(this);
            headerPart.fill;
            append(this,headerPart);

            this.filllistdetails();
        end


        function filllistdetails(this)
            allLinks=this.LinkList.keys;
            for index=1:length(allLinks)
                cLink=allLinks{index};
                linkInfo=this.LinkList(cLink);
                bodyPart=slreq.report.ReportChangedLinkListBodyPart(this,linkInfo,num2str(index));
                bodyPart.fill;
                append(this,bodyPart);
            end
        end

        function fillChangedLinkListForPDF(this)

            tb=mlreportgen.dom.Table();
            tb.StyleName='SLReqChangedLinkListTable';

            tRow=mlreportgen.dom.TableRow();


            content=mlreportgen.dom.Text('#');
            content.StyleName='SLReqChangedLinkListNumName';
            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderItem')));

            content.StyleName='SLReqChangedLinkListItemName';
            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderChangedTarget')));

            content.StyleName='SLReqChangedLinkListChangedTargetName';
            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderStoredInfo')));
            content.StyleName='SLReqChangedLinkListStoredInfoName';
            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentChangedLinkListHeaderActualInfo')));

            content.StyleName='SLReqChangedLinkListActualInfoName';
            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);
            tb.append(tRow);

            allLinks=this.LinkList.keys;

            for index=1:length(allLinks)
                cLink=allLinks{index};
                linkInfo=this.LinkList(cLink);
                tRow=mlreportgen.dom.TableRow();

                content=mlreportgen.dom.Text(num2str(index));
                content.StyleName='SLReqChangedLinkListNumValue';
                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);


                linkIcon=linkInfo.LinkIcon;
                tCell=slreq.report.utils.createTableCell(linkIcon,false);
                content=mlreportgen.dom.Text(linkInfo.LinkStr);
                content.StyleName='SLReqChangedLinkListItemValue';
                tCell.append(content);

                tRow.append(tCell);


                bookmarkstr=slreq.report.utils.getLinkTargetString(linkInfo.ChangedTarget);
                content=mlreportgen.dom.InternalLink(bookmarkstr,linkInfo.ChangedTarget);
                content.StyleName='SLReqChangedLinkListChangedTargetValue';
                tCell=slreq.report.utils.createTableCell(content,false);
                content=mlreportgen.dom.Text(['(',linkInfo.ChangedTargetType,')']);
                content.StyleName='SLReqChangedLinkListChangedTargetValue';
                tCell.append(content);
                tRow.append(tCell);


                content=mlreportgen.dom.Text(linkInfo.StoredInfo);
                content.StyleName='SLReqChangedLinkListStoredInfoValue';
                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);


                content=mlreportgen.dom.Text(linkInfo.ActualInfo);
                content.StyleName='SLReqChangedLinkListActualInfoValue';
                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);

                tb.append(tRow);
            end
            this.append(tb);

        end
    end
end