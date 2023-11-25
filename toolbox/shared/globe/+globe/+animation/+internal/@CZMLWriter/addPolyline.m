function addPolyline(writer,name,positions,time,varargin)

    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'positions');
    addRequired(p,'time');
    addParameter(p,'Description','');
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'Width',1);
    addParameter(p,'FollowSurface',false);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'ID','');
    addParameter(p,'InitiallyVisible',true);
    parse(p,name,positions,time,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    positions=inputs.positions;
    time=inputs.time;
    description=inputs.Description;
    color=inputs.Color;
    width=inputs.Width;
    followSurface=inputs.FollowSurface;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    id=inputs.ID;
    initiallyVisible=inputs.InitiallyVisible;
    if(isempty(id))
        id=name;
    end

    createPositionReference=false;

    sizeOfPositions=size(positions);

    if~isempty(time)

        references=strings(1,sizeOfPositions(1));

        positionName=strings(1,sizeOfPositions(1));

        for idx=1:sizeOfPositions(1)

            positionName(idx)=id+"PositionReference"+idx;

            references(idx)=positionName(idx)+"#position";

            createPositionReference=true;
        end
        positionStruct=struct("references",references);
    else
        positionCoordinates=reshape(positions',1,...
        sizeOfPositions(1)*sizeOfPositions(2));

        positionStruct=struct("referenceFrame",referenceFrame,...
        coordinateDefinition,positionCoordinates);
    end


    colorStruct=struct("rgba",color);
    solidColor=struct("color",colorStruct);
    polylineMaterial=struct("solidColor",solidColor);
    polyline=struct("positions",positionStruct,...
    "material",polylineMaterial,"width",width,...
    "followSurface",followSurface);
    packetString=struct("id",id,"name",name,...
    "description",description,"polyline",polyline,...
    "properties",struct("initiallyVisible",initiallyVisible));


    type="polyline";
    addPacket(writer,id,type,packetString);
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
    'addPolyline','name',1);
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
    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addPolyline','Description');


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

    if ismatrix(inputs.positions)
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addPolyline','InterpolationDegree');


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


