function pathItems=getPathItems(h,blkObj)%#ok





    if strcmpi(blkObj.FilterSource,'dfilt object')

        pathItems={};
    else



        pathItems={'Numerator product output',...
        'Denominator product output',...
        'Numerator accumulator',...
        'Denominator accumulator',...
        'Output',...
        'Numerator coefficients',...
        'Denominator coefficients'};









        if strcmpi(blkObj.IIRFiltStruct,'Direct form I')||...
            strcmpi(blkObj.IIRFiltStruct,'Direct form II transposed')
            skipSectionIO=false;
        else

            if strcmpi(blkObj.FilterSource,'Input port(s)')
                skipSectionIO=strcmpi(blkObj.ScaleValueMode,'Assume all are unity and optimize');
            else

                if~blkObj.optimizeScaleValues
                    skipSectionIO=false;
                else
                    skipSectionIO=all(slResolve(blkObj.ScaleValues,blkObj.getFullName)==1.0);
                end
            end
        end

        if~skipSectionIO
            pathItems{end+1}='Section input';
            pathItems{end+1}='Section output';
        end


        if~strcmpi(blkObj.IIRFiltStruct,'Direct form I')
            pathItems{end+1}='State';
        end


        if strcmpi(blkObj.IIRFiltStruct,'Direct form I transposed')
            pathItems{end+1}='Multiplicand';
        end
    end


