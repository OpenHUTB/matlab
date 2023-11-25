function addPositionReference(writer,name,position,time,...
    interpolation,interpolationDegree,referenceFrame,...
    coordinateDefinition)

    sizeOfPosition=size(position);

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

    packetString=struct("id",name,"position",positionStruct);


    type="position reference";
    addPacket(writer,name,type,packetString);
end