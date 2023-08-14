


function[tf,datum]=validateShapeData(datum,type)

    if isstruct(datum)
        tf=isempty(datum)&&isfield(datum,'Position');
        for i=1:numel(datum)
            datum_i=datum(i);
            if isfield(datum_i,'Position')
                roiVal=datum_i.Position;
                tf=isValidShapeValue(roiVal,type);
                datum(i).Position=convertToFloat(roiVal);
            else
                tf=false;
            end
        end
    else
        tf=isValidShapeValue(datum,type);
        datum=convertToFloat(datum);
    end

    function floatData=convertToFloat(data)
        if iscell(data)
            nonFloatValues=~(cellfun(@isfloat,data));
            data(nonFloatValues)=cellfun(@single,data(nonFloatValues),...
            'UniformOutput',false);
        else
            if~isfloat(data)
                data=single(data);
            end
        end
        floatData=data;
    end
end


function tf=isValidShapeValue(shapeVal,type)

    switch type
    case labelType.Rectangle
        tf=isValidBboxValue(shapeVal);
    case{labelType.Line,labelType.Polygon}
        tf=isValidLineValue(shapeVal);
    case labelType.ProjectedCuboid
        tf=isValidProjCuboidValue(shapeVal);
    case labelType.Cuboid
        tf=isVaildCubiodValue(shapeVal);
    otherwise
        tf=false;
    end

end


function tf=isValidBboxValue(roiVal)
    tf=isempty(roiVal)||...
    size(roiVal,2)==4;


    if~isempty(roiVal)
        tf=tf&&~any(any(roiVal(:,3:4)<0));
    end
end


function tf=isValidLineValue(lineVal)



    if isempty(lineVal)
        tf=true;
    elseif iscell(lineVal)
        tf=isvector(lineVal)&&...
        all(cellfun(@(x)size(x,2)==2,lineVal));

    elseif ismatrix(lineVal)&&((size(lineVal,2)==2))
        tf=true;
    else
        tf=false;
    end
    tf=tf||isValidLine3DValue(lineVal);
end


function tf=isValidProjCuboidValue(projCuboidValue)
    tf=isempty(projCuboidValue)||...
    size(projCuboidValue,2)==8;


    if~isempty(projCuboidValue)
        tf=tf&&~any(any(projCuboidValue(:,[3,4,7,8])<0));
    end
end


function tf=isVaildCubiodValue(cuboidValue)
    tf=isempty(cuboidValue)||...
    size(cuboidValue,2)==9;


    if~isempty(cuboidValue)
        tf=tf&&~any(any(cuboidValue(:,4:6)<0));
    end
end


function tf=isValidLine3DValue(lineVal)



    if iscell(lineVal)
        tf=isvector(lineVal)&&...
        all(cellfun(@(x)size(x,2)==3,lineVal));
    elseif ismatrix(lineVal)&&(size(lineVal,2)==3)
        tf=true;
    else
        tf=false;
    end
end
