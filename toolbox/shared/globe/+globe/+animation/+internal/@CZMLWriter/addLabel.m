function addLabel(writer,name,position,time,labelText,varargin)







    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'labelText');
    addParameter(p,'Description','');
    addParameter(p,'FontSize',12);
    addParameter(p,'Scale',1);
    addParameter(p,'PixelOffset',[0,0]);
    addParameter(p,'Color',[1,1,1,1]);
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    addParameter(p,'ID','');
    addParameter(p,'ShowBackground',true);
    addParameter(p,'InitiallyVisible',true);
    parse(p,name,position,time,labelText,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    labelText=inputs.labelText;
    description=inputs.Description;
    fontSize=inputs.FontSize;
    scale=inputs.Scale;
    pixelOffset=inputs.PixelOffset;
    color=inputs.Color;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;
    showBackground=inputs.ShowBackground;
    id=inputs.ID;
    initiallyVisible=inputs.InitiallyVisible;
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


    fillColor=struct("rgba",color);
    pixelOffsetStruct=struct("cartesian2",pixelOffset);
    font=fontSize+"px "+"Arial";
    label=struct("fillColor",fillColor,...
    "font",font,"horizontalOrigin","LEFT",...
    "verticalOrigin","BOTTOM",...
    "text",labelText,"pixelOffset",pixelOffsetStruct,...
    "showBackground",showBackground,"backgroundColor",struct("rgba",[0,0,0,127.5]),...
    "backgroundPadding",struct("cartesian2",[5,5]),...
    "scale",scale);
    packetString=struct("id",id,"name",name,...
    "description",description,"label",label,...
    "position",positionStruct,"properties",struct("initiallyVisible",initiallyVisible));


    type="label";
    addPacket(writer,id,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addLabel','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','real','finite','ncols',3},...
    'addLabel','position',2);



    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addLabel','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addLabel','time',3);
    end


    validateattributes(inputs.labelText,...
    {'char','string'},{'nonempty','scalartext'},...
    'addLabel','labelText',4);


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addLabel','Description');


    validateattributes(inputs.FontSize,...
    {'numeric'},...
    {'nonempty','scalar','finite','real','positive'},...
    'addLabel','FontSize');


    validateattributes(inputs.PixelOffset,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,2]},...
    'addLabel','PixelOffset');


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','real','finite','size',[1,4],'>=',0,'<=',1},...
    'addLabel','Color');
    inputs.Color=inputs.Color*255;


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addLabel','Interpolation');



    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addLabel','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addLabel','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addLabel','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end