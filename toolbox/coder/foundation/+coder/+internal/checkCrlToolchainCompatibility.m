function checkCrlToolchainCompatibility(crlStr,rTargetRegistry,rToolchainName)
    loadedCrlNames=coder.internal.getCrlLibraries(crlStr);
    mainError=[];
    for i=1:length(loadedCrlNames)
        crl=coder.internal.getTfl(rTargetRegistry,loadedCrlNames{i});
        if(~isempty(crl))
            [~,errorForLib]=crl.validateToolchain(rTargetRegistry,rToolchainName,true);
            if~isempty(errorForLib)
                if isempty(mainError)
                    mainError=MSLException('CoderFoundation:tfl:CrlToolchainCompatibilityIssues',rToolchainName);
                end
                mainError=mainError.addCause(errorForLib);
            end
        end
    end
    if~isempty(mainError)
        throw(mainError);
    end
end
