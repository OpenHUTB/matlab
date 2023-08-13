classdef RoadGroupArbitrary<driving.internal.scenarioApp.road.Specification

    properties
Roads
    end

    methods

        function this=RoadGroupArbitrary(roads,varargin)

            this@driving.internal.scenarioApp.road.Specification(varargin{:});
            if nargin>0
                this.Roads=roads;
            end
        end

        function Centers=plotEditPoints(this,hAxes,varargin)
            Centers=driving.scenario.internal.plotRoadCenters(deriveCenters(this),...
            hAxes,varargin{:});
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                for ind=1:numel(this.Roads)
                    road=this.Roads{1,ind};
                    road.Centers=road.Centers.*[1,-1,-1];
                    lanes=road.Lanes;
                    if~isempty(lanes)
                        lanes.Marking=fliplr(lanes.Marking);
                        lanes.Type=fliplr(lanes.Type);
                        road.Lanes=fliplr(lanes);
                    end
                    this.Roads{1,ind}=road;
                end
            end
        end

        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.road.RoadGroupPropertySheet';
        end

        function set.Roads(this,roads)
            this.Roads=roads;
            clearScenario(this);
        end

        function applyToScenario(this,scenario)

            rg=driving.scenario.RoadGroup('Name',this.Name);
            for ind=1:numel(this.Roads)
                r=this.Roads{1,ind};
                if isfield(r,'Heading')
                    road(rg,r.Centers,r.BankAngle,'Lanes',r.Lanes,'Heading',r.Heading);
                else
                    road(rg,r.Centers,r.BankAngle,'Lanes',r.Lanes);
                end
            end
            roadGroup(scenario,rg);
        end

        function str=generateMatlabCode(this,scenarioName)




            str="rg = driving.scenario.RoadGroup('Name', '"+this.Name+"');";
            groupVariableName='rg';
            for ind=1:numel(this.Roads)
                str=str+newline+"Centers = ";
                str=str+strrep(mat2str(this.Roads{1,ind}.Centers),';',[';',newline])+';';

                trailingArgs="";




                width=this.Roads{1,ind}.Width;
                bank=this.Roads{1,ind}.BankAngle;
                if(width~=6||any(bank~=0))&&isempty(this.Roads{1,ind}.Lanes)
                    str=str+newline+"roadWidth = "+mat2str(width)+';';
                    trailingArgs=trailingArgs+', roadWidth';
                end

                if any(bank~=0)
                    str=str+newline+'bankAngle = '+mat2str(bank)+';';
                    trailingArgs=trailingArgs+', bankAngle';
                end


                if~isempty(this.Roads{1,ind}.Lanes)


                    str=str+newline+driving.internal.scenarioApp.road.lanespecToString(this.Roads{1,ind}.Lanes);

                    trailingArgs=trailingArgs+', ''Lanes'', laneSpecification';
                end


                if isfield(this.Roads{1,ind},'Heading')&&~isempty(this.Roads{1,ind}.Heading)&&any(~isnan(this.Roads{1,ind}.Heading))
                    str=str+newline+'headings = '+mat2str(this.Roads{1,ind}.Heading)+';';

                    trailingArgs=trailingArgs+', ''Heading'', headings';
                end


                roadName=this.Roads{1,ind}.Name;
                if~isempty(roadName)&&strlength(roadName)~=0

                    trailingArgs=trailingArgs+', ''Name'', '''+roadName+'''';
                end
                str=str+sprintf('\nroad(%s, Centers%s);',groupVariableName,trailingArgs)+newline;
            end
            str=str+sprintf('\nroadGroup(%s, %s);',scenarioName,groupVariableName);
        end

        function pvPairs=getPvPairsForDrag(this,offset)
            if numel(offset)==2
                offset(3)=[];
            end
            roads=this.Roads;
            for ind=1:numel(roads)
                roads{1,ind}.Centers=this.Roads{1,ind}.Centers+offset;
            end
            pvPairs={'Roads',roads};
        end

        function pvPairs=getPvPairsForDoubleClick(this,~)
            pvPairs={'Roads',this.Roads};
        end

        function pvPairs=getPvPairsForPaste(this,location)
            if nargin>1
                roads=this.Roads;
                centers=roads{1,1}.Centers;
                for ind=2:numel(roads)
                    centers=cat(1,centers,roads{1,ind}.Centers);
                end
                centers=unique(centers,'rows');
                midpoint=mean(centers,1);
                offset=midpoint-location;
                for ind=1:numel(roads)
                    roads{1,ind}.Centers=this.Roads{1,ind}.Centers-offset;
                end
                pvPairs={'Roads',roads};
            else
                pvPairs=getPvPairsForDrag(this,-[this.Roads{1,1}.Width,this.Roads{1,1}.Width,0]);
            end
        end

        function centers=deriveCenters(this)
            centers=[];
            roads=this.Roads;
            for ind=1:numel(this.Roads)
                centers=[centers;roads{1,ind}.Centers(1,:);...
                roads{1,ind}.Centers(end,:)];%#ok<AGROW>
            end


            centers=round(centers,8);

            centers=unique(centers,'rows');

            centers=sortrows(centers,1);
        end

        function id=getEditPointId(this,point,varargin)

            id=this.getMatchingPointIndex(point,deriveCenters(this),varargin{:});
        end
    end

    methods(Hidden)
        function b=shouldEnableAddRoadCenter(~)
            b=false;
        end
    end

    methods(Static)
        function junctionSpecs=fromScenario(scenario)


            roadGroups=scenario.RoadGroupHistory;
            name=getString(message('driving:scenarioApp:DefaultRoadGroupName'));
            junctionSpecs=driving.internal.scenarioApp.road.Specification.empty;
            for index=1:numel(roadGroups)
                roadGroup=roadGroups{index};
                roads=roadGroup{2};
                roadGroupName=roadGroup{3};
                if isempty(roadGroupName)||(roadGroupName=="")
                    roadGroupName=getRoadGroupName(name,index);
                end
                inputs={roads,'Name',roadGroupName};
                junctionSpecs(index)=driving.internal.scenarioApp.road.RoadGroupArbitrary(inputs{:});
            end
        end
    end

end


function name=getRoadGroupName(name,index)

    if index>1
        name=sprintf('%s%d',name,index-1);
    end

end


