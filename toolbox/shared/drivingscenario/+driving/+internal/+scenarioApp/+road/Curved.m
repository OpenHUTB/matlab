classdef Curved<driving.internal.scenarioApp.road.Specification
    properties
        Width=6;
        StartPoint=[0,-10,0];
        EndPoint=[0,10,0];
        Radius=10;
        Lanes=lanespec.empty;
    end

    properties(Hidden,Transient)
RoadCenters
    end

    methods
        function this=Curved(varargin)
            this@driving.internal.scenarioApp.road.Specification(varargin{:});
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                this.StartPoint=this.StartPoint.*[1,-1,-1];
                this.EndPoint=this.EndPoint.*[1,-1,-1];
                lanes=this.Lanes;
                if~isempty(lanes)
                    lanes.Marking=fliplr(lanes.Marking);
                    lanes.Type=fliplr(lanes.Type);
                    this.Lanes=fliplr(lanes);
                end
            end
        end

        function applyToScenario(this,scenario)

            start=this.StartPoint;
            endp=this.EndPoint;

            r=this.Radius;

            [xc,yc,theta1,theta2]=calculateCenter(this);

            delTheta=wrapToPi(theta2-theta1)/256;

            theta1d=wrapToPi(theta1+delTheta);
            theta2d=wrapToPi(theta2-delTheta);
            thetaM=wrapToPi((theta2+theta1)/2);
            if theta1>theta2
                thetaM=pi-thetaM;
            end
            roadCenters=[
            start;
            xc+r*cos(theta1d),yc+r*sin(theta1d),start(3)+endp(3)/256;
            xc+r*cos(thetaM),yc+r*sin(thetaM),(start(3)+endp(3))/2;
            xc+r*cos(theta2d),yc+r*sin(theta2d),endp(3)-start(3)/256;
            endp];
            this.RoadCenters=roadCenters;
            road(scenario,roadCenters,this.Width,'Lanes',this.Lanes);
        end

        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.road.CurvedPropertySheet';
        end

        function str=generateMatlabCode(this,scenarioName)
            str='INSERT CURVED ROAD';
        end

        function[b,str]=validate(this)
            b=true;
            str='';
            try
                calculateCenter(this);
            catch ME
                b=false;
                str=ME.message;
            end
        end

        function set.Width(this,width)
            this.Width=width;
            clearScenario(this);
        end
        function set.Radius(this,rad)
            this.Radius=rad;
            clearScenario(this);
        end
        function set.StartPoint(this,startPoint)
            this.StartPoint=startPoint;
            clearScenario(this);
        end
        function set.EndPoint(this,endPoint)
            this.EndPoint=endPoint;
            clearScenario(this);
        end
    end

    methods(Hidden)
        function p=plotEditPoints(this,hAxes,varargin)
            roadCenters=this.RoadCenters;
            p=line(hAxes,'XData',roadCenters([1,3,5],1),'YData',roadCenters([1,3,5],2),'Marker','o','LineStyle','none',...
            'MarkerFaceColor','w','Tag','CurvedEditPoint');
        end

        function pvPairs=getPvPairsForAddPoints(this,addPoints)
            pvPairs={'StartPoint',this.StartPoint+addPoints,'EndPoint',this.EndPoint+addPoints};
        end

        function pvPairs=getPvPairsForDrag(this,offset)
            pvPairs=getPvPairsForAddPoints(this,offset);
        end

        function pvPairs=getPvPairsForPaste(this,location)
            if nargin>1
                midpoint=(this.StartPoint+this.EndPoint)/2;
                offset=midpoint-location;
                pvPairs={'StartPoint',this.StartPoint-offset,'EndPoint',this.EndPoint-offset};
            else
                pvPairs=getPvPairsForDrag(this,-[this.Width,this.Width,0]);
            end
        end

        function[xc,yc,theta1,theta2]=calculateCenter(this)
            start=this.StartPoint;
            endp=this.EndPoint;

            x1=start(1);
            x2=endp(1);
            y1=start(2);
            y2=endp(2);
            x3=(x1+x2)/2;
            y3=(y1+y2)/2;

            q=sqrt((x2-x1)^2+(y2-y1)^2);
            r=this.Radius;
            xc=x3+sqrt(r^2-(q/2)^2)*(y1-y2)/q;
            yc=y3+sqrt(r^2-(q/2)^2)*(x2-x1)/q;
            theta1=atan2((y1-yc),(x1-xc));

            theta2=atan2((y2-yc),(x2-xc));
        end
    end
end


