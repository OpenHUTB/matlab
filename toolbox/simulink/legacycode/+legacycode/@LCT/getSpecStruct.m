function userStruct=getSpecStruct(getUserStruct,lctObj)








    userStruct=legacycode.LCT.DefaultSpecStruct;

    if nargin>1
        assert(isa(lctObj,'legacycode.LCT'),'Input must be of type ''legacycode.LCT''');


        publicFields=fields(userStruct);
        for i=1:length(publicFields)
            field=publicFields{i};
            userStruct.(field)=lctObj.(field);
        end
    end

    if nargin<1
        getUserStruct=true;
    end

    if getUserStruct



        for currHiddenField=legacycode.LCT.HiddenSpecFields
            if isempty(userStruct.(currHiddenField{:}))
                userStruct=rmfield(userStruct,currHiddenField{:});
            end
        end



        userStruct.Options=rmfield(userStruct.Options,legacycode.LCT.HiddenOptionFields);
    end


