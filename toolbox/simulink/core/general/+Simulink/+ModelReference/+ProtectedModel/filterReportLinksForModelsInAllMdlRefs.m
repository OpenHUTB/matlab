function out=filterReportLinksForModelsInAllMdlRefs(infoStruct,allMdlRefs)













    out={};
    for i=1:length(infoStruct.htmlrptLinks)
        currentLink=infoStruct.htmlrptLinks{i};
        if locCurrentLinkReferencesModel(currentLink,allMdlRefs)&&...
            exist(fullfile(Simulink.ModelReference.ProtectedModel.getRTWBuildDir(),currentLink),'file')
            out=[out,currentLink];%#ok<AGROW>
        end
    end

end

function out=locCurrentLinkReferencesModel(currentLink,allMdlRefs)
    out=false;
    for i=1:length(allMdlRefs)
        if strfind(currentLink,[allMdlRefs{i},'_codegen_rpt.html'])
            out=true;
        end
    end
end

