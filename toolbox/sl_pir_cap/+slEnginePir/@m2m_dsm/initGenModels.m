


function mdlName=initGenModels(mdl)

    mdlName=mdl;



    [listMdlRef,~]=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',false,'IncludeCommented','off','IgnoreVariantErrors',1);

    for i=1:length(listMdlRef)
        refMdlName=listMdlRef{i};
        if refMdlName==mdl
            outMdlFile=['gen_',refMdlName];
            save_system(refMdlName,outMdlFile);
            Simulink.BlockDiagram.deleteContents(refMdlName);
            open_system(mdl);
            continue
        end
        if isempty(find_system(refMdlName,'flat'))
            load_system(refMdlName);
        end
        shadow=find_system(refMdlName,'SearchDepth',1,'BlockType','InportShadow');
        delete_block(shadow);
        Simulink.BlockDiagram.deleteContents(refMdlName);

        outMdlFile=['gen_',refMdlName];
        save_system(refMdlName,outMdlFile);

        load_system(refMdlName);
    end


end
