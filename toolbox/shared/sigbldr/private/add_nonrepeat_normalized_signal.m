function UD=add_nonrepeat_normalized_signal(UD,xNorm,yNorm,dontScale,add_new)








    if nargin<4
        dontScale=0;
    end

    chIdx=UD.current.channel;


    UD=mouse_handler('ForceMode',UD.dialog,UD,1);

    if isempty(UD.current.axes)||UD.current.axes==0
        if isfield(UD,'axes')&&~isempty(UD.axes)


            UD.current.axes=UD.axes(1).handle;
        end
    end



    if dontScale
        xData=xNorm;
        yData=yNorm;
    else
        xData=UD.common.dispTime(1)+xNorm*diff(UD.common.dispTime);
        yData=yNorm;
    end



    xData(1)=UD.common.minTime;
    xData(end)=UD.common.maxTime;


    if(add_new==0&&chIdx>0)
        UD=apply_new_channel_data(UD,chIdx,xData,yData);
        UD=rescale_axes_to_fit_data(UD,UD.channels(chIdx).axesInd,chIdx,1);
        UD=set_dirty_flag(UD);
    else

        SBSigSuite=UD.sbobj;
        groupSignalAppend(SBSigSuite,xData,yData);
        sigName=SBSigSuite.Groups(1).Signals(end).Name;
        UD.sbobj=SBSigSuite;
        UD=signal_new(UD,0,0,sigName);
        if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
            UD=new_axes(UD,1,[]);
            UD=new_plot_channel(UD,UD.numChannels,1);
            UD.current.mode=3;
            UD.current.channel=UD.numChannels;
            UD.current.bdPoint=[0,0];
            UD.current.bdObj=UD.channels(UD.numChannels).lineH;
        end
        UD=update_channel_select(UD);
    end
