function handleDevicePropertiesTabCallback(this,javaEvent)


    if javaEvent.javaEvent

        timerPeriod=round(propertyPanelUpdateRate()*2,3);
        if timerPeriod<1
            timerPeriod=1;
        end

        if isempty(this.propertyUpdateTimer)||~isa(this.propertyUpdateTimer,'timer')
            this.propertyUpdateTimer=timer('ExecutionMode','fixedRate','Period',timerPeriod,...
            'TimerFcn',@updatePropertyDisplay);
        elseif isa(this.propertyUpdateTimer,'timer')&&(this.propertyUpdateTimer.Running=="Off")

            timerPeriod=round(propertyPanelUpdateRate()*2,3);
            if timerPeriod<1
                timerPeriod=1;
            end
            this.propertyUpdateTimer.Period=timerPeriod;
        end
        this.startPropertyUpdateTimer();
    else
        this.stopPropertyUpdateTimer();
    end

    function updatePropertyDisplay(timerObj,timerEvent)%#ok<INUSD>

        vidObj=iatbrowser.Browser().currentVideoinputObject;
        if~isa(vidObj,'videoinput')||~isvalid(vidObj)
            return;
        end
        curSrc=getselectedsource(vidObj);



        javaPeer=java(this.javaPeer);
        formatNodePanel=javaPeer.getFormatNodePanel();
        propertyEditor=formatNodePanel.getPropertyEditor();
        props=propertyEditor.getProperties();

        for idx=0:(props.size()-1)
            aprop=props.get(idx);

            if aprop.isBeingEdited()
                continue
            end

            propname=aprop.getName();

            javaMethodEDT('setValue',aprop,get(curSrc,char(propname)))
        end
    end


    function timerPeriod=propertyPanelUpdateRate()
        localTimerObj=timer('TimerFcn',@updatePropertyDisplay);
        tElapsed=tic;
        start(localTimerObj);
        wait(localTimerObj);
        timerPeriod=toc(tElapsed);
        delete(localTimerObj);
    end

end