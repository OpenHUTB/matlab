function this=importConfigurationXML(xmlFileName)




    import matlab.io.xml.dom.*

    this={};
    if~exist(xmlFileName,'file')
        return
    end






















    xdoc=parseFile(Parser,xmlFileName);




    this.ReducedTree=getXMLProperty(xdoc,'ReducedTree');


    this.SLVersionInfo=getXMLProperty(xdoc,'SLVersionInfo');


    ConfigUIRoot=xdoc.getElementsByTagName('ConfigUIRoot');
    if isa(ConfigUIRoot,'matlab.io.xml.dom.Element')
        ConfigUIRoot=ConfigUIRoot.item(0);
        this.ConfigUIRoot=readConfigUIElement(ConfigUIRoot);
    end


    this.ConfigUICellArray={};
    ConfigUICellArray=xdoc.getElementsByTagName('ConfigUICellArray');
    if isa(ConfigUICellArray,'matlab.io.xml.dom.Element')
        ConfigUICellArray=ConfigUICellArray.item(0);
        for i=1:2:ConfigUICellArray.getLength-1
            configuiElement=ConfigUICellArray.item(i);
            this.ConfigUICellArray{end+1}=readConfigUIElement(configuiElement);
        end
    end

end

function this=readConfigUIElement(element)
    this.ID=getXMLProperty(element,'ID');
    this.MAC=getXMLProperty(element,'MAC');
    this.InputParameters={};
    InputParameters=element.getElementsByTagName('InputParameters');
    if isa(InputParameters,'matlab.io.xml.dom.Element')&&~isempty(InputParameters.item(0))
        InputParameters=InputParameters.item(0);
        for i=1:2:InputParameters.getLength-1
            inputparam=InputParameters.item(i);
            this.InputParameters{end+1}.Name=getXMLProperty(inputparam,'Name');
            this.InputParameters{end}.Type=getXMLProperty(inputparam,'Type');
            if strcmpi(this.InputParameters{end}.Type,'BlockType')
                recordValue={};
                blocktypes=inputparam.getElementsByTagName('Value');
                if isa(blocktypes,'matlab.io.xml.dom.Element')&&~isempty(blocktypes.item(0))
                    blocktypes=blocktypes.item(0);
                    for j=1:2:blocktypes.getLength-1
                        blocktype=blocktypes.item(j);
                        recordValue{end+1,1}=blocktype.item(0).getNodeValue;%#ok<AGROW>
                        recordValue{end,2}=blocktype.getAttribute('MaskType');
                    end
                end
                this.InputParameters{end}.Value=recordValue;
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
