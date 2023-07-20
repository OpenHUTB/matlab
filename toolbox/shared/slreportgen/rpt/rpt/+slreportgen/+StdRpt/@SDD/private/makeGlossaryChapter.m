function makeGlossaryChapter(sddRpt)




















    import mlreportgen.report.*
    import mlreportgen.dom.*


    chap=Chapter();
    chap.Title=...
    getString(message("slreportgen:StdRpt:SDD:glossarySectTitle"));


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermAtomicSubsystem"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefAtomicSubsystem"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermBlockDiagram"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefBlockDiagram"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermBlockParam"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefBlockParam"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermBlockExecOrder"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefBlockExecOrder"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermChecksum"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefChecksum"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermDesignVariable"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefDesignVariable"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermSignal"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefSignal"));
    makeDescriptionPara(term,definition,chap);


    term=getString(message("slreportgen:StdRpt:SDD:glossaryTermVirtualSubsys"));
    definition=getString(message("slreportgen:StdRpt:SDD:glossaryDefVirtualSubsys"));
    makeDescriptionPara(term,definition,chap);


    append(sddRpt,chap);
end

function makeDescriptionPara(term,definition,chap)





    import mlreportgen.dom.*


    para=Paragraph();
    para.WhiteSpace="preserve";


    termObj=Text(strcat(term,". "));
    termObj.WhiteSpace="preserve";
    termObj.StyleName="paragraphTitle";
    append(para,termObj);


    definitionObj=Text(definition);
    append(para,definitionObj);


    append(chap,para);
end