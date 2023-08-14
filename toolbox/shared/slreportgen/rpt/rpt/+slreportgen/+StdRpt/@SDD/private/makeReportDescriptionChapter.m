function makeReportDescriptionChapter(sddRpt)























    import mlreportgen.report.*


    chap=Chapter();
    chap.Title=getString(message("slreportgen:StdRpt:SDD:rptDescTitle"));


    makeReportOverview(sddRpt,chap);


    makeRootSystemDescription(sddRpt,chap);


    makeSubSystemDescription(sddRpt,chap);


    makeStateChartDescription(sddRpt,chap);


    append(sddRpt,chap);
end

function makeReportOverview(sddRpt,chap)




    import mlreportgen.report.*


    sect=Section();
    sect.Title=getString(message("slreportgen:StdRpt:SDD:rptDescOverviewTitle"));
    sect.Numbered=false;
    append(sect,getString(message("slreportgen:StdRpt:SDD:rptDescOverview",...
    sddRpt.RootSystem)));


    title=getString(message("slreportgen:StdRpt:SDD:rptDescVersionTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rptDescVersion"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:rptDescRootSystemTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rptDescRootSystem"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:rptDescSubsystemsTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rptDescSubsystems"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:rptDescDesignVariablesTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rptDescDesignVariables"));
    makeDescriptionPara(title,description,sect);

    if sddRpt.IncludeDetails

        title=getString(message("slreportgen:StdRpt:SDD:rptDescCfgSetTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:rptDescCfgSet"));
        makeDescriptionPara(title,description,sect);
    end

    if sddRpt.IncludeGlossary

        title=getString(message("slreportgen:StdRpt:SDD:rptDescGlossaryTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:rptDescGlossary"));
        makeDescriptionPara(title,description,sect);
    end


    append(chap,sect);
end

function makeRootSystemDescription(sddRpt,chap)




    import mlreportgen.dom.*
    import mlreportgen.report.*


    sect=Section();
    sect.Title=getString(message("slreportgen:StdRpt:SDD:rootSysDescTitle"));
    sect.Numbered=false;
    append(sect,getString(message("slreportgen:StdRpt:SDD:rootSysDescIntro")));


    title=getString(message("slreportgen:StdRpt:SDD:rootSysDescDiagramTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rootSysDescDiagram"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:rootSysDescDescTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rootSysDescDesc"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:rootSysDescInterfaceTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rootSysDescInterface"));
    makeDescriptionPara(title,description,sect);

    if sddRpt.IncludeDetails

        title=getString(message("slreportgen:StdRpt:SDD:rootSysDescBlocksTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:rootSysDescBlocks"));
        makeDescriptionPara(title,description,sect);


        blockList=UnorderedList;
        append(sect,blockList);


        title=getString(message("slreportgen:StdRpt:SDD:rootSysDescParamsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:rootSysDescParams"));
        makeDescriptionPara(title,description,blockList);


        title=getString(message("slreportgen:StdRpt:SDD:rootSysDescBlockExecOrderTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:rootSysDescBlockExecOrder"));
        makeDescriptionPara(title,description,blockList);
    end


    title=getString(message("slreportgen:StdRpt:SDD:rootSysDescChartsTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:rootSysDescCharts"));
    makeDescriptionPara(title,description,sect);


    add(chap,sect);
end

function makeSubSystemDescription(sddRpt,chap)




    import mlreportgen.dom.*
    import mlreportgen.report.*


    sect=Section();
    sect.Title=getString(message("slreportgen:StdRpt:SDD:subsysDescTitle"));
    sect.Numbered=false;
    append(sect,getString(message("slreportgen:StdRpt:SDD:subsysDescIntro")));


    title=getString(message("slreportgen:StdRpt:SDD:subsysDescChecksumTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:subsysDescChecksum"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:subsysDescDiagramTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:subsysDescDiagram"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:subsysDescDescTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:subsysDescDesc"));
    makeDescriptionPara(title,description,sect);


    title=getString(message("slreportgen:StdRpt:SDD:subsysDescInterfaceTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:subsysDescInterface"));
    makeDescriptionPara(title,description,sect);

    if sddRpt.IncludeDetails

        title=getString(message("slreportgen:StdRpt:SDD:subsysDescBlocksTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:subsysDescBlocks"));
        makeDescriptionPara(title,description,sect);


        blockList=UnorderedList;
        append(sect,blockList);


        title=getString(message("slreportgen:StdRpt:SDD:subsysDescParamsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:subsysDescParams"));
        makeDescriptionPara(title,description,blockList);


        title=getString(message("slreportgen:StdRpt:SDD:subsysDescBlockExecOrderTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:subsysDescBlockExecOrder"));
        makeDescriptionPara(title,description,blockList);
    end


    title=getString(message("slreportgen:StdRpt:SDD:subsysDescChartsTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:subsysDescCharts"));
    makeDescriptionPara(title,description,sect);


    add(chap,sect);
end

function makeStateChartDescription(sddRpt,chap)




    import mlreportgen.report.*


    sect=Section();
    sect.Title=getString(message("slreportgen:StdRpt:SDD:chartDescTitle"));
    sect.Numbered=false;
    append(sect,getString(message("slreportgen:StdRpt:SDD:chartDescIntro")));


    title=getString(message("slreportgen:StdRpt:SDD:chartDescDiagramTitle"));
    description=getString(message("slreportgen:StdRpt:SDD:chartDescDiagram"));
    makeDescriptionPara(title,description,sect);

    if sddRpt.IncludeDetails

        title=getString(message("slreportgen:StdRpt:SDD:chartDescStatesTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescStates"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescTransitionsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescTransitions"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescJunctionsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescJunctions"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescEventsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescEvents"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescDataTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescData"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescTargetsTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescTargets"));
        makeDescriptionPara(title,description,sect);


        title=getString(message("slreportgen:StdRpt:SDD:chartDescEMLSupportTitle"));
        description=getString(message("slreportgen:StdRpt:SDD:chartDescEMLSupport"));
        makeDescriptionPara(title,description,sect);
    end


    add(chap,sect);
end

function para=makeDescriptionPara(title,description,parent)





    import mlreportgen.dom.*


    para=Paragraph();
    para.WhiteSpace="preserve";


    titleObj=Text(strcat(title,". "));
    titleObj.WhiteSpace="preserve";
    titleObj.StyleName="paragraphTitle";
    append(para,titleObj);


    descriptionObj=Text(description);
    append(para,descriptionObj);


    append(parent,para);
end