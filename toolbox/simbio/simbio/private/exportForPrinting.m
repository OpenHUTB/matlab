function hf=exportForPrinting(source,eventdata,names,ax)%#ok<INUSL,INUSL>












    hf=figure('Visible','off','Tag','sbioplotInNewWindow');


    ha=copyobj(ax,hf);


    set(ha,'Units','default','Position','default','UIContextMenu',[]);


    legend(ha,names,'Location','NorthEastOutside','Interpreter','none');
    set(hf,'Visible','on');
