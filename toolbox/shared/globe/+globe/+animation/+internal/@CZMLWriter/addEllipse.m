function addEllipse(writer,name,position,time,semiMajorAxis,...
    semiMinorAxis,varargin)








    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'semiMajorAxis');
    addRequired(p,'semiMinorAxis');
    addParameter(p,'Description','');
    addParameter(p,'Height',0);
    addParameter(p,'HeightReference','none');
    addParameter(p,'ExtrudedHeight',0);
    addParameter(p,'ExtrudedHeightReference','none');
    addParameter(p,'Rotation',0);
    addParameter(p,'Color',[1,0,0,1]);
    addParameter(p,'Outline',false);
    addParameter(p,'OutlineColor',[0,0,0,1]);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    parse(p,name,position,time,semiMajorAxis,semiMinorAxis,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    semiMajorAxis=inputs.semiMajorAxis;
    semiMinorAxis=inputs.semiMinorAxis;
    description=inputs.Description;
    height=inputs.Height;
    heightReference=inputs.HeightReference;
    extrudedHeight=inputs.ExtrudedHeight;
    extrudedHeightReference=inputs.ExtrudedHeightReference;
    rotation=inputs.Rotation;
    color=inputs.Color;
    outline=inputs.Outline;
    outlineColor=inputs.OutlineColor;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;


    sizeOfPosition=size(position);


    if isscalar(semiMajorAxis)
        semiMajorAxisStruct=semiMajorAxis;
    end


    if isscalar(semiMinorAxis)
        semiMinorAxisStruct=semiMinorAxis;
    end


    if isscalar(height)
        heightStruct=height;
    end


    if isscalar(extrudedHeight)
        extrudedHeightStruct=extrudedHeight;
    end


    if isscalar(rotation)
        rotationStruct=rotation;
    end

    if~isempty(time)


        if strcmp(interpolation,'NONE')






            positionStruct(1:sizeOfPosition(1)-1)=...
            struct("interval","","referenceFrame",referenceFrame,...
            coordinateDefinition,[]);

            if length(semiMajorAxis)>1


                semiMajorAxisStruct(1:length(semiMajorAxis)-1)...
                =struct("interval","","number",[]);
            end

            if length(semiMinorAxis)>1


                semiMinorAxisStruct(1:length(semiMinorAxis)-1)...
                =struct("interval","","number",[]);
            end

            if length(height)>1


                heightStruct(1:length(height)-1)=...
                struct("interval","","number",[]);
            end

            if length(extrudedHeight)>1


                extrudedHeightStruct(1:length(height)-1)=...
                struct("interval","","number",[]);
            end

            if length(rotation)>1


                rotationStruct(1:length(rotation)-1)=...
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

                if length(semiMajorAxis)>1








                    semiMajorAxisStruct(idx).interval=intervalString;
                    semiMajorAxisStruct(idx).number=semiMajorAxis(idx);
                end

                if length(semiMinorAxis)>1








                    semiMinorAxisStruct(idx).interval=intervalString;
                    semiMinorAxisStruct(idx).number=semiMinorAxis(idx);
                end

                if length(height)>1







                    heightStruct(idx).interval=intervalString;
                    heightStruct(idx).number=height(idx);
                end

                if length(extrudedHeight)>1







                    extrudedHeightStruct(idx).interval=intervalString;
                    extrudedHeightStruct(idx).number=extrudedHeight(idx);
                end

                if length(rotation)>1







                    rotationStruct(idx).interval=intervalString;
                    rotationStruct(idx).number=rotation(idx);
                end
            end
        else




            epochTime=string(datetime(time(1),...
            'Format',writer.DateTimeFormat));



            timeDelta=seconds(time-time(1));


            positionCoordinates=...
            zeros(1,(sizeOfPosition(2)+1)*sizeOfPosition(1));

            if length(semiMajorAxis)>1




                semiMajorAxisCell=zeros(1,2*length(semiMajorAxis));
            end

            if length(semiMinorAxis)>1




                semiMinorAxisCell=zeros(1,2*length(semiMinorAxis));
            end

            if length(height)>1




                heightCell=zeros(1,2*length(height));
            end

            if length(extrudedHeight)>1




                extrudedHeightCell=zeros(1,2*length(extrudedHeight));
            end

            if length(rotation)>1




                rotationCell=zeros(1,2*length(rotation));
            end

            for idx=1:sizeOfPosition(1)








                idx1=((idx-1)*(sizeOfPosition(2)+1))+1;
                idx2=idx1+sizeOfPosition(2);
                positionCoordinates(idx1:idx2)=[timeDelta(idx),...
                position(idx,1),position(idx,2),position(idx,3)];

                if length(semiMajorAxis)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    semiMajorAxisCell(idx1:idx2)=[timeDelta(idx),...
                    semiMajorAxis(idx)];
                end

                if length(semiMinorAxis)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    semiMinorAxisCell(idx1:idx2)=[timeDelta(idx),...
                    semiMinorAxis(idx)];
                end

                if length(height)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    heightCell(idx1:idx2)=[timeDelta(idx),height(idx)];
                end

                if length(extrudedHeight)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    extrudedHeightCell(idx1:idx2)=...
                    [timeDelta(idx),extrudedHeight(idx)];
                end

                if length(rotation)>1









                    idx1=((idx-1)*2)+1;
                    idx2=idx1+1;
                    rotationCell(idx1:idx2)=[timeDelta(idx),rotation(idx)];
                end
            end



            positionStruct=struct("epoch",epochTime,...
            "interpolationAlgorithm",interpolation,...
            "interpolationDegree",interpolationDegree,...
            "referenceFrame",referenceFrame,...
            coordinateDefinition,{positionCoordinates});

            if length(semiMajorAxis)>1




                semiMajorAxisStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{semiMajorAxisCell});
            end

            if length(semiMinorAxis)>1




                semiMinorAxisStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{semiMinorAxisCell});
            end

            if length(height)>1



                heightStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{heightCell});
            end

            if length(extrudedHeight)>1




                extrudedHeightStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{extrudedHeightCell});
            end

            if length(rotation)>1



                rotationStruct=struct("epoch",epochTime,...
                "interpolationAlgorithm",interpolation,...
                "interpolationDegree",interpolationDegree,...
                "number",{rotationCell});
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
    ellipse=struct("semiMajorAxis",semiMajorAxisStruct,...
    "semiMinorAxis",semiMinorAxisStruct,...
    "height",heightStruct,...
    "heightReference",heightReference,...
    "extrudedHeight",extrudedHeightStruct,...
    "extrudedHeightReference",extrudedHeightReference,...
    "rotation",rotationStruct,...
    "material",material,...
    "outline",outline,...
    "outlineColor",outlineColorStruct);
    packetString=struct("id",name,"name",name,...
    "description",description,"position",positionStruct,...
    "ellipse",ellipse);


    type="ellipse";
    addPacket(writer,name,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addEllipse','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','real','finite','ncols',3},...
    'addEllipse','position',2);



    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addEllipse','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addEllipse','time',3);
    end



    validateattributes(inputs.semiMajorAxis,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addEllipse','semiMajorAxis');
    if numel(inputs.semiMajorAxis)>1
        validateattributes(inputs.semiMajorAxis,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addEllipse','semiMajorAxis',4);
    end



    validateattributes(inputs.semiMinorAxis,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addEllipse','semiMinorAxis');
    if numel(inputs.semiMinorAxis)>1
        validateattributes(inputs.semiMinorAxis,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addEllipse','semiMinorAxis',4);
    end


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addEllipse','Description');



    validateattributes(inputs.Height,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addEllipse','Height');
    if numel(inputs.Height)>1
        validateattributes(inputs.Height,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addEllipse','Height');
    end


    inputs.HeightReference=...
    validatestring(lower(inputs.HeightReference),...
    {'none','clamp-to-ground','relative-to-ground'},...
    'addEllipse','HeightReference');
    if strcmpi(inputs.HeightReference,'none')
        inputs.HeightReference='NONE';
    elseif strcmpi(inputs.HeightReference,'clamp-to-ground')
        inputs.HeightReference='CLAMP_TO_GROUND';
    else
        inputs.HeightReference='RELATIVE_TO_GROUND';
    end



    validateattributes(inputs.ExtrudedHeight,...
    {'numeric'},...
    {'nonempty','vector','real','nonnegative','finite'},...
    'addEllipse','ExtrudedHeight');
    if numel(inputs.ExtrudedHeight)>1
        validateattributes(inputs.ExtrudedHeight,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addEllipse','ExtrudedHeight');
    end


    inputs.ExtrudedHeightReference=...
    validatestring(lower(inputs.ExtrudedHeightReference),...
    {'none','clamp-to-ground','relative-to-ground'},...
    'addEllipse','ExtrudedHeightReference');
    if strcmpi(inputs.ExtrudedHeightReference,'none')
        inputs.ExtrudedHeightReference='NONE';
    elseif strcmpi(inputs.ExtrudedHeightReference,'clamp-to-ground')
        inputs.ExtrudedHeightReference='CLAMP_TO_GROUND';
    else
        inputs.ExtrudedHeightReference='RELATIVE_TO_GROUND';
    end



    validateattributes(inputs.Rotation,...
    {'numeric'},...
    {'nonempty','vector','real','finite'},'addEllipse','Rotation');
    if numel(inputs.Rotation)>1
        validateattributes(inputs.Rotation,...
        {'numeric'},{'numel',size(inputs.position,1)},...
        'addEllipse','Rotation');
    end


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,4],'>=',0,'<=',1},...
    'addEllipse','Color');
    inputs.Color=inputs.Color*255;


    validateattributes(inputs.Outline,{'logical'},{'scalar'},...
    'addEllipse','Outline');


    validateattributes(inputs.OutlineColor,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,4],'>=',0,'<=',1},...
    'addEllipse','OutlineColor');
    inputs.OutlineColor=inputs.OutlineColor*255;


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addEllipse','Interpolation');



    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addEllipse','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addEllipse','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addEllipse','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end