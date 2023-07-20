function makeDesignDataChapter(sddRpt)
































    import mlreportgen.report.*


    chap=Chapter();
    chap.Title=...
    getString(message("slreportgen:StdRpt:SDD:variablesSectTitle"));


    varResults=findVariables(sddRpt);


    fcnResults=findFunctionReferences(sddRpt);


    makeDesignSummary(varResults,fcnResults,chap);

    if sddRpt.IncludeDetails


        makeDesignDetails(varResults,chap);
    end


    add(sddRpt,chap);
end

function varResults=findVariables(sddRpt)




    import slreportgen.finder.*



    varFinder=ModelVariableFinder(sddRpt.RootSystem);
    varFinder.SearchReferencedModels=sddRpt.IncludeReferencedModels;
    varFinder.LookUnderMasks=sddRpt.IncludeMaskedSubsystems;
    if strcmpi(sddRpt.IncludeVariants,"all")
        varFinder.IncludeInactiveVariants=true;
    end





    if~sddRpt.IncludeSimulinkLibraries&&~sddRpt.IncludeCustomLibraries
        varFinder.FollowLibraryLinks=false;
    end


    varResults=find(varFinder);
end

function fcnResults=findFunctionReferences(sddRpt)




    import slreportgen.finder.*



    fcnFinder=FunctionReferenceFinder(sddRpt.RootSystem);
    fcnFinder.SearchReferencedModels=sddRpt.IncludeReferencedModels;
    fcnFinder.LookUnderMasks=sddRpt.IncludeMaskedSubsystems;
    if strcmpi(sddRpt.IncludeVariants,"all")
        fcnFinder.IncludeInactiveVariants=true;
    end





    if~sddRpt.IncludeSimulinkLibraries&&~sddRpt.IncludeCustomLibraries
        fcnFinder.FollowLibraryLinks=false;
    end


    fcnResults=find(fcnFinder);
end

function makeDesignSummary(varResults,fcnResults,chap)





    import mlreportgen.report.*
    import slreportgen.report.*

    nVarResults=numel(varResults);
    nFcnResults=numel(fcnResults);
    if(nVarResults>0)||(nFcnResults>0)

        sect=Section();
        sect.Title=...
        getString(message("slreportgen:StdRpt:SDD:variablesSectTitleSummary"));
        sect.Numbered=false;

        if nVarResults>0

            varSummaryTable=SummaryTable(varResults);
            varSummaryTable.Title=...
            getString(message("slreportgen:StdRpt:SDD:variablesTableTitle"));
            append(sect,varSummaryTable);
        end

        if nFcnResults>0

            fcnSummaryTable=SummaryTable(fcnResults);
            fcnSummaryTable.Title=...
            getString(message("slreportgen:StdRpt:SDD:variablesFcnTableTitle"));
            append(sect,fcnSummaryTable);
        end


        append(chap,sect);
    end
end

function makeDesignDetails(varResults,chap)




    import mlreportgen.report.*

    nVarResults=numel(varResults);
    if nVarResults>0

        sect=Section();
        sect.Title=...
        getString(message("slreportgen:StdRpt:SDD:variablesSectTitleDetails"));
        sect.Numbered=false;

        for iResult=1:nVarResults

            variableReporter=getReporter(varResults(iResult));


            add(sect,variableReporter);
        end


        add(chap,sect);
    end
end