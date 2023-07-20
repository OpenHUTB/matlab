classdef ReqSetCustomAttributePart<slreq.report.ReportPart

    properties
        AttInfo;
    end

    methods

        function part=ReqSetCustomAttributePart(p1,attInfo)
            switch attInfo.typeName
            case slreq.datamodel.AttributeRegType.Edit
                quickPart='SLReqReqSetCustomAttEditPart';
            case slreq.datamodel.AttributeRegType.Combobox
                quickPart='SLReqReqSetCustomAttListPart';
            case slreq.datamodel.AttributeRegType.Checkbox
                quickPart='SLReqReqSetCustomAttCheckBoxPart';
            case slreq.datamodel.AttributeRegType.DateTime
                quickPart='SLReqReqSetCustomAttEditPart';
            end


            part=part@slreq.report.ReportPart(p1,quickPart);
            part.AttInfo=attInfo;
        end


        function fill(this)
            cAttr=this.AttInfo;
            while(~strcmp(this.CurrentHoleId,'#dummyend#')&&~strcmp(this.CurrentHoleId,'#end#'))
                text=[];
                switch lower(this.CurrentHoleId)
                case 'name'
                    str=getString(message('Slvnv:slreq:Name'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttName');
                case 'value'
                    text=mlreportgen.dom.Text(cAttr.name,'SLReqReqSetCustomAttValue');
                case 'typename'
                    str=getString(message('Slvnv:slreq:Type'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttTypeName');
                case 'typevalue'

                    text=mlreportgen.dom.Text(char(cAttr.typeName),'SLReqReqSetCustomAttTypeValue');
                case 'descriptionname'
                    str=getString(message('Slvnv:slreq:Description'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttDescriptionName');
                case 'descriptionvalue'
                    text=mlreportgen.dom.Text(cAttr.description,'SLReqReqSetCustomAttDescriptionValue');
                case 'defaultvaluename'
                    str=getString(message('Slvnv:slreq:DefaultValue'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttDefaultValueName');
                case 'defaultvaluevalue'
                    text=mlreportgen.dom.Text(string(cAttr.default),'SLReqReqSetCustomAttDefaultValueValue');
                case 'listname'
                    str=getString(message('Slvnv:slreq:List'));
                    text=mlreportgen.dom.Text(str,'SLReqReqSetCustomAttListName');
                case 'listvaluevalue'
                    allEntries=cAttr.entries.toArray;
                    allList=strjoin(allEntries,',');
                    text=mlreportgen.dom.Text(allList,'SLReqReqSetCustomAttListValue');
                end
                if~isempty(text)
                    append(this,text);
                end
                moveToNextHole(this);
            end
        end
    end
end




