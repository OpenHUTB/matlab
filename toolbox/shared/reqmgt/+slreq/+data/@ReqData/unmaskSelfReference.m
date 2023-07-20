function unmaskSelfReference(~,ref,srcPath)
















    stored=ref.artifactUri;

    [~,srcName,srcExt]=fileparts(srcPath);
    possibleSelfRefCases={'_SELF',['_SELF',srcExt]};

    if any(strcmp(stored,possibleSelfRefCases))
        ref.artifactUri=[srcName,srcExt];



        if strcmpi(srcExt,'.slreqx')
            ref.reqSetUri=strrep(ref.reqSetUri,'_SELF',srcName);
        end






    end

end

