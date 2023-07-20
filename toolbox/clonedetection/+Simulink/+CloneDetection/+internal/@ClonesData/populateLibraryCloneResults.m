function populateLibraryCloneResults(~,m2mObj)








    index=1;
    m2mObj.cloneresult.librarymap=[];
    for i=1:length(m2mObj.cloneresult.Before.libsubsysBlk)
        m2mObj.cloneresult.librarymap{index}.index=i;
        m2mObj.cloneresult.librarymap{index}.targetLib=m2mObj.cloneresult.Before.libsubsysBlk{i};
        index=index+1;
    end

end


