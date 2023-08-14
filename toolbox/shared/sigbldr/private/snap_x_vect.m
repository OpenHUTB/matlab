function XfixStep=snap_x_vect(axes,X,channelStruct)




    if(channelStruct.stepX>0)
        XfixStep=channelStruct.stepX*round(X/channelStruct.stepX);
    else
        axesH=axes(channelStruct.axesInd).handle;
        rawSnap=fig_2_ax_ext([1.5,1.5],axesH);
        defaultStepX=nearest_125(rawSnap(1));
        XfixStep=defaultStepX*round(X/defaultStepX);
    end
