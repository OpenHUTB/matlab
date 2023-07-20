function string=getStringToDefineDifferenceType(differenceType)





    if isfloat(differenceType)
        string=['tableValuesDelta = cast(zeros(1,nargin),''like'',',differenceType.DataType,'([]));'];
    else
        string=['tableValuesDelta = cast(zeros(1,nargin),''like'',',differenceType.tostring,');'];
    end
end