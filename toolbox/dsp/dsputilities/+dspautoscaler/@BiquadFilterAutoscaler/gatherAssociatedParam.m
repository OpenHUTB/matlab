function associateRecords=gatherAssociatedParam(h,blkObj)%#ok<INUSL>






    fnames={'ModelRequiredMax','ModelRequiredMin'};

    Valuestr=get_param(blkObj.getFullName,'BiQuadCoeffs');
    [isValid,val]=evalNumericParameter(blkObj,Valuestr);


    if isValid

        associateRecords(1).blkObj=blkObj;
        associateRecords(1).pathItem='Numerator coefficients';
        for iFName=1:length(fnames)
            curFName=fnames{iFName};
            valFinal=getMinMax(curFName,val(1:3));
            associateRecords(1).(curFName)=valFinal;
        end

        associateRecords(2).blkObj=blkObj;
        associateRecords(2).pathItem='Denominator coefficients';
        for iFName=1:length(fnames)
            curFName=fnames{iFName};
            valFinal=getMinMax(curFName,val(5:6));
            associateRecords(2).(curFName)=valFinal;
        end
    else
        associateRecords=[];
    end


    function[isValid,val]=evalNumericParameter(block,unevaledParamStr)

        isValid=false;
        try
            valResolved=slResolve(unevaledParamStr,block.getFullName);
            val=double(valResolved);
            isValid=true;
        catch %#ok<CTCH>
            val=[];
        end


        function netValue=getMinMax(curFName,val)


            netValue=[];

            isMax=~isempty(strfind(curFName,'Max'));

            isMin=~isempty(strfind(curFName,'Min'));

            if~isMax&&~isMin

                return
            end

            if isMax

                netValue=findMaxValue(val(:));
            else
                netValue=findMinValue(val(:));
            end

            function minValue=findMinValue(rangeVector)

                if isempty(rangeVector)
                    minValue=[];
                else
                    if~isreal(rangeVector)
                        minValueVec=min(real(rangeVector),imag(rangeVector));
                        minValue=min(minValueVec(:));
                    else
                        minValue=min(rangeVector(:));
                    end
                end


                function maxValue=findMaxValue(rangeVector)

                    if isempty(rangeVector)
                        maxValue=[];
                    else
                        if~isreal(rangeVector)
                            maxValueVec=max(real(rangeVector),imag(rangeVector));
                            maxValue=max(maxValueVec(:));
                        else
                            maxValue=max(rangeVector(:));
                        end
                    end
