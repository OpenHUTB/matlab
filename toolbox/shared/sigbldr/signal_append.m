function UD=signal_append(input,SBSigSuite)





    ActiveGroup=SBSigSuite.ActiveGroup;
    newSigCnt=SBSigSuite.Groups(ActiveGroup).NumSignals;



    forceOpen=false;
    if ishandle(input)

        blockH=input;
        figH=get_param(blockH,'UserData');
        if isempty(figH)||~ishghandle(figH,'figure')

            forceOpen=true;
            open_system(blockH,'OpenFcn');
            figH=get_param(blockH,'UserData');
        end

        UD=get(figH,'UserData');
    else

        UD=input;
    end
    curSigCnt=length(UD.channels);

    UD.sbobj=SBSigSuite;
    theGroup_=UD.sbobj.Groups(ActiveGroup);
    sigNames=cell(1,newSigCnt-curSigCnt);
    for n=curSigCnt+1:newSigCnt
        sigNames{n-curSigCnt}=theGroup_.Signals(n).Name;
        UD=signal_new(UD,0,0,sigNames{n-curSigCnt});

        if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
            UD=new_axes(UD,1,[]);
            UD=new_plot_channel(UD,UD.numChannels,1);
            UD.current.mode=3;
            UD.current.channel=UD.numChannels;
            UD.current.bdPoint=[0,0];
            UD.current.bdObj=UD.channels(UD.numChannels).lineH;
        end
    end
    UD=trimDataPoints(UD);
    UD=update_channel_select(UD);
    UD=cant_undo(UD);
    set(UD.dialog,'UserData',UD)

    if(forceOpen)
        close_internal(UD);
    end

end

