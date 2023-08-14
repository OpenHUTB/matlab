classdef DepFileReader<dependencies.internal.graph.GraphReader




    properties(Constant)
        Extensions=".dep";
    end

    methods

        function graph=read(~,file,~)
            dom=i_readDom(file);
            data=i_parseDom(dom);
            graph=i_buildGraph(data);
        end

    end

end


function dom=i_readDom(file)

    tempFolder=tempname;
    unzip(file,tempFolder);
    cleanup=onCleanup(@()rmdir(tempFolder,"s"));

    abstractData=fullfile(tempFolder,'abstractData');
    parser=matlab.io.xml.dom.Parser;
    dom=parser.parseFile(abstractData);

end


function data=i_parseDom(dom)

    data.Nodes=containers.Map;
    data.Types=containers.Map;
    data.Connectors=containers.Map;
    data.Dependencies=struct('Source',{},'Target',{});

    typeLookup=i_createTypeLookup;

    root=dom.getDocumentElement;
    nodes=root.getElementsByTagName("node");

    for n=1:nodes.getLength
        node=nodes.node(n);
        type=i_getText(node,"type");
        id=i_getText(node,"id");
        props=i_getElement(node,"properties");

        switch type
        case typeLookup.keys
            path=i_getText(props,"pathOnDisk");
            data.Nodes(id)=dependencies.internal.graph.Node.createFileNode(path);
            data.Types(id)=typeLookup(type);
        case "Dependency"
            data.Dependencies(end+1).Source=i_getText(props,"start");
            data.Dependencies(end).Target=i_getText(props,"end");
        case "GraphConnector"
            data.Connectors(id)=i_getText(props,"graphElement");
        end
    end

end


function graph=i_buildGraph(data)

    graph=dependencies.internal.graph.MutableGraph;

    nodes=data.Nodes.values;
    graph.addNode([nodes{:}]);

    for link=data.Dependencies
        source=data.Nodes(data.Connectors(link.Source));
        target=data.Nodes(data.Connectors(link.Target));
        type=data.Types(data.Connectors(link.Target));

        dep=dependencies.internal.graph.Dependency(...
        source,"",target,"",type);

        graph.addDependency(dep);
    end

end


function map=i_createTypeLookup
    import dependencies.internal.analysis.simulink.*;

    map=containers.Map;
    map('ModelReferenceDepNode')=ModelReferenceAnalyzer.ModelReferenceType;
    map('SubsystemReferenceDepNode')=SubsystemReferenceAnalyzer.SubsystemReferenceType;
    map('LibraryDepNode')=LibraryLinksAnalyzer.LibraryLinkType.ID;
end


function element=i_getElement(node,tag)
    elements=node.getElementsByTagName(tag);
    element=elements.node(1);
end


function text=i_getText(element,tag)
    child=i_getElement(element,tag);
    text=string(child.TextContent);
end
