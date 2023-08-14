function valueStr=getEnumString(h,inputStr)%#ok










    persistent enumMap;
    persistent enumMapReverse;

    if isempty(enumMap)
        enumMap=containers.Map;

        enumMap('RTW_SATURATE_UNSPECIFIED')='Unspecified Saturation';
        enumMap('RTW_WRAP_ON_OVERFLOW')='Wrap on Overflow';
        enumMap('RTW_SATURATE_ON_OVERFLOW')='Saturate on Overflow';


        enumMap('RTW_ROUND_UNSPECIFIED')='Unspecified Rounding';
        enumMap('RTW_ROUND_FLOOR')='Floor';
        enumMap('RTW_ROUND_CEILING')='Ceil';
        enumMap('RTW_ROUND_ZERO')='Zero';
        enumMap('RTW_ROUND_NEAREST')='Nearest';
        enumMap('RTW_ROUND_NEAREST_ML')='MATLAB Nearest';
        enumMap('RTW_ROUND_SIMPLEST')='Simplest';
        enumMap('RTW_ROUND_CONV')='Conv';


        enumMap('RTW_IO_INPUT')='INPUT';
        enumMap('RTW_IO_OUTPUT')='OUTPUT';


        enumMap('FCN_IMPL_FUNCT')='FUNCTION';
        enumMap('FCN_IMPL_MACRO')='MACRO';


        enumMap('RTW_PASSBY_AUTO')='Auto';
        enumMap('RTW_PASSBY_POINTER')='Pointer';
        enumMap('RTW_PASSBY_VOID_POINTER')='void Pointer';
        enumMap('RTW_PASSBY_BASE_POINTER')='base Pointer';


        enumMap('RTW_OP_ADD')='Addition';
        enumMap('RTW_OP_MINUS')='Minus';
        enumMap('RTW_OP_MUL')='Multiply';
        enumMap('RTW_OP_ELEM_MUL')='Element-wise Matrix Multiply';
        enumMap('RTW_OP_DIV')='Divide';
        enumMap('RTW_OP_LDIV')='Left Matrix Divide';
        enumMap('RTW_OP_RDIV')='Right Matrix Divide';
        enumMap('RTW_OP_INV')='Matrix Inverse';
        enumMap('RTW_OP_CAST')='Cast';
        enumMap('RTW_OP_SL')='Shift Left';
        enumMap('RTW_OP_SRA')='Shift Right Arithmetic';
        enumMap('RTW_OP_SRL')='Shift Right Logical';
        enumMap('RTW_OP_TRANS')='Transpose';
        enumMap('RTW_OP_CONJUGATE')='Complex Conjugate';
        enumMap('RTW_OP_HERMITIAN')='Complex Conjugate Transpose (Hermitian)';
        enumMap('RTW_OP_HMMUL')='Hermitian Multiplication';
        enumMap('RTW_OP_TRMUL')='Transpose Multiplication';
        enumMap('RTW_OP_MULDIV')='Multiply Divide';
        enumMap('RTW_OP_MUL_SRA')='Multiply Shift Right Arithmetic';
        enumMap('RTW_OP_GREATER_THAN')='Greater Than';
        enumMap('RTW_OP_LESS_THAN')='Less Than';
        enumMap('RTW_OP_GREATER_THAN_OR_EQUAL')='Greater Than Or Equal';
        enumMap('RTW_OP_LESS_THAN_OR_EQUAL')='Less Than Or Equal';
        enumMap('RTW_OP_EQUAL')='Equal';
        enumMap('RTW_OP_NOT_EQUAL')='Not Equal';


        enumMap('UNSPECIFIED')='UNSPECIFIED';
        enumMap('ENABLE')='ENABLE';
        enumMap('DISABLE')='DISABLE';


        enumMap('RTW_UNSPECIFIED')='Unspecified';
        enumMap('RTW_CORDIC')='Cordic';
        enumMap('RTW_DEFAULT')='Default';
        enumMap('RTW_LOOKUP')='Lookup';
        enumMap('RTW_NEWTON_RAPHSON')='Newton Raphson';


        enumMap('RTW_CAST_BEFORE_OP')='Cast before operation';
        enumMap('RTW_CAST_AFTER_OP')='Cast after operation';



        enumMap('RTW_FIR2D_CONV_MODE')='FIR2D Convolution';
        enumMap('RTW_FIR2D_CORR_MODE')='FIR2D Correlation';
        enumMap('RTW_FIR2D_UNSPECIFIED')='FIR2D Unspecified';

        enumMap('RTW_FIR2D_OUTPUT_SAMEASINPUT_MODE')='Same as Input';
        enumMap('RTW_FIR2D_OUTPUT_FULL_MODE')='Full Output';
        enumMap('RTW_FIR2D_OUTPUT_VALID_MODE')='Valid Output';
        enumMap('RTW_FIR2D_OUTPUT_UNRESTRICTED_MODE')='Unrestricted Output';
        enumMap('RTW_FIR2D_OUTPUT_NUM_OUTPUTMODES')='Num Output';
        enumMap('RTW_FIR2D_OUTPUT_UNSPECIFIED')='Unspecified Output';


        enumMap('RTW_CONVCORR1D_CONV_MODE')='CONVCORR1D Convolution';
        enumMap('RTW_CONVCORR1D_CORR_MODE')='CONVCORR1D Correlation';
        enumMap('RTW_CONVCORR1D_UNSPECIFIED')='CONVCORR1D Unspecified';


        enumMap('RTW_LOOKUP_EVEN_SEARCH')='Even Search';
        enumMap('RTW_LOOKUP_LINEAR_SEARCH')='Linear Search';
        enumMap('RTW_LOOKUP_BINARY_SEARCH')='Binary Search';
        enumMap('RTW_LOOKUP_SEARCH_UNSPECIFIED')='Unspecified Search';

        enumMap('RTW_LOOKUP_FLAT_INTRP')='Flat Interpolation';
        enumMap('RTW_LOOKUP_LINEAR_INTRP')='Linear Interpolation';
        enumMap('RTW_LOOKUP_LINEAR_LAGRANGE_INTRP')='Linear Lagrange Interpolation';
        enumMap('RTW_LOOKUP_ABOVE_INTRP')='Above Interpolation';
        enumMap('RTW_LOOKUP_NEAREST_INTRP')='Nearest Interpolation';
        enumMap('RTW_LOOKUP_CUBICSPLINE_INTRP')='Cubic Spline Interpolation';
        enumMap('RTW_LOOKUP_INTRP_UNSPECIFIED')='Unspecified Interpolation';

        enumMap('RTW_LOOKUP_CLIP_EXTRP')='Clip Extrapolation';
        enumMap('RTW_LOOKUP_LINEAR_EXTRP')='Linear Extrapolation';
        enumMap('RTW_LOOKUP_CUBICSPLINE_EXTRP')='Cubic Spline Extrapolation';
        enumMap('RTW_LOOKUP_EXTRP_UNSPECIFIED')='Unspecified Extrapolation';

        enumMap('RTW_SEM_INIT')='Semaphore Init';
        enumMap('RTW_SEM_WAIT')='Semaphore Wait';
        enumMap('RTW_SEM_POST')='Semaphore Post';
        enumMap('RTW_SEM_DESTROY')='Semaphore Destroy';
        enumMap('RTW_MUTEX_INIT')='Mutex Init';
        enumMap('RTW_MUTEX_LOCK')='Mutex Lock';
        enumMap('RTW_MUTEX_UNLOCK')='Mutex Unlock';
        enumMap('RTW_MUTEX_DESTROY')='Mutex Destroy';


        enumMap('RTW_TIMER_UP')='Up';
        enumMap('RTW_TIMER_DOWN')='Down';


        enumMap('COLUMN_MAJOR')='Column-major';
        enumMap('ROW_MAJOR')='Row-major';
        enumMap('COLUMN_AND_ROW')='Column-and-Row';

    end


    if isempty(enumMapReverse)
        k=keys(enumMap);
        v=values(enumMap);

        enumMapReverse=containers.Map(v,k);
    end


    if isKey(enumMapReverse,inputStr)
        valueStr=enumMapReverse(inputStr);
    elseif isKey(enumMap,inputStr)
        valueStr=enumMap(inputStr);
    else
        valueStr=inputStr;
    end




