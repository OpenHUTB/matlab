function[datatype,typeMin,typeMax]=getDatatypeMinimumMaximum(blockH,inportIdx,outportIdx)

    datatype='';
    typeMin=0;
    typeMax=0;
    try
        pHs=get_param(blockH,'PortHandles');

        if inportIdx>0
            datatype=get_param(pHs.Inport(inportIdx),'CompiledPortDataType');
        elseif outportIdx>0
            datatype=get_param(pHs.Outport(outportIdx),'CompiledPortDataType');
        end
        if isIntDatatype(datatype)
            typeMin=intmin(datatype);
            typeMax=intmax(datatype);
        elseif strcmp(datatype,'double')||strcmp(datatype,'single')


        else
            try
                fixedPtObject=fixdt(datatype);
                datatype='fixedpoint';
                if strcmp(fixedPtObject.DataTypeMode,'Fixed-point: binary point scaling')
                    if strcmp(fixedPtObject.Signedness,'Signed')
                        sign=1;
                    else
                        sign=0;
                    end
                    fiObject=fi(0,sign,fixedPtObject.WordLength,fixedPtObject.FractionLength);
                    range=fiObject.range;
                    typeMin=range(1);
                    typeMax=range(2);
                    datatype='Fixed-point: binary point scaling';
                elseif strcmp(fixedPtObject.DataTypeMode,'Fixed-point: slope and bias scaling')
                    if strcmp(fixedPtObject.Signedness,'Signed')
                        sign=1;
                    else
                        sign=0;
                    end
                    fiObject=fi(0,sign,fixedPtObject.WordLength,fixedPtObject.Slope,fixedPtObject.Bias);
                    range=fiObject.range;
                    typeMin=range(1);
                    typeMax=range(2);
                    datatype='Fixed-point: slope and bias scaling';
                else
                    typeMin=0;
                    typeMax=0;
                end
            catch Mex
                typeMin=0;
                typeMax=0;
            end
        end
    catch Mex
        datatype='';
        typeMin=0;
        typeMax=0;
    end

end
