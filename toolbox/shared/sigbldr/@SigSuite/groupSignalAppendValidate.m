function groupSignalAppendValidate(this,grpList,sigList)



    curGrpCnt=this.NumGroups;
    newGrpCnt=length(grpList);
    newSigCnt=length(sigList{1});



    if(newGrpCnt==1)
        if(newSigCnt~=curGrpCnt)

            DAStudio.error('Sigbldr:sigsuite:GroupSignalAppendIncorrectNumberofSignals',...
            newSigCnt,curGrpCnt);
        end
    else


        if(newGrpCnt~=curGrpCnt)
            DAStudio.error('Sigbldr:sigsuite:GroupSignalAppendIncorrectNumberofGroups',...
            newGrpCnt,curGrpCnt);
        end
        doesmatch=SigSuite.sigPerGroupNumberCheck(newGrpCnt,sigList);
        if(~doesmatch)
            DAStudio.error('Sigbldr:sigsuite:GroupAppendIncorrectNumberofSignalsInGroups');
        end
    end

end

