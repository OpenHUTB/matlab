function subDim=calculateSubstrateDimensions(obj)



    ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
    (isequal(obj.GroundPlaneWidth,0));

    if~ZeroGPState
        if isa(obj.Element,'reflectorCircular')
            subDim=[obj.GroundPlaneRadius,obj.GroundPlaneRadius];
        else
            subDim=[obj.GroundPlaneLength,obj.GroundPlaneWidth];
        end
    else
        arraysize=obj.ArraySize;
        elementSubLength=obj.Element.Substrate.Length;
        elementSubWidth=obj.Element.Substrate.Width;
        if isa(obj,'linearArray')||isa(obj,'rectangularArray')
            S=calculateArraySpacing(obj);
            subDim=[elementSubLength*arraysize(2),elementSubWidth*arraysize(1)];
        else
            subDim=[2*max(obj.Radius)+elementSubLength,2*max(obj.Radius)+elementSubWidth];

        end

    end

end