function dirName=sbiotempdir()














    persistent TEMPDIR


    if isempty(TEMPDIR)
        root=sbioroot;
        TEMPDIR=root.Tempdir;
    end
    dirName=TEMPDIR;


    if~exist(dirName,'dir')
        mkdir(dirName);
    end






    ps=pathsep;
    p=[ps,matlabpath,ps];
    dirName2=[ps,dirName,ps];
    if contains(p,dirName2)
        return
    end


    addpath(dirName);