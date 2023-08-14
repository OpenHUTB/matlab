classdef(Hidden=true)Plot<handle







    properties
        HFig;
        HAxes;
        HZoom;
        HPan;
        XData;
        YData;
        handleMap;
        SDIEngine;
        sd;



        Quality;
    end


    methods


        function this=Plot(SDIEngine)
            this.SDIEngine=SDIEngine;
            this.Quality=0.25;
            this.sd=Simulink.sdi.internal.StringDict;
            this.handleMap=Simulink.sdi.Map(0,?handle);
        end


        function plotInspectorFigure(this,hFig)
            clf(hFig);
            plotInspectReportWebVersion(this,hFig);
        end


        function plotCompareRunsFigure(this,sigID1,hFig)
            clf(hFig);
            this.plotUpdateCompRuns(sigID1,hFig);
        end


        function plotCompareSignalsFigure(this,hFig)
            clf(hFig);
            eng=Simulink.sdi.Instance.engine;
            sigID1=eng.comparedSignal1;
            sigID2=eng.comparedSignal2;
            if~isempty(sigID1)&&~isempty(sigID2)
                this.plotUpdateCompareSignals(sigID1,sigID2,hFig);
            end
        end


        function plotSignals(this,hAxes,signals2PlotList,varargin)
            if nargin<4
                isNormalized=false;
            else
                isNormalized=varargin{1};
            end

            if nargin==5
                interp=varargin{2};
            else
                interp=Simulink.sdi.internal.PlotType.Default;
            end


            if isempty(interp)
                interp=Simulink.sdi.internal.PlotType.Default;
            end

            if(~strcmp(get(hAxes,'Type'),'axes'))
                error(message('SDI:sdi:InvalidAxesHandle'));
            end

            this.HAxes=hAxes;


            xmin=inf;
            xmax=-inf;

            for i=1:length(signals2PlotList)
                data=signals2PlotList(i);
                interpi=interp;


                if isempty(data.DataValues)||isempty(data.DataValues.Time)
                    continue;
                end

                dataToPlot=data.DataValues.Data;
                if~isvector(dataToPlot)
                    sz=size(dataToPlot);
                    if(max(sz)==numel(dataToPlot))
                        dataToPlot=reshape(dataToPlot,1,max(sz));
                    end
                end

                if~isreal(dataToPlot)
                    dataToPlot=real(dataToPlot);
                end

                if isNormalized
                    dataToPlot=this.transformAndScale(dataToPlot,...
                    min((double(dataToPlot))),...
                    max((double(dataToPlot))));
                end


                if interpi==Simulink.sdi.internal.PlotType.Default
                    interpMethod=this.SDIEngine.getSignalInterpMethod(data.DataID);
                    if strcmpi(interpMethod,'zoh')
                        interpi=Simulink.sdi.internal.PlotType.Stair;
                    else
                        interpi=Simulink.sdi.internal.PlotType.Line;
                    end
                end

                switch interpi
                case Simulink.sdi.internal.PlotType.Stair
                    hold(hAxes,'on');
                    hl=stairs(data.DataValues.Time,dataToPlot,'Parent',hAxes);
                    hold(hAxes,'off');
                case Simulink.sdi.internal.PlotType.Line
                    hl=line(data.DataValues.Time,dataToPlot,'Parent',hAxes);
                end


                xmin=min(xmin,min(data.DataValues.Time));
                xmax=max(xmax,max(data.DataValues.Time));

                set(hl,'Color',data.LineColor);
                set(hl,'LineStyle',data.LineDashed);
                marker=this.SDIEngine.getSignalMarker(data.DataID);
                set(hl,'marker',marker);
                set(hl,'Parent',hAxes);
                this.handleMap.insert(data.DataID,hl);


                if length(dataToPlot)==1
                    set(hl,'Marker','p')
                end


                this.setupAppData(hl,hAxes);
            end


            yLim=get(hAxes,'ylim');
            buffer=(yLim(2)-yLim(1))/50;
            yLim=[yLim(1)-buffer,yLim(2)+buffer];


            set(hAxes,'ylim',yLim);


            xLim=get(hAxes,'xlim');
            buffer=(xLim(2)-xLim(1))/50;
            xLim=[xmin-buffer,xmax+buffer];

            if(xLim(2)>xLim(1))
                set(hAxes,'xlim',xLim);
            end
            zoom(hAxes,'reset');


            this.setupCallbacks(hAxes);
        end


        function plotComparisonSignals(this,hAxes,signals2PlotList,varargin)
            if nargin<4
                isNormalized=false;
            else
                isNormalized=varargin{1};
            end

            if nargin==5
                interp=varargin{2};
            else
                interp=Simulink.sdi.internal.PlotType.Default;
            end

            if nargin==6
                colorAndLineStyles=varargin{3};
            end


            if isempty(interp)
                interp=Simulink.sdi.internal.PlotType.Default;
            end
            if(~strcmp(get(hAxes,'Type'),'axes'))
                error(message('SDI:sdi:InvalidAxesHandle'));
            end

            this.HAxes=hAxes;


            xmin=inf;
            xmax=-inf;
            ymin=inf;
            ymax=-inf;

            for i=1:length(signals2PlotList)
                data=signals2PlotList(i);
                interpi=interp;


                if isempty(data.DataValues)||isempty(data.DataValues.Time)
                    continue;
                end

                dataToPlot=data.DataValues.Data;
                if~isvector(dataToPlot)
                    sz=size(dataToPlot);
                    if(max(sz)==numel(dataToPlot))
                        dataToPlot=reshape(dataToPlot,1,max(sz));
                    end
                end

                if~isreal(dataToPlot)
                    dataToPlot=real(dataToPlot);
                end

                if isNormalized
                    dataToPlot=this.transformAndScale(dataToPlot,...
                    min((double(dataToPlot))),...
                    max((double(dataToPlot))));
                end


                if interpi==Simulink.sdi.internal.PlotType.Default
                    interpMethod=this.SDIEngine.getSignalInterpMethod(data.DataID);
                    if strcmpi(interpMethod,'zoh')
                        interpi=Simulink.sdi.internal.PlotType.Stair;
                    else
                        interpi=Simulink.sdi.internal.PlotType.Line;
                    end
                end

                switch interpi
                case Simulink.sdi.internal.PlotType.Stair
                    hold(hAxes,'on');
                    hl=stairs(data.DataValues.Time,dataToPlot,'Parent',hAxes);
                    hold(hAxes,'off');
                case Simulink.sdi.internal.PlotType.Line
                    hl=line(data.DataValues.Time,dataToPlot,'Parent',hAxes);
                end


                xmin=min(xmin,min(data.DataValues.Time));
                xmax=max(xmax,max(data.DataValues.Time));
                ymin=min(ymin,min(data.DataValues.Data));
                ymax=max(ymax,max(data.DataValues.Data));

                set(hl,'Color',colorAndLineStyles(i).Color);
                set(hl,'LineStyle',colorAndLineStyles(i).LineStyle);
                marker=this.SDIEngine.getSignalMarker(data.DataID);
                set(hl,'marker',marker);
                set(hl,'Parent',hAxes);
                this.handleMap.insert(data.DataID,hl);


                if length(dataToPlot)==1
                    set(hl,'Marker','p')
                end


                this.setupAppData(hl,hAxes);
            end


            yLim=get(hAxes,'ylim');
            buffer=(yLim(2)-yLim(1))/50;
            yLim=[ymin-buffer,ymax+buffer];


            set(hAxes,'ylim',yLim);


            xLim=get(hAxes,'xlim');
            buffer=(xLim(2)-xLim(1))/50;
            xLim=[xmin-buffer,xmax+buffer];

            if(xLim(2)>xLim(1))
                set(hAxes,'xlim',xLim);
            end
            zoom(hAxes,'reset');


            this.setupCallbacks(hAxes);
        end


        function plotZeroDiff(this,hAxes,lhsID)
            data=this.SDIEngine.getSignal(int32(lhsID));

            if(~strcmp(get(hAxes,'Type'),'axes'))
                error(message('SDI:sdi:InvalidAxesHandle'));
            end

            this.HAxes=[this.HAxes,hAxes];

            if isempty(data.DataValues)
                return;
            end

            sz=size(data.DataValues.Data);
            toPlot=zeros(sz);
            if~isvector(toPlot)
                if(max(sz)==numel(toPlot))
                    toPlot=reshape(toPlot,1,max(sz));
                end
            end
            xPlot=data.DataValues.Time;
            hLine=plot(hAxes,xPlot,toPlot);

            if~isempty(xPlot)&&max(xPlot)>0
                set(hAxes,'Xlim',[0,max(xPlot)],'Ylim',[-1,1]);
            end


            if length(toPlot)==1
                set(hLine,'Marker','p')
            end

            strDict=Simulink.sdi.internal.StringDict;
            set(hLine,'Color','r');
            h=legend(hAxes,strDict.mgDifference);
            set(h,'Box','off');

            this.setupAppData(hLine,hAxes);

            this.setupCallbacks(hAxes);
            zoom(hAxes,'reset');
        end


        function plotDiff(this,hAxes,Diff,Tol,varargin)
            if nargin<5
                isNormalized=false;
            else
                isNormalized=varargin{1};
            end

            if nargin==6
                interp=varargin{2};
            else
                interp=Simulink.sdi.internal.PlotType.Default;
            end


            if isempty(interp)
                interp=Simulink.sdi.internal.PlotType.Default;
            end
            if(~strcmp(get(hAxes,'Type'),'axes'))
                error(message('SDI:sdi:InvalidAxesHandle'));
            end

            this.HAxes=[this.HAxes,hAxes];

            if(~isa(Diff,'timeseries'))
                error(message('SDI:sdi:InvalidTimeSeriesObject',...
                '2nd or 3rd parameter'));
            end

            dataToPlot=abs(Diff.Data);

            if isempty(dataToPlot)
                return;
            end

            if~isvector(dataToPlot)
                sz=size(dataToPlot);
                if(max(sz)==numel(dataToPlot))
                    dataToPlot=reshape(dataToPlot,1,max(sz));
                end
            end

            if isNormalized
                dataToPlot=this.transformAndScale(dataToPlot,...
                min((double(dataToPlot))),...
                max((double(dataToPlot))));
            end


            if interp==Simulink.sdi.internal.PlotType.Default
                interpMethod=Diff.getinterpmethod();
                if strcmpi(interpMethod,'zoh')
                    interp=Simulink.sdi.internal.PlotType.Stair;
                else
                    interp=Simulink.sdi.internal.PlotType.Line;
                end
            end

            switch interp
            case Simulink.sdi.internal.PlotType.Stair
                hold(hAxes,'on');
                hLineDiff=stairs(Diff.Time,dataToPlot,'Parent',hAxes);
                hold(hAxes,'off');
            case Simulink.sdi.internal.PlotType.Line
                hLineDiff=line(Diff.Time,dataToPlot,'Parent',hAxes);
            end

            set(hLineDiff,'Color','r');
            set(hLineDiff,'Parent',hAxes);


            if length(dataToPlot)==1
                set(hLineDiff,'Marker','p')
            end


            if~isempty(Diff.Time)&&(Diff.Time(end)>Diff.Time(1))
                set(hAxes,'XLim',[Diff.Time(1),Diff.Time(end)]);
            end

            this.setupAppData(hLineDiff,hAxes);

            dataToPlot=abs(Tol.Data);
            if~isvector(dataToPlot)
                sz=size(dataToPlot);
                if(max(sz)==numel(dataToPlot))
                    dataToPlot=reshape(dataToPlot,1,max(sz));
                end
            end
            if isNormalized
                dataToPlot=this.transformAndScale(dataToPlot,...
                min((double(dataToPlot))),...
                max((double(dataToPlot))));
            end


            switch interp
            case Simulink.sdi.internal.PlotType.Stair
                hold(hAxes,'on');
                hLineDiff2=stairs(Tol.Time,dataToPlot,'Parent',hAxes);
                hold(hAxes,'off');
            case Simulink.sdi.internal.PlotType.Line
                hLineDiff2=line(Tol.Time,dataToPlot,'Parent',hAxes);
            end

            set(hLineDiff2,'Color','g');
            set(hLineDiff2,'LineStyle',':');
            set(hLineDiff2,'Parent',hAxes);


            if length(dataToPlot)==1
                set(hLineDiff2,'Marker','p')
            end

            if~isempty(Tol.Time)&&(Tol.Time(end)>Tol.Time(1))
                set(hAxes,'XLim',[Tol.Time(1),Tol.Time(end)]);
            end

            this.setupAppData(hLineDiff2,hAxes);


            yLim=get(hAxes,'ylim');
            buffer=(yLim(2)-yLim(1))/50;
            yLim=[yLim(1)-buffer,yLim(2)+buffer];


            set(hAxes,'ylim',yLim);
            zoom(hAxes,'reset');


            this.setupCallbacks(hAxes);
        end


        function clearPlot(this)


            [r,c]=size(this.HAxes);
            for i=1:r
                for j=1:c
                    if~isempty(this.HAxes(i,j))&&ishandle(this.HAxes(i,j))
                        Simulink.sdi.internal.Util.clearAxes(this.HAxes(i,j));
                    end
                end
            end
        end

    end


    methods(Hidden=true)


        function getQuality(this)
            this.Quality
        end


        function setQuality(this,value)
            this.Quality=value;
        end


        function setupAppData(this,hLine,hAxes)
            xData=get(hLine,'XData')';
            yData=get(hLine,'YData')';
            setappdata(hLine,'XD',xData);
            setappdata(hLine,'YD',yData);
            this.plotHelperCallback([],hAxes,hLine);
        end


        function setupCallbacks(this,hAxes)
            parent1=get(hAxes,'parent');
            parent1Type=get(parent1,'Type');
            parent2=get(parent1,'parent');
            parent3=get(parent2,'parent');
            parent3Type=get(parent3,'Type');
            parent4=get(parent3,'parent');
            parent4Type=get(parent4,'Type');
            parent5=get(parent4,'parent');
            parent5Type=get(parent5,'Type');


            if strcmp(parent1Type,'figure')
                this.HFig=parent1;
            elseif strcmp(parent3Type,'figure')
                this.HFig=parent3;
            elseif strcmp(parent4Type,'figure')
                this.HFig=parent4;
            elseif strcmp(parent5Type,'figure')
                this.HFig=parent5;
            else
                error(message('SDI:sdi:WrongFigureHandle'))
            end


            this.HZoom=zoom(this.HFig);
            set(this.HZoom,'ActionPostCallback',@this.plotMainCallback);


            this.HPan=pan(this.HFig);
            set(this.HPan,'ActionPostCallback',@this.plotMainCallback);

        end
    end


    methods(Access='private')


        plotInspectReportWebVersion(this,hFig)


        function plotMainCallback(this,s,~)

            [r,c]=size(this.HAxes);


            for i=1:r
                for j=1:c
                    this.plotAxesCallback([],[],this.HAxes(i,j),s);
                end
            end
        end


        function plotAxesCallback(this,~,~,hAxes,s)

            if~ishandle(hAxes)||(isappdata(hAxes,'unlinked')&&...
                (strcmp(getappdata(hAxes,'unlinked'),'true'))&&hAxes~=s)
                return;
            end

            children=get(hAxes,'Children');
            count=length(children);
            for i=1:count
                this.plotHelperCallback([],hAxes,children(i))
            end
        end


        function retdata=transformAndScale(this,data,minVal,maxVal)%#ok
            if(sign(minVal)==-1&&sign(maxVal)==-1)
                maxVal1=abs(minVal);
                minVal1=abs(maxVal);
            elseif(sign(minVal)==-1&&sign(maxVal)==1)||...
                (sign(minVal)==-1&&sign(maxVal)==0)
                minVal1=0;
                maxVal1=max(abs(minVal),abs(maxVal));
            elseif(sign(minVal)==0&&sign(maxVal)==1)
                minVal1=0;
                maxVal1=abs(maxVal);
            else
                maxVal1=abs(maxVal);
                minVal1=abs(minVal);
            end

            maxVal=maxVal1;
            minVal=minVal1;

            if((maxVal-minVal)<eps)
                if(maxVal<eps)
                    retdata=zeros(size(data));
                    return;
                end
                retdata=ones(size(data));
                return;
            end

            if islogical(data)
                retdata=data;
            elseif isinteger(data)


                data=double(data);
                retdata=(sign(data)).*(abs(data)-minVal)/(maxVal-minVal);
            else
                retdata=(sign(data)).*(abs(data)-minVal)/(maxVal-minVal);
            end
        end


        function plotHelperCallback(this,~,~,varargin)
            if~isempty(varargin)
                hLine=varargin{1};
            else
                return;
            end


            if~ishandle(hLine)||~isappdata(hLine,'XD')||~isappdata(hLine,'YD')
                return;
            end


            xData=getappdata(hLine,'XD');
            lengthOfData=length(xData);
            yData=getappdata(hLine,'YD');

            hAxes=get(hLine,'Parent');





            if~ishandle(hLine)
                return;
            end

            xLim=get(hAxes,'XLim');


            lXIdx=this.findCondIdx(xData,xLim(1));

            if(lXIdx>1)
                lXIdx=lXIdx-1;
            end
            uXIdx=this.findCondIdx(xData,xLim(2));

            if(uXIdx<lengthOfData)
                uXIdx=uXIdx+1;
            end


            xPreData=xData(lXIdx:uXIdx);
            yPreData=yData(lXIdx:uXIdx);


            set(hLine,'XData',xPreData,'YData',yPreData);
        end


        function i=findCondIdx(~,arr,cond)


            i=find(arr>=cond,1);
            if isempty(i)
                i=length(arr);
            end
        end
    end

end



