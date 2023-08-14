classdef(Abstract)PerfPlot<handle

    properties
hFig

cPanel
pPanel
iPanel

hAx
lm
plotB
infoText
    end

    properties(Abstract)
pTitle
xLabel
yLabel
    end

    methods
        function this=PerfPlot(figName)
            this.lm=soc.internal.LayoutManager();


            this.hFig=this.lm.createFigure(figName);


            this.pPanel=this.lm.addPlotPanel(this.hFig,this.pTitle);
            this.hAx=this.lm.addAxes(this.pPanel,this.xLabel,this.yLabel);


            this.cPanel=this.lm.addControlsPanel(this.hFig);


            this.iPanel=this.lm.addInfoPanel(this.hFig);
            this.infoText=this.lm.addInfoTextControl(this.iPanel,'');
        end

        function setCurrentPlotInfo(this,text)
            set(this.infoText,'String',text);
        end

        function setPlotTitle(this,title)
            set(this.pPanel,'Title',title);
        end

        function delete(this)
            delete(this.hFig);
        end
    end

    methods(Abstract)
        plotCb(this,~,~)
    end
end
