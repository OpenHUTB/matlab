classdef ReportArtifactListPart<slreq.report.ReportPart


    properties
        DomainType;
        ArtifactList;
    end

    methods

        function part=ReportArtifactListPart(p1,DomainType,artifactList)
            part=part@slreq.report.ReportPart(p1,'SLReqArtifactListPart');
            part.DomainType=DomainType;
            part.ArtifactList=artifactList;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'artifacttype'
                    filltype(this);
                case 'artifactlist'
                    filllist(this);
                end
                moveToNextHole(this);
            end
            endpart=slreq.report.ReqDummyPart(this);
            endpart.fill();
            append(this,endpart);
        end


        function filltype(this)
            switch this.DomainType
            case 'slreq'
                msgID='Slvnv:slreq:ReportContentArtifactTypeSLREQ';
            case 'slmodel'
                msgID='Slvnv:slreq:ReportContentArtifactTypeSLMODEL';
            case 'sltest'
                msgID='Slvnv:slreq:ReportContentArtifactTypeSLTEST';
            case 'sldata'
                msgID='Slvnv:slreq:ReportContentArtifactTypeSLDATA';
            case 'other'
                msgID='Slvnv:slreq:ReportContentArtifactTypeOthers';
            otherwise

                error('invalid types');
            end
            artiStr=mlreportgen.dom.Text(getString(message(msgID)),'SLReqArtifactListName');
            append(this,artiStr);
        end


        function filllist(this)

            if strcmpi(this.Type,'pdf')
                fillArtifactListForPDF(this)
                return;
            end
            headerPart=slreq.report.ReportArtifactListHeaderPart(this,this.DomainType);
            headerPart.fill;
            append(this,headerPart);

            this.filllistdetails();
        end


        function filllistdetails(this)
            allArtifactList=this.ArtifactList;
            for index=1:length(allArtifactList)
                cArtifact=allArtifactList{index};
                artiData=getArtiInfo(cArtifact);
                bodyPart=slreq.report.ReportArtifactListBodyPart(this,artiData,num2str(index),this.DomainType);
                bodyPart.fill;
                append(this,bodyPart);
            end
        end

        function fillArtifactListForPDF(this)

            tb=mlreportgen.dom.Table();
            tb.StyleName='SLReqArtifactListTable';
            tb.Width='550px';

            tRow=mlreportgen.dom.TableRow();


            content=mlreportgen.dom.Text('#');
            content.StyleName='SLReqArtifactListNumName';
            tCell=slreq.report.utils.createTableCell(content,true);

            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentArtifactListHeaderName')));
            content.StyleName='SLReqArtifactListItemName';

            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentArtifactListHeaderFolder')));

            content.StyleName='SLReqArtifactListFolderName';

            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);


            switch this.DomainType
            case 'slmodel'
                content=mlreportgen.dom.Text(...
                getString(message('Slvnv:slreq:ReportContentArtifactListHeaderRevisionForSLMODEL')));
            case 'slreq'
                content=mlreportgen.dom.Text(...
                getString(message('Slvnv:slreq:ReportContentArtifactListHeaderRevision')));
            otherwise
                content=mlreportgen.dom.Text(...
                getString(message('Slvnv:slreq:ReportContentArtifactListHeaderTimestamp')));
            end

            content.StyleName='SLReqArtifactListRevisionName';

            tCell=slreq.report.utils.createTableCell(content,true);
            tRow.append(tCell);
            tb.append(tRow);


            allArtifactList=this.ArtifactList;
            for index=1:length(allArtifactList)
                cArtifact=allArtifactList{index};
                artiData=getArtiInfo(cArtifact);
                tRow=mlreportgen.dom.TableRow();


                content=mlreportgen.dom.Text(num2str(index));
                content.StyleName='SLReqArtifactListNumValue';

                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);


                content=mlreportgen.dom.Text(artiData.ShortName);
                content.StyleName='SLReqArtifactListItemValue';

                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);


                if isempty(artiData.Folder)
                    contentStr=getString(message('Slvnv:slreq:ReportContentArtifactListBodyUnresolved'));
                else
                    contentStr=artiData.Folder;
                end
                content=mlreportgen.dom.Text(contentStr);

                content.StyleName='SLReqArtifactListFolderValue';
                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);


                contentStr=artiData.getExtraInfoForArtifactListBody;
                content=mlreportgen.dom.Text(contentStr);

                content.StyleName='SLReqArtifactListRevisionValue';

                tCell=slreq.report.utils.createTableCell(content,false);
                tRow.append(tCell);
                tb.append(tRow);
            end

            this.append(tb);
        end

    end
end


function artiData=getArtiInfo(artifactFullPath)
    artiData=slreq.report.ReportArtifactData(artifactFullPath);
    artiData.updateFileUri;
    artiData.refreshArtiInfo;
end