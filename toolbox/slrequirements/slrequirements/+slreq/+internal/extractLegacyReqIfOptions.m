function[mappingFile,specName]=extractLegacyReqIfOptions(artifactUri,reqSetName)



    [~,artifactName]=fileparts(artifactUri);
    options=slreq.import.ImportDataChecker.loadStoredImportOptions(reqSetName,artifactName,[]);
    options=fixMappingOptions(options);
    [mappingFile,~,specName]=slreq.internal.writeMappingToFile(artifactUri,options.attr2reqprop);
end

function options=fixMappingOptions(options)




    mappingHelper=slreq.internal.MappingHelper();
    builtinOptions=mappingHelper.builtIns(:,1);

    k=options.attr2reqprop.keys();
    for i=1:length(k)
        v=options.attr2reqprop(k{i});

        convertedV=[lower(v(1)),v(2:end)];
        if any(strcmp(builtinOptions,convertedV))
            options.attr2reqprop(k{i})=convertedV;
        end
    end
end