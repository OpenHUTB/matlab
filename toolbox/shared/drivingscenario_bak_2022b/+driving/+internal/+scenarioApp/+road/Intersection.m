classdef Intersection<driving.internal.scenarioApp.road.Specification
    properties
        Width=6
        StartPoint=[159,24,0;110,80,0];
        EndPoint=[50,24,0;110,-30,0];
        Lanes=lanespec.empty;
        laneSpecification=[];
        Centers;
    end
    properties(Hidden)
RoadCenters
BankAngle
LeftRoadWidth
RightRoadWidth
IsOpenDRIVE
Junction
    end
    methods
        function this=Intersection(varargin)
            this@driving.internal.scenarioApp.road.Specification(varargin{:});
            this.LeftRoadWidth=[];
            this.RightRoadWidth=[];
            this.IsOpenDRIVE=[];
            this.Junction=[];
            this.Name='Road';
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                this.Centers=this.Centers.*[1,-1,-1];
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
            marking=[laneMarking('Solid','Color',[0.98,0.86,0.36])
            laneMarking('Solid')
            laneMarking('Dashed')
            laneMarking('DoubleDashed','Color',[0.98,0.86,0.36])
            laneMarking('DoubleDashed','Color',[0.98,0.86,0.36])
            laneMarking('Dashed')
            laneMarking('Solid')
            laneMarking('Solid')];
            this.Lanes=lanespec(7,'Width',[0.5,3,3,1,3,3,0.5],'Marking',marking);
            [startPointSize,~]=size(this.StartPoint);
            for i=1:startPointSize
                startloc=this.StartPoint(i,:);
                endloc=this.EndPoint(i,:);
                roadCenters=[startloc;endloc;];
                this.RoadCenters=roadCenters;
                this.Centers=roadCenters;
                road(scenario,roadCenters,this.Width,'Lanes',this.Lanes);
            end
        end
        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.road.IntersectionPropertySheet';
        end
        function str=generateMatlabCode(this,scenarioName)
            str="roadCenters = ";
            [startPointSize,~]=size(this.StartPoint);
            for i=1:startPointSize
                if(i~=1)
                    str=str+newline;
                    str=str+"roadCenters = ";
                end
                startloc=this.StartPoint(i,:);
                endloc=this.EndPoint(i,:);
                if isequal(startloc(1,:),endloc(end,:))
                    precision={};
                else
                    first=startloc(1,:);
                    last=endloc(end,:);
                    for precision=4:20
                        if~isequal(mat2str(first,precision),mat2str(last,precision))
                            break;
                        end
                    end
                    precision={precision};
                end
                this.Centers=[startloc;endloc];
                str=str+strrep(mat2str(this.Centers,precision{:}),';',[';',newline,repmat(' ',1,strlength(str)+1)])+';';
                trailingArgs="";
                width=this.Width;
                if(width~=6)&&isempty(this.laneSpecification)
                    str=str+newline+"roadWidth = "+mat2str(width)+';';
                    trailingArgs=trailingArgs+', roadWidth';
                end
                bank=this.BankAngle;
                if any(bank~=0)
                    str=str+newline+'bankAngle = '+mat2str(bank)+';';
                    trailingArgs=trailingArgs+', bankAngle';
                end

                if~isempty(this.Lanes)

                    str=str+driving.internal.scenarioApp.road.lanespecToString(this.Lanes);
                    trailingArgs=trailingArgs+', ''Lanes'', laneSpecification';
                end
                str=str+sprintf('\nroad(%s, roadCenters%s);',scenarioName,trailingArgs);
            end
        end

        function set.Width(this,width)
            this.Width=width;
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
            p=line(hAxes,'XData',roadCenters([1,2],1),'YData',roadCenters([1,2],2),'Marker','o','LineStyle','none',...
            'MarkerFaceColor','w');
        end
        function pvPairs=getPvPairsForAddPoints(this,addPoints)
            roadLength=(this.StartPoint+this.EndPoint);
            centerPoint=roadLength/2;
            loc=centerPoint-addPoints;
            this.StartPoint=this.StartPoint-loc;
            this.EndPoint=this.EndPoint-loc;
            pvPairs={'StartPoint',this.StartPoint,'EndPoint',this.EndPoint};
        end
        function pvPairs=getPvPairsForDrag(this,offset)
            pvPairs={'StartPoint',this.StartPoint+offset,'EndPoint',this.EndPoint+offset};
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
    end
end