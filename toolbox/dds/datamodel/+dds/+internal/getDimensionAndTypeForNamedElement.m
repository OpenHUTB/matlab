function[type,dimension]=getDimensionAndTypeForNamedElement(namedElement,evalNames)









    if nargin<2
        evalNames=true;
    end

    isTypeRef=~isempty(namedElement.TypeRef)&&isempty(namedElement.Type);
    dimension=[];
    dimension=appendDimension(dimension,namedElement.Dimension,evalNames);
    if~isTypeRef
        type=namedElement.Type;
    else
        typeRef=namedElement.TypeRef;
        dimension=appendDimension(dimension,typeRef.Dimension,evalNames);
        while isprop(typeRef,'Type')&&isempty(typeRef.Type)
            typeRef=typeRef.TypeRef;
            if isprop(typeRef,'Type')&&isempty(typeRef.Type)
                dimension=appendDimension(dimension,typeRef.Dimension,evalNames);
            end
        end
        if isprop(typeRef,'Type')
            type=typeRef.Type;
        else
            type=typeRef;
        end
    end
    if isempty(dimension)
        dimension=1;
    end
end

function dimension=appendDimension(dimension,curDimension,evalNames)
    if~isempty(curDimension)
        curLength=curDimension.CurLength;
        for i=1:curLength.Size
            valOrConst=curLength(i);
            if~isempty(valOrConst.ValueConst)

                if~evalNames
                    val=dds.internal.getFullNameForType(valOrConst.ValueConst,'_');
                else
                    val=double(valOrConst.ValueConst.getValue());
                end
            else
                val=double(valOrConst.Value);
            end
            if ischar(dimension)||ischar(val)

                if~ischar(dimension)
                    dimstr=num2str(dimension);
                else
                    if dimension(1)=='['&&dimension(end)==']'
                        dimstr=dimension(2:end-1);
                    else
                        dimstr=dimension;
                    end
                end
                if~ischar(val)
                    valstr=num2str(val);
                else
                    valstr=val;
                end
                if~isempty(dimstr)
                    dimension=['[',dimstr,',',valstr,']'];
                else
                    dimension=valstr;
                end
            else
                dimension=[dimension,val];%#ok<AGROW> 
            end
        end
    end
end


