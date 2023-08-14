function[numOverflows,numUnderflows,fiObject]=numOverAndUnderflows(numericValue,dataTypeContainer)































    mustBeNumericOrLogical(numericValue);
    mustBeAValidDataTypeContainer(dataTypeContainer);


    if isfi(dataTypeContainer)
        overflowMode=dataTypeContainer.OverflowMode;
        roundMode=dataTypeContainer.RoundMode;
    else
        overflowMode='wrap';
        roundMode='floor';
    end


    dataType=numerictype(dataTypeContainer);


    f=fipref;
    currentLoggingMode=f.LoggingMode;
    f.LoggingMode='on';


    warnStruct=warning;
    warning('off','fixed:fi:underflow');
    warning('off','fixed:fi:overflow');


    fiObject=fi(numericValue,dataType,...
    'OverflowMode',overflowMode,...
    'RoundMode',roundMode);


    numOverflows=noverflows(fiObject);
    numUnderflows=nunderflows(fiObject);


    warning(warnStruct);


    f.LoggingMode=currentLoggingMode;
end

function mustBeAValidDataTypeContainer(dataTypeContainer)


    assert(isnumerictype(dataTypeContainer)...
    ||isa(dataTypeContainer,'Simulink.NumericType')...
    ||isfi(dataTypeContainer));
end
