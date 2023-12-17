function addLineWithIntervals(writer,name,positions,intervals,varargin)

    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'positions');
    addRequired(p,'time');
    addRequired(p,'intervals');
    addParameter(p,'Description','');
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'Width',1);
    addParameter(p,'FollowSurface',false);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'InitiallyVisible',true);
    addParameter(p,'Dashed',false);
    addParameter(p,'DashLength',16);
    parse(p,name,positions,intervals,varargin{:});

    inputs=validateInput(p.Results);

    name=inputs.name;
    positions=inputs.positions;
    time=inputs.time;
    intervals=inputs.intervals;
    description=inputs.Description;
    color=inputs.Color;
    width=inputs.Width;
    followSurface=inputs.FollowSurface;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    initiallyVisible=inputs.InitiallyVisible;
    dashed=inputs.Dashed;
    dashLength=inputs.DashLength;

    createPositionReference=false;

    sizeOfPositions=size(positions);

    if~isempty(time)
        positionName=name+"PositionReference"+(1:sizeOfPositions(1));
        references=positionName+"#position";

        createPositionReference=true;
        positionStruct=struct("references",references);
    else

        positionCoordinates=reshape(positions',1,...
        sizeOfPositions(1)*sizeOfPositions(2));

        positionStruct=struct("referenceFrame",referenceFrame,...
        coordinateDefinition,positionCoordinates);
    end

    startTime=writer.StartTime;
    stopTime=writer.EndTime;

    numIntervals=size(intervals,1);

    if numIntervals==0
        startInterval=string(datetime(startTime,'Format',...
        writer.DateTimeFormat));
        endInterval=string(datetime(stopTime,'Format',...
        writer.DateTimeFormat));
        intervalString=startInterval+"/"+endInterval;
        showStruct.interval=intervalString;
        showStruct.boolean=false;
    else

        numShowStruct=2*numIntervals-1;
        if startTime<intervals(1,1)
            numShowStruct=numShowStruct+1;
        end
        if stopTime>intervals(end,2)
            numShowStruct=numShowStruct+1;
        end
        showStruct(1:numShowStruct)=struct("interval",[],"boolean",[]);

        showStructIdx=1;

        if startTime<intervals(1,1)
            startInterval=string(datetime(startTime,'Format',...
            writer.DateTimeFormat));
            endInterval=string(datetime(intervals(1,1),'Format',...
            writer.DateTimeFormat));
            intervalString=startInterval+"/"+endInterval;
            showStruct(showStructIdx).interval=intervalString;
            showStruct(showStructIdx).boolean=false;

            showStructIdx=showStructIdx+1;
        end

        if stopTime>intervals(end,2)
            startInterval=string(datetime(intervals(end,2),'Format',...
            writer.DateTimeFormat));
            endInterval=string(datetime(stopTime,'Format',...
            writer.DateTimeFormat));
            intervalString=startInterval+"/"+endInterval;
            showStruct(end).interval=intervalString;
            showStruct(end).boolean=false;
        end

        for idx=1:size(intervals,1)
            indx=showStructIdx+(2*(idx-1));
            startInterval=string(datetime(intervals(idx,1),'Format',...
            writer.DateTimeFormat));
            endInterval=string(datetime(intervals(idx,2),'Format',...
            writer.DateTimeFormat));
            intervalString=startInterval+"/"+endInterval;
            showStruct(indx).interval=intervalString;
            showStruct(indx).boolean=true;


            if idx~=size(intervals,1)
                indx=indx+1;
                startInterval=string(datetime(intervals(idx,2),...
                'Format',writer.DateTimeFormat));
                endInterval=string(datetime(intervals(idx+1,1),...
                'Format',writer.DateTimeFormat));
                intervalString=startInterval+"/"+endInterval;
                showStruct(indx).interval=intervalString;
                showStruct(indx).boolean=false;
            end
        end
    end
    colorStruct=struct("rgba",round(color));
    if dashed
        dashStruct=struct("color",colorStruct,"dashLength",dashLength);
        polylineMaterial=struct("polylineDash",dashStruct);
    else
        solidColor=struct("color",colorStruct);
        polylineMaterial=struct("solidColor",solidColor);
    end

    polyline=struct("show",showStruct,"positions",positionStruct,...
    "material",polylineMaterial,"width",width,...
    "followSurface",followSurface);
    packetString=struct("id",name,"name",name,...
    "description",description,"polyline",polyline,...
    "properties",struct("initiallyVisible",initiallyVisible));


    type="lineWithIntervals";
    addPacket(writer,name,type,packetString);
    packetIdx=findPacket(writer,name);

    if createPositionReference
        try
            for idx=1:sizeOfPositions(1)

                addPositionReference(writer,positionName(idx),...
                reshape(positions(idx,:,:),3,size(positions,3))',...
                time,interpolation,interpolationDegree,...
                referenceFrame,coordinateDefinition);


                writer.Packets(packetIdx).ReferencePackets{idx}=...
                positionName(idx);

                writer.NumGraphics=writer.NumGraphics-1;
            end
        catch
            for idx2=idx-1:1
                removePacket(writer,...
                writer.Packets(packetIdx).ReferencePackets{idx2});
            end
            removePacket(writer,name);
            writer.NumGraphics=writer.NumGraphics-1;
            error(message('shared_globe:viewer:UnableToAddCZMLGraphic'));
        end
    end
end


function validatedInputs=validateInput(inputs)

    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addLineWithIntervals','name',1);
    validateattributes(inputs.positions,...
    {'numeric'},...
    {'nonempty','finite','real','size',[NaN,3,NaN]},...
    'addPolyline','positions',2);

    validateattributes(size(inputs.positions,1),...
    {'numeric'},{'scalar','>=',2},...
    'addPolyline','size of first dimension of positions');


    if isempty(inputs.time)||numel(inputs.time)==1
        validateattributes(inputs.positions,...
        {'numeric'},{'ndims',2},'addPolyline','positions',2);
    else
        validateattributes(inputs.positions,...
        {'numeric'},{'ndims',3},'addPolyline','positions',2);
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.positions,3)},...
        'addPolyline','time',3);
    end


    validateattributes(inputs.intervals,...
    {'datetime'},...
    {'nonempty','size',[NaN,2],'finite'},...
    'addLineWithIntervals','intervals',3);


    for idx=1:size(inputs.intervals,1)
        currentIntervalStart=inputs.intervals(idx,1);
        currentIntervalEnd=inputs.intervals(idx,2);
        if currentIntervalStart>currentIntervalEnd
            error('c');
        end
        if idx>1&&currentIntervalStart<inputs.intervals(idx-1,2)
            error('c');
        end
    end


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},...
    'addLineWithIntervals','Description');


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','finite','real','size',[1,4],'>=',0,'<=',1},...
    'addPolyline','Color');
    inputs.Color=inputs.Color*255;


    validateattributes(inputs.Width,...
    {'numeric'},{'nonempty','scalar','finite','real','positive'},...
    'addPolyline','Width');


    validateattributes(inputs.FollowSurface,{'logical'},...
    {'nonempty','scalar'},'addPolyline','FollowSurface');


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addPolyline','Interpolation');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addPolyline','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addPolyline','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        latitudes=inputs.positions(:,1,:);
        inputs.positions(:,1,:)=inputs.positions(:,2,:);
        inputs.positions(:,2,:)=latitudes;
    end


    validatedInputs=inputs;
end


