function addRptgenCodeReplacementSection(obj,chapter)
    import mlreportgen.dom.*;
    sectionId=1;
    sectionId=obj.addRptgenFunctionReplacementSection(chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_ADD','AddReplacementTitle',obj.getAddReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_MINUS','SubReplacementTitle',obj.getSubReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_MUL','MulReplacementTitle',obj.getMulReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_DIV','DivReplacementTitle',obj.getDivReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_CAST','CastReplacementTitle',obj.getCastReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_SL','SLReplacementTitle',obj.getSLReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_SR','SRReplacementTitle',obj.getSRReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_ELEM_MUL','EMReplacementTitle',obj.getEMReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_TRANS','TransReplacementTitle',obj.getTransReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_CONJUGATE','ConjReplacementTitle',obj.getConjReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_HERMITIAN','HermReplacementTitle',obj.getHermReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_TRMUL','TRMReplacementTitle',obj.getTRReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_HMMUL','HMReplacementTitle',obj.getHMReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_GREATER_THAN','GTReplacementTitle',obj.getGTReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_GREATER_THAN_OR_EQ','GTEReplacementTitle',obj.getGTEReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_LESS_THAN','LTReplacementTitle',obj.getLTReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_LESS_THAN_OR_EQ','LTEReplacementTitle',obj.getLTEReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_EQUAL','EQReplacementTitle',obj.getEQReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenOperatorReplacementSection('RTW_OP_NOT_EQUAL','NEQReplacementTitle',obj.getNEQReplacementIntro(),chapter,sectionId);
    sectionId=obj.addRptgenSimdReplacementSection(chapter,sectionId);
    if sectionId==1
        chapter.append(Paragraph(obj.getMessage('CodeReplacementEmptyReport')));
    end
end
