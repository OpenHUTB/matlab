function pathItems=getPathItems(h,blkObj)




    if strcmpi(blkObj.FilterSource,'dfilt object')

        pathItems={};
    else



        pathItems={'Product output','Accumulator','Output'};


        if strcmpi(blkObj.CoeffSource,'Specify via dialog')
            numPathItems=length(h.getCoefficientPropertyNames(blkObj));
            if numPathItems==1
                pathItems{end+1}='Coefficients';
            elseif numPathItems==2
                pathItems{end+1}='Numerator coefficients';
                pathItems{end+1}='Denominator coefficients';
            end
        end


        if h.showState(blkObj)
            pathItems{end+1}='State';
        end


        if strcmpi(blkObj.TypePopup,'FIR (all zeros)')
            if contains(blkObj.FIRFiltStruct,'symmetric')
                pathItems{end+1}='Tap sum';
            end
        end




        if strcmpi(blkObj.TypePopup,'IIR (poles & zeros)')
            if strcmpi(blkObj.IIRFiltStruct,'Direct form I transposed')
                pathItems{end+1}='Multiplicand';
            elseif contains(blkObj.IIRFiltStruct,'Biquad')
                pathItems{end+1}='Section input';
                pathItems{end+1}='Section output';
            end
        end
    end
end


