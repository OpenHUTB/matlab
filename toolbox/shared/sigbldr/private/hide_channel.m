function UD=hide_channel(UD,index)





    if~isempty(UD.channels(index).lineH)
        delete(UD.channels(index).lineH);
        UD.channels(index).lineH=[];
    end


    chanStr=get(UD.hgCtrls.chanListbox,'String');


    hiddenPlot=[char(9744),' '];

    chanStr(index,1:2)=hiddenPlot;

    set(UD.hgCtrls.chanListbox,'String',chanStr);


    if(~isempty(UD.channels(index).axesInd))&(UD.channels(index).axesInd~=0)
        axesInd=UD.channels(index).axesInd;

        UD.axes(axesInd).channels(UD.axes(axesInd).channels==index)=[];
    end

    UD.channels(index).axesInd=0;
    UD=update_show_menu(UD);