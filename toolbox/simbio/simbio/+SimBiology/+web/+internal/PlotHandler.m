classdef PlotHandler<handle



    properties(Access=protected)
        plotObj;
        plotStyle;
        logfile;
    end


    methods
        function obj=PlotHandler(inputs)
            if inputs.figure.handle>0
                createPlotObj(obj,inputs);
            end
        end

        function delete(obj)
            obj.deleteFile(obj.logfile);
        end

        function createPlotObj(obj,inputs)
            obj.plotObj=SimBiology.internal.plotting.sbioplot.SBioPlotObject.createSBioPlotObject(inputs);
        end
    end


    methods
        function out=generateFigure(obj,inputs,isNewPlot)
            if nargin==2
                isNewPlot=true;
            end


            fig=obj.createFigure();
            inputs.figure.handle=double(fig);
            obj.createPlotObj(inputs);


            if isNewPlot
                obj.plotObj.createBlankPlot();
                set(fig,'Visible','on');
                out=obj.plotObj.getInfo();
            else
                out=inputs;
            end


            out.figure.id=inputs.figure.id;
            out.figure.embeddedFigurePacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(fig);
        end
    end


    methods
        function out=recreateFigure(obj,inputs)
            obj.enableWarningLog();

            additionalArgs=inputs.additionalArgs;
            oldAxesInfo=inputs.axes;


            inputs=obj.generateFigure(inputs,false);



            inputs.axes=oldAxesInfo;
            obj.createPlotObj(inputs);
            obj.recreatePlot(inputs,additionalArgs.styleChanged,additionalArgs.dataChanged,[]);
            set(handle(inputs.figure.handle),'Visible','on');


            out=obj.getInfo();
            out.figure.id=inputs.figure.id;
            out.figure.embeddedFigurePacket=inputs.figure.embeddedFigurePacket;
        end

        function out=dropData(obj,inputs)
            obj.enableWarningLog();
            obj.plotObj.setPreserveFormats(~inputs.additionalArgs.isNewPlot);
            obj.plot(inputs);


            obj.waitForFigureRenderingToComplete();

            out=obj.getInfo();
        end

        function out=plotAfterRun(obj,inputs,newdata)










            id=inputs.figure.id;


            figureExists=(inputs.figure.handle~=-1);



            isNewDefaultPlot=isempty(inputs.figure.name);


            assert(~(figureExists&&isNewDefaultPlot),message('SimBiology:Internal:InternalError'));

            if~figureExists
                generatedFigureInfo=obj.generateFigure(inputs,false);

                inputs.figure=generatedFigureInfo.figure;
            end




            styleChanged=isNewDefaultPlot;
            dataChanged=true;
            obj.createPlotObj(inputs);
            obj.recreatePlot(inputs,styleChanged,dataChanged,newdata);


            out=obj.getInfo();
            out.figure.id=id;
            if~figureExists
                out.figure.embeddedFigurePacket=inputs.figure.embeddedFigurePacket;
            end
        end

        function out=refreshPlots(obj,inputs)
            obj.enableWarningLog();
            obj.recreatePlot(inputs,inputs.additionalArgs.styleChanged,inputs.additionalArgs.dataChanged,[]);
            out=obj.getInfo();
        end

        function out=clearPlot(obj,inputs)
            obj.plotObj.createBlankPlot();
            out=obj.getInfo();
        end
    end


    methods
        function out=recreateFigureForReport(obj,inputs,width,height)
            fig=figure('Visible','off');
            set(fig,'Position',[50,50,width,height]);

            inputs.figure.handle=double(fig);
            obj.createPlotObj(inputs);
            obj.recreatePlot(inputs,false,false,[]);

            destinationChildren=get(fig,'Children');
            obj.plotObj.addLegendToStandalonePlot(fig,destinationChildren);


            leg=findobj(fig,'Tag','sliceDataLegend');


            legHeight=(numel(leg)-1)*20;
            for i=1:numel(leg)
                units=get(leg(i),'Units');
                set(leg(i),'Units','pixels');
                legPos=get(leg(i),'Position');
                legHeight=legHeight+legPos(4);
                set(leg(i),'Units',units);
            end

            pos=get(fig,'Position');
            legHeight=min(legHeight,1000);
            if(legHeight>pos(4))
                pos(4)=legHeight;
            end


            screenSize=get(0,'ScreenSize');
            pos(1)=screenSize(3)/2-pos(3)/2;
            pos(2)=screenSize(4)/2-pos(4)/2;
            set(fig,'Position',pos);


            set(fig,'Visible','on');
            out.handles=inputs.figure.handle;
        end
    end


    methods
        function out=updateFigureProperties(obj,inputs)
            obj.plotObj.updateFigureProperties(inputs.figure.props);
            out=obj.getInfo();
        end
    end


    methods
        function out=updateAxesSelection(obj,inputs)
            obj.plotObj.refreshAxesProperty('Selected');
            out=obj.getInfo();
        end

        function out=configureAxesProperty(obj,inputs)
            obj.enableWarningLog();
            changedAxes=handle(inputs.additionalArgs.axesHandles);
            property=inputs.additionalArgs.property;
            value=inputs.additionalArgs.value;

            switch(property)
            case 'Grid'
                configureAxesGridProperty(obj,changedAxes,value);
            case 'Scale'
                configureAxesScaleProperty(obj,changedAxes,value);
            otherwise
                obj.plotObj.configureAxesProperty(changedAxes,property,value);
            end

            out=obj.getInfo();
            out.additionalArgs=inputs.additionalArgs;
        end

        function configureAxesGridProperty(obj,changedAxes,value)
            switch(value)
            case 'none'
                obj.plotObj.configureAxesProperty(changedAxes,'XGrid','off');
                obj.plotObj.configureAxesProperty(changedAxes,'YGrid','off');
            case 'xgrid'
                obj.plotObj.configureAxesProperty(changedAxes,'XGrid','on');
                obj.plotObj.configureAxesProperty(changedAxes,'YGrid','off');
            case 'ygrid'
                obj.plotObj.configureAxesProperty(changedAxes,'XGrid','off');
                obj.plotObj.configureAxesProperty(changedAxes,'YGrid','on');
            case 'both'
                obj.plotObj.configureAxesProperty(changedAxes,'XGrid','on');
                obj.plotObj.configureAxesProperty(changedAxes,'YGrid','on');
            end
        end

        function out=configureAxesScaleProperty(obj,changedAxes,value)
            currentXScale=get(changedAxes,'XScale');
            currentYScale=get(changedAxes,'YScale');

            switch(value)
            case 'plot'
                xscale='linear';
                yscale='linear';
            case 'semilogx'
                xscale='log';
                yscale='linear';
            case 'semilogy'
                xscale='linear';
                yscale='log';
            case 'loglog'
                xscale='log';
                yscale='log';
            end


            if~strcmp(currentXScale,xscale)
                obj.plotObj.configureAxesProperty(changedAxes,'XScale',xscale);
            end
            if~strcmp(currentYScale,yscale)
                obj.plotObj.configureAxesProperty(changedAxes,'YScale',yscale);
            end

            out=obj.getInfo();
        end
    end


    methods
        function out=setBinStyle(obj,inputs)
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(inputs.additionalArgs.categoryVariable);
            binToUpdate=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(inputs.additionalArgs.binToUpdate);

            obj.plotObj.setBinStyle(categoryVariable,binToUpdate,inputs.additionalArgs.property,inputs.additionalArgs.value);
            out=obj.getInfo();
        end

        function out=setBinVisibility(obj,inputs)
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(inputs.additionalArgs.categoryVariable);
            binsToShow=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(inputs.additionalArgs.binsToShow);
            binsToHide=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(inputs.additionalArgs.binsToHide);

            obj.plotObj.setBinVisibility(categoryVariable,binsToShow,binsToHide);


            obj.waitForFigureRenderingToComplete();

            out=obj.getInfo();
        end
    end


    methods
        function out=linkAxes(obj,inputs)
            isUseX=strcmp(inputs.additionalArgs.property,'LinkedX');
            obj.plotObj.linkAxes(true,isUseX);
            out=obj.getInfo();
        end

        function out=unlinkAxes(obj,inputs)
            isUseX=strcmp(inputs.additionalArgs.property,'LinkedX');
            obj.plotObj.linkAxes(false,isUseX);
            out=obj.getInfo();
        end

        function out=zoom(obj,inputs)
            type=inputs.additionalArgs.type;
            switch(type)
            case 'horizontal'
                setX=true;
                setY=false;
            case 'vertical'
                setX=false;
                setY=true;
            otherwise
                setX=true;
                setY=true;
            end


            changedAxes=handle(inputs.additionalArgs.axesHandle);
            mx=str2double(inputs.additionalArgs.x(1:end-2));
            my=str2double(inputs.additionalArgs.y(1:end-2));
            mwidth=str2double(inputs.additionalArgs.width(1:end-2));
            mheight=str2double(inputs.additionalArgs.height(1:end-2));

            if setX
                xLim=obj.pixel2DataSpaceX(changedAxes,[mx,mx+mwidth]);
            else
                xLim=[];
            end
            if setY
                yLim=obj.pixel2DataSpaceY(changedAxes,[my+mheight,my]);
            else
                yLim=[];
            end


            obj.plotObj.zoom(inputs.additionalArgs.axesHandle,xLim,yLim);
            out=obj.getInfo();
            out.additionalArgs=inputs.additionalArgs;

        end

        function out=resetZoom(obj,inputs)
            obj.plotObj.resetZoom(inputs.additionalArgs.axesHandle,inputs.additionalArgs.wasZoomedX,inputs.additionalArgs.wasZoomedY);
            out=obj.getInfo();
            out.additionalArgs=inputs.additionalArgs;
        end
    end


    methods
        function out=addDataTip(obj,inputs)
            obj.plotObj.addDataTip(handle(inputs.additionalArgs.axesHandle),inputs.additionalArgs.x,inputs.additionalArgs.y);
            out=obj.getEmptyInfo();
        end

        function out=clearAllDataTips(obj,inputs)
            obj.plotObj.clearAllDataTips();
            out=obj.getEmptyInfo();
        end
    end


    methods
        function out=export(obj,inputs)
            destinationFig=obj.exportPlotHelper(inputs);
            set(destinationFig,'Visible','on');
            out.figure=inputs.figure;
        end

        function out=save(obj,inputs)
            destinationFig=obj.exportPlotHelper(inputs);
            set(destinationFig,'Visible','on');
            filemenufcn(destinationFig,'FileSave');
            delete(destinationFig);
            out.figure=inputs.figure;
        end

        function out=print(obj,inputs)

            destinationFig=obj.exportPlotHelper(inputs);
            printpreview(destinationFig);
            delete(destinationFig);
            out.figure=inputs.figure;
        end
    end


    methods(Access=protected)

        function out=getInfo(obj)
            out=obj.plotObj.getInfo();
            out.errors=[];
            out.warnings=obj.getWarningsFromLog();
        end

        function out=getEmptyInfo(obj)
            out=struct;
            out.errors=[];
            out.warnings=obj.getWarningsFromLog();
        end

        function enableWarningLog(obj)
            obj.logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
            matlab.internal.diagnostic.log.open(obj.logfile);
        end

        function warnings=getWarningsFromLog(obj)
            warnings=[];
            if~isempty(obj.logfile)

                matlab.internal.diagnostic.log.close(obj.logfile);


                warningLog=matlab.internal.diagnostic.log.load(obj.logfile);
                for i=1:numel(warningLog)
                    [message,identifier]=SimBiology.web.internal.errortranslator(warningLog(i));

                    if~isempty(message)&&~warningLog(i).wasDisabled
                        if any(strcmp(identifier,{'SimBiology:SimData:datasetColumnNotNumeric'}))

                        elseif isempty(warnings)
                            warnings=struct('id',identifier,'message',message);
                        else

                            if~any(arrayfun(@(w)strcmp(w.id,identifier),warnings))||...
                                ~any(arrayfun(@(w)strcmp(w.message,message),warnings))
                                warnings(end+1)=struct('id',identifier,'message',message);%#ok<AGROW>
                            end
                        end
                    end
                end
                obj.logfile='';
            end
        end

        function recreatePlot(obj,inputs,styleChanged,dataChanged,newdata)
            if(dataChanged&&styleChanged)
                obj.plotObj.setPreserveFormats(false);
            else
                obj.plotObj.setPreserveFormats(true);
            end

            if(~dataChanged&&~styleChanged)
                obj.plotObj.setPreserveLabels(true);
            else
                obj.plotObj.setPreserveLabels(false);
            end


            if~dataChanged
                oldWarningState=warning(struct('identifier',{'SimBiology:Plotting:GROUPS_EXCLUDED_FROM_RESAMPLING'},...
                'state',{'off'}));
                warningStateCleanup=onCleanup(@()warning(oldWarningState));

            end

            obj.plot(inputs,newdata);


            obj.waitForFigureRenderingToComplete();
        end

        function plot(obj,inputs,newdata)
            if nargin==2
                newdata=[];
            end

            plotArguments=obj.loadPlotArguments(inputs,newdata);

            obj.plotObj.plot(plotArguments,inputs.definition.props);
        end

        function plotArguments=loadPlotArguments(obj,inputs,newdata)
            plotArguments=SimBiology.internal.plotting.sbioplot.PlotArgument(inputs.definition.plotArguments);
            plotArguments.loadData(newdata,obj.plotObj);
        end

        function destinationFigure=exportPlotHelper(obj,inputs)
            destinationFigure=obj.plotObj.exportPlot(inputs);
        end
    end

    methods(Static)
        function f=createFigure()
            f=matlab.ui.internal.embeddedfigure;
            set(f,'Color','w','HandleVisibility','off','IntegerHandle','off','AutoResizeChildren','off');
            set(f,'SizeChangedFcn',@SimBiology.web.internal.PlotHandler.handleFigureSizeChange);
        end

        function waitForFigureRenderingToComplete()
            drawnow limitrate nocallbacks;
        end

        function deleteFile(name)
            oldWarnState=warning('off','MATLAB:DELETE:Permission');
            cleanup=onCleanup(@()warning(oldWarnState));

            if exist(name,'file')
                oldState=recycle;
                recycle('off');
                delete(name)
                recycle(oldState);
            end
        end

        function value=pixel2DataSpaceX(ax,mx)
            f=SimBiology.internal.plotting.hg.AxesInfo.getParentFigureForAxes(ax);
            info=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPosition(ax,f.Position);
            xleft=info.left;
            width=info.width;
            xlim=ax.DataSpace.XLim;
            xlow=xlim(1);
            xhigh=xlim(2);

            if strcmp(get(ax,'XScale'),'log')
                xlow=log(xlow);
                xhigh=log(xhigh);
            end

            value=zeros(1,length(mx));
            for i=1:length(mx)
                value(i)=(mx(i)-xleft)/(width/(xhigh-xlow))+xlow;
            end

            if strcmp(get(ax,'XScale'),'log')
                value=exp(value);
            end
        end

        function value=pixel2DataSpaceY(ax,my)
            f=SimBiology.internal.plotting.hg.AxesInfo.getParentFigureForAxes(ax);
            info=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPosition(ax,f.Position);
            ytop=info.top;
            height=info.height;
            ylim=ax.DataSpace.YLim;
            ylow=ylim(1);
            yhigh=ylim(2);

            if strcmp(get(ax,'YScale'),'log')
                ylow=log(ylow);
                yhigh=log(yhigh);
            end

            value=zeros(1,length(my));
            for i=1:length(my)
                value(i)=(yhigh-ylow)-(my(i)-ytop)*((yhigh-ylow)/height)+ylow;
            end

            if strcmp(get(ax,'YScale'),'log')
                value=exp(value);
            end
        end
    end


    methods(Static)
        function handleFigureSizeChange(varargin)


            try
                fig=varargin{1};
                props=fig.UserData.props;
                backgroundAxes=findobj(fig.Children,'tag',SimBiology.internal.plotting.sbioplot.SBioPlotObject.BACKGROUND_AXES_TAG);
                plotAxes=handle(reshape(props.AxGrid,props.Row,props.Column));
                SimBiology.internal.plotting.sbioplot.SBioPlotObject.layoutFigure(fig,plotAxes,backgroundAxes,props);

                fPos=fig.Position;
                out.figure.handle=double(fig);
                out.axes=arrayfun(@(ax)SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPositionInfo(ax,fPos),plotAxes);

                out.axes=[out.axes(:)];
                out.type='layoutPerformed';
                message.publish('/SimBiology/plot',out);
            catch ex



            end
        end
    end
end
