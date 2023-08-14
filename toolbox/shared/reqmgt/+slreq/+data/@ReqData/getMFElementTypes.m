




function mfElementTypes=getMFElementTypes(this)

    mfElementTypes=containers.Map('KeyType','char','ValueType','double');

    tlElements=this.model.topLevelElements;

    for i=1:length(tlElements)
        tlElement=tlElements(i);
        elementType=class(tlElement);

        count=0;
        if isKey(mfElementTypes,elementType)
            count=mfElementTypes(elementType);
        end
        count=count+1;
        mfElementTypes(elementType)=count;
    end
end
