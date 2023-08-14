function result=getBuiltinList(option)




    switch option
    case 'Num'
        result=getNumTypes;
    case 'NumHalf'
        result=getNumHalfTypes;
    case 'Bool'
        result=getBoolType;
    case 'NumBool'
        result=getNumBoolTypes;
    case 'NumHalfBool'
        result=getNumHalfBoolTypes;
    case 'Int'
        result=getIntTypes;
    case 'SignedInt'
        result=getSignedIntTypes;
    case 'Float'
        result=getFloatTypes;
    otherwise
        assert(false,'Unsupported option');
    end
end





function result=getNumTypes()
    result=[getFloatTypes;getIntTypes];
end




function result=getNumHalfTypes()
    result=[getFloatTypes;getHalfType;getIntTypes];
end

function result=getNumBoolTypes()
    result=[getNumTypes;getBoolType];
end

function result=getNumHalfBoolTypes()
    result=[getNumHalfTypes;getBoolType];
end

function result=getBoolType()
    result={'boolean'};
end

function result=getIntTypes()
    result={
'int8'
'uint8'
'int16'
'uint16'
'int32'
'uint32'
    };
    if slfeature('SLInt64')>0
        result=[result;{'int64';'uint64'}];
    end
end

function result=getSignedIntTypes()
    result={
'int8'
'int16'
'int32'
    };
    if slfeature('SLInt64')>0
        result=[result;{'int64'}];
    end
end

function result=getFloatTypes()
    result={
'double'
'single'
    };
end

function result=getHalfType()
    result={'half'};
end


