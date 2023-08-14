classdef ReqRationalePart<slreq.report.ReportPart

    properties
        ReqInfo;
    end

    methods

        function part=ReqRationalePart(p1)
            if strcmpi(p1.Type,'docx')&&isempty(p1.ReqInfo.rationale)
                partName='SLReqReqRationaleEmptyPart';
            else
                partName='SLReqReqRationalePart';
            end
            part=part@slreq.report.ReportPart(p1,partName);
            part.ReqInfo=p1.ReqInfo;
        end


        function fill(this)
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'rationalename'
                    str=getString(message('Slvnv:slreq:Rationale'));
                    text=mlreportgen.dom.Text(str,'SLReqReqRationaleName');
                case 'rationalevalue'
                    try
                        tReqSet=this.ReqInfo.getReqSet;
                        dasRationale=tReqSet.unpackImages(this.ReqInfo.rationale);
                        text=slreq.report.utils.createDOMForRichText(dasRationale,this.ReqInfo.external,this.Type);
                    catch ex %#ok<NASGU>






                        partname=getString(message('Slvnv:slreq:Rationale'));
                        rmiut.warnNoBacktrace('Slvnv:slreq:ReportGenWarnInvalidHTML',partname,this.ReqInfo.id,this.ReqInfo.getReqSet.name);
                        errorMsg=getString(message('Slvnv:slreq:ReportInvalidContent'));
                        text=mlreportgen.dom.Text(errorMsg);
                        text.StyleName='SLReqReqRationaleValueError';
                    end
                    if isempty(text)
                        text=mlreportgen.dom.Text('   ','SLReqRationaleValue');
                        text.WhiteSpace='preserve';
                    end
                end

                if~isempty(text)
                    append(this,text);
                end

                moveToNextHole(this);
            end
        end
    end
end




