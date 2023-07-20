function this=importEditTimeXML(xmlFileName)




    import matlab.io.xml.dom.*

    this={};
    if~exist(xmlFileName,'file')
        return
    end

    xdoc=parseFile(Parser,xmlFileName);


    this.CheckCellArray={};
    CheckCellArray=xdoc.getElementsByTagName('CheckCellArray');
    if isa(CheckCellArray,'matlab.io.xml.dom.Element')
        CheckCellArray=CheckCellArray.item(0);
        for i=1:2:CheckCellArray.getLength-1
            checkElement=CheckCellArray.item(i);
            this.CheckCellArray{end+1}=readCheckElement(checkElement);
        end
    end

end

function this=readCheckElement(element)
    this.ID=getXMLProperty(element,'ID');
    this.Selected=strcmpi(getXMLProperty(element,'Selected'),'true');
    this.InputParameters={};
    InputParameters=element.getElementsByTagName('InputParameters');
    if isa(InputParameters,'matlab.io.xml.dom.Element')&&~isempty(InputParameters.item(0))
        InputParameters=InputParameters.item(0);
        for i=1:2:InputParameters.getLength-1
            inputparam=InputParameters.item(i);
            this.InputParameters{end+1}.Name=char(inputparam.getAttribute('Name'));
            this.InputParameters{end}.Type=char(inputparam.getAttribute('Type'));
            if strcmpi(this.InputParameters{end}.Type,'BlockType')
                recordValue={};
                blocktypes=inputparam.getElementsByTagName('Value');
                if isa(blocktypes,'matlab.io.xml.dom.Element')&&~isempty(blocktypes.item(0))
                    blocktypes=blocktypes.item(0);
                    for j=1:2:blocktypes.getLength-1
                        blocktype=blocktypes.item(j);
                        recordValue{end+1,1}=char(blocktype.item(0).getNodeValue);%#ok<AGROW>
                        recordValue{end,2}=char(blocktype.getAttribute('MaskType'));
                    end
                end
                this.InputParameters{end}.Value=recordValue;
            elseif strcmpi(this.InputParameters{end}.Type,'Enum')
                recordValue={};
                Entries=inputparam.getElementsByTagName('Entries');
                if isa(Entries,'matlab.io.xml.dom.Element')&&~isempty(Entries.item(0))
                    Entries=Entries.item(0);
                    for j=1:2:Entries.getLength-1
                        Entry=Entries.item(j);
                        recordValue{end+1}=char(Entry.item(0).getNodeValue);%#ok<AGROW>
                    end
                end
                this.InputParameters{end}.Entries=recordValue;
                this.InputParameters{end}.Value=getXMLProperty(inputparam,'Value');
            elseif strcmpi(this.InputParameters{end}.Type,'Bool')
                paramValue=getXMLProperty(inputparam,'Value');
                this.InputParameters{end}.Value=strcmpi(paramValue,'true');
            else
                this.InputParameters{end}.Value=getXMLProperty(inputparam,'Value');
            end
        end
    end
end









function output=getXMLProperty(xmlobj,property)
    output='';

    propertyobj=xmlobj.getElementsByTagName(property);
    if isa(propertyobj,'matlab.io.xml.dom.Element')
        if~isempty(propertyobj.item(0))&&~isempty(propertyobj.item(0).item(0))
            output=char(propertyobj.item(0).item(0).getNodeValue);
        end
    end
end
