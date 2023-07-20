classdef(Abstract)FiniteDifferenceInterface





    properties(Abstract,Constant)







Coefficients
    end

    methods
        function values=calculate(this,functionWrapper,stepSize,derivativeOrder,inputValues)

            values=zeros(size(inputValues));
            nD=size(inputValues,2);
            coefficents=this.Coefficients{derivativeOrder};
            nCoeffcientRows=size(coefficents,1);
            nInputs=size(inputValues,1);


            minValues=min(inputValues);
            maxValues=max(inputValues);
            minEqualMaxIndices=maxValues==minValues;
            minValues(minEqualMaxIndices)=0;
            maxValues(minEqualMaxIndices)=1;
            normalizedValues=(inputValues-minValues)./(maxValues-minValues);
            allvalues=zeros(nCoeffcientRows*nInputs,nD);
            ranges=(maxValues-minValues);
            for dim=1:nD
                deltas=zeros(1,nD);
                deltas(dim)=stepSize(dim);


                cellNormalizedValues=repmat({normalizedValues},1,nCoeffcientRows);
                for k=1:nCoeffcientRows
                    if coefficents(k,1)~=0
                        cellNormalizedValues{k}=cellNormalizedValues{k}+coefficents(k,1)*deltas;
                    end
                    lb=(k-1)*nInputs+1;
                    ub=k*nInputs;
                    allvalues(lb:ub,:)=cellNormalizedValues{k}.*(maxValues-minValues)+minValues;
                end


                functionValues=functionWrapper.evaluate(allvalues);


                nInputs=size(inputValues,1);
                for k=1:nCoeffcientRows
                    lb=(k-1)*nInputs+1;
                    ub=k*nInputs;
                    values(:,dim)=values(:,dim)+coefficents(k,2)*functionValues(lb:ub);
                end


                delta=ranges(dim)*stepSize(dim);
                values(:,dim)=values(:,dim)./(delta^derivativeOrder);
            end
        end
    end
end


