function addRectangle(writer,name,coordinates,time,imageURL,varargin)











    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'coordinates');
    addRequired(p,'time');
    addRequired(p,'imageURL');
    addParameter(p,'Description','');
    addParameter(p,'Height',0);
    addParameter(p,'Color',[1,1,1,1]);
    parse(p,name,coordinates,time,imageURL,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    coordinates=inputs.coordinates;
    time=inputs.time;
    description=inputs.Description;
    imageURL=inputs.imageURL;
    height=inputs.Height;
    color=inputs.Color;


    colorStruct=struct("rgba",color);


    lengthOfTimes=length(time);

    if~isempty(time)




        coordinateStruct(1:lengthOfTimes-1)=...
        struct("interval","","wsenDegrees",[]);
        imageStruct(1:lengthOfTimes-1)=struct("interval","","uri","");

        for idx=1:lengthOfTimes-1






            startInterval=string(datetime(time(idx),...
            'Format',writer.DateTimeFormat));
            endInterval=char(datetime(time(idx+1),...
            'Format',writer.DateTimeFormat));
            intervalString=startInterval+"/"+endInterval;
            imageStruct(idx).interval=intervalString;
            imageStruct(idx).uri=imageURL(idx);
            coordinateStruct(idx).interval=intervalString;
            coordinateStruct(idx).wsenDegrees=coordinates(idx,:);
        end
    else


        coordinateStruct=struct("wsenDegrees",coordinates);


        imageStruct=struct("uri",imageURL);
    end


    image=struct("image",imageStruct,"color",colorStruct);
    material=struct("image",image);
    rectangle=struct("coordinates",coordinateStruct,"height",height,...
    "fill",true,"material",material);
    packetString=struct("id",name,"name",name,...
    "description",description,"rectangle",rectangle);


    type="rectangle";
    addPacket(writer,name,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addRectangle','name',1);


    validateattributes(inputs.coordinates,...
    {'numeric'},{'nonempty','finite','real','ncols',4},...
    'addRectangle','coordinates',2);




    if isempty(inputs.time)
        validateattributes(inputs.coordinates,...
        {'numeric'},{'size',[1,4]},'addRectangle','coordinates',2);
    else
        validateattributes(size(inputs.coordinates,1),...
        {'numeric'},{'>=',2},...
        'addRectangle','number of rows in coordinates');
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.coordinates,1)},...
        'addRectangle','time',3);
    end


    validateattributes(inputs.imageURL,...
    {'string'},...
    {'nonempty','vector','numel',size(inputs.coordinates,1)},...
    'addRectangle','imageURL',4);


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addRectangle','Description');


    validateattributes(inputs.Height,...
    {'numeric'},...
    {'nonempty','scalar','finite','real','nonnegative'},...
    'addRectangle','Height');


    validateattributes(inputs.Color,...
    {'numeric'},...
    {'nonempty','finite','real','size',[1,4],'>=',0,'<=',1},...
    'addRectangle','Color');
    inputs.Color=inputs.Color*255;


    validatedInputs=inputs;
end