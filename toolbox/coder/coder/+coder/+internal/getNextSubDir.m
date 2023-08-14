function d=getNextSubDir(baseFolder)




    cnt=0;
    d=getSubdirCnt(baseFolder,cnt);
    while isfolder(d)
        cnt=cnt+1;
        d=getSubdirCnt(baseFolder,cnt);
    end
end

function f=getSubdirCnt(baseFolder,cnt)
    f=fullfile(baseFolder,"run_"+cnt);
end
