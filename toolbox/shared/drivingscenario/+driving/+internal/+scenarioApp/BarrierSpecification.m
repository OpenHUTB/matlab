classdef BarrierSpecification<driving.internal.scenarioApp.Specification

    properties
        BarrierID=0;
        ClassID=0;
        SegmentID=[];
        BarrierCenters=[];
        RoadEdgeOffset=0;
        Road=[];
        RoadEdge='';
        BankAngle=0;
        BarrierType;

        BarrierSegments=[];
        Mesh=[];
        Width=0.5;
        Height=0.75;
        SegmentLength=5;
        SegmentGap=0;
        RCSPattern=[10,10;10,10];
        RCSAzimuthAngles=[-180,180];
        RCSElevationAngles=[-90,90];
        PlotColor=[];
        AssetType;

        Scenario
    end


    properties(Hidden)
        BarrierCentersChanged=false
        OriginalBarrierCenters=[]
    end


    methods

        function this=BarrierSpecification(reqInput,varargin)
            this@driving.internal.scenarioApp.Specification(varargin{:});
            if nargin>0
                if isa(reqInput,'double')
                    this.BarrierCenters=reqInput;
                elseif isa(reqInput,'driving.scenario.Road')
                    this.Road=reqInput;
                end
            end
        end


        function initializePropertiesFromClassSpecification(this,classSpec)
            barrierProps={'BarrierType','Width','Height','Mesh','PlotColor',...
                'RCSPattern','RCSAzimuthAngles','RCSElevationAngles'};
            for i=1:numel(barrierProps)
                this.(barrierProps{i})=classSpec.(barrierProps{i});
            end
            this.Name=classSpec.name;
            this.ClassID=classSpec.id;
        end


        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                centers=this.BarrierCenters.*[1,-1,-1];
                centers(centers==0)=0;
                this.BarrierCenters=centers;

                pos=this.Position.*[1,-1,-1];

                pos(pos==0)=0;
                this.Position=pos;
            end
        end


        function barrierCenters=plotEditPoints(this,hAxes,varargin)

            barrierCenters=driving.scenario.internal.plotRoadCenters(this.BarrierCenters,hAxes,varargin{:});
        end


        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.barrierProperties';
        end


        function resetRoadData(this)
            if this.BarrierCentersChanged
                this.Road=[];
                this.RoadEdge='';
                this.OriginalBarrierCenters=[];
            end
        end


        function schema=getBarrierContextMenuSchema(this,location)
            schema=struct(...
                'tag','AddBarrierCenter',...
                'label',getString(message('driving:scenarioApp:AddBarrierCenterLabel')),...
                'callback',@addBarrierCenterCallback,...
                'enable',canAddBarrierCenter(this,location));
        end


        function set.BarrierCenters(this,centers)
            if size(centers,2)==2
                centers=[centers,zeros(size(centers,1),1)];
            end
            this.BarrierCenters=centers;

            resetRoadData(this);
        end


        function set.SegmentLength(this,segmentLength)
            this.SegmentLength=segmentLength;
        end


        function set.BankAngle(this,angle)
            this.BankAngle=angle;
        end


        function applyToScenario(this,scenario,varargin)
            pvPairs=[toPvPairs(this),varargin];
            if~isempty(this.Road)&&~this.BarrierCentersChanged
                if~isempty(this.RoadEdgeOffset)&&~isempty(this.OriginalBarrierCenters)
                    this.BarrierCenters=this.OriginalBarrierCenters;
                end
                barrier(scenario,this.Road,...
                    'RoadEdge',this.RoadEdge,'RoadEdgeOffset',this.RoadEdgeOffset,...
                    'BarrierCenters',this.BarrierCenters,pvPairs{:});
                this.BarrierCenters=scenario.Barriers(end).BarrierCenters;
            else
                barrier(scenario,this.BarrierCenters,this.BankAngle,pvPairs{:});
                this.BarrierCentersChanged=false;
            end
            this.Scenario=scenario;
            this.BarrierID=scenario.Barriers(end).BarrierID;
            this.BarrierSegments=scenario.Barriers(end).BarrierSegments;
            this.SegmentID=scenario.Barriers(end).SegmentID;
        end


        function pvPairs=toPvPairs(this)
            pvPairs={
                'ClassID',this.ClassID,...
                'Name',this.Name,...
                'SegmentLength',this.SegmentLength,...
                'SegmentGap',this.SegmentGap,...
                'Width',this.Width,...
                'Height',this.Height,...
                'RCSPattern',this.RCSPattern,...
                'RCSAzimuthAngles',this.RCSAzimuthAngles,...
                'RCSElevationAngles',this.RCSElevationAngles};

            color=this.PlotColor;
            if~isempty(color)
                pvPairs=[pvPairs,...
                    {'PlotColor',color}];
            end

            mesh=this.Mesh;
            if~isempty(mesh)
                pvPairs=[pvPairs,...
                    {'Mesh',mesh}];
            end
        end


        function b=shouldEnableAddBarrierCenter(~)
            b=true;
        end


        function str=generateMatlabCode(this,scenarioName)
            str="";
            if~isempty(this.Road)
                requiredArgs="road"+num2str(this.Road.RoadID)+", 'RoadEdge', '"+string(this.RoadEdge)+"'";
                roadEdgeOffset=this.RoadEdgeOffset;
                if roadEdgeOffset~=0
                    requiredArgs=requiredArgs+", 'RoadEdgeOffset', "+num2str(roadEdgeOffset)+"'";
                end
            else
                str="barrierCenters = ";
                requiredArgs="barrierCenters";
                centers=this.BarrierCenters;
                if isequal(centers(1,:),centers(end,:))
                    precision={};
                else
                    first=centers(1,:);
                    last=centers(end,:);
                    for precision=ceil(max(max(log10(abs(centers)))))+(3:20)
                        if~isequal(mat2str(first,precision),mat2str(last,precision))
                            break;
                        end
                    end
                    precision={precision};
                end
                str=str+strrep(mat2str(this.BarrierCenters,precision{:}),';',[';',newline,repmat(' ',1,strlength(str)+1)])+';';

                bank=this.BankAngle;
                if any(bank~=0)
                    str=str+newline+"bankAngle = "+mat2str(bank)+";";
                    requiredArgs=requiredArgs+", bankAngle";
                end
                str=str+newline;
            end

            pvPairs="";
            props={'ClassID','SegmentLength','SegmentGap','Width','Height',...
                'RCSPattern','RCSAzimuthAngles','RCSElevationAngles'};
            for indx=1:numel(props)
                propName=props{indx};
                propHandle=findprop(this,props{indx});
                value=this.(propName);
                if~isequal(value,propHandle.DefaultValue)
                    pvPairs=pvPairs+sprintf(", ...\n    '%s', %s",propName,mat2str(value));
                end
            end

            mesh=this.Mesh;
            if~isempty(mesh)
                meshStr="";
                switch this.BarrierType
                    case 'Jersey Barrier'
                        meshStr="driving.scenario.jerseyBarrierMesh";
                    case 'Guardrail'
                        meshStr="driving.scenario.guardrailMesh";
                end
                pvPairs=pvPairs+sprintf(", ...\n    'Mesh', %s",meshStr);
            end

            color=this.PlotColor;
            if~isempty(color)
                intColor=color*255;
                if abs(round(intColor)-intColor)<0.01
                    colorStr=[mat2str(round(intColor)),' / 255'];
                else
                    colorStr=mat2str(color);
                end
                pvPairs=pvPairs+sprintf(", 'PlotColor', %s",colorStr);
            end

            if~isempty(this.Name)
                pvPairs=pvPairs+', ''Name'', '''+this.Name+'''';
            end
            str=str+sprintf('barrier(%s, %s%s);',scenarioName,requiredArgs,pvPairs);
        end


        function numPoints=getNumAddPoints(~)
            numPoints=[2,inf];
        end


        function addPoints=getStartingAddPoints(this)
            addPoints=this.BarrierCenters;
        end


        function pvPairs=getPvPairsForAddPoints(this,addPoints)
            pvPairs={'BarrierCenters',addPoints};
            bankAngle=this.BankAngle;

            if numel(bankAngle)>1
                numOfNewBarrierCenters=size(addPoints,1)-size(this.BarrierCenters,1);
                if numOfNewBarrierCenters~=0
                    bankAngle=[bankAngle,repmat(bankAngle(end),1,numOfNewBarrierCenters)];
                end
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end
        end


        function pvPairs=getPvPairsForAddRoad(~,road,roadEdge)
            pvPairs={'Road',road,...
                'RoadEdge',roadEdge};
        end


        function pvPairs=getPvPairsForDrag(this,offset)
            if numel(offset)==2
                offset(3)=[];
            end
            pvPairs={'BarrierCenters',this.BarrierCenters+offset};
        end


        function pvPairs=getPvPairsForDoubleClick(this,location)
            [centers,pointIndex]=this.insertIntoClothoid(this.BarrierCenters,location);
            me=this.validateCenters(centers,this.Width);
            if~isempty(me)
                throw(me);
            end

            pvPairs={'BarrierCenters',centers};
            if numel(this.BankAngle)>1
                bankAngle=this.calculateBankAngleVector(this.BankAngle,pointIndex);
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end
        end


        function pvPairs=getPvPairsForPaste(this,location)
            if nargin>1
                centers=this.BarrierCenters;

                if all(centers(1,:)==centers(end,:))
                    midpoint=mean(centers(1:end-1,:),1);
                else
                    midpoint=mean(centers,1);
                end
                offset=midpoint-location;
                pvPairs={'BarrierCenters',centers-offset};
            else
                pvPairs=getPvPairsForDrag(this,-[this.Width,this.Width,0]);
            end
        end


        function schema=getEditPointContextMenuSchema(this,id)
            centers=this.BarrierCenters;

            if all(centers(1,:)==centers(end,:))
                centers(end,:)=[];
            end

            centers(all(diff(centers)==[0,0,0],2),:)=[];

            schema=struct(...
                'tag','DeleteBarrierCenter',...
                'label',getString(message('driving:scenarioApp:DeleteBarrierCenterLabel')),...
                'callback',@deleteBarrierCenterCallback,...
                'enable',size(centers,1)>2&&canRemoveBarrierCenter(this,id));

        end


        function id=getEditPointId(this,point,varargin)
            id=this.getMatchingPointIndex(point,this.BarrierCenters,varargin{:});
        end


        function pvPairs=getPvPairsCacheForEditPointDrag(this,~)
            pvPairs={'BarrierCenters',this.BarrierCenters};
        end


        function pvPairs=getPvPairsForEditPointDrag(this,id,point,varargin)
            centers=this.BarrierCenters;

            point(3)=centers(id(1),3);

            centers(id,:)=repmat(point,numel(id),1);

            numCenters=size(centers,1);
            if numel(id)==1&&(id==numCenters||id==1)
                isLooping=this.isWaypointLooping(centers,varargin{:});
                if isLooping
                    if numCenters==2
                        pvPairs={'BarrierCenters',centers};
                        return;
                    elseif id==1
                        centers(1,:)=centers(end,:);
                    else
                        centers(end,:)=centers(1,:);
                    end
                end
            end

            pvPairs={'BarrierCenters',centers};
        end


        function bbs=getBarrierBoundaries(this)
            if~isequal(this.Scenario.Barriers(this.BarrierID).BarrierCenters,this.BarrierCenters)
                pvPairs=toPvPairs(this);
                barrier(this.Scenario,this.BarrierCenters,this.BankAngle,pvPairs{:});
                segments=this.Scenario.Barriers(end).BarrierSegments;
            else
                segments=this.BarrierSegments;
            end
            rights=zeros(numel(segments)*2,3);
            lefts=zeros(numel(segments)*2,3);
            for i=1:numel(segments)
                origin=segments(i).Position;
                pt1=[-segments(i).Length/2,segments(i).Width/2,0];
                pt2=[-segments(i).Length/2,-segments(i).Width/2,0];
                pt3=[segments(i).Length/2,segments(i).Width/2,0];
                pt4=[segments(i).Length/2,-segments(i).Width/2,0];

                R=egoToScenarioRotator(segments(i));
                pt1=pt1*R+origin;
                pt2=pt2*R+origin;
                pt3=pt3*R+origin;
                pt4=pt4*R+origin;
                rgtIdx=[2*i-1,2*i];
                rights(rgtIdx,:)=[pt2;pt4];
                lftIdx=[size(lefts,1)-2*i+2,size(lefts,1)-2*i+1];
                lefts(lftIdx,:)=[pt1;pt3];
            end
            bbs={[rights;lefts;rights(1,:)]};
        end


        function set.BarrierType(this,value)
            this.BarrierType=value;
            this=driving.internal.scenarioApp.BarrierSpecification.setDefaultBarrierProperties(this);
        end
    end


    methods(Access=protected)
        function clearScenario(this)
            this.Scenario=[];
        end
    end


    methods(Hidden)
        function b=canAddBarrierCenter(this,location)
            [centers,pointIndex]=this.insertIntoClothoid(this.BarrierCenters,location);
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle=this.calculateBankAngleVector(bankAngle,pointIndex);
            end
            b=isempty(this.validateCenters(centers,this.Width,bankAngle));
        end


        function b=canRemoveBarrierCenter(this,id)
            centers=this.BarrierCenters;
            centers(id,:)=[];
            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle(id)=[];
            end
            b=isempty(this.validateCenters(centers,this.Width,bankAngle));
        end


        function addBarrierCenterCallback(this,canvas,location)
            pvPairs=getPvPairsForDoubleClick(this,location);

            canvas.ShouldDirty=true;
            applyBarrierPvPairs(canvas,pvPairs);
        end


        function deleteBarrierCenterCallback(this,canvas,id)
            centers=this.BarrierCenters;
            centers(id,:)=[];
            pvPairs={'BarrierCenters',centers};

            bankAngle=this.BankAngle;
            if numel(bankAngle)>1
                bankAngle(id)=[];
                pvPairs=[pvPairs,{'BankAngle',bankAngle}];
            end

            canvas.ShouldDirty=true;
            applyBarrierPvPairs(canvas,pvPairs);
        end


        function[id,str]=validateSegmentLength(this,value)
            id='';
            str='';
            barrier=this.Scenario.Barriers(this.BarrierID);
            barrierLength=sum([barrier.BarrierSegments(:).Length]);
            if numel(value)~=1||isnan(value)||value>100||value<=0
                id='driving:scenarioApp:BadLengthBarrier';
                str=getString(message(id));
            elseif value>barrierLength
                id='driving:scenario:SegmentLengthGreaterThanBarrierLength';
                str=getString(message(id));
            end
        end


        function[id,str]=validateSegmentGap(this,value)
            id='';
            str='';
            barrier=this.Scenario.Barriers(this.BarrierID);
            if numel(value)~=1||isnan(value)||value>100||value<=0
                id='driving:scenarioApp:BadLengthBarrier';
                str=getString(message(id));
            elseif value>barrier.BarrierSegments(1).Length
                id='driving:scenario:SegmentGapGreaterThanSegmentLength';
                str=getString(message(id));
            end
        end


        function[id,str]=validateHeight(~,value)
            id='';
            str='';
            if numel(value)~=1||isnan(value)||value>20||value<=0
                id='driving:scenarioApp:BadHeightBarrier';
                str=getString(message(id));
            end
        end


        function[id,str]=validateRoadEdgeOffset(~,value)
            id='';
            str='';
            if any(isnan(value))||~any(isnumeric(value))
                id='driving:scenarioApp:BadRoadEdgeOffset';
                str=getString(message(id));
            end
        end


        function[id,str]=validateWidth(obj,value,interactiveMode,canvas)
            id='';
            str='';
            if nargin<3
                interactiveMode=false;
                canvas=[];
            end
            if numel(value)~=1||isnan(value)||value>20||value<=0
                id='driving:scenarioApp:BadWidthBarrier';
                str=getString(message(id));
            else
                if interactiveMode
                    obj.BarrierCenters=canvas.Waypoints;
                    obj.BankAngle=canvas.CurrentBarrier.BankAngle;
                end
                if isempty(obj.BarrierCenters)
                    me=[];
                else
                    me=driving.internal.scenarioApp.BarrierSpecification.validateCenters(obj.BarrierCenters,value,obj.BankAngle);
                end
                if~isempty(me)
                    id=me.identifier;
                    str=me.message;
                    return
                end
            end
        end
    end


    methods(Static)

        function classIDMap=getClassAndID(classSpecs)
            classIDMap=containers.Map('KeyType','double','ValueType','char');
            ids=cell2mat(keys(classSpecs));
            for i=ids
                spec=classSpecs(i);
                if isfield(spec,'BarrierType')
                    if~strcmp(spec.BarrierType,'None')
                        classIDMap(i)=spec.name;
                    end
                elseif isfield(spec,'AssetType')
                    if strcmp(spec.AssetType,'Barrier')
                        classIDMap(i)='Jersey Barrier';
                    end
                elseif strcmp(spec.name,'Barrier')
                    classIDMap(i)='Jersey Barrier';
                end
            end
        end


        function types=getBarrierTypes()
            types={'JerseyBarrier','Guardrail'};
        end


        function obj=setDefaultBarrierProperties(obj)
            if isprop(obj,'BarrierType')||isfield(obj,'BarrierType')
                switch obj.BarrierType
                    case 'Jersey Barrier'
                        [obj.Width,obj.Height]=driving.scenario.BarrierSegment.getJerseyBarrierDimensions;
                        obj.Mesh=driving.scenario.jerseyBarrierMesh;
                        obj.AssetType='Barrier';
                    case 'Guardrail'
                        [obj.Width,obj.Height]=driving.scenario.BarrierSegment.getGuardrailDimensions;
                        obj.Mesh=driving.scenario.guardrailMesh;
                        obj.AssetType='Cuboid';
                end
            end
        end


        function barrierSpecs=fromScenario(scenario,classMap)
            barriers=scenario.Barriers;
            barrierSpecs=driving.internal.scenarioApp.BarrierSpecification.empty(numel(barriers),0);
            if isempty(barriers)
                return;
            end
            barrierProps={'BarrierID','Name','RoadEdge','SegmentID',...
                'SegmentGap','BankAngle','RoadEdgeOffset'};
            segmentProps={'ClassID','SegmentLength','Width','Height','Mesh','PlotColor',...
                'RCSPattern','RCSAzimuthAngles','RCSElevationAngles'};
            classIDMap=driving.internal.scenarioApp.BarrierSpecification.getClassAndID(classMap);
            validIds=cell2mat(keys(classIDMap));
            allErrors={};
            allWarnings={};
            countMap=containers.Map('KeyType','double','ValueType','double');
            barrierTypeString='';
            format='%s%d (%s), ';
            for indx=1:numel(validIds)
                id=validIds(indx);
                countMap(id)=0;
                name=classIDMap(id);
                barrierTypeString=sprintf(format,barrierTypeString,id,name);
            end
            if~isempty(barrierTypeString)
                barrierTypeString(end-1:end)=[];
            end
            for indx=1:numel(barriers)
                barrier=barriers(indx);
                classID=barrier.BarrierSegments(1).ClassID;
                if any(classID==validIds)
                    countMap(classID)=countMap(classID)+1;
                    name=classIDMap(classID);
                    if countMap(classID)>1
                        name=[name,num2str(countMap(classID)-1)];
                    end
                    if~isa(barrier,'driving.scenario.Barrier')
                        err=getString(message('driving:scenarioApp:InvalidBarrierImportType',indx,'barrier',barrierTypeString));
                        allErrors{end+1}=err;%#ok<*AGROW>
                    end
                else
                    allErrors{end+1}=getString(message('driving:scenarioApp:InvalidBarrierImportID',indx,classID));
                    name="";
                end

                numProp=numel(barrierProps)+numel(segmentProps);
                pvPairs=cell(1,numProp*2);
                pvPairs(1:2:numel(barrierProps)*2-1)=barrierProps;
                pvPairs(numel(barrierProps)*2+1:2:numProp*2-1)=segmentProps;
                for jndx=1:numel(barrierProps)
                    pvPairs{jndx*2}=barrier.(barrierProps{jndx});
                end

                for jndx=1:numel(segmentProps)
                    segment=barrier.BarrierSegments(1);
                    pvIdx=numel(barrierProps)*2+jndx*2;
                    if strcmp(segmentProps{jndx},'SegmentLength')
                        pvPairs{pvIdx}=segment.('Length');
                    else
                        pvPairs{pvIdx}=segment.(segmentProps{jndx});
                    end
                end
                if~strcmp(barrier.Name,"")
                    name=barrier.Name;
                end
                pvPairs=[pvPairs,{'Name',name}];

                classID=barrier.BarrierSegments(1).ClassID;

                switch classID
                    case 5
                        barrierType='Jersey Barrier';
                    case 6
                        barrierType='Guardrail';
                end
                pvPairs=[pvPairs,{'BarrierType',barrierType}];
                if isempty(barrier.Road)
                    barrierSpecs(indx)=driving.internal.scenarioApp.BarrierSpecification(barrier.BarrierCenters,pvPairs{:});
                else
                    barrierSpecs(indx)=driving.internal.scenarioApp.BarrierSpecification(barrier.Road,pvPairs{:});
                end
                if~isempty(allErrors)
                    errorStr=sprintf('%s\n',allErrors{:});
                    errorStr(end)=[];
                    error('driving:scenarioApp:InvalidImport',errorStr);
                end
                if~isempty(allWarnings)
                    warnStr=sprintf('%s\n',getString(message('driving:scenarioApp:InconsistentImportHeader')),allWarnings{:});
                    warnStr(end)=[];
                    warning('driving:scenarioApp:InconsistentImport',warnStr);
                end
            end
        end


        function barrierSpec=convertActorToBarrier(actorSpec)
            barrierSpec=driving.internal.scenarioApp.BarrierSpecification;

            commonFields={'Name','ClassID','PlotColor','Width','Height',...
                'RCSPattern','RCSElevationAngles','RCSAzimuthAngles'};
            for i=1:numel(commonFields)
                f=commonFields{i};
                barrierSpec.(f)=actorSpec.(f);
            end

            barrierSpec.BankAngle=actorSpec.Roll;

            switch actorSpec.ClassID
                case 5
                    barrierSpec.BarrierType='Jersey Barrier';
                    barrierSpec.AssetType='Barrier';
                    barrierSpec.Mesh=driving.scenario.jerseyBarrierMesh;
                    if isempty(barrierSpec.PlotColor)
                        barrierSpec.PlotColor=[0.65,0.65,0.65];
                    end
                case 6
                    barrierSpec.BarrierType='Guardrail';
                    barrierSpec.AssetType='Cuboid';
                    barrierSpec.Mesh=driving.scenario.guardrailMesh;
                    if isempty(barrierSpec.PlotColor)
                        barrierSpec.PlotColor=[0.55,0.55,0.55];
                    end
            end

            actorOrigin=actorSpec.Position;
            pt1=[-actorSpec.Length/2,0,0];
            pt2=[actorSpec.Length/2,0,0];
            R=driving.scenario.internal.rotZ(actorSpec.Yaw)...
                *driving.scenario.internal.rotY(actorSpec.Pitch)...
                *driving.scenario.internal.rotX(actorSpec.Roll);
            pt1=pt1*R'+actorOrigin;
            pt2=pt2*R'+actorOrigin;
            barrierSpec.BarrierCenters=[pt1;pt2];
        end


        function me=validateCenters(centers,width,varargin)
            me=[];

            if size(centers,1)<3
                return;
            end
            if nargin<2
                width=0.5;
            end

            try
                barrier(drivingScenario,centers,varargin{:});
            catch me
                if~strncmp(me.identifier,'driving:',8)&&~strncmp(me.identifier,'MATLAB:road',11)
                    id='driving:scenarioApp:InvalidBarrierCenters';
                    me=MException(id,getString(message(id)));
                end
            end

            dist=sqrt(sum(diff(centers,1,1).^2,2));

            if all(dist>4*width)
                return;
            end

            [r0,r1]=getRadii(centers);
            if all(r0>width*2)&&all(r1>width*2)
                return;
            elseif any(r0<width/3)||any(r1<width/3)
                id='driving:scenario:BarrierCurvatureTooSharp';
                me=MException(id,getString(message(id)));
                return;
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


function[r0,r1]=getRadii(barrierCenters)

n=size(barrierCenters,1);

course=NaN(n,1);
course=matlabshared.tracking.internal.scenario.clothoidG2fitMissingCourse(barrierCenters,course);

hip=complex(barrierCenters(:,1),barrierCenters(:,2));

[k0,k1]=matlabshared.tracking.internal.scenario.clothoidG1fit2(hip(1:n-1),course(1:n-1),hip(2:n),course(2:n));

r0=abs(1./k0);
r1=abs(1./k1);

end


function name=getName(name,index)
if index>1
    name=sprintf('%s%d',name,index-1);
end
end


