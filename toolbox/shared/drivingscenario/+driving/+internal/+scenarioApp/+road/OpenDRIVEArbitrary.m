classdef OpenDRIVEArbitrary<driving.internal.scenarioApp.road.Specification

    properties
        Centers;
        Width=6;
        BankAngle=0;
        Lanes=[];
        LeftRoadWidth=[];
        RightRoadWidth=[];
        Junction=[];
        LaneOffset=[];
    end

    methods

        function this=OpenDRIVEArbitrary(centers,varargin)

            this@driving.internal.scenarioApp.road.Specification(varargin{:});
            if nargin>0
                this.Centers=centers;
            end
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                this.Centers=this.Centers.*[1,-1,-1];
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
            c='driving.internal.scenarioApp.road.OpenDRIVEArbitraryPropertySheet';
        end

        function set.Centers(this,centers)

            if size(centers,2)==2
                centers=[centers,zeros(size(centers,1),1)];
            end
            this.Centers=centers;
            clearScenario(this);
        end

        function set.Width(this,width)
            this.Width=width;
            clearScenario(this);
        end

        function set.BankAngle(this,angle)
            this.BankAngle=angle;
            clearScenario(this);
        end

        function applyToScenario(this,scenario)

            openDrivePvPairs={'LeftRoadWidth',this.LeftRoadWidth,...
            'RightRoadWidth',this.RightRoadWidth,...
            'Junction',this.Junction,'LaneOffset',this.LaneOffset};
            if~isempty(this.Lanes)
                driving.scenario.internal.OpenDRIVEroad(scenario,this.Centers,this.BankAngle,'Lanes',this.Lanes,openDrivePvPairs{:});


                this.Width=scenario.RoadSegments(end).RoadWidth;
            else
                driving.scenario.internal.OpenDRIVEroad(scenario,this.Centers,this.Width,this.BankAngle,openDrivePvPairs{:});
            end
        end

        function str=generateMatlabCode(this,scenarioName)




            str="roadCenters = ";
            centers=this.Centers;
            if isequal(centers(1,:),centers(end,:))
                precision={};
            else





                first=centers(1,:);
                last=centers(end,:);
                for precision=4:20
                    if~isequal(mat2str(first,precision),mat2str(last,precision))
                        break;
                    end
                end
                precision={precision};
            end
            str=str+strrep(mat2str(this.Centers,precision{:}),';',[';',newline,repmat(' ',1,strlength(str)+1)])+';';

            trailingArgs="";




            width=this.Width;
            if(width~=6)&&isempty(this.Lanes)
                str=str+newline+"roadWidth = "+mat2str(width)+';';

                trailingArgs=trailingArgs+', roadWidth';
            end


            bank=this.BankAngle;
            if any(bank~=0)
                str=str+newline+'bankAngle = '+mat2str(bank)+';';
                trailingArgs=trailingArgs+', bankAngle';
            end


            if~isempty(this.Lanes)


                str=addLanesString(this,str);

                trailingArgs=trailingArgs+', ''Lanes'', laneSpecification';
            end
            str=str+sprintf('\nroad(%s, roadCenters%s);',scenarioName,trailingArgs);
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


            if numel(bankAngle)>1
                numOfNewRoadCenters=size(addPoints,1)-size(this.Centers,1);
                if numOfNewRoadCenters~=0
                    bankAngle=[bankAngle,repmat(bankAngle(end),1,numOfNewRoadCenters)];
                end
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end
        end

        function pvPairs=getPvPairsForDrag(this,offset)
            if numel(offset)==2
                offset(3)=[];
            end
            pvPairs={'Centers',this.Centers+offset};
        end

        function pvPairs=getPvPairsForDoubleClick(this,location)
            enable=IsEnableLanes(this);
            if~strcmp(enable,'off')
                [centers,pointIndex]=this.insertIntoClothoid(this.Centers,location);
                me=this.validateCenters(centers,this.Width);
                if~isempty(me)
                    throw(me);
                end

                pvPairs={'Centers',centers};
                if numel(this.BankAngle)>1
                    bankAngle=this.calculateBankAngleVector(this.BankAngle,pointIndex);
                    pvPairs=[pvPairs,{'BankAngle',bankAngle}];
                end
            else
                pvPairs=[{'Centers',this.Centers},{'BankAngle',this.BankAngle}];
            end
        end

        function enable=IsEnableLanes(roadSpec)
            enable='on';
            ls=roadSpec.Lanes;
            if~isempty(ls)
                if numel(ls)>1||ls.IsAsymmetric
                    enable='off';
                else
                    isVariableMarkers=false;
                    for lmndx=1:numel(ls.Marking)
                        if numel(ls.Marking(lmndx).lm)>1
                            isVariableMarkers=true;
                            break;
                        end
                    end
                    if isVariableMarkers
                        enable='off';
                    end
                end
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
                pvPairs=getPvPairsForDrag(this,-[this.Width,this.Width,0]);
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
    end

    methods(Hidden)
        function b=canAddRoadCenter(this,location)

            [centers,pointIndex]=this.insertIntoClothoid(this.Centers,location);
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle=this.calculateBankAngleVector(bankAngle,pointIndex);
            end
            b=isempty(this.validateCenters(centers,this.Width,bankAngle));
        end

        function b=canRemoveRoadCenter(this,id)
            centers=this.Centers;
            centers(id,:)=[];
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle(id)=[];
            end
            b=isempty(this.validateCenters(centers,this.Width,bankAngle));
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

            canvas.ShouldDirty=true;
            applyRoadPvPairs(canvas,pvPairs);
        end

        function b=shouldEnableAddRoadCenter(~)
            b=true;
        end

    end

    methods(Access=private)
        function str=addLanesString(this,str)


            numLanes=this.Lanes.NumLanes;
            laneWidth=this.Lanes.Width;
            marking=this.Lanes.Marking;

            lanespecArgs="";

            if~all(laneWidth==lanespec.DefaultWidth)

                if all(laneWidth==laneWidth(1))
                    laneWidth=laneWidth(1);
                end
                lanespecArgs=lanespecArgs+', ''Width'', '+mat2str(laneWidth);
            end

            prototypeLanesObj=lanespec(numLanes);
            if~isequal(marking,prototypeLanesObj.Marking)

                isSameMarking=true;
                for kndx=2:length(marking)
                    if~isequal(marking(1),marking(kndx))
                        isSameMarking=false;
                        break;
                    end
                end
                if isSameMarking
                    marking=marking(1);
                end
                numMarkings=length(marking);



                markingString="";
                if numMarkings>1
                    markingString="[";
                end
                for kndx=1:numMarkings
                    if kndx>1
                        markingString=markingString+newline;
                    end

                    markingArgs="";
                    currentMarking=marking(kndx);

                    if isprop(currentMarking,'Color')&&~isequal(currentMarking.Color,[1,1,1])
                        markingArgs=markingArgs+', ''Color'', '+mat2str(currentMarking.Color);
                    end

                    if isprop(currentMarking,'Width')&&~isequal(currentMarking.Width,0.15)
                        markingArgs=markingArgs+', ''Width'', '+mat2str(currentMarking.Width);
                    end

                    if isprop(currentMarking,'Strength')&&~isequal(currentMarking.Strength,1)
                        markingArgs=markingArgs+', ''Strength'', '+mat2str(currentMarking.Strength);
                    end

                    if isprop(currentMarking,'Length')&&~isequal(currentMarking.Length,3)
                        markingArgs=markingArgs+', ''Length'', '+mat2str(currentMarking.Length);
                    end

                    if isprop(currentMarking,'Space')&&~isequal(currentMarking.Space,9)
                        markingArgs=markingArgs+', ''Space'', '+mat2str(currentMarking.Space);
                    end
                    markingString=markingString+sprintf('laneMarking(''%s''%s)',...
                    currentMarking.Type,markingArgs);
                end

                if numMarkings>1
                    markingString=markingString+"]";
                end

                str=str+newline+'marking = '+markingString+';';
                lanespecArgs=lanespecArgs+', ''Marking'', marking';
            end

            lanespecString=sprintf('lanespec(%s%s);',mat2str(numLanes),lanespecArgs);
            str=str+newline+'laneSpecification = '+lanespecString;
        end
    end

    methods(Static)
        function roadSpecs=fromScenario(scenario)



            roadSpecs=driving.internal.scenarioApp.road.OpenDRIVEArbitrary(...
            scenario.RoadCenters);
        end

        function me=validateCenters(centers,width,varargin)

            me=[];

            if size(centers,1)<3
                return;
            end
            if nargin<2
                width=6;
            end
            dist=sqrt(sum(diff(centers,1,1).^2,2));



            if all(dist>4*width)
                return;
            end


            [r0,r1]=getRadii(centers);

            if all(r0>width*2)&&all(r1>width*2)



                return;
            elseif any(r0<width/3)||any(r1<width/3)


                id='driving:scenario:CurvatureTooSharp';
                me=MException(id,getString(message(id)));
                return;
            end

            try
                road(drivingScenario,centers,width,varargin{:});
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

function[r0,r1]=getRadii(roadCenters)

    n=size(roadCenters,1);


    course=NaN(n,1);
    course=matlabshared.tracking.internal.scenario.clothoidG2fitMissingCourse(roadCenters,course);


    hip=complex(roadCenters(:,1),roadCenters(:,2));


    [k0,k1]=matlabshared.tracking.internal.scenario.clothoidG1fit2(hip(1:n-1),course(1:n-1),hip(2:n),course(2:n));

    r0=abs(1./k0);
    r1=abs(1./k1);

end


