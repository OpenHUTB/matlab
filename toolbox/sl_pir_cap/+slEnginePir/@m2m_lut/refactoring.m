function errMsg=refactoring(m2mObj,aPrefix)



    if~m2mObj.fIsPirXformed
        m2mObj.fXformCommands=[];
        mdls=[{m2mObj.fMdl},m2mObj.fRefMdls];
        for mIdx=1:length(mdls)
            m2mObj.fXformObj.setContext(mdls{mIdx});

            exclusionList=[];
            if isKey(m2mObj.fExcludedBlks,mdls{mIdx})
                exclusionList=[exclusionList,m2mObj.fExcludedBlks(mdls{mIdx})];
            end
            if isKey(m2mObj.fInvalidCandidates,mdls{mIdx})
                exclusionList=[exclusionList,m2mObj.fInvalidCandidates(mdls{mIdx})];
            end
            if~isempty(exclusionList)
                exclusionList=unique(exclusionList);
                m2mObj.fXformObj.setExclusions(exclusionList);
            end


            cmds=m2mObj.fXformObj.getRefactoringCommands();
            m2mObj.fXformCommands=[m2mObj.fXformCommands;cmds];
        end
        m2mObj.fIsPirXformed=1;
    end

    errMsg=m2mObj.generateMdls(aPrefix);
end
