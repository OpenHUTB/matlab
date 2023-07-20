function groupAppendValidate(this,grpList,sigList)



    newGrpCnt=length(grpList);


    curSigCnt=this.Groups.NumSignals;
    newSigCnt=length(sigList{1});

    if(newSigCnt~=curSigCnt)
        DAStudio.error('Sigbldr:sigsuite:GroupAppendOldNewGroupSignalSizeMismatch',...
        curSigCnt,newSigCnt);
    end
    doesmatch=SigSuite.sigPerGroupNumberCheck(newGrpCnt,sigList);
    if(~doesmatch)
        DAStudio.error('Sigbldr:sigsuite:GroupAppendIncorrectNumberofSignalsInGroups');
    end

end


