function resetArgumentInPlace(h,input)






    if isempty(input)
        return;
    end
    names={h.object.Implementation.Arguments.Name};
    index=find(ismember(names,input),1);
    secondarg='';
    if~isempty(index)
        secondarg=h.object.Implementation.Arguments(index).ArgumentForInPlaceUse;
        if isprop(h.object.Implementation.Arguments(index),'ArgumentForInPlaceUse')
            h.object.Implementation.Arguments(index).ArgumentForInPlaceUse='';
        end
    end
    index=find(ismember(names,secondarg),1);
    if~isempty(index)
        if isprop(h.object.Implementation.Arguments(index),'ArgumentForInPlaceUse')
            h.object.Implementation.Arguments(index).ArgumentForInPlaceUse='';
        end
    end
