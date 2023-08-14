function[contourargs,boundaryargs]=parseAltitudeEnvelopeInputs(args)





    [args,minimumAltitude]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"MinimumAltitude");
    [args,maximumAltitude]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"MaximumAltitude");
    [args,minimumSpeed]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"MinimumSpeed");
    [args,maximumSpeed]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"MaximumSpeed");
    [args,boundaryXData]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"BoundaryXData");
    [args,boundaryYData]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"BoundaryYData");
    [args,clipContour]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"ClipContour");
    [args,resolveBoundary]=Aero.internal.namevalues.findAndTrimNameValuePair(args,"ResolveBoundary");


    contourargs=args;






    if~isempty(clipContour)
        boundaryargs.ClipContour=matlab.lang.OnOffSwitchState(clipContour);
    else
        boundaryargs.ClipContour=matlab.lang.OnOffSwitchState('on');
    end
    if~isempty(resolveBoundary)
        boundaryargs.ResolveBoundary=matlab.lang.OnOffSwitchState(resolveBoundary);
    else
        boundaryargs.ResolveBoundary=matlab.lang.OnOffSwitchState('on');
    end


    if xor(isempty(boundaryXData),isempty(boundaryYData))
        error(message("aero_graphics:altitudeEnvelope:BoundaryXandYDataMustExist"));
    elseif~isempty(boundaryXData)&&~isempty(boundaryYData)

        nameX="BoundaryXData";
        nameY="BoundaryYData";
        mustBeNumericVector(boundaryXData,nameX);
        mustBeNumericVector(boundaryYData,nameY);
        mustBeSameLength(boundaryXData,boundaryYData,nameX,nameY);


        boundary=[boundaryXData(:),boundaryYData(:)];

        if boundaryargs.ResolveBoundary
            boundaryargs.Boundary={boundary};
            boundaryargs.Groups=[];
        else
            boundaryargs.Boundary=boundary;
            boundaryargs.Groups=ones(size(boundary,1),1);
        end


        return
    end


    if~isempty(minimumAltitude)
        mustBeScalarOrNby2Matrix(minimumAltitude,"MinimumAltitude")
    end
    if~isempty(maximumAltitude)
        mustBeScalarOrNby2Matrix(maximumAltitude,"MaximumAltitude")
    end
    if~isempty(minimumSpeed)
        mustBeScalarOrNby2Matrix(minimumSpeed,"MinimumSpeed")
    end
    if~isempty(maximumSpeed)
        mustBeScalarOrNby2Matrix(maximumSpeed,"MaximumSpeed")
    end


    if boundaryargs.ResolveBoundary
        [boundaryargs.Boundary,boundaryargs.Groups]=...
        Aero.internal.math.constructEnclosedBoundingBoxFromParts(...
        minimumAltitude,maximumSpeed,maximumAltitude,minimumSpeed);
    else
        [boundaryargs.Boundary,boundaryargs.Groups]=...
        Aero.internal.math.constructPiecewiseBoundingBoxFromParts(...
        minimumAltitude,maximumSpeed,maximumAltitude,minimumSpeed);
    end
end


function mustBeNumericRealFinite(value,name)
    if~all(isnumeric(value)&isreal(value)&isfinite(value),"all")
        error(message("aero_graphics:altitudeEnvelope:mustBeNumericRealFinite",name))
    end
end

function mustBeNumericVector(value,name)
    mustBeNumericRealFinite(value,name)

    if(numel(value)<2)||~isvector(value)
        error(message("aero_graphics:altitudeEnvelope:mustBeVector",name))
    end
end

function mustBeSameLength(value1,value2,name1,name2)
    if numel(value1)~=numel(value2)
        error(message("aero_graphics:altitudeEnvelope:mustBeSameLength",name1,name2))
    end
end

function mustBeScalarOrNby2Matrix(value,name)
    mustBeNumericRealFinite(value,name)

    s=size(value);
    if~isscalar(value)&&~((s(2)==2)&&(numel(s)==2))
        error(message("aero_graphics:altitudeEnvelope:mustBeScalarOrNby2Matrix",name))
    end
end
