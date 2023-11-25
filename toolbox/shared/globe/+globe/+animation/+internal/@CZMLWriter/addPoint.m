function addPoint(writer,name,position,time,varargin)

    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addParameter(p,'Description','');
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'OutlineColor',[0,0,0,1]);
    addParameter(p,'OutlineWidth',4);
    addParameter(p,'PixelSize',20);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'ID','');
    addParameter(p,'InitiallyVisible',true);
    addParameter(p,'ShowTooltip',false);
    addParameter(p,'DisplayDistance',1e308);
    addParameter(p,'LinkedGraphic','');
    parse(p,name,position,time,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    description=inputs.Description;
    color=inputs.Color;
    outlineColor=inputs.OutlineColor;
    outlineWidth=inputs.OutlineWidth;
    pixelSize=inputs.PixelSize;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    id=inputs.ID;
    initiallyVisible=inputs.InitiallyVisible;
    showTooltip=inputs.ShowTooltip;
    displayDistance=inputs.DisplayDistance;
    linkedGraphic=inputs.LinkedGraphic;
    if(isempty(id))
        id=name;
    end


    sizeOfPosition=size(position);

    if~isempty(time)


        if strcmp(interpolation,'NONE')
            positionStruct(1:sizeOfPosition(1)-1)=...
            struct("interval","","referenceFrame",referenceFrame,...
            coordinateDefinition,[]);

            for idx=1:sizeOfPosition(1)-1

                startInterval=string(datetime(time(idx),...
                'Format',writer.DateTimeFormat));
                endInterval=string(datetime(time(idx+1),...
                'Format',writer.DateTimeFormat));
                intervalString=startInterval+"/"+endInterval;
                positionStruct(idx).interval=intervalString;



                if strcmp(coordinateDefinition,'cartesian')
                    positionStruct(idx).cartesian=position(idx,:);
                else
                    positionStruct(idx).cartographicDegrees=...
                    position(idx,:);
                end
            end
        else
            epochTime=string(datetime(time(1),...
            'Format',writer.DateTimeFormat));

            timeDelta=seconds(time-time(1));


            positionCoordinates=...
            zeros(1,(sizeOfPosition(2)+1)*sizeOfPosition(1));

            for idx=1:sizeOfPosition(1)
                idx1=((idx-1)*(sizeOfPosition(2)+1))+1;
                idx2=idx1+sizeOfPosition(2);
                positionCoordinates(idx1:idx2)=[timeDelta(idx),...
                position(idx,1),position(idx,2),position(idx,3)];
            end
            positionStruct=struct("epoch",epochTime,...
            "interpolationAlgorithm",interpolation,...
            "interpolationDegree",interpolationDegree,...
            "referenceFrame",referenceFrame,...
            coordinateDefinition,{positionCoordinates});
        end
    else
        positionStruct=struct("referenceFrame",referenceFrame,...
        coordinateDefinition,position);
    end

    colorStruct=struct("rgba",color);
    outlineColorStruct=struct("rgba",outlineColor);
    displayDistanceStruct=struct("distanceDisplayCondition",[0,displayDistance]);
    point=struct("color",colorStruct,...
    "outlineColor",outlineColorStruct,"outlineWidth",outlineWidth,...
    "pixelSize",pixelSize,"distanceDisplayCondition",displayDistanceStruct);
    packetString=struct("id",id,"name",name,...
    "description",description,"position",positionStruct,...
    "point",point,"properties",...
    struct("initiallyVisible",initiallyVisible,"showTooltip",showTooltip,"linkedGraphic",linkedGraphic));


    type="point";
    addPacket(writer,id,type,packetString);
end

function validatedInputs=validateInput(inputs)

    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addPoint','name',1);
    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','finite','real','ncols',3},...
    'addPoint','position',2);

    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addPoint','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addPoint','time',3);
    end


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addPoint','Description');


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','finite','real','size',[1,4],'>=',0,'<=',1},...
    'addPoint','Color');
    inputs.Color=inputs.Color*255;


    validateattributes(inputs.OutlineColor,...
    {'numeric'},...
    {'nonempty','finite','real','size',[1,4],'>=',0,'<=',1},...
    'addPoint','OutlineColor');
    inputs.OutlineColor=inputs.OutlineColor*255;

    validateattributes(inputs.OutlineWidth,...
    {'numeric'},{'nonempty','scalar','real','positive','finite'},...
    'addPoint','OutlineWidth');

    validateattributes(inputs.PixelSize,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive','>=',1},...
    'addPoint','PixelSize');


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addPoint','Interpolation');


    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end

    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addPoint','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addPoint','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addPoint','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end