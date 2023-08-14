




function res=compareRoots(rootId1,rootId2)

    try
        p1=cv('GetRootPath',rootId1);
        p2=cv('GetRootPath',rootId2);
        md1=cv('get',rootId1,'.modelDepth');
        md2=cv('get',rootId2,'.modelDepth');

        p1l=numel(p1);
        p2l=numel(p2);






        res=0;
        if(md1==md2)&&strcmp(p1,p2)
            res=1;
        elseif(md1==0)||...
            (md1<md2&&(p2l>p1l&&p2(p1l+1)=='/'))
            res=2;
        elseif(md2==0)||...
            (md1>md2&&p2l<p1l&&p1(p2l+1)=='/')
            res=3;
        end




    catch MEx
        rethrow(MEx);
    end























