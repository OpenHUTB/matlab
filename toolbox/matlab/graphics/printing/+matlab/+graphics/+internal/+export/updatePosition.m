function updatePosition(pj)



    fpos=get(pj.ParentFig,'Position');

    newFigPos=hgconvertunits(pj.ParentFig,...
    [fpos(1:2),pj.PixelOutputPosition(3:4)],'Pixels',...
    get(pj.ParentFig,'Units'),groot);


    if~strcmp(pj.ParentFig.WindowState,'docked')
        set(pj.ParentFig,'WindowState','normal')
        drawnow;
    end
    set(pj.ParentFig,'Position',newFigPos);


    if(newFigPos(3)>fpos(3))||(newFigPos(4)>fpos(4))
        errmsg='MATLAB:uistring:alternateprintpath:RequestedSizeTooLarge';
    else
        errmsg='MATLAB:uistring:alternateprintpath:RequestedSizeTooSmall';
    end

    LocalPollUntilReady(@LocalIsSizeUpdated,errmsg,pj,...
    pj.ParentFig,newFigPos(3:4),pj.DebugMode);



    drawnow;
end






function LocalPollUntilReady(isReadyFcn,msg,pj,varargin)
    startT=cputime;


    pj.temp.PollCounter=0;
    pj.temp.Current_Width=0;
    pj.temp.Current_Height=0;

    while~isReadyFcn(pj,varargin{:})
        delay=cputime-startT;



        if delay>500||pj.temp.PollCounter>1000
            error(message('MATLAB:print:polling',floor(delay),...
            message(msg).getString))
        end
    end
end



function updated=LocalIsSizeUpdated(pj,fig,targetSize,debugMode)

    pos=getpixelposition(fig);

    targetPixPos=hgconvertunits(fig,[1,1,targetSize],get(fig,'Units'),'pixels',groot);





    pixPosDiff=abs(pos-targetPixPos);
    updated=(pixPosDiff(3)<1)&&(pixPosDiff(4)<1);

    if(pos(3)==pj.temp.Current_Width&&pos(4)==pj.temp.Current_Height)


        pj.temp.PollCounter=pj.temp.PollCounter+1;
    else


        pj.temp.PollCounter=0;
    end

    if~updated
        if debugMode
            fprintf(1,getString(message('MATLAB:uistring:alternateprintpath:SizeNotReady',pos(3),pos(4),targetSize(1),targetSize(2))));
        end
        pos=get(fig,'Position');
        set(fig,'Position',[pos(1),pos(2),targetSize])
    end


    pj.temp.Current_Width=pos(3);
    pj.temp.Current_Height=pos(4);
end