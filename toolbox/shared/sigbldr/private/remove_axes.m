function UD=remove_axes(UD,index,doFast)




    if nargin<3
        doFast=0;
    end

    oldAxStruct=UD.axes(index);


    channels=UD.axes(index).channels;
    for chNum=channels;
        UD.channels(chNum).axesInd=0;
        UD.channels(chNum).lineH=[];
    end


    moveAxesInd=(index+1):UD.numAxes;

    if~isempty(moveAxesInd)
        for oldAxInd=moveAxesInd,
            axUD=get(UD.axes(oldAxInd).handle,'UserData');
            axUD.index=oldAxInd-1;
            set(UD.axes(oldAxInd).handle,'UserData',axUD);
            for chNum=UD.axes(oldAxInd).channels
                UD.channels(chNum).axesInd=oldAxInd-1;
            end
            if(axUD.index==1)
                xl=get(UD.axes(oldAxInd).handle,'XLabel');
                set(xl,'String',getString(message('sigbldr_ui:create:TimeSec')),'FontWeight','Bold');
                set(UD.axes(oldAxInd).handle,'XTickLabelMode','auto');
            end
        end
        UD.axes=[UD.axes(1:(index-1)),UD.axes(moveAxesInd)];
    else
        UD.axes(index)=[];
    end


    delete(oldAxStruct.handle);
    UD.numAxes=UD.numAxes-1;

    if UD.numAxes>0

        ySizeIncrease=(1/(1-oldAxStruct.vertProportion))-eps;
        for i=1:UD.numAxes
            UD.axes(i).vertProportion=ySizeIncrease*UD.axes(i).vertProportion;
        end
        UD.current.axes=UD.axes(1).handle;
    else
        UD.current.axes=0;
    end


    if~doFast
        UD=resize(UD);
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end
