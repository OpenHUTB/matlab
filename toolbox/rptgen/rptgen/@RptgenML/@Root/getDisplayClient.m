function displayClient=getDisplayClient(this,action)












    if nargin<2
        displayClient=setClientVisible(this,true);
        rptgen.internal.gui.GenerationDisplayClient.setMessageClient(displayClient);
    else
        switch action
        case '-hide'
            setClientVisible(this,false);
        case '-view'
            setClientVisible(this,true);
        otherwise
            setClientVisible(this,~getClientVisible(this));
        end
    end


    function displayClient=setClientVisible(this,isVis)

        if isempty(this.StatusWindow)&&isVis
            displayClient=rptgen.internal.gui.GenerationMessageList;
            displayClient.frameify;
            this.StatusWindow=displayClient;
        else
            displayClient=this.StatusWindow;
            if~isempty(displayClient)
                try
                    setFrameVisible(displayClient,isVis);
                catch

                end
            end
        end


        function isVis=getClientVisible(this)

            if isempty(this.StatusWindow)
                isVis=false;
            else
                try
                    isVis=this.StatusWindow.getRootPane.getParent.isVisible;
                catch
                    isVis=false;
                end
            end






