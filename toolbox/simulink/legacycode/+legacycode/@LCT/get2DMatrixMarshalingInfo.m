function matInfo=get2DMatrixMarshalingInfo(infoStruct,typeId,dims)









    matInfo=0;

    dataType=infoStruct.DataTypes.DataType(typeId);
    if dataType.IsBus||dataType.IsStruct


        if nBusNeed2DMatrixMarshalling(dataType,false)
            matInfo=2;
            return
        end
    end

    if numel(dims)==2&&~any(dims==1)
        matInfo=1;
    end

    function res=nBusNeed2DMatrixMarshalling(busType,res)
        for ii=1:busType.NumElements
            el=busType.Elements(ii);

            if el.NumDimensions==2&&~any(el.Dimensions==1)

                res=true;
                return
            else
                dt=infoStruct.DataTypes.DataType(el.DataTypeId);
                if dt.IsBus||dt.IsStruct

                    res=res||nBusNeed2DMatrixMarshalling(dt,res);
                end
            end
        end
    end

end
