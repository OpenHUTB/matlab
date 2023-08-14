classdef ReqImplementationPart<slreq.report.ReportPart

    properties
        ImpStatus;
        StyleStruct;
    end

    methods

        function part=ReqImplementationPart(p1,impStatus,styleType)
            part=part@slreq.report.ReportPart(p1,'SLReqReqImplementationPart');
            part.ImpStatus=impStatus;
            if strcmpi(styleType,'set')
                part.StyleStruct.title='SLReqReqSetImplementationTitle';
                part.StyleStruct.totalName='SLReqReqSetImpTotalName';
                part.StyleStruct.totalValue='SLReqReqSetImpTotalValue';
                part.StyleStruct.implementedName='SLReqReqSetImpImplementedName';
                part.StyleStruct.implementedValue='SLReqReqSetImpImplementedValue';
                part.StyleStruct.justifiedName='SLReqReqSetImpJustifiedName';
                part.StyleStruct.justifiedValue='SLReqReqSetImpJustifiedValue';
                part.StyleStruct.noneName='SLReqReqSetImpNoneName';
                part.StyleStruct.noneValue='SLReqReqSetImpNoneValue';
            else
                part.StyleStruct.title='SLReqReqImplementationTitle';
                part.StyleStruct.totalName='SLReqReqImpTotalName';
                part.StyleStruct.totalValue='SLReqReqImpTotalValue';
                part.StyleStruct.implementedName='SLReqReqImpImplementedName';
                part.StyleStruct.implementedValue='SLReqReqImpImplementedValue';
                part.StyleStruct.justifiedName='SLReqReqImpJustifiedName';
                part.StyleStruct.justifiedValue='SLReqReqImpJustifiedValue';
                part.StyleStruct.noneName='SLReqReqImpNoneName';
                part.StyleStruct.noneValue='SLReqReqImpNoneValue';
            end
        end


        function fill(this)
            impStatus=this.ImpStatus;
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'implementationstatusname'
                    str=getString(message('Slvnv:slreq:ImplementationStatus'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.title);
                case 'totalname'
                    str=getString(message('Slvnv:slreq:Total'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.totalName);
                case 'totalvalue'
                    text=mlreportgen.dom.Text(impStatus(1),this.StyleStruct.totalValue);
                case 'implementedname'
                    str=getString(message('Slvnv:slreq:Implemented'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.implementedName);
                case 'implementedvalue'
                    text=mlreportgen.dom.Text(impStatus(2),this.StyleStruct.implementedValue);
                case 'justifiedname'
                    str=getString(message('Slvnv:slreq:Justified'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.justifiedName);
                case 'justifiedvalue'
                    text=mlreportgen.dom.Text(impStatus(3),this.StyleStruct.justifiedValue);
                case 'nonename'
                    str=getString(message('Slvnv:slreq:None'));
                    text=mlreportgen.dom.Text(str,this.StyleStruct.noneName);
                case 'nonevalue'
                    text=mlreportgen.dom.Text(impStatus(4),this.StyleStruct.noneValue);
                end
                if~isempty(text)
                    append(this,text);
                end
                moveToNextHole(this);
            end
        end
    end
end




