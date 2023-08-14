function UD=remove_channel(UD,index)






    axIdx=UD.channels(index).axesInd;

    if axIdx>0
        UD=remove_axes(UD,axIdx);
    end

    outIndex=UD.channels(index).outIndex;


    chanStr=get(UD.hgCtrls.chanListbox,'String');
    chanStr(index,:)=[];
    set(UD.hgCtrls.chanListbox,'String',chanStr,'Value',1);

    if(index~=UD.numChannels)
        moveChannels=(index+1):UD.numChannels;
        moveDownChannels=UD.channels(moveChannels);
        UD.channels=[UD.channels(1:(index-1)),moveDownChannels];


        for i=moveChannels-1;
            if~isempty(UD.channels(i).lineH)
                lineUD=get(UD.channels(i).lineH,'UserData');
                lineUD.index=i;
                set(UD.channels(i).lineH,'UserData',lineUD);
                mvAxesInd=UD.channels(i).axesInd;
                UD.axes(mvAxesInd).channels(UD.axes(mvAxesInd).channels==i+1)=i;
            end
        end
    else
        UD.channels=UD.channels(1:(index-1));
    end


    for i=1:length(UD.dataSet)
        chanIdx=UD.dataSet(i).activeDispIdx;
        chanIdx(chanIdx==index)=[];
        decChanIdx=chanIdx>index;
        chanIdx(decChanIdx)=chanIdx(decChanIdx)-1;
        UD.dataSet(i).activeDispIdx=chanIdx;
    end


    if outIndex~=UD.numChannels
        decrementIdx=(outIndex+1):UD.numChannels;
        for i=1:(UD.numChannels-1)
            if any(UD.channels(i).outIndex==decrementIdx)
                UD.channels(i).outIndex=UD.channels(i).outIndex-1;
            end
        end
    end

    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        UD.simulink=sigbuilder_block('delete_outport',UD.simulink,index);
    end

    UD.numChannels=UD.numChannels-1;
    UD.current.channel=0;


    UD=update_show_menu(UD);
    UD=set_dirty_flag(UD);