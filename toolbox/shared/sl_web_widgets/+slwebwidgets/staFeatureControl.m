function ftrControlStruct=staFeatureControl





    listoffeatures={

    };


    ftrControlStruct=[];

    for id=1:length(listoffeatures)
        ftrName=listoffeatures{id};
        try
            ftrControlStruct.(ftrName)=slfeature(ftrName);
        catch

            ftrControlStruct.(ftrName)=0;
        end
    end


end

