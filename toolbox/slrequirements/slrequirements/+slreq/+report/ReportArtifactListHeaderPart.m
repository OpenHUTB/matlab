classdef ReportArtifactListHeaderPart<slreq.report.ReportPart


    properties
        DomainType;
        NeedStyle=true;
    end

    methods

        function part=ReportArtifactListHeaderPart(p1,domainType)
            part=part@slreq.report.ReportPart(p1,'SLReqArtifactListHeaderPart');
            part.DomainType=domainType;
            if strcmpi(p1.Type,'docx')
                part.NeedStyle=true;
            else
                part.NeedStyle=false;
            end
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                switch lower(this.CurrentHoleId)
                case 'itemnumname'
                    fillnum(this);
                case 'itemnamename'
                    fillname(this);
                case 'itempathname'
                    fillpath(this);
                case 'itemrevisionname'
                    fillrevision(this);
                end
                moveToNextHole(this);
            end
        end


        function fillnum(header)
            content=mlreportgen.dom.Text('#');
            if header.NeedStyle
                content.StyleName='SLReqArtifactListNumName';
            end
            append(header,content);
        end


        function fillname(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentArtifactListHeaderName')));
            if header.NeedStyle
                content.StyleName='SLReqArtifactListItemName';
            end
            append(header,content);
        end


        function fillpath(header)
            content=mlreportgen.dom.Text(...
            getString(message('Slvnv:slreq:ReportContentArtifactListHeaderFolder')));
            if header.NeedStyle
                content.StyleName='SLReqArtifactListFolderName';
            end
            append(header,content);
        end


        function fillrevision(header)
            switch header.DomainType
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
            if header.NeedStyle
                content.StyleName='SLReqArtifactListRevisionName';
            end
            append(header,content);
        end
    end

end
