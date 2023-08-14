classdef Line<handle






    properties
hLine
hAxes
hInst
        acquireGroupIndex int32
        acquireSignalIndex int32
acquireSignalArrayIndex
lineName
Callback
    end

    methods

        function obj=Line(hInst,hAxes,index,options)

            obj.hAxes=hAxes;
            obj.hInst=hInst;

            obj.acquireGroupIndex=index.acquiregroupindex;
            obj.acquireSignalIndex=index.signalindex;
            obj.acquireSignalArrayIndex=index.arrayindex;

            obj.Callback=options.Callback;

            assert(length(obj.acquireGroupIndex)==1);

            signalStruct=hInst.AcquireList.AcquireListModel.getAcquireSignalStruct(...
            obj.acquireGroupIndex,obj.acquireSignalIndex);

            names=slrealtime.Instrument.getSignalNames(signalStruct);

            if all(obj.acquireSignalArrayIndex==1)
                obj.lineName=names{1};
            else
                if length(obj.acquireSignalArrayIndex)==1
                    obj.lineName=sprintf('%s-(%d)',names{1},obj.acquireSignalArrayIndex);
                else
                    obj.lineName=sprintf('%s-(%d, %d)',names{1},obj.acquireSignalArrayIndex(1),obj.acquireSignalArrayIndex(2));
                end
            end


            obj.hLine=matlab.graphics.chart.primitive.Line('Parent',obj.hAxes,'XData',[],'YData',[]);
            obj.hLine.LineWidth=options.LineStyle.Width;
            obj.hLine.Color=options.LineStyle.Color;
            obj.hLine.LineStyle=options.LineStyle.Style;
            obj.hLine.Marker=options.LineStyle.Marker;
            obj.hLine.MarkerSize=options.LineStyle.MarkerSize;
            obj.hLine.DisplayName=obj.lineName;
        end

        function update(obj,time,data)


            if numel(obj.acquireSignalArrayIndex)==1

                j=obj.acquireSignalArrayIndex;
                sdata=data(:,j);
                obj.localaddpoints(time,double(sdata));
            else

                i=obj.acquireSignalArrayIndex(1);
                j=obj.acquireSignalArrayIndex(2);
                sdata=squeeze(data(i,j,:));
                obj.localaddpoints(time,double(sdata));
            end
        end

        function localaddpoints(this,time,data)


            XData=this.hLine.XData;
            YData=this.hLine.YData;

            if~isempty(this.Callback)
                data=this.Callback(time,data);
            end

            if isempty(XData)&&this.hInst.AxesTimeSpan~=Inf
                this.hAxes.XLim=[time(1),time(1)+this.hInst.AxesTimeSpan];
            end


            XData=[XData(:);time(:)];
            YData=[YData(:);data(:)];


            if this.hInst.AxesTimeSpan~=Inf
                if strcmp(this.hInst.AxesTimeSpanOverrun,'wrap')

                    if XData(end)>XData(1)+this.hInst.AxesTimeSpan
                        origYLimMode=this.hAxes.YLimMode;
                        this.hAxes.XLim=[XData(end),XData(end)+this.hInst.AxesTimeSpan];
                        this.hAxes.YLimMode='manual';
                        XData=XData(end);
                        YData=YData(end);
                        this.hAxes.YLimMode=origYLimMode;
                    end
                else

                    if XData(end)>XData(1)+this.hInst.AxesTimeSpan
                        XData=XData(XData>=XData(end)-this.hInst.AxesTimeSpan);
                        YData=YData(end-(length(XData))+1:end);
                        this.hAxes.XLim=[XData(1),XData(end)];
                    end
                end
            end


            set(this.hLine,'XData',XData','YData',YData');

        end

        function clearData(obj)
            set(obj.hLine,'XData',[],'YData',[]);
            set(obj.hAxes,'XLim',[0,1]);
            set(obj.hAxes,'XLimMode','auto');
            if strcmp(obj.hAxes.YLimMode,'auto')
                set(obj.hAxes,'YLim',[0,1]);
                obj.hAxes.YLimMode='auto';
            end
            set(obj.hAxes,'XTickMode','auto');
            set(obj.hAxes,'XTickLabelMode','auto');
            set(obj.hAxes,'XTickLabelsMode','auto');
            set(obj.hAxes,'YTickMode','auto');
            set(obj.hAxes,'YTickLabelMode','auto');
            set(obj.hAxes,'YTickLabelsMode','auto');

        end

        function[x,y]=getData(obj)
            x=obj.hLine.XData;
            y=obj.hLine.YData;

            x=x(:);
            y=y(:);
        end


        function delete(obj)
            if~isempty(obj.hLine)
                delete(obj.hLine);
            end
        end
    end
end

