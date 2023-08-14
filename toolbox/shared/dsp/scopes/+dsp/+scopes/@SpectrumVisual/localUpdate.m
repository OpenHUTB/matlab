function localUpdate(this,reScalePSDFlag,forceUpdateFlag,refreshsamplesPerUpdate,zeroOutSpectrogram)









    if nargin==2
        forceUpdateFlag=false;
    end
    if nargin<4


        refreshsamplesPerUpdate=false;
    end
    if nargin<5
        zeroOutSpectrogram=false;
    end
    if~reScalePSDFlag


        this.PropChanged=true;
        if~isFrequencyInputMode(this)



            updateBuffer(this.SpectrumObject);
        end
    end
    hScope=this.Application;
    if~isempty(hScope.DataSource)&&this.IsSourceValid&&...
        (isSourceRunning(this)||forceUpdateFlag)&&this.IsNotInCorrectionMode

        if reScalePSDFlag


            fromLocalUpdate=true;
            update(this,reScalePSDFlag,refreshsamplesPerUpdate,fromLocalUpdate);
        else


            disableSamplesPerUpdateMessage=resetSpectrogram(this,zeroOutSpectrogram);




            refreshsamplesPerUpdate=refreshsamplesPerUpdate&&~disableSamplesPerUpdateMessage;


            if~this.UpdateInProgress
                this.SpectrumObject.DataBuffer.rebuffer;
                this.ProcessLastSegmentOnly=true;
                fromLocalUpdate=true;
                update(this,reScalePSDFlag,refreshsamplesPerUpdate,fromLocalUpdate);
                updateText(this);
                this.ProcessLastSegmentOnly=false;
            end
        end
        redoMaskTest(this);

        if this.ForceAutoScaleOnUpdate
            fevalOnExtension(this.Application,'Tools','Plot Navigation',...
            @(hPlotNavigator)performAutoscale(hPlotNavigator,true,true));
            this.ForceAutoScaleOnUpdate=false;
        end


        sendEvent(hScope,'VisualUpdated');
        sendEvent(hScope,'TextUpdated');
    end
end
