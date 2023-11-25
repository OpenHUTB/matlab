function addBillboard(writer,name,position,time,imageURL,varargin)

    p=inputParser;
    addRequired(p,'name');
    addRequired(p,'position');
    addRequired(p,'time');
    addRequired(p,'imageURL');
    addParameter(p,'Description','');
    addParameter(p,'Width',36);
    addParameter(p,'Height',36);
    addParameter(p,'HorizontalOrigin','center');
    addParameter(p,'VerticalOrigin','bottom');
    addParameter(p,'Interpolation','linear');
    addParameter(p,'InterpolationDegree',1);
    addParameter(p,'ReferenceFrame','fixed');
    addParameter(p,'CoordinateDefinition','cartographic-degrees');
    parse(p,name,position,time,imageURL,varargin{:});


    inputs=validateInput(p.Results);


    name=inputs.name;
    position=inputs.position;
    time=inputs.time;
    imageURL=inputs.imageURL;
    description=inputs.Description;
    width=inputs.Width;
    height=inputs.Height;
    horizontalOrigin=inputs.HorizontalOrigin;
    verticalOrigin=inputs.VerticalOrigin;
    interpolation=inputs.Interpolation;
    interpolationDegree=inputs.InterpolationDegree;
    referenceFrame=inputs.ReferenceFrame;
    coordinateDefinition=inputs.CoordinateDefinition;


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


    billboard=struct("image",imageURL,"width",width,"height",height,...
    "horizontalOrigin",horizontalOrigin,...
    "verticalOrigin",verticalOrigin);
    packetString=struct("id",name,"name",name,...
    "description",description,"billboard",billboard,...
    "position",positionStruct);


    type="billboard";
    addPacket(writer,name,type,packetString);
end

function validatedInputs=validateInput(inputs)




    validateattributes(inputs.name,...
    {'char','string'},{'nonempty','scalartext'},...
    'addBillboard','name',1);


    validateattributes(inputs.position,...
    {'numeric'},{'nonempty','real','finite','ncols',3},...
    'addBillboard','position',2);



    if isempty(inputs.time)
        validateattributes(inputs.position,...
        {'numeric'},{'size',[1,3]},'addBillboard','position',2);
    else
        validateattributes(inputs.time,...
        {'datetime'},...
        {'finite','vector','numel',size(inputs.position,1)},...
        'addBillboard','time',3);
    end


    validateattributes(inputs.imageURL,...
    {'char','string'},{'nonempty','scalartext'},...
    'addBillboard','imageURL',4);


    validateattributes(inputs.Description,...
    {'char','string'},{'scalartext'},'addBillboard','Description');


    validateattributes(inputs.Width,...
    {'numeric'},...
    {'nonempty','scalar','real','positive','finite'},...
    'addBillboard','Width');


    validateattributes(inputs.Height,...
    {'numeric'},...
    {'nonempty','scalar','real','positive','finite'},...
    'addBillboard','Height');


    inputs.HorizontalOrigin=...
    validatestring(upper(inputs.HorizontalOrigin),...
    {'LEFT','CENTER','RIGHT'},'addBillboard','HorizontalOrigin');


    inputs.VerticalOrigin=...
    validatestring(upper(inputs.VerticalOrigin),...
    {'BOTTOM','CENTER','TOP'},'addBillboard','VerticalOrigin');


    inputs.Interpolation=...
    validatestring(upper(inputs.Interpolation),...
    {'NONE','LINEAR','LAGRANGE','HERMITE'},...
    'addBillboard','Interpolation');



    if size(inputs.position,1)==1
        inputs.Interpolation='LINEAR';
    end


    validateattributes(inputs.InterpolationDegree,...
    {'numeric'},...
    {'nonempty','scalar','finite','integer','positive'},...
    'addBillboard','InterpolationDegree');


    inputs.ReferenceFrame=...
    validatestring(upper(inputs.ReferenceFrame),...
    {'FIXED','INERTIAL'},'addBillboard','ReferenceFrame');


    inputs.CoordinateDefinition=...
    validatestring(lower(inputs.CoordinateDefinition),...
    {'cartographic-degrees','cartesian'},...
    'addBillboard','CoordinateDefinition');
    if strcmpi(inputs.CoordinateDefinition,'cartographic-degrees')
        inputs.CoordinateDefinition='cartographicDegrees';


        inputs.position=...
        [inputs.position(:,2),inputs.position(:,1),inputs.position(:,3)];
    end


    validatedInputs=inputs;
end