classdef OrientationAxes<handle

    properties

Panel
hAx
XAxisLine
YAxisLine
ZAxisLine
XAxisPointer
YAxisPointer
ZAxisPointer
XText
YText
ZText

    end


    methods

        function self=OrientationAxes(hFig,initialCameraPos)

            self.Panel=uipanel('Parent',hFig,'Units','Normalized','Position',[0,0,1,1],'visible','off');
            self.hAx=axes('Parent',self.Panel,'Visible','off','Units','Normalized');
            self.hAx.Position=[0,0,1,1];
            self.hAx.Visible='off';
            self.hAx.Clipping='off';
            axis(self.hAx,'equal');

            lineRatio=0.75;
            lineLength=lineRatio/(1-lineRatio);
            totalAxisLength=lineLength+1;

            arrowHeadRadius=1-lineRatio;

            self.hAx.XLim=[-totalAxisLength,totalAxisLength]+[-0.5,0.5];
            self.hAx.YLim=[-totalAxisLength,totalAxisLength]+[-0.5,0.5];
            self.hAx.ZLim=[-totalAxisLength,totalAxisLength]+[-0.5,0.5];

            self.XAxisLine=line('XData',[0,lineLength],'YData',[0,0],'ZData',[0,0],'Parent',self.hAx);
            self.YAxisLine=line('XData',[0,0],'YData',[0,lineLength],'ZData',[0,0],'Parent',self.hAx);
            self.ZAxisLine=line('XData',[0,0],'YData',[0,0],'ZData',[0,lineLength],'Parent',self.hAx);

            self.XAxisLine.Color='red';
            self.YAxisLine.Color='green';
            self.ZAxisLine.Color='blue';

            self.hAx.CameraPositionMode='manual';
            self.hAx.ClippingStyle='3dbox';
            self.hAx.Camera.DepthSort='off';

            self.hAx.CameraUpVector=[0,0,1];
            self.hAx.CameraTarget=[0,0,0];
            normPos=initialCameraPos./norm(initialCameraPos);
            self.hAx.CameraPosition=4*normPos;

            textLoc=totalAxisLength+0.2;
            self.XText=text(self.hAx,textLoc,0,0,'X','FontSize',14,'Color','red');
            self.YText=text(self.hAx,0,textLoc,0,'Y','FontSize',14,'Color','green');
            self.ZText=text(self.hAx,0,0,textLoc,'Z','FontSize',14,'Color','blue');

            [self.XAxisLine.LineWidth,self.YAxisLine.LineWidth,self.ZAxisLine.LineWidth]=deal(2);

            [D1,D2,D3]=cylinder([arrowHeadRadius,0]);
            D3=D3+lineLength;

            hold on;
            [cDataX,cDataY,cDataZ]=deal(zeros([size(D3),3]));
            cDataZ(:,:,3)=1;
            cDataY(:,:,2)=1;
            cDataX(:,:,1)=1;
            self.ZAxisPointer=surf(D1,D2,D3,cDataZ,'EdgeColor','none');
            self.YAxisPointer=surf(D1,D3,D2,cDataY,'EdgeColor','none');
            self.XAxisPointer=surf(D3,D2,D1,cDataX,'EdgeColor','none');

            hold off;



            hFig.HandleVisibility='callback';

        end
    end
end