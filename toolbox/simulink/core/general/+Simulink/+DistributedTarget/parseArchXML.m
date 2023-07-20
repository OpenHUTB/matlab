function[xmlStruct,valid]=parseArchXML(fileName,arch,validateOnly)





    archSchemaFile=Simulink.DistributedTarget.getSupportFilePath('architecture.xsd');
    parser=matlab.io.xml.dom.Parser;
    parser.Configuration.Schema=true;
    parser.Configuration.Validate=true;
    parser.Configuration.ExternalNoNamespaceSchemaLocation=archSchemaFile;
    parser.Configuration.ErrorHandler=Simulink.DistributedTarget.XMLValidationErrorHandler;
    parser.parseFile(fileName);
    errs=parser.Configuration.ErrorHandler.getErrors();

    valid=isempty(errs);
    if~valid
        errMsg='';
        for ii=1:length(errs)
            errMsg=sprintf('%s\n [ line: %d, col:%d ]: %s',...
            errMsg,...
            errs(ii).Location.LineNumber,errs(ii).Location.ColumnNumber,errs(ii).Message);
        end
        DAStudio.error('Simulink:mds:ArchXMLValidationFailed',fileName,errMsg);
    end

    xmlStruct=readstruct(fileName,'AttributeSuffix','__Attribute',...
    'StructNodeName','architecture');

    if validateOnly,return;end

    setArchitectureAttributes(xmlStruct,fileName,arch);
    createArchitectureNodes(xmlStruct,arch);
    createArchitectureTemplates(xmlStruct,arch);
    createConfigSetConstraintsForArch(xmlStruct,arch);
    createChannelInterfaces(xmlStruct,arch);
    createConnections(xmlStruct,arch);
end

function createArchitectureNodes(xmlStruct,arch)

    import Simulink.DistributedTarget.DistributedTargetUtils

    if~isfield(xmlStruct,'node')||isMissingType(xmlStruct.node)
        return;
    end
    nodes=xmlStruct.node;

    for i=1:numel(nodes)
        thisNode=nodes(i);
        assert(numel(getAttributeFields(thisNode))==3);

        nodeH=arch.addNode(DistributedTargetUtils.getArchAttribute(thisNode,'name'),...
        DistributedTargetUtils.getArchAttribute(thisNode,'type'));
        nodeH.UUID=DistributedTargetUtils.getArchAttribute(thisNode,'uuid');

        tmpl=createTemplate(arch,thisNode);
        if~isempty(tmpl)
            tmpl.Implicit=true;
            builtIns={'Clock Frequency','ClockFrequency'};
            for j=1:2:length(builtIns)
                builtIn=builtIns{j};
                propDefs={tmpl.TargetSpecificProperties.Name};
                propDef=tmpl.TargetSpecificProperties(strcmp(propDefs,builtIn));
                if~isempty(propDef)
                    nodeH.(builtIns{j+1})=propDef.Value;
                    tmpl.deleteTargetSpecificProperty(builtIn);
                end
            end
            nodeH.setTemplate(tmpl);
        else
            nodeH.clearTemplate();
        end
    end
end

function createArchitectureTemplates(xmlStruct,arch)


    if~isfield(xmlStruct,'template')||isMissingType(xmlStruct.template)
        return;
    end
    templates=xmlStruct.template;

    for i=1:numel(templates)
        template=templates(i);
        assert(numel(getAttributeFields(template))==3);

        createTemplate(arch,template);
    end
end

function tmpl=createTemplate(arch,xmlNode)
    import Simulink.DistributedTarget.DistributedTargetUtils

    tmpl=[];

    if~isfield(xmlNode,'property')||isMissingType(xmlNode.property)
        return;
    end

    arch.addTemplate(DistributedTargetUtils.getArchAttribute(xmlNode,'name'));
    tmpl=arch.Templates(end);
    tmpl.Type=DistributedTargetUtils.getArchAttribute(xmlNode,'type');
    tmpl.UUID=DistributedTargetUtils.getArchAttribute(xmlNode,'uuid');

    props=xmlNode.property;
    for i=1:numel(props)
        tmpl.addTargetSpecificProperty(DistributedTargetUtils.getArchAttribute(props(i),'name'),...
        DistributedTargetUtils.getArchAttribute(props(i),'value'));
        prop=tmpl.TargetSpecificProperties(end);

        if isfield(props(i),'allowedValue')&&~isMissingType(props(i).allowedValue)
            prop.AllowedValues=...
            arrayfun(@num2str,props(i).allowedValue,'UniformOutput',false);
        end

        editable=DistributedTargetUtils.getArchAttribute(props(i),'editable');
        prop.Editable=~strcmp(editable,'false');

        evaluate=DistributedTargetUtils.getArchAttribute(props(i),'evaluate');
        prop.Evaluate=strcmp(evaluate,'true');

        prompt=DistributedTargetUtils.getArchAttribute(props(i),'prompt');
        if~isempty(prompt)
            prop.Prompt=prompt;
        end
    end
end

function setArchitectureAttributes(xmlStruct,fileName,arch)


    attribs=getAttributeFields(xmlStruct);
    for idx=1:numel(attribs)
        attrib=attribs{idx};
        switch attrib
        case 'format__Attribute'
            arch.Format=num2str(xmlStruct.(attrib));
        case 'revision__Attribute'
            arch.Revision=num2str(xmlStruct.(attrib));
        case 'name__Attribute'
            arch.Name=char(xmlStruct.(attrib));
        case 'uuid__Attribute'
            arch.UUID=char(xmlStruct.(attrib));
        end
    end

    [~,fName,ext]=fileparts(fileName);
    arch.FileName=[fName,ext];
end

function createChannelInterfaces(xmlStruct,arch)

    import Simulink.DistributedTarget.DistributedTargetUtils

    if~isfield(xmlStruct,'channelInterface')||...
        isMissingType(xmlStruct.channelInterface)
        return;
    end

    channelInterfaceItems=xmlStruct.channelInterface;

    for i=1:numel(channelInterfaceItems)
        connAttribs=channelInterfaceItems(i);
        chInterf=arch.addChannelInterface(DistributedTargetUtils.getArchAttribute(connAttribs,'name'),...
        DistributedTargetUtils.getArchAttribute(connAttribs,'channelClassName'));
        chInterf.UUID=DistributedTargetUtils.getArchAttribute(connAttribs,'uuid');
    end
end

function createConnections(xmlStruct,arch)

    import Simulink.DistributedTarget.DistributedTargetUtils

    if~isfield(xmlStruct,'connection')||isMissingType(xmlStruct.connection)
        return;
    end
    connectionItems=xmlStruct.connection;

    for idx=1:numel(connectionItems)
        connection=connectionItems(idx);
        bidirectionalAttr=DistributedTargetUtils.getArchAttribute(connection,'bidirectional');
        bidirectional=strcmp(bidirectionalAttr,'true')||...
        strcmp(bidirectionalAttr,'1');
        connH=arch.addConnection(DistributedTargetUtils.getArchAttribute(connection,'srcNode'),...
        DistributedTargetUtils.getArchAttribute(connection,'dstNode'),...
        bidirectional,...
        DistributedTargetUtils.getArchAttribute(connection,'interfaceType'));
        connH.UUID=DistributedTargetUtils.getArchAttribute(connection,'uuid');
    end
end

function createConfigSetConstraintsForArch(xmlStruct,arch)

    import Simulink.DistributedTarget.DistributedTargetUtils

    if~isfield(xmlStruct,'configurationSet')||...
        isMissingType(xmlStruct.configurationSet)
        return;
    end
    csConstraintsItem=xmlStruct.configurationSet;

    if isMissingType(csConstraintsItem)
        return;
    end


    assert(numel(csConstraintsItem)==1);
    assert(isfield(csConstraintsItem,'parameter'));

    for idx=1:numel(csConstraintsItem.parameter)
        param=csConstraintsItem.parameter(idx);
        arch.addConfigSetConstraint(DistributedTargetUtils.getArchAttribute(param,'name'),...
        DistributedTargetUtils.getArchAttribute(param,'value'));
    end
end

function attribs=getAttributeFields(xmlNode)

    allFields=fields(xmlNode);
    attribs=allFields(cellfun(@(f)contains(f,'__Attribute'),allFields));

end

function m=isMissingType(f)





    m=isa(f,'missing');
end


