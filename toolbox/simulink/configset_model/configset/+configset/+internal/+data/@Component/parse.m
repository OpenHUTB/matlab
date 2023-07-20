function parse(obj,xmlFile,varargin)






    parser=matlab.io.xml.dom.Parser;
    document=parser.parseFile(xmlFile);
    root=document.getDocumentElement;

    fid=fopen(xmlFile,'r');
    fullPathName=fopen(fid);
    txt=fscanf(fid,'%c');
    fclose(fid);

    obj.ParamMap=containers.Map('KeyType','char','ValueType','any');
    obj.ParamList={};

    obj.Name=configset.internal.helper.getSingleNodeValue(root,'name');
    disp(['  parsing ',obj.Name,' ...']);

    obj.ShortName=configset.internal.helper.getOptionalNodeValue(root,'shortName','');

    obj.NameKey=configset.internal.helper.getOptionalNodeValue(root,'nameKey','');
    if isempty(obj.NameKey)
        obj.NameKey=configset.internal.helper.getSingleNodeValue(root,'name_key');
    end
    obj.Class=configset.internal.helper.getOptionalNodeValue(root,'className','');
    if isempty(obj.Class)
        obj.Class=configset.internal.helper.getSingleNodeValue(root,'class_name');
    end
    obj.key_prefix=configset.internal.helper.getOptionalNodeValue(root,'keyPrefix','');
    if isempty(obj.key_prefix)
        obj.key_prefix=configset.internal.helper.getSingleNodeValue(root,'key_prefix');
    end
    obj.key_suffix_name=configset.internal.helper.getOptionalNodeValue(root,'keySuffixName','');
    if isempty(obj.key_suffix_name)
        obj.key_suffix_name=configset.internal.helper.getOptionalNodeValue(root,'key_suffix_name','');
    end
    depNode=configset.internal.helper.getChildNodeByTagName(root,'dependency');
    if~isempty(depNode)
        obj.Dependency=configset.internal.data.ParamDependency(depNode);
    end
    obj.namespace=configset.internal.helper.getOptionalNodeValue(root,'namespace','');

    obj.tag=configset.internal.helper.getSingleNodeValue(root,'tag');

    typeMap=containers.Map('KeyType','char','ValueType','any');
    typeNodes=configset.internal.helper.getChildNodeByTagName(root,'typedef');
    for j=1:length(typeNodes)
        typeNode=typeNodes{j};
        typeName=strtrim(typeNode.getFirstChild.getNodeValue);
        type=configset.internal.data.ParamType.create(typeNode);
        typeMap(typeName)=type;
    end
    obj.typeMap=typeMap;

    functions=configset.internal.helper.getChildNodeByTagName(root,'memberFunction');
    for j=1:length(functions)
        funcNode=functions{j};
        obj.memberFunctions{end+1}=strtrim(funcNode.getFirstChild.getNodeValue);
        if funcNode.hasAttribute('input')
            tmp=funcNode.getAttribute('input');
            obj.functionInputs{end+1}=strtrim(strsplit(tmp,','));
        else
            obj.functionInputs{end+1}={};
        end
        if funcNode.hasAttribute('output')
            obj.functionOutputs{end+1}=funcNode.getAttribute('output');
        else
            obj.functionOutputs{end+1}='';
        end
    end

    initNode=configset.internal.helper.getChildNodeByTagName(root,'initializeFunction');
    obj.initFunction=~isempty(initNode);

    relativePathName=locGetRelativePath(fullPathName);
    params=configset.internal.helper.getChildNodeByTagName(root,'param');
    obj.PrototypeFeature=struct();
    for j=1:length(params)
        paramNode=params{j};
        param=configset.internal.data.ParamStaticData(paramNode,obj);
        if~isempty(param.PrototypeFeature)
            locPrototypeFeatureSetup(obj,param);
            locAddPrototypeFeature(obj,param.PrototypeFeature,param.Name);
        else
            obj.ParamList{end+1}=param;
        end

        param.Location.file=strsplit(relativePathName,filesep);
        param.Location.line=length(regexp(txt(1:regexp(txt,['<name>',param.Name,'</name>'])),'\n'))+1;
    end



    locConvertPrototypeFeatures(obj);


    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        name=p.Name;
        fullName=p.FullName;

        q=obj.getParamAllFeatures(name);
        if isempty(q)
            a=p;
        elseif isempty(p.Feature)
            if obj.ParamMap.isKey(name)
                error('RTW:configSet:DataModelDupParam',['Duplicate parameter: ',name]);
            end
        else
            if~iscell(q)
                q={q};
            end
            for j=1:length(q)
                if isequal(q{j}.Feature,p.Feature)
                    error('RTW:configSet:DataModelDupParamFeature',['Duplicate parameter ''',name,''' with feature ''',p.Feature.Name,'''']);
                end
            end
            a=[q,{p}];
        end

        obj.ParamMap(name)=a;
        obj.ParamMap(fullName)=a;

        for j=1:length(p.Alias)
            obj.ParamMap(p.Alias{j})=p;
            obj.ParamMap([p.Component,':',p.Alias{j}])=p;
        end
    end


    importNodes=root.getElementsByTagName('import');
    for k=1:importNodes.getLength
        import=importNodes.item(k-1);
        importXml=strtrim(import.getFirstChild.getNodeValue);
        importList=configset.internal.helper.getMultipleNodeValues(import,'param');

        if(nargin>=4)

            obj.import(fullfile(fileparts(fullPathName),importXml),importList,varargin{1},varargin{2});
        else
            obj.import(fullfile(fileparts(fullPathName),importXml),importList,[],[]);
        end
    end


    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        if~isempty(p.Feature)
            obj.Feature=union(obj.Feature,p.Feature.Name);
        end

        if~isempty(p.Dependency)
            for j=1:length(p.Dependency.StatusDepList)
                dep=p.Dependency.StatusDepList{j};
                if isa(dep,'configset.internal.dependency.LicenseDependency')
                    obj.License=union(obj.License,dep.LicenseNames,'stable');
                    obj.Product=union(obj.Product,dep.ProductNames,'stable');
                elseif~isempty(dep.License)
                    obj.License=union(obj.License,dep.License.LicenseNames,'stable');
                    obj.Product=union(obj.Product,dep.License.ProductNames,'stable');
                end
            end
        end

        for w=1:length(p.WidgetList)
            widget=p.WidgetList{w};
            if~isempty(widget.Dependency)
                for j=1:length(widget.Dependency.StatusDepList)
                    dep=widget.Dependency.StatusDepList{j};
                    if isa(dep,'configset.internal.dependency.LicenseDependency')
                        obj.License=union(obj.License,dep.LicenseNames,'stable');
                        obj.Product=union(obj.Product,dep.ProductNames,'stable');
                    elseif~isempty(dep.License)
                        obj.License=union(obj.License,dep.License.LicenseNames,'stable');
                        obj.Product=union(obj.Product,dep.License.ProductNames,'stable');
                    end
                end
            end
        end
    end


    map=containers.Map;
    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        uname=p.UniqueName;
        if map.isKey(uname)
            error('RTW:configSet:DataModelDupParam',['Duplicate parameter: ',uname]);
        else
            map(uname)=true;
        end
        if~isempty(p.WidgetList)
            dupName=false;
            for j=1:length(p.WidgetList)
                w=p.WidgetList{j};
                wuname=w.UniqueName;
                if strcmp(wuname,uname)


                    if dupName
                        error('RTW:configSet:DataModelDupWidget',['Duplicate widget: ',wuname]);
                    else
                        dupName=true;
                    end
                else
                    if map.isKey(wuname)
                        error('RTW:configSet:DataModelDupWidget',['Duplicate widget: ',wuname]);
                    else
                        map(wuname)=true;
                    end
                end
            end
        end
    end

end


function out=locGetRelativePath(fullPathName)
    mlroot=[matlabroot,'/'];
    n=length(mlroot);
    if strncmp(fullPathName,mlroot,n)
        out=fullPathName(n+1:end);
    else
        out=fullPathName;
    end
end

function locPrototypeFeatureSetup(obj,param)
    param.Feature.Name=param.PrototypeFeature;
    if contains(param.PrototypeFeature,':')


        error(['Invalid feature name: ',param.PrototypeFeature]);
    end



    paramCopy=param.copy;

    param.Feature.Value=0;
    param.Hidden=true;
    param.UDDProps.nonSerialize=true;
    param.UDDProps.prototype=true;
    obj.ParamList{end+1}=param;

    paramCopy.Feature.Value=true;
    paramCopy.Hidden=false;
    paramCopy.UDDProps.nonSerialize=false;
    paramCopy.UDDProps.prototype=true;
    obj.ParamList{end+1}=paramCopy;


    if~isempty(param.WidgetList)
        for i=1:2
            p=obj.ParamList{end-i};
            for w=1:length(p.WidgetList)
                p.WidgetList{w}.Feature=p.Feature;
                p.WidgetList{w}.Hidden=p.Hidden;
                p.WidgetList{w}.UDDProps=p.UDDProps;
            end
        end
    end
end


function locAddPrototypeFeature(obj,feature,param)
    if isfield(obj.PrototypeFeature,feature)
        l=obj.PrototypeFeature.(feature);
    else
        l={};
    end
    l{end+1}=param;
    obj.PrototypeFeature.(feature)=l;
end



function locConvertPrototypeFeatures(obj)
    v=struct2cell(obj.PrototypeFeature);
    f=fieldnames(obj.PrototypeFeature);

    obj.PrototypeFeature=cellfun(@(x,y){x,y},f,v,'UniformOutput',false);
end


