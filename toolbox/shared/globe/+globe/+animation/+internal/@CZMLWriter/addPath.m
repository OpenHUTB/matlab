function addPath(writer,name,position,time,leadTime,trailTime,...
    varargin)






    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'leadTime');
    addRequired(p,'trailTime');
    addParameter(p,'Description','');
    addParameter(p,'Width',1);
    addParameter(p,'Resolution',60);
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'ID','');
    addParameter(p,'InitiallyVisible',true);
    addParameter(p,'Dashed',false);
    parse(p,name,position,time,leadTime,trailTime,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    leadTime=inputs.leadTime;
    trailTime=inputs.trailTime;
    description=inputs.Description;
    width=inputs.Width;
    resolution=inputs.Resolution;
    color=inputs.Color;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    dashed=inputs.Dashed;
    id=inputs.ID;
    initiallyVisible=inputs.InitiallyVisible;
    if(isempty(id))
        id=name;
    end


    sizeOfPosition=size(position);



    positionCoordinates=zeros(1,(sizeOfPosition(2)+1)*sizeOfPosition(1));


    epochTime=string(datetime(time(1),'Format',writer.DateTimeFormat));



    timeDelta=seconds(time-time(1));

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


    colorStruct=struct("rgba",color);
    if dashed
        dashStruct=struct("color",colorStruct,"dashLength",16);
        materialStruct=struct("polylineDash",dashStruct);
    else
        solidColor=struct("color",colorStruct);
        materialStruct=struct("solidColor",solidColor);
    end
    path=struct("material",materialStruct,"width",width,...
    "leadTime",leadTime,"trailTime",trailTime,...
    "resolution",resolution);
    packetString=struct("id",id,"name",name,...
    "description",description,"position",positionStruct,"path",path,...
    "properties",struct("initiallyVisible",initiallyVisible));


    type="path";
    addPacket(writer,id,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addPath','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'ndims',2,'ncols',3,'finite','real'},...
    'addPath','position',2);


    validateattributes(size(inputs.position,1),{'numeric'},{'>=',2},...
    'addPath','number of rows in position');



    validateattributes(inputs.time,...
    {'datetime'},...
    {'finite','vector','numel',size(inputs.position,1)},...
    'addPath','time',3);


    validateattributes(inputs.leadTime,...
    {'numeric'},...
    {'nonempty','scalar','finite','real','nonnegative'},...
    'addPath','leadTime');


    validateattributes(inputs.trailTime,...
    {'numeric'},...
    {'nonempty','scalar','finite','real','nonnegative'},...
    'addPath','trailTime');


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addPath','Description');


    validateattributes(inputs.Width,...
    {'numeric'},{'nonempty','scalar','finite','real','positive'},...
    'addPath','Width');


    validateattributes(inputs.Resolution,...
    {'numeric'},{'nonempty','scalar','finite','real','positive'},...
    'addPath','Resolution');


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','finite','real','size',[1,4],'>=',0,'<=',1},...
    'addPath','Color');
    inputs.Color=inputs.Color*255;


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'LINEAR','LAGRANGE','HERMITE'},'addPath','Interpolation');


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addPath','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addPath','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addPath','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end