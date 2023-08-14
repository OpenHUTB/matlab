function mplayinst(blk,isConnect)


















    if nargin<1,blk=gcbh;isConnect=false;end
    if nargin==1,isConnect=false;end



    hParent=get_param(blk,'Parent');
    if strcmpi(get_param(hParent,'BlockDiagramType'),'library')
        return;
    end


    ioObj=get_param(blk,'userdata');


    hFig=[];
    isValid=~isempty(ioObj);
    if isValid
        hMPlay=ioObj.hMPlay;
        isValid=~isempty(hMPlay)&&isvalid(hMPlay);
        if isValid
            hFig=hMPlay.Parent;
            isValid=ishghandle(hFig);
        end
    end


    isVisible=get(hFig,'Visible');

    if isValid

        figure(hFig);
    else


        ioObj=MPlayIO.MPlay(blk);


        set_param(blk,'userdata',ioObj);

    end




    if(~(strcmp(get_param(blk,'iotype'),'none'))&&isConnect)



        if(strcmp(isVisible,'off')&&strcmp(get(hFig,'Visible'),'on'))
            set(hFig,'Visible','off')
        end

        MPlayIO.mplayconnect(blk);
    end

    ioObj.hListen.Enabled=true;

