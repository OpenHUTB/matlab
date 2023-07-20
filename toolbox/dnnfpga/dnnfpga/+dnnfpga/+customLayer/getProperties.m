function pvList=getProperties(customLayerList)





    basicProperties=["Name",...
    "Description",...
    "Type",...
    "NumInputs",...
    "InputNames",...
    "NumOutputs",...
    "OutputNames"];
    pvList=[];

    for customLayer=customLayerList
        customLayerProperties=properties(customLayer);

        for idy=1:numel(customLayerProperties)
            property=customLayerProperties{idy};
            if~any(strcmp(property,basicProperties))








                if isa(customLayer.(property),'double')
                    value=single(customLayer.(property));
                else
                    value=customLayer.(property);
                end
                pvPair=struct('property',property,'value',value);
                pvList=horzcat(pvList,pvPair);%#ok<AGROW>
            end
        end
    end

end

