

function pirctx=testpir_GenMdl(mdl)

    load_simulink;
    load_system(mdl);



    oldf=slfeature('EnableAutomaticPIRCreator',0);


    cleanup=onCleanup(@()slfeature('EnableAutomaticPIRCreator',oldf));

    initGenModels(mdl);
    h=slEnginePir.PIRCreatorGenMdl(Simulink.SLPIR.Event.PostBlockSortingModel);
    h.add;

    set_param(mdl,'SLPIR','on');

    sess=Simulink.CMI.CompiledSession;
    bd=Simulink.CMI.CompiledBlockDiagram(sess,mdl);
    bd.init;
    bd.term;
    pirctx=h.getNamedCtx(mdl);
    close_system(['gen_',mdl]);
    open_system(['gen_',mdl]);
end


function initGenModels(mdl)



    [listMdlRef,~]=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',false,'IncludeCommented','off','IgnoreVariantErrors',1);

    for i=1:length(listMdlRef)
        refMdlName=listMdlRef{i};
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
    open_system(mdl);

end
