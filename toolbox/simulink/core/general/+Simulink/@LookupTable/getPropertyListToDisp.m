function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));




    builtinclassProps=properties('Simulink.LookupTable');
    allProps=properties(this);


    subclassProps=setdiff(allProps,builtinclassProps,'stable');


    if strcmp(this.BreakpointsSpecification,'Reference')
        supportTunableSizeIndex=find(~cellfun(@isempty,strfind(builtinclassProps,'SupportTunableSize')),1);
        if~isempty(supportTunableSizeIndex)
            builtinclassProps(supportTunableSizeIndex)=[];
        end
        if(slfeature('VariableSizeLookupTables')>0)
            supportDifferentlySizedArrays=find(~cellfun(@isempty,strfind(builtinclassProps,'AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes')),1);
            if~isempty(supportDifferentlySizedArrays)
                builtinclassProps(supportDifferentlySizedArrays)=[];
            end
        end
        structTypeInfoIndex=find(~cellfun(@isempty,strfind(builtinclassProps,'StructTypeInfo')),1);
        if~isempty(structTypeInfoIndex)
            builtinclassProps(structTypeInfoIndex)=[];
        end
    end


    if(slfeature('VariableSizeLookupTables')<=0)
        supportDifferentlySizedArraysFeatOff=find(~cellfun(@isempty,strfind(builtinclassProps,'AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes')),1);
        if~isempty(supportDifferentlySizedArraysFeatOff)
            builtinclassProps(supportDifferentlySizedArraysFeatOff)=[];
        end
    end

    allPropsToDisp=[subclassProps;builtinclassProps];

end


