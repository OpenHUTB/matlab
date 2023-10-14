function detector = loadObjectDetector( matfile, nvps )

arguments
    matfile
    nvps.ReturnDetectorClassName( 1, 1 )logical = false
end
assert( exist( matfile, 'file' ) == 2,  ...
    message( 'gpucoder:cnncodegen:invalid_filename', matfile ) );
if endsWith( matfile, '.mat' )
    detector = [  ];
    foundDLObject = false;
    matobj = load( matfile );
    f = fields( matobj );

    for i = 1:numel( f )

        if isObjectDetector( matobj.( f{ i } ) )
            if ~foundDLObject
                detector = matobj.( f{ i } );
                foundDLObject = true;
            else

                error( message( 'vision:ObjectDetectorBlock:InvalidDLObjectCount' ) );
            end
        end
    end

    assert( ~isempty( detector ),  ...
        message( 'vision:ObjectDetectorBlock:InvalidMatFileObject', matfile ) );

else

    detector = feval( matfile );
    assert( isObjectDetector( detector ),  ...
        message( 'vision:ObjectDetectorBlock:InvalidFunction', matfile ) );
end

if nvps.ReturnDetectorClassName
    detector = class( detector );
end
end


function isDetector = isObjectDetector( obj )
isDetector =  ...
    isa( obj, 'yolov4ObjectDetector' ) ||  ...
    isa( obj, 'yolov3ObjectDetector' ) ||  ...
    isa( obj, 'yolov2ObjectDetector' ) ||  ...
    isa( obj, 'ssdObjectDetector' ) ||  ...
    isa( obj, 'rcnnObjectDetector' ) ||  ...
    isa( obj, 'fastRCNNObjectDetector' ) ||  ...
    isa( obj, 'fasterRCNNObjectDetector' );
end


