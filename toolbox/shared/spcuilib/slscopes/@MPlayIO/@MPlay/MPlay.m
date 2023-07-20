function h=MPlay(blk)






    h=MPlayIO.MPlay;


    h.hMPlay=uiscopes.new(MPlayIOScopeCfg);




    if~(strcmp(get_param(blk,'iotype'),'none'))
        h.hListen=event.listener(h.hMPlay,...
        'DataSourceChanged',@(h1,e1)SourceChange(h));

        h.hListen.Enabled=false;
    else
        h.hListen=[];
    end


    h.hBlk=blk;


