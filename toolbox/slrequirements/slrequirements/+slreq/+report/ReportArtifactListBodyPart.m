classdef ReportArtifactListBodyPart<slreq.report.ReportPart


    properties
        ArtifactOrderNum;

        ArtifactInfo;
        DomainType;
        NeedStyle=true;
    end

    methods

        function part=ReportArtifactListBodyPart(p1,artifactInfo,artifactOrderNum,domainType)
            part=part@slreq.report.ReportPart(p1,'SLReqArtifactListBodyPart');
            part.ArtifactOrderNum=artifactOrderNum;
            part.ArtifactInfo=artifactInfo;
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
                case 'itemnumvalue'
                    fillnum(this);
                case 'itemnamevalue'
                    fillname(this);
                case 'itempathvalue'
                    fillpath(this);
                case 'itemrevisionvalue'
                    fillrevision(this);
                end
                moveToNextHole(this);
            end
        end


        function fillnum(this)
            orderNum=mlreportgen.dom.Text(this.ArtifactOrderNum);
            if this.NeedStyle
                orderNum.StyleName='SLReqArtifactListNumValue';
            end
            append(this,orderNum);
        end


        function fillname(this)
            shortNameText=mlreportgen.dom.Text(this.ArtifactInfo.ShortName);
            if this.NeedStyle
                shortNameText.StyleName='SLReqArtifactListItemValue';
            end
            append(this,shortNameText);
        end


        function fillpath(this)
            if isempty(this.ArtifactInfo.Folder)
                content=getString(message('Slvnv:slreq:ReportContentArtifactListBodyUnresolved'));
            else
                content=this.ArtifactInfo.Folder;
            end
            path=mlreportgen.dom.Text(content);
            if this.NeedStyle
                path.StyleName='SLReqArtifactListFolderValue';
            end
            append(this,path);
        end


        function fillrevision(this)
            revisionInfo=this.ArtifactInfo.getExtraInfoForArtifactListBody;
            revision=mlreportgen.dom.Text(revisionInfo);
            if this.NeedStyle
                revision.StyleName='SLReqArtifactListRevisionValue';
            end
            append(this,revision);
        end
    end
end
