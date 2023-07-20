function PfixStep=snap_point(UD,P,Ind,OverrideDefault)




    chIdx=UD.current.channel;
    channelStruct=UD.channels(chIdx);
    ActiveGroup=UD.sbobj.ActiveGroup;
    if nargin==2
        Ind=[];
        OverrideDefault=0;
    end

    if nargin==3
        OverrideDefault=0;
    end


    if~isempty(Ind)
        if min(Ind)>1
            minx=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(min(Ind)-1);
        else
            minx=-inf;
        end

        if max(Ind)<length(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData)
            maxx=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(max(Ind)+1);
        else
            maxx=inf;
        end


        if P(1)>maxx
            dlgTagStart=['Msgbox_',getString(message('sigbldr_ui:snap_point:SegStartWarnTitle'))];

            if isempty(findall(0,'Type','figure','Tag',dlgTagStart))
                createModeStr='modal';
                if(UD.current.lockOutSingleClick==1)
                    createModeStr='';
                end
                warndlg(getString(message('sigbldr_ui:snap_point:StartGreaterThanEnd',num2str(maxx))),getString(message('sigbldr_ui:snap_point:SegStartWarnTitle')),createModeStr);
            end
            P(1)=maxx;
        elseif P(1)<minx
            dlgTagEnd=['Msgbox_',getString(message('sigbldr_ui:snap_point:SegEndWarnTitle'))];

            if isempty(findall(0,'Type','figure','Tag',dlgTagEnd))
                createModeStr='modal';
                if(UD.current.lockOutSingleClick==1)
                    createModeStr='';
                end
                warndlg(getString(message('sigbldr_ui:snap_point:EndLessThanStart',num2str(minx))),getString(message('sigbldr_ui:snap_point:SegEndWarnTitle')),createModeStr);
            end
            P(1)=minx;
        end
    else
        minx=-inf;
        maxx=inf;
    end
    if isfield(channelStruct,'yMax')&~isempty(channelStruct.yMax)&P(2)>channelStruct.yMax
        P(2)=channelStruct.yMax;
    elseif isfield(channelStruct,'yMin')&~isempty(channelStruct.yMin)&P(2)<channelStruct.yMin
        P(2)=channelStruct.yMin;
    end




    axesH=UD.axes(channelStruct.axesInd).handle;
    rawSnap=fig_2_ax_ext(pixels2points(UD.dialog,[1,1]),axesH);
    defaultStepX=nearest_125(rawSnap(1));
    defaultStepY=nearest_125(rawSnap(2));

    if(channelStruct.stepX>0)
        stepX=channelStruct.stepX;
    elseif(OverrideDefault)
        stepX=0;
    else
        stepX=defaultStepX;
    end

    if(stepX>0)&(P(1)~=maxx)&(P(1)~=minx)
        PfixStep(1)=stepX*round(P(1)/stepX);
    else
        PfixStep(1)=P(1);
    end

    if(channelStruct.stepY>0)
        stepY=channelStruct.stepY;
    elseif(OverrideDefault)
        stepY=0;
    else
        stepY=defaultStepY;
    end

    if stepY>0
        PfixStep(2)=stepY*round(P(2)/stepY);
    else
        PfixStep(2)=P(2);
    end
