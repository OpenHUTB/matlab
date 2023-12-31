function r=isequal(obj,other)





    r=false;
    if~isa(other,'Simulink.CSCDefn')
        return;
    end


    assert(strcmp(class(obj),'Simulink.CSCDefn'));%#ok
    assert(strcmp(class(other),'Simulink.CSCDefn'));%#ok


    h=classhandle(obj);
    assert(length(h.Properties)==41);


    props_string={...
    'Name',...
    'OwnerPackage',...
    'CSCType',...
    'MemorySection',...
    'IsMemorySectionInstanceSpecific',...
    'IsGrouped',...
...
    'DataScope',...
    'IsDataScopeInstanceSpecific',...
    'IsAutosarPerInstanceMemory',...
    'IsAutosarPostBuild',...
    'SupportSILPIL',...
    'DataInit',...
    'IsDataInitInstanceSpecific',...
    'DataAccess',...
    'IsDataAccessInstanceSpecific',...
    'HeaderFile',...
    'IsHeaderFileInstanceSpecific',...
    'DefinitionFile',...
    'IsDefinitionFileInstanceSpecific',...
    'Owner',...
    'IsOwnerInstanceSpecific',...
    'PreserveDimensions',...
    'PreserveDimensionsInstanceSpecific',...
    'IsReusable',...
    'IsReusableInstanceSpecific',...
    'Latching',...
    'IsLatchingInstanceSpecific',...
    'CriticalSection',...
    'CommentSource',...
    'TypeComment',...
    'DeclareComment',...
    'DefineComment',...
...
...
...
    'CSCTypeAttributesClassName',...
...
    'TLCFileName',...
    'ConcurrentAccess',...
    'IsConcurrentAccessInstanceSpecific',...
    };

    for k=1:length(props_string)
        if~isequal(obj.(props_string{k}),other.(props_string{k}))
            return;
        end
    end


    if((obj.DataUsage.IsParameter~=other.DataUsage.IsParameter)||...
        (obj.DataUsage.IsSignal~=other.DataUsage.IsSignal))
        return;
    end


    if isempty(obj.CSCTypeAttributes)&&isempty(other.CSCTypeAttributes)
        r=true;
        return;
    end
    if isempty(obj.CSCTypeAttributes)||isempty(other.CSCTypeAttributes)
        return;
    end

    assert(isa(obj.CSCTypeAttributes,'Simulink.CustomStorageClassAttributes')&&...
    isa(other.CSCTypeAttributes,'Simulink.CustomStorageClassAttributes'));
    extra_props1=obj.CSCTypeAttributes.getInstanceSpecificProps;
    extra_props2=other.CSCTypeAttributes.getInstanceSpecificProps;
    if isempty(extra_props1)&&isempty(extra_props2)
        r=true;
        return;
    end
    if isempty(extra_props1)||isempty(extra_props2)||...
        length(extra_props1)~=length(extra_props2)
        return;
    end

    extra_propnames={};
    for k=1:length(extra_props2)
        extra_propnames{end+1}=extra_props2(k).Name;%#ok
    end
    for k=1:length(extra_props1)
        propname=extra_props1(k).Name;
        if~ismember(propname,extra_propnames)
            return;
        end
        if~isequal(obj.CSCTypeAttributes.(propname),other.CSCTypeAttributes.(propname))
            return;
        end
    end
    r=true;




