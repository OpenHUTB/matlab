
classdef RangeSliderDisplay<vision.internal.uitools.AppFig

    properties(Access=protected)
SignalNavigationContainerObj
    end

    methods

        function this=RangeSliderDisplay(hFig)
            nameDisplayedInTab=vision.getMessage('vision:labeler:RangeSlider');

            this=this@vision.internal.uitools.AppFig(hFig,nameDisplayedInTab,true);
            this.Fig.Resize='on';
            this.Fig.Tag='RangeSliderDisplay';








            initialize(this);
        end

        function UIObj=getLabeledVideoContainer(this)
            UIObj=this.SignalNavigationContainerObj;
        end


        function configure(this,...
            keyPressCallback)

            this.Fig.KeyPressFcn=keyPressCallback;
        end


        function resizeFigure(this)
            this.SignalNavigationContainerObj.resizeFigureCallback();
        end


        function freezeSignalNavInteractions(this)
            freezeSignalNavInteractions(this.SignalNavigationContainerObj);
        end


        function unfreezeSignalNavInteractions(this)
            unfreezeSignalNavInteractions(this.SignalNavigationContainerObj);
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end
    end





    methods(Access=protected)


        function initialize(this)

            this.SignalNavigationContainerObj=vision.internal.videoLabeler.tool.SignalNavigationContainer(this.Fig);
        end
    end
end
