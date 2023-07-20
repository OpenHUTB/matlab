function[out,isVarDims]=getExampleVal(typeName,dimension,complexity,fiNumerictype,fiFimath,fieldTypesInfos)

    dim=dimension;

    varyingSize=isinf(dim);
    isVarDims=any(varyingSize);

    dim(varyingSize)=1;

    switch typeName
    case{'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','logical'}
        s=zeros(1,1,typeName);
        if complexity
            s=complex(s,s);
        end
        out=zeros(dim,'like',s);
    case 'embedded.fi'
        s=fi(0,fiNumerictype,fiFimath);
        if complexity
            s=complex(s,s);
        end
        out=zeros(dim,'like',s);
    case 'struct'
        try
            if~isempty(fieldTypesInfos)
                for ii=1:length(fieldTypesInfos)
                    fieldInfo=fieldTypesInfos(ii);
                    tmpOut.(fieldInfo.FieldName)=getExampleVal(fieldInfo.Typename,fieldInfo.Dimension,fieldInfo.Complexity,fieldInfo.Numerictype,fieldInfo.Fimath,fieldInfo.FieldTypesInfo);
                end
                out=repmat(tmpOut,dim);
            else
                out=[];
            end
        catch ex
            error(ex.message());
        end
    case 'char'
        out=repmat(' ',dim);
    otherwise
        error(['getExampleVal does not handle ',typeName,' yet.']);
    end
end