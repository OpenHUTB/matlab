function addModel(writer,name,position,time,modelURL,varargin)

    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'modelURL');
    addParameter(p,'Description','');
    addParameter(p,'Orientation',[]);
    addParameter(p,'Scale',1);
    addParameter(p,'MinimumPixelSize',0);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'ID','');
    addParameter(p,'InitiallyVisible',true);
    parse(p,name,position,time,modelURL,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    modelURL=inputs.modelURL;
    description=inputs.Description;
    orientation=inputs.Orientation;
    scale=inputs.Scale;
    minimumPixelSize=inputs.MinimumPixelSize;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    id=inputs.ID;
    initiallyVisible=inputs.InitiallyVisible;
    if(isempty(id))
        id=name;
    end


    sizeOfPosition=size(position);


    sizeOfOrientation=size(orientation);



    if~isempty(orientation)&&isequal(sizeOfOrientation,[1,4])
        orientationStruct=struct("unitQuaternion",orientation);
    end

    if~isempty(time)


        if strcmp(interpolation,'NONE')
            positionStruct(1:sizeOfPosition(1)-1)=...
            struct("interval","","referenceFrame",referenceFrame,...
            coordinateDefinition,[]);

            if sizeOfOrientation(1)>1
                orientationStruct(1:sizeOfOrientation(1)-1)=...
                struct("interval","","unitQuaternion",[]);
            end

            for idx=1:sizeOfPosition(1)-1

                startInterval=string(datetime(time(idx),'Format',...
                writer.DateTimeFormat));
                endInterval=string(datetime(time(idx+1),'Format',...
                writer.DateTimeFormat));
                intervalString=startInterval+"/"+endInterval;
                positionStruct(idx).interval=intervalString;



                if strcmp(coordinateDefinition,'cartesian')
                    positionStruct(idx).cartesian=position(idx,:);
                else
                    positionStruct(idx).cartographicDegrees=...
                    position(idx,:);
                end

                if sizeOfOrientation(1)>1
                    orientationStruct(idx).interval=intervalString;
                    orientationStruct(idx).unitQuaternion=orientation(idx,:);
                end
            end
        else
            epochTime=string(datetime(time(1),...
            'Format',writer.DateTimeFormat));
            timeDelta=seconds(time-time(1));

            positionCoordinates=...
            zeros(1,(sizeOfPosition(2)+1)*sizeOfPosition(1));

            if sizeOfOrientation(1)>1


                unitQuaternion=zeros(1,(sizeOfOrientation(2)+1)*...
                sizeOfOrientation(1));
            end

            for idx=1:sizeOfPosition(1)
                idx1=((idx-1)*(sizeOfPosition(2)+1))+1;
                idx2=idx1+sizeOfPosition(2);
                positionCoordinates(idx1:idx2)=[timeDelta(idx),...
                position(idx,1),position(idx,2),position(idx,3)];

                if sizeOfOrientation(1)>1
                    idx1=((idx-1)*(sizeOfOrientation(2)+1))+1;
                    idx2=idx1+sizeOfOrientation(2);
                    unitQuaternion(idx1:idx2)=[timeDelta(idx),...
                    orientation(idx,1),orientation(idx,2),...
                    orientation(idx,3),orientation(idx,4)];
                end
            end
            positionStruct=struct("epoch",epochTime,...
            "interpolationAlgorithm",interpolation,...
            "interpolationDegree",interpolationDegree,...
            "referenceFrame",referenceFrame,...
            coordinateDefinition,{positionCoordinates});

            if sizeOfOrientation(1)>1
                orientationStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "unitQuaternion",{unitQuaternion});
            end
        end
    else
        positionStruct=struct("referenceFrame",referenceFrame,...
        coordinateDefinition,position);
    end
    model=struct("gltf",modelURL,"scale",scale,...
    "minimumPixelSize",minimumPixelSize);


    if isempty(orientation)
        packetString=struct("id",id,"name",name,...
        "description",description,"position",positionStruct,...
        "model",model,"properties",struct("initiallyVisible",initiallyVisible));
    else
        packetString=struct("id",id,"name",name,...
        "description",description,"position",positionStruct,...
        "orientation",orientationStruct,"model",model,...
        "properties",struct("initiallyVisible",initiallyVisible));
    end


    type="model";
    addPacket(writer,id,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addModel','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','real','finite','ncols',3},...
    'addModel','position',2);



    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addModel','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addModel','time',3);
    end


    validateattributes(inputs.modelURL,...
    {'char','string'},{'nonempty','scalartext'},...
    'addModel','modelURL',4);


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addModel','Description');


    if~isempty(inputs.Orientation)
        validateattributes(inputs.Orientation,...
        {'numeric'},{'real','finite','ncols',4},...
        'addModel','Orientation');



        if size(inputs.Orientation,1)>1
            validateattributes(inputs.Orientation,...
            {'numeric'},{'nrows',size(inputs.position,1)},...
            'addModel','Orientation');
        end



        validateattributes(vecnorm(inputs.Orientation,2,2),...
        {'numeric'},{'<=',1+1e-3,'>=',1-1e-3},...
        'addModel','norm of Orientation quaternion');
    end


    validateattributes(inputs.Scale,...
    {'numeric'},{'nonempty','scalar','real','finite','positive'},...
    'addModel','Scale');


    validateattributes(inputs.MinimumPixelSize,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','nonnegative'},...
    'addModel','MinimumPixelSize');


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addModel','Interpolation');



    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addModel','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addModel','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addModel','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end