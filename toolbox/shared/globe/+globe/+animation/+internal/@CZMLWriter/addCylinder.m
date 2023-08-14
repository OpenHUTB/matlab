function addCylinder(writer,name,position,time,cylinderLength,...
    topRadius,bottomRadius,varargin)







    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'cylinderLength');
    addRequired(p,'topRadius');
    addRequired(p,'bottomRadius');
    addParameter(p,'Description','');
    addParameter(p,'Orientation',[]);
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'Outline',false);
    addParameter(p,'OutlineColor',[0,0,0,1]);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    parse(p,name,position,time,cylinderLength,topRadius,bottomRadius,...
    varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    cylinderLength=inputs.cylinderLength;
    topRadius=inputs.topRadius;
    bottomRadius=inputs.bottomRadius;
    description=inputs.Description;
    orientation=inputs.Orientation;
    color=inputs.Color;
    outline=inputs.Outline;
    outlineColor=inputs.OutlineColor;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;


    sizeOfPosition=size(position);


    sizeOfOrientation=size(orientation);


    if isscalar(cylinderLength)
        lengthStruct=cylinderLength;
    end


    if isscalar(topRadius)
        topRadiusStruct=topRadius;
    end


    if isscalar(bottomRadius)
        bottomRadiusStruct=bottomRadius;
    end



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

            if length(cylinderLength)>1


                lengthStruct(1:sizeOfPosition(1)-1)=...
                struct("interval","","number",[]);
            end

            if length(topRadius)>1


                topRadiusStruct(1:sizeOfPosition(1)-1)=...
                struct("interval","","number",[]);
            end

            if length(bottomRadius)>1


                bottomRadiusStruct(1:sizeOfPosition(1)-1)=...
                struct("interval","","number",[]);
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

                if length(cylinderLength)>1








                    lengthStruct(idx).interval=intervalString;
                    lengthStruct(idx).number=cylinderLength(idx);
                end

                if length(topRadius)>1







                    topRadiusStruct(idx).interval=intervalString;
                    topRadiusStruct(idx).number=topRadius(idx);
                end

                if length(bottomRadius)>1







                    bottomRadiusStruct(idx).interval=intervalString;
                    bottomRadiusStruct(idx).number=bottomRadius(idx);
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

            if length(cylinderLength)>1




                lengthCell=zeros(1,2*sizeOfPosition(1));
            end

            if length(topRadius)>1




                topRadiusCell=zeros(1,2*sizeOfPosition(1));
            end

            if length(bottomRadius)>1




                bottomRadiusCell=zeros(1,2*sizeOfPosition(1));
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

                if length(cylinderLength)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    lengthCell(idx1:idx2)=...
                    [timeDelta(idx),cylinderLength(idx)];
                end

                if length(topRadius)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    topRadiusCell(idx1:idx2)=...
                    [timeDelta(idx),topRadius(idx)];
                end

                if length(bottomRadius)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    bottomRadiusCell(idx1:idx2)=[timeDelta(idx),...
                    bottomRadius(idx)];
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

            if length(cylinderLength)>1




                lengthStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{lengthCell});
            end

            if length(topRadius)>1




                topRadiusStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{topRadiusCell});
            end

            if length(bottomRadius)>1




                bottomRadiusStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{bottomRadiusCell});
            end
        end
    else





        positionStruct=struct("referenceFrame",referenceFrame,...
        coordinateDefinition,position);
    end


    colorStruct=struct("rgba",color);
    solidColor=struct("color",colorStruct);
    material=struct("solidColor",solidColor);
    outlineColorStruct=struct("rgba",outlineColor);
    cylinder=struct("length",lengthStruct,"topRadius",topRadiusStruct,...
    "bottomRadius",bottomRadiusStruct,"material",material,...
    "outline",outline,"outlineColor",outlineColorStruct);



    if isempty(orientation)
        packetString=struct("id",name,"name",name,...
        "description",description,"position",positionStruct,...
        "cylinder",cylinder);
    else
        packetString=struct("id",name,"name",name,...
        "description",description,"position",positionStruct,...
        "orientation",orientationStruct,"cylinder",cylinder);
    end


    type="cylinder";
    addPacket(writer,name,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addCylinder','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','real','finite','ncols',3},...
    'addCylinder','position',2);



    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addCylinder','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addCylinder','time',3);
    end



    validateattributes(inputs.cylinderLength,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addCylinder','cylinderLength',4);
    if numel(inputs.cylinderLength)>1
        validateattributes(inputs.cylinderLength,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addCylinder','cylinderLength',4);
    end



    validateattributes(inputs.topRadius,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addCylinder','topRadius',5);
    if numel(inputs.topRadius)>1
        validateattributes(inputs.topRadius,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addCylinder','topRadius',5);
    end



    validateattributes(inputs.bottomRadius,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addCylinder','bottomRadius',6);
    if numel(inputs.bottomRadius)>1
        validateattributes(inputs.bottomRadius,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addCylinder','bottomRadius',6);
    end


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addCylinder','Description');


    if~isempty(inputs.Orientation)
        validateattributes(inputs.Orientation,...
        {'numeric'},{'real','finite','ncols',4},...
        'addCylinder','Orientation');



        if size(inputs.Orientation,1)>1
            validateattributes(inputs.Orientation,...
            {'numeric'},{'nrows',size(inputs.position,1)},...
            'addCylinder','Orientation');
        end



        validateattributes(vecnorm(inputs.Orientation,2,2),...
        {'numeric'},{'<=',1+1e-6,'>=',1-1e-6},...
        'addCylinder','norm of Orientation quaternion');
    end


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,4],'>=',0,'<=',1},...
    'addCylinder','Color');
    inputs.Color=inputs.Color*255;


    validateattributes(inputs.Outline,{'logical'},{'nonempty','scalar'},...
    'addCylinder','Outline');


    validateattributes(inputs.OutlineColor,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,4],'>=',0,'<=',1},...
    'addCylinder','OutlineColor');
    inputs.OutlineColor=inputs.OutlineColor*255;


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addCylinder','Interpolation');



    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addCylinder','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addCylinder','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addCylinder','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end