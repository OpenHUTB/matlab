function setPropertyGroups(h)




    props=find(h.classhandle.properties,'accessflags.publicset',...
    'on','accessflags.publicget','on','visible','on');%#ok<GTARG>

    groupStruct=[];

    PropertyGroups=get(props,'Description');
    PropertyGroupsUnique=unique(PropertyGroups);
    Properties=get(props,'Name');
    for i=1:length(PropertyGroupsUnique),
        I=strmatch(PropertyGroupsUnique{i},PropertyGroups);
        groupProperties=Properties(I);
        groupStruct.(PropertyGroupsUnique{i})=groupProperties;
    end
    h.propertyGroups=groupStruct;
