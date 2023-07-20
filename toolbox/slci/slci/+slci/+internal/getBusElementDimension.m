





function fieldDim=getBusElementDimension(busType,field,context)

    fieldDim=[];

    assert(isa(busType,'Simulink.Bus'));
    for i=1:numel(busType.Elements)
        if strcmp(busType.Elements(i).Name,field)
            fieldDim=busType.Elements(i).Dimensions;
            if ischar(fieldDim)
                fieldDim=slci.internal.resolveSymbol(...
                fieldDim,'int32',context);
                if isempty(fieldDim)
                    fieldDim=-1;
                end
            end
            assert(~isempty(fieldDim));
            return;
        end
    end

end
