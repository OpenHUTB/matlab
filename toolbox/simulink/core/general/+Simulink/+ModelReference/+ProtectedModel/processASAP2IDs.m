function out=processASAP2IDs(modelName,argIdentifier)







    out=argIdentifier;
    [isProtected,~]=slInternal('getReferencedModelFileInformation',modelName);
    if isProtected
        opts=Simulink.ModelReference.ProtectedModel.getOptions(modelName);
        if opts.obfuscateCode
            out=regexprep(argIdentifier,'_prot$','');
        end
    end
end
