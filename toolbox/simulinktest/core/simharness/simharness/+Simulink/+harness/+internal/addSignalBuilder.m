function blockH=addSignalBuilder(path,sigNames,left,top,width,height)


    time=[0,1];
    n=length(sigNames);
    data=cell(n,1);
    for i=1:n
        data{i}=[0,0];
    end
    if nargin==6
        pos=[left,top,left+width-1,top+height-1];
    else
        pos=[50,50,150,50+n*20];
    end
    blockH=signalbuilder(path,'create',time,data,sigNames,'Group 1',[],pos);
    blockUD=get_param(blockH,'UserData');
    if~isempty(blockUD)&&isgraphics(blockUD,'figure')
        UD=get(blockUD,'UserData');
        delete(UD.dialog);
    end
    set_param(blockH,'Position',pos);
end
