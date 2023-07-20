function matInfo=getNDArrayMarshalingInfo(this,dataOrType,theDims)






    narginchk(2,3);

    if nargin==2
        dataType=this.DataTypes.Items(dataOrType.DataTypeId);
        theDims=dataOrType.Dimensions;
    elseif nargin==3
        if isa(dataOrType,'legacycode.types.Type')
            dataType=dataOrType;
        else
            dataType=this.DataTypes.Items(dataOrType);
        end
    end





    matInfo=0;

    if dataType.isAggregateType()


        if nBusNeedNDArrayMarshalling(dataType,false)

            matInfo=2;
            return
        end
    end


    if numel(theDims)>=2&&~any(theDims==1)
        matInfo=1;
    end

    function res=nBusNeedNDArrayMarshalling(busType,res)
        for ii=1:busType.NumElements
            el=busType.Elements(ii);

            if el.NumDimensions>=2&&~any(el.Dimensions==1)

                res=true;
                return
            else
                dt=this.DataTypes.Items(el.DataTypeId);
                if dt.isAggregateType()

                    res=res||nBusNeedNDArrayMarshalling(dt,res);
                end
            end
        end
    end

end


