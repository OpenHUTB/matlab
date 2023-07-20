function[WL,FL,signed]=hdlgetwordsizefromdata(data)


%#codegen
    coder.allowpcode('plain');
    classtype=class(data);

    switch classtype


    case 'single'
        WL=0;
        FL=0;
        signed=1;
    case 'double'
        WL=0;
        FL=0;
        signed=1;
    case 'boolean'
        WL=1;
        FL=0;
        signed=0;
    case 'logical'
        WL=1;
        FL=0;
        signed=0;
    case 'int8'
        WL=8;
        FL=0;
        signed=1;
    case 'uint8'
        WL=8;
        FL=0;
        signed=0;
    case 'int16'
        WL=16;
        FL=0;
        signed=1;
    case 'uint16'
        WL=16;
        FL=0;
        signed=0;
    case 'int32'
        WL=32;
        FL=0;
        signed=1;
    case 'uint32'
        WL=32;
        FL=0;
        signed=0;
    case 'int64'
        WL=64;
        FL=0;
        signed=1;
    case 'uint64'
        WL=64;
        FL=0;
        signed=0;
    case 'embedded.fi'
        WL=data.WordLength;
        FL=data.FractionLength;
        signed=strcmpi(data.Signedness,'signed');
    otherwise
        WL=0;
        FL=0;
        signed=0;

    end



end