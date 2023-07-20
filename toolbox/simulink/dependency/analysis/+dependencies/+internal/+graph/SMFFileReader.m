classdef SMFFileReader<dependencies.internal.graph.GraphReader




    properties(Constant)
        Extensions=".smf";
        Schema=fullfile(matlabroot,"toolbox","simulink","dependency","analysis","schema","dependencies.xsd");
    end

    methods

        function graph=read(this,file,~)
            dom=i_readFile(file,this.Schema);

            root=i_readProjectRoot(dom);
            nodes=i_readFileList(dom,root);
            deps=i_readDepSets(dom,root);

            graph=dependencies.internal.graph.Graph(nodes,deps);
        end

    end

end

function dom=i_readFile(file,schema)
    parser=matlab.io.xml.dom.Parser;
    parser.Configuration.Schema=true;
    parser.Configuration.Validate=true;
    parser.Configuration.ExternalNoNamespaceSchemaLocation=schema;
    dom=parser.parseFile(file);
end

function root=i_readProjectRoot(dom)
    list=dom.getElementsByTagName("FileList");
    if list.Length==0
        root="";
    else
        attr=list.node(1).getAttribute("ProjectRoot");
        root=i_deserialize(attr);
    end
end

function[nodes,root]=i_readFileList(dom,root)
    nodes=dependencies.internal.graph.Node.empty(1,0);
    filestates=dom.getElementsByTagName("FileState");
    for n=1:filestates.Length
        nodes(n)=i_readFileName(filestates.node(n),root);
    end
end

function deps=i_readDepSets(dom,root)
    deps=dependencies.internal.graph.Dependency.empty(1,0);

    depsets=dom.getElementsByTagName("MDLDepSet");
    if depsets.Length==0
        return;
    end

    models=i_readModelNames(depsets,root);

    for n=1:depsets.Length
        list=depsets.node(n).getElementsByTagName("FileReference");
        for m=1:list.Length
            deps(end+1)=i_readFileReference(list.node(m),root,models);%#ok<AGROW>
        end
    end
end

function map=i_readModelNames(depsets,root)
    map=containers.Map;
    for n=1:depsets.Length
        depset=depsets.node(n);
        name=string(i_getFirstChildWithTagName(depset,"MDLName").TextContent);
        node=i_readFileName(depset,root);
        map(name)=node;
    end
end

function dep=i_readFileReference(reference,root,models)
    import dependencies.internal.graph.Component;
    import dependencies.internal.graph.Dependency;
    import dependencies.internal.graph.Type;
    downnode=i_readFileName(reference,root);
    type=string(i_getFirstChildWithTagName(reference,"ReferenceType").TextContent);
    location=string(i_getFirstChildWithTagName(reference,"ReferenceLocation").TextContent);

    model=strtok(location,"/");
    if models.isKey(model)

        upnode=models(model);
        if model==location
            component=Component.createRoot(upnode);
        else
            component=Component.createBlock(upnode,location,"");
        end
    else
        location=i_deserialize(location);

        component=i_getLineComponentOrRoot(location,type);
    end

    dep=Dependency.createSource(component,downnode,Type(type));
end

function component=i_getLineComponentOrRoot(location,type)
    import dependencies.internal.graph.Component;
    import dependencies.internal.graph.Node;
    node=Node.createFileNode(location);
    component=Component.createRoot(node);
    if~ismember(type,["MATLABFile","CSource"])||~contains(location,":")
        return;
    end

    idx=strfind(location,":");
    lineNumber=str2double(extractAfter(location,idx(end)));
    if isempty(lineNumber)
        return;
    end
    path=extractBefore(location,idx(end));
    node=dependencies.internal.graph.Node.createFileNode(path);
    component=Component.createLine(node,lineNumber);
end

function node=i_readFileName(parent,root)
    element=i_getFirstChildWithTagName(parent,"FileName");
    relative=element.getAttribute("RelativeTo");
    filename=i_deserialize(element.TextContent);

    if relative=="projectroot"
        filename=fullfile(root,filename);
    elseif relative=="matlabroot"
        filename=fullfile(matlabroot,filename);
    end

    node=dependencies.internal.graph.Node.createFileNode(filename);
end

function element=i_getFirstChildWithTagName(element,name)
    list=element.getChildNodes();
    for n=1:list.Length
        element=list.node(n);
        if isa(element,"matlab.io.xml.dom.Element")&&strcmp(element.TagName,name)
            return;
        end
    end
    element=matlab.io.xml.dom.Element.empty(1,0);
end

function path=i_deserialize(path)
    path=strrep(path,'/',filesep);
end
