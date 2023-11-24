function leavingROIMode(this)
    prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
    startAcqCallback=handle(prevPanelButtonPanel.getStartAcqCallback());
    this.startAcquisitionBtnListener=handle.listener(startAcqCallback,'delayed',@handleStartAcqClicked);

    function handleStartAcqClicked(obj,event)
        this.handleStartAcqClickedCallback(obj,event);
    end

end
