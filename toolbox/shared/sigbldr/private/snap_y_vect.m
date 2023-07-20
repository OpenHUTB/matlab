function YfixStep=snap_y_vect(axes,Y,channelStruct)




    if(channelStruct.stepY>0)
        YfixStep=channelStruct.stepY*round(Y/channelStruct.stepY);
    else
        axesH=axes(channelStruct.axesInd).handle;
        rawSnap=fig_2_ax_ext([0.75,0.75],axesH);
        defaultStepY=nearest_125(rawSnap(2));
        YfixStep=defaultStepY*round(Y/defaultStepY);
    end