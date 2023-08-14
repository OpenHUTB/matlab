function[groups,hasHiddenGroups]=convertSystemObjectGroupsToCustomDisplayGroups(obj,systemObjectGroups,isLongDisplay)



























    rootIdx=findRootGroups(systemObjectGroups);


    [matlabNonRootGroup,nonRootIncludeInShortDisplay]=convertNonRootGroups(systemObjectGroups(~rootIdx));


    [matlabRootGroups,rootIncludeInShortDisplay]=convertRootGroups(systemObjectGroups(rootIdx));



    activeMatlabGroups=removeInactivePropertiesFromPropertyGroups(obj,...
    [matlabNonRootGroup,matlabRootGroups]);



    [groups,hasHiddenGroups]=filterGroupsForDisplay(activeMatlabGroups,...
    [nonRootIncludeInShortDisplay,rootIncludeInShortDisplay],isLongDisplay);
end

function rootIdx=findRootGroups(systemObjectGroups)

    rootIdx=~[systemObjectGroups.IsSection];
end

function[matlabGroup,include]=convertNonRootGroups(systemObjectGroups)
    propertyList=getPropertyList(systemObjectGroups);
    if isempty(propertyList)
        matlabGroup=matlab.mixin.util.PropertyGroup.empty;
        include=logical.empty;
    else
        matlabGroup=matlab.mixin.util.PropertyGroup(propertyList);
        include=true;
    end
end

function propertyList=getPropertyList(systemObjectGroups)
    numGroups=numel(systemObjectGroups);
    subPropertyList=cell(1,numGroups);
    for n=1:numGroups
        subPropertyList{n}=getPropertyNames(systemObjectGroups(n));
    end
    propertyList=[subPropertyList{:}];
end

function[matlabGroups,include]=convertRootGroups(systemObjectGroups)
    if isempty(systemObjectGroups)
        matlabGroups=matlab.mixin.util.PropertyGroup.empty;
        include=logical.empty;
    else
        groupCount=numel(systemObjectGroups);
        matlabGroups(1,groupCount)=matlab.mixin.util.PropertyGroup;
        include(1,groupCount)=false;
        for n=1:groupCount
            [matlabGroups(n),include(n)]=convertRootGroup(systemObjectGroups(n));
        end
    end
end

function[matlabGroup,include]=convertRootGroup(systemObjectGroup)
    title=getRootGroupTitle(systemObjectGroup);
    [propertyList,include]=getRootGroupPropertyList(systemObjectGroup);
    matlabGroup=matlab.mixin.util.PropertyGroup(propertyList,title);
end

function title=getRootGroupTitle(group)
    if strcmp(group.TitleSource,'Property')
        title=group.Title;
    else
        title='';
    end
end

function[propertyList,include]=getRootGroupPropertyList(systemObjectGroup)
    propertyList=getPropertyNames(systemObjectGroup);
    include=false;
    if isHierarchicalGroup(systemObjectGroup)
        propertyList=[propertyList,getPropertyList(systemObjectGroup.Sections)];
        include=systemObjectGroup.IncludeInShortDisplay;
    end
end

function flag=isHierarchicalGroup(systemObjectGroup)

    flag=[systemObjectGroup.IsSectionGroup];
end

function[groups,hasHiddenGroups]=filterGroupsForDisplay(allGroups,includeInShortDisplay,isLongDisplay)
    if isLongDisplay||isempty(allGroups)
        groups=allGroups;
        hasHiddenGroups=false;
    else
        inShortDisplayIdx=[true,includeInShortDisplay(2:end)];
        groups=allGroups(inShortDisplayIdx);
        hasHiddenGroups=any([allGroups(~inShortDisplayIdx).NumProperties]>0);
    end
end
