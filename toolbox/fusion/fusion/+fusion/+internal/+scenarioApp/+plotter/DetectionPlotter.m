classdef DetectionPlotter<handle

    properties(SetAccess=protected,Hidden)
Axes
        Detections matlab.graphics.chart.primitive.Scatter
    end

    properties
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor
        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.MeshAlpha=1
        ZDir=1;
    end

    methods

        function this=DetectionPlotter(hAxes)
            this.Axes=hAxes;
            this.FaceColor=hAxes.ColorOrder(4,:);
            this.Detections=matlab.graphics.chart.primitive.Scatter;
            set(this.Detections,'Parent',this.Axes,...
            'SizeData',36,'Tag','detection.marker');
        end
    end

    methods

        function plotDetections(this,dets)
            pvpairsDets={'Marker','o',...
            'MarkerFaceColor',this.FaceColor,...
            'MarkerEdgeColor','k',...
            'MarkerFaceAlpha',this.FaceAlpha};
            [x,y,z]=getGlobalCoordinates(this,dets);
            zDir=this.ZDir;
            scatdets=this.Detections;
            set(scatdets,...
            'XData',x,...
            'YData',y,...
            'ZData',zDir*z,...
            pvpairsDets{:});
        end

        function clear(this)
            set(this.Detections,'XData',[],'YData',[],'ZData',[]);
        end

    end

    methods(Access=protected)

        function[x,y,z]=getGlobalCoordinates(~,detobj)


            num=numel(detobj);
            x=zeros(num,1);
            y=zeros(num,1);
            z=zeros(num,1);
            for i=1:num
                pos=matlabshared.tracking.internal.fusion.parseDetectionForInitFcn(detobj{i},'DetectionPlotter','double');
                x(i)=pos(1);
                y(i)=pos(2);
                z(i)=pos(3);
            end
        end

    end

end