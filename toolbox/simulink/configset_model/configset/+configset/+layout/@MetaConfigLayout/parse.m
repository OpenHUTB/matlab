function parse(obj,xmlFile)





    [~,fileName,~]=fileparts(xmlFile);
    disp(['parsing ',fileName,' layout...']);

    obj.WidgetGroupMap=containers.Map('KeyType','char','ValueType','any');
    obj.GroupObjectMap=containers.Map('KeyType','char','ValueType','any');
    obj.ParentGroupMap=containers.Map('KeyType','char','ValueType','any');
    obj.EnglishNameMap=containers.Map('KeyType','char','ValueType','char');
    obj.TopLevelPanes={};


    parser=matlab.io.xml.dom.Parser;
    document=parser.parseFile(xmlFile);


    root=configset.internal.helper.getChildNodeByTagName(document,'component_layout');
    if isempty(root)
        root=configset.internal.helper.getChildNodeByTagName(document,'configset_layout');
    end
    root=root{1};
    tagPrefix=configset.internal.helper.getSingleNodeValue(root,'tag_prefix');
    if~isempty(tagPrefix)
        tagPrefix=[tagPrefix,'_'];
    end
    cNodes=root.getChildNodes();
    for i=1:cNodes.getLength
        node=cNodes.item(i-1);
        nodeName=node.getNodeName;
        if strcmp(nodeName,'pane')
            group=configset.layout.CategoryUIGroup(obj,node,tagPrefix,'',[]);
            obj.TopLevelPanes{end+1}=group;
            loc_setEnglishNames(obj,group,'');
            loc_propagateComponents(group);
        end
    end
end



function loc_setEnglishNames(obj,group,parentName)
    if isempty(parentName)
        paneName=group.NameEnglish;
    else
        paneName=[parentName,'/',group.NameEnglish];

        if~obj.EnglishNameMap.isKey(group.NameEnglish)
            obj.EnglishNameMap(group.NameEnglish)=group.Name;
        end
    end
    obj.EnglishNameMap(paneName)=group.Name;


    for i=1:length(group.Children)
        child=group.Children{i};
        if isobject(child)&&strcmp(child.Type,'pane')
            loc_setEnglishNames(obj,child,paneName);
        end
    end

end



function loc_propagateComponents(parentGroup)
    for i=1:length(parentGroup.Children)
        child=parentGroup.Children{i};
        if isa(child,'configset.layout.CategoryUIGroup')
            if isempty(child.Components)
                child.Components=parentGroup.Components;
            end
            loc_propagateComponents(child);
        end
    end
end
