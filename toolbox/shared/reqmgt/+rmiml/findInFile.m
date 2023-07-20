function found=findInFile(mFile,pattern,doSelect)





    fullText=rmiml.getText(mFile);
    matchIdx=strfind(fullText,pattern);
    if isempty(matchIdx)
        found=0;
        if doSelect
            errordlg(...
            getString(message('Slvnv:rmiml:InvalidSearchPattern',pattern,mFile)),...
            getString(message('Slvnv:rmiml:NavigationProblem')));


            rmiut.RangeUtils.setSelection(mFile,[1,1]);
        end
    else
        found=1;
        if doSelect
            edit(mFile);
            range=matchIdx(1)+[0,length(pattern)];
            rmiut.RangeUtils.setSelection(mFile,range);
        end
    end
end
