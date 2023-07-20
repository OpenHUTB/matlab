function[minV,maxV]=gatherDesignMinMax(h,blkObj,pathItem)%#ok<INUSL>





    minV=[];
    maxV=[];


    blkDialogParams=blkObj.IntrinsicDialogParameters;



    switch pathItem
    case{'Output','1'}

        baseParamNameStr='Out';

    case 'Table'

        baseParamNameStr='Table';

    case 'Accumulator'

        baseParamNameStr='Accum';

    case 'Coefficients'

        baseParamNameStr='Coef';

    case 'Numerator Coefficients'

        baseParamNameStr='NumCoef';

    case 'Denominator Coefficients'

        baseParamNameStr='DenCoef';

    case 'Gain'

        baseParamNameStr='Param';

    case 'Breakpoint'

        baseParamNameStr='Breakpoint';

    otherwise
        if strncmp(pathItem,'BreakpointsForDimension',23)
            baseParamNameStr=pathItem;
        else
            return;
        end
    end

    maxParamNameStr=[baseParamNameStr,'Max'];
    minParamNameStr=[baseParamNameStr,'Min'];



    if isfield(blkDialogParams,maxParamNameStr)&&~isempty(blkObj.(maxParamNameStr))&&~strcmpi(blkObj.(maxParamNameStr),'[]')
        maxV=slResolve(blkObj.(maxParamNameStr),blkObj.Handle);
    end



    if isfield(blkDialogParams,minParamNameStr)&&~isempty(blkObj.(minParamNameStr))&&~strcmpi(blkObj.(minParamNameStr),'[]')
        minV=slResolve(blkObj.(minParamNameStr),blkObj.Handle);
    end





