function makeSystemHierarchyChapter(sddRpt)























    import mlreportgen.report.*
    import slreportgen.report.*


    chap=Chapter;
    chap.Title=...
    getString(message("slreportgen:StdRpt:SDD:sysHierSectTitle"));



    sysHier=SystemHierarchy(sddRpt.RootSystem);
    sysHier.IncludeMaskedSubsystems=sddRpt.IncludeMaskedSubsystems;
    sysHier.IncludeReferencedModels=sddRpt.IncludeReferencedModels;
    sysHier.IncludeUserLibraryLinks=sddRpt.IncludeCustomLibraries;
    sysHier.IncludeSimulinkLibraryLinks=sddRpt.IncludeSimulinkLibraries;
    sysHier.IncludeVariants=sddRpt.IncludeVariants;


    append(chap,sysHier);


    append(sddRpt,chap);
end