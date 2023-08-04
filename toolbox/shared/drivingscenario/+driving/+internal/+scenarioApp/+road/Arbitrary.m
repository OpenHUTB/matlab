classdef Arbitrary<driving.internal.scenarioApp.road.Specification
    % 任意的道路继承自路的规范
    properties
        Centers;
        Width=driving.internal.scenarioApp.road.Specification.getDefaultWidth;
        BankAngle=0;
        Lanes=lanespec.empty;
        LeftRoadWidth=[];
        RightRoadWidth=[];
        IsOpenDRIVE=false;
        Junction=[];
        LaneOffset=[];
        Heading=[];
    end

    properties(Transient,Hidden)
        pHeading=[];
    end


    methods

        function this=Arbitrary(centers,varargin)

            this@driving.internal.scenarioApp.road.Specification(varargin{:});
            if nargin>0
                this.Centers=centers;
            end
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                centers=this.Centers.*[1,-1,-1];
                centers(centers==0)=0;
                this.Centers=centers;
                lanes=this.Lanes;
                if~isempty(lanes)
                    lanes.Marking=fliplr(lanes.Marking);
                    lanes.Type=fliplr(lanes.Type);
                    this.Lanes=fliplr(lanes);
                end
            end
        end


        function roadCenters=plotEditPoints(this,hAxes,varargin)
            roadCenters=driving.scenario.internal.plotRoadCenters(this.Centers,hAxes,varargin{:});
        end


        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.road.ArbitraryPropertySheet';
        end


        function set.Centers(this,centers)

            if size(centers,2)==2
                centers=[centers,zeros(size(centers,1),1)];
            end
            this.Centers=centers;
            clearScenario(this);
        end


        function set.Width(this,width)
            oldWidth=this.Width;
            this.Width=width;

            if numel(oldWidth)~=numel(width)||any(oldWidth~=width)
                clearScenario(this);
            end
        end


        function set.BankAngle(this,angle)
            this.BankAngle=angle;
            clearScenario(this);
        end


        function set.Lanes(this,lanes)
            oldLanes=this.Lanes;
            this.Lanes=lanes;
            if~isequal(oldLanes,lanes)
                clearScenario(this);
            end
        end


        function set.Heading(this,headings)
            this.Heading=headings;
            clearScenario(this);
        end


        function set.pHeading(this,pHeadings)
            this.pHeading=pHeadings;
            clearScenario(this);
        end


        function applyToScenario(this,scenario)

            openDrivePvPairs={'LeftRoadWidth',this.LeftRoadWidth,...
            'RightRoadWidth',this.RightRoadWidth,...
            'IsOpenDRIVE',this.IsOpenDRIVE,'Junction',this.Junction,'LaneOffset',this.LaneOffset};
            headingAnglePvPairs={'Heading',[]};
            if~isempty(this.Heading)&&any(~isnan(this.Heading))
                headingAnglePvPairs={'Heading',this.Heading};
            end
            if~isempty(this.Lanes)
                road(scenario,this.Centers,this.BankAngle,'Lanes',this.Lanes,headingAnglePvPairs{:},openDrivePvPairs{:});

                this.Width=scenario.RoadSegments(end).RoadWidth;
                if isa(this.Lanes,'compositeLaneSpec')
                    this.Lanes=scenario.RoadSegments(end).LaneSpecification;
                end
            else
                road(scenario,this.Centers,this.Width,this.BankAngle,headingAnglePvPairs{:},openDrivePvPairs{:});
            end

            pHeadingAngle=rad2deg(scenario.RoadSegments(end).course);
            if~isequal(this.Centers,scenario.RoadSegments(end).RoadCenters)
                if size(pHeadingAngle,1)~=size(this.Centers,1)
                    irepeated=find(all(this.Centers(1:end-1,:)==this.Centers(2:end,:),2));
                    for k=1:numel(irepeated)
                        repeatedIdx=irepeated(k);
                        pHeadingAngle=[pHeadingAngle(1:repeatedIdx-1,:);pHeadingAngle(repeatedIdx,:);pHeadingAngle(repeatedIdx:end,:)];
                    end
                end
            end
            this.pHeading=pHeadingAngle;
        end

        function str=generateMatlabCode(this,scenarioName,roadID)

            str="roadCenters = ";
            centers=this.Centers;
            if isequal(centers(1,:),centers(end,:))
                precision={};
            else
                first=centers(1,:);
                last=centers(end,:);
                for precision=14:30
                    if~isequal(mat2str(first,precision),mat2str(last,precision))
                        break;
                    end
                end
                precision={precision};
            end
            str=str+strrep(mat2str(centers,precision{:}),';',[';',newline,repmat(' ',1,strlength(str)+1)])+';';

            trailingArgs="";

            roadWidth=getFirstSegmentWidth(this);
            width=roadWidth;
            bank=this.BankAngle;
            heading=this.Heading;
            if(width~=6||any(bank~=0))&&isempty(this.Lanes)
                str=str+newline+"roadWidth = "+mat2str(width)+';';

                trailingArgs=trailingArgs+', roadWidth';
            end

            if any(bank~=0)
                str=str+newline+'bankAngle = '+mat2str(bank)+';';

                trailingArgs=trailingArgs+', bankAngle';
            end

            if~isempty(heading)&&any(~isnan(heading))
                str=str+newline+'headings = '+mat2str(heading)+';';

                trailingArgs=trailingArgs+', ''Heading'', headings';
            end

            if~isempty(this.Lanes)
                str=str+newline+driving.internal.scenarioApp.road.lanespecToString(this.Lanes);
                if isa(this.Lanes,'lanespec')

                    trailingArgs=trailingArgs+', ''Lanes'', laneSpecification';
                else
                    trailingArgs=trailingArgs+', ''Lanes'', compLaneSpecification';
                end
            end

            if~isempty(this.Name)

                trailingArgs=trailingArgs+', ''Name'', '''+getMatlabPrintName(this)+'''';
            end

            if nargin>2
                str=str+sprintf('\nroad%s = road(%s, roadCenters%s);',num2str(roadID),scenarioName,trailingArgs);
            else
                str=str+sprintf('\nroad(%s, roadCenters%s);',scenarioName,trailingArgs);
            end
        end

        function numPoints=getNumAddPoints(~)
            numPoints=[2,inf];
        end

        function addPoints=getStartingAddPoints(this)
            addPoints=this.Centers;
        end


        function pvPairs=getPvPairsForAddPoints(this,addPoints)
            pvPairs={'Centers',addPoints};
            bankAngle=this.BankAngle;
            headingAngle=this.Heading;
            pHeadingAngle=this.pHeading;

            if numel(bankAngle)>1
                numOfNewRoadCenters=size(addPoints,1)-size(this.Centers,1);
                if numOfNewRoadCenters~=0
                    bankAngle=[bankAngle,repmat(bankAngle(end),1,numOfNewRoadCenters)];
                end
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end

            if~isempty(headingAngle)
                numOfNewRoadCenters=size(addPoints,1)-size(this.Centers,1);
                if numOfNewRoadCenters~=0
                    headingAngle=[headingAngle;nan(numOfNewRoadCenters,1)];
                end
                pvPairs=[pvPairs,{'Heading',headingAngle}];
            end
            if~isempty(pHeadingAngle)
                numOfNewRoadCenters=size(addPoints,1)-size(this.Centers,1);
                if numOfNewRoadCenters~=0
                    pHeadingAngle=[pHeadingAngle;nan(numOfNewRoadCenters,1)];
                end
                pvPairs=[pvPairs,{'pHeading',pHeadingAngle}];
            end
        end


        function pvPairs=getPvPairsForDrag(this,offset)
            if numel(offset)==2
                offset(3)=[];
            end
            pvPairs={'Centers',this.Centers+offset};
        end


        function pvPairs=getPvPairsForDoubleClick(this,location)
            [centers,pointIndex]=this.insertIntoClothoid(this.Centers,location);
            roadWidth=getFirstSegmentWidth(this);

            pvPairs={'Centers',centers};
            bankAngle=this.BankAngle;
            if numel(this.BankAngle)>1
                bankAngle=this.calculateBankAngleVector(this.BankAngle,pointIndex);
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end

            if isempty(this.Heading)
                headingAngle=nan(size(centers,1),1);
            else
                headingAngle=[this.Heading(1:pointIndex);nan;this.Heading(pointIndex+1:end)];
            end
            pvPairs=[pvPairs,{'Heading',headingAngle}];

            if isempty(this.pHeading)
                pHeadingAngle=nan(size(centers,1),1);
            else
                pHeadingAngle=[this.pHeading(1:pointIndex);nan;this.pHeading(pointIndex+1:end)];
            end
            pvPairs=[pvPairs,{'pHeading',pHeadingAngle}];

            if isempty(headingAngle)||all(isnan(headingAngle))
                me=this.validateCenters(centers,roadWidth,bankAngle);
            else
                me=this.validateCenters(centers,roadWidth,bankAngle,headingAngle);
            end

            if~isempty(me)
                throw(me);
            end
        end


        function pvPairs=getPvPairsForPaste(this,location)
            if nargin>1
                centers=this.Centers;

                if all(centers(1,:)==centers(end,:))
                    midpoint=mean(centers(1:end-1,:),1);
                else
                    midpoint=mean(centers,1);
                end
                offset=midpoint-location;
                pvPairs={'Centers',centers-offset};
            else
                roadWidth=getFirstSegmentWidth(this);
                pvPairs=getPvPairsForDrag(this,-[roadWidth,roadWidth,0]);
            end
        end


        function schema=getRoadContextMenuSchema(this,location)
            schema=struct(...
            'tag','AddRoadCenter',...
            'label',getString(message('driving:scenarioApp:AddRoadCenterLabel')),...
            'callback',@addRoadCenterCallback,...
            'enable',canAddRoadCenter(this,location));
        end


        function schema=getEditPointContextMenuSchema(this,id)
            centers=this.Centers;

            if all(centers(1,:)==centers(end,:))
                centers(end,:)=[];
            end

            centers(all(diff(centers)==[0,0,0],2),:)=[];

            schema=struct(...
            'tag','DeleteRoadCenter',...
            'label',getString(message('driving:scenarioApp:DeleteRoadCenterLabel')),...
            'callback',@deleteRoadCenterCallback,...
            'enable',size(centers,1)>2&&canRemoveRoadCenter(this,id));

        end


        function id=getEditPointId(this,point,varargin)
            id=this.getMatchingPointIndex(point,this.Centers,varargin{:});
        end


        function pvPairs=getPvPairsCacheForEditPointDrag(this,~)
            pvPairs={'Centers',this.Centers};
        end


        function pvPairs=getPvPairsForEditPointDrag(this,id,point,varargin)
            centers=this.Centers;

            point(3)=centers(id(1),3);

            centers(id,:)=repmat(point,numel(id),1);

            numCenters=size(centers,1);
            if numel(id)==1&&(id==numCenters||id==1)
                isLooping=this.isWaypointLooping(centers,varargin{:});
                if isLooping
                    if numCenters==2
                        pvPairs={'Centers',centers};
                        return;
                    elseif id==1
                        centers(1,:)=centers(end,:);
                    else
                        centers(end,:)=centers(1,:);
                    end
                end
            end

            pvPairs={'Centers',centers};
        end


        function rWidth=getFirstSegmentWidth(this)
            rWidth=this.Width(1);
        end
    end
    

    methods(Hidden)
        function b=canAddRoadCenter(this,location)

            [centers,pointIndex]=this.insertIntoClothoid(this.Centers,location);
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle=this.calculateBankAngleVector(bankAngle,pointIndex);
            end
            roadWidth=getFirstSegmentWidth(this);
            if isempty(this.Heading)||all(isnan(this.Heading))
                b=isempty(this.validateCenters(centers,roadWidth,bankAngle));
            else
                headings=this.Heading;
                headings=[headings(1:pointIndex);nan;headings(pointIndex+1:end)];
                b=isempty(this.validateCenters(centers,roadWidth,bankAngle,headings));
            end

        end

        function b=canRemoveRoadCenter(this,id)
            centers=this.Centers;
            centers(id,:)=[];
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle(id)=[];
            end
            roadWidth=getFirstSegmentWidth(this);
            if isempty(this.Heading)||all(isnan(this.Heading))
                b=isempty(this.validateCenters(centers,roadWidth,bankAngle));
            else
                headings=this.Heading;
                headings(id,:)=[];
                b=isempty(this.validateCenters(centers,roadWidth,bankAngle,headings));
            end

        end

        function addRoadCenterCallback(this,canvas,location)

            pvPairs=getPvPairsForDoubleClick(this,location);

            canvas.ShouldDirty=true;
            applyRoadPvPairs(canvas,pvPairs);
        end

        function deleteRoadCenterCallback(this,canvas,id)

            centers=this.Centers;
            centers(id,:)=[];
            pvPairs={'Centers',centers};

            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle(id)=[];
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end

            headingAngle=this.Heading;
            if~isempty(headingAngle)
                headingAngle(id)=[];
                pvPairs=[pvPairs,{'Heading',headingAngle}];
            end

            pHeadingAngle=this.pHeading;
            if~isempty(pHeadingAngle)
                pHeadingAngle(id)=[];
                pvPairs=[pvPairs,{'pHeading',pHeadingAngle}];
            end


            canvas.ShouldDirty=true;
            applyRoadPvPairs(canvas,pvPairs);
        end

        function b=shouldEnableAddRoadCenter(~)
            b=true;
        end
    end

    methods(Static)
        function roadSpecs=fromScenario(scenario)



            roads=scenario.RoadHistory;
            roadSpecs=driving.internal.scenarioApp.road.Specification.empty;
            if isempty(roads)&&~isempty(scenario.RoadTiles)
                id='driving:scenarioApp:MissingRoadHistory';
                warning(id,getString(message(id)));
            end
            name=getString(message('driving:scenarioApp:DefaultRoadName'));
            for index=1:numel(roads)
                road=roads{index};
                numArgs=numel(road);
                type=road{1};
                inputs={road{2},'Width',road{3},...
                'BankAngle',road{4},...
                'Lanes',road{5}};
                roadHeading=[];
                if strcmp(type,'roadNetwork')





                    switch numArgs
                    case 9
                        laneOffset=road{9};
                        roadName="";
                    case 10
                        laneOffset=road{9};
                        roadName=road{10};
                    case 11
                        laneOffset=road{9};
                        roadName=road{10};
                        roadHeading=road{11};
                    otherwise
                        laneOffset=[];
                        roadName="";
                    end
                    inputs=[inputs,{
                    'LeftRoadWidth',road{6},...
                    'RightRoadWidth',road{7},...
                    'Junction',road{8},...
                    'IsOpenDRIVE',true,...
                    'LaneOffset',laneOffset}];%#ok<*AGROW>
                else
                    switch numArgs
                    case 6
                        roadName=road{6};
                    case 7
                        roadName=road{6};
                        roadHeading=road{7};
                    otherwise
                        roadName="";
                    end
                end
                if isempty(roadName)||(roadName=="")
                    roadName=getRoadName(name,index);
                end
                inputs=[inputs,{'Name',roadName}];
                if~isempty(roadHeading)
                    inputs=[inputs,{'Heading',roadHeading}];
                end
                roadSpecs(index)=driving.internal.scenarioApp.road.Arbitrary(inputs{:});
            end
        end

        function me=validateCenters(centers,width,varargin)
            me=[];

            if size(centers,1)<3
                return;
            end
            if nargin<2
                width=6;
            end
            if numel(width)>1
                width=width(1);
            end
            dist=sqrt(sum(diff(centers,1,1).^2,2));



            if all(dist>4*width)
                return;
            end


            if nargin<4
                [r0,r1]=getRadii(centers);
            else
                headings=varargin{2};
                [r0,r1]=getRadii(centers,headings);
            end

            if all(r0>width*2)&&all(r1>width*2)



                return;
            end

            try
                if nargin<4
                    road(drivingScenario,centers,width,varargin{:});
                else
                    bankAngles=varargin{1};
                    headings=varargin{2};
                    road(drivingScenario,centers,width,bankAngles,'Heading',headings);
                end
            catch me
                if~strncmp(me.identifier,'driving:',8)&&~strncmp(me.identifier,'MATLAB:road',11)
                    id='driving:scenarioApp:InvalidRoadCenters';
                    me=MException(id,getString(message(id)));
                end
            end
        end

        function[bankAngle]=calculateBankAngleVector(oldBankAngle,pointIndex)






            if pointIndex==numel(oldBankAngle)
                bankAngle=[oldBankAngle,oldBankAngle(end)];
            else
                bankAngle=[oldBankAngle(1:pointIndex),(oldBankAngle(pointIndex)+oldBankAngle(pointIndex+1))/2,oldBankAngle(pointIndex+1:end)];
            end
        end
    end
end

function[r0,r1]=getRadii(roadCenters,varargin)

    n=size(roadCenters,1);


    if nargin<2
        course=NaN(n,1);
    else
        course=varargin{1};
    end
    if any(~isnan(course))
        course=matlabshared.tracking.internal.scenario.clothoidG2fitMissingCourse(roadCenters,course);
    end


    hip=complex(roadCenters(:,1),roadCenters(:,2));


    [k0,k1]=matlabshared.tracking.internal.scenario.clothoidG1fit2(hip(1:n-1),course(1:n-1),hip(2:n),course(2:n));

    r0=abs(1./k0);
    r1=abs(1./k1);

end

function name=getRoadName(name,index)

    if index>1
        name=sprintf('%s%d',name,index-1);
    end

end


