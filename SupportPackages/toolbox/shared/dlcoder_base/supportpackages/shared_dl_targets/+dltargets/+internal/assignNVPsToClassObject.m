function obj=assignNVPsToClassObject(obj,nvps)





    fieldNames=fieldnames(nvps);
    for iProp=1:numel(fieldNames)
        assert(isprop(obj,fieldNames{iProp}));
        obj.(fieldNames{iProp})=nvps.(fieldNames{iProp});
    end

end
