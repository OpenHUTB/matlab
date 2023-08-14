function hPjt=filterOutProject(h,hPjt)









    hPjt.deleteSourceFiles('ti_nonfinite.c');





    wasDeleted=hPjt.deleteSourceFiles('ccp_utils.c');
    if wasDeleted
        hPjt.addSourceFiles(fullfile(matlabroot,'toolbox','target',...
        'extensions','processor','tic2000','src','ccp_utils.c'));
    end

    pathToMove=fullfile('$(MATLAB_ROOT)','toolbox','rtw','targets',...
    'common','can','blocks','tlc_c');
    wasDeleted=hPjt.deleteIncludePaths(pathToMove);
    if wasDeleted
        pathToAdd=fullfile('$(MATLAB_ROOT)','toolbox','target',...
        'extensions','processor','tic2000','include');
        hPjt.addIncludePaths(pathToAdd);


        hPjt.addIncludePaths(pathToMove);
    end
