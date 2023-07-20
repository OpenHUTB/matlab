function[WL,FL,signed]=hdlgetwordsizefromtype(classtype)


%#codegen
    coder.allowpcode('plain');

    if isa(classtype,'embedded.numerictype')
        WL=classtype.WordLength;
        FL=classtype.FractionLength;
        signed=classtype.SignednessBool;
    else
        switch classtype
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
        case 'double'
            WL=0;
            FL=0;
            signed=1;
        case 'single'
            WL=0;
            FL=0;
            signed=1;
        case 'logical'
            WL=1;
            FL=0;
            signed=0;
        otherwise
            WL=0;
            FL=0;
            signed=0;
        end
    end