function dtInfo=getSourceDataTypeInfo(obj,maxVal)
























    if(nargin<2)
        maxVal=-1;
    end

    dtInfo.IsScaled=true;
    dtInfo.IsSigned=true;
    dtInfo.WordLength=2;
    dtInfo.FractionLength=0;
    dtInfo.Id=-1;

    dtMode=obj.OutputDataType;
    if matlab.system.isSpecifiedTypeMode(dtMode)
        dtType=obj.CustomOutputDataType;
    else
        dtType=numerictype(dtMode);
    end


    if strcmp(dtType.Scaling,'Unspecified')
        dtInfo.IsScaled=false;
    else
        dtInfo.IsScaled=true;
    end


    switch(dtType.Signedness)
    case 'Signed'
        dtInfo.IsSigned=1;
    case 'Unsigned'
        dtInfo.IsSigned=0;
    case 'Auto'
        dtInfo.IsSigned=-1;
    end


    dtInfo.WordLength=dtType.WordLength;


    if dtInfo.IsScaled
        dtInfo.FractionLength=dtType.FractionLength;
    else
        isSigned=dtInfo.IsSigned;
        if isequal(isSigned,-1)
            isSigned=1;
        end
        nt=numerictype(isSigned,dtInfo.WordLength);
        SetBestFractionLength(nt,max(maxVal(:)));
        dtInfo.FractionLength=nt.FractionLength;

    end











    switch dtType.DataType
    case 'double'
        dtInfo.Id=0;
    case 'single'
        dtInfo.Id=1;
    case 'boolean'
        dtInfo.Id=8;
    case{'Fixed','ScaledDouble'}
        if(dtInfo.FractionLength~=0)||~any(dtInfo.WordLength==[8,16,32])
            dtInfo.Id=-2;
        else

            id=0+2*find(dtInfo.WordLength==[8,16,32]);
            if~dtInfo.IsSigned
                id=id+1;
            end
            dtInfo.Id=id;
        end
    otherwise

    end
end
