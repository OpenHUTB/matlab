function kind=getMATLABFunctionKind(caller,fcnName)
    FunctionKindUnknown=0;
    UserDefinedFunction=1;
    LibFunctionSkipped=2;
    LibFunctionNoWarnings=3;
    LibFunctionSimple=4;
    LibDoublePrecision=5;
    LibC89DoublePrecision=6;
    LibFunctionNotConverted=7;

    kind=FunctionKindUnknown;

    path=which(fcnName,'in',caller);
    toolboxPath=fullfile(matlabroot,'toolbox');

    if~isempty(strfind(path,toolboxPath))||~isempty(strfind(path,'built-in'))||~isempty(strfind(path,'builtin'))

        dtslibpath=fullfile(matlabroot,'toolbox','coder','float2fixed','dtslib');
        if~isempty(strfind(path,dtslibpath))
            kind=LibFunctionSkipped;
            return;
        end

        nOutputArgs=-1;
        try
            nOutputArgs=nargout(fcnName);
        catch
        end

        if nOutputArgs==0

            kind=LibFunctionSkipped;
            return;
        end



        switch fcnName
        case{'beta','betainc','betaincinv','betaln',...
            'erf','erfc','erfcinv','erfcx','erfinv',...
            'gamma','gammainc','gammaincinv','gammaln',...
            'nchoosek',...
            'psi',...
            'rank',...
            'rand','randi','randstream','randperm'...
            }
            kind=LibDoublePrecision;

        case{'isempty'}


            kind=LibFunctionSkipped;

        case{'cell'}

            kind=LibFunctionSkipped;

        case{'coder.const'}




            kind=LibFunctionNoWarnings;

        case{'feval'}




            kind=LibFunctionSkipped;

        case{'load','coder.load','coder.nullcopy','coder.opaque','coder.inline',...
            'coder.unroll','coder.extrinsic','coder.cstructname','coder.replace',...
            'coder.ceval','coder.ref','coder.rref','coder.wref','coder.target',...
            'coder.internal.prefer_const','coder.internal.isConst',...
            'eml.nullcopy'}

            kind=LibFunctionSkipped;

        case{'int8','int16','int32','int64',...
            'uint8','uint16','uint32','uint64',...
            'logical','char','single'}

            kind=LibFunctionSkipped;

        case{'assert'}
            kind=LibFunctionSkipped;











        case{'acos','acosd','asin','asind','atan','atand','atan2','atan2d'...
            ,'cos','cosd','cosh','sin','sind','sinh','tan','tanh',...
            'ceil','floor','round','fix',...
            'exp','expint','expm1',...
            'abs','angle','unwrap','hypot',...
            'mod','rem',...
            'log','log2','log10','reallog',...
            'pow2',...
            'sqrt'}
            kind=LibC89DoublePrecision;

        case{'numel','size','ndims','length','end'}
            kind=LibFunctionNoWarnings;

        case{'fopen','figure'}

            kind=LibFunctionNotConverted;

        otherwise
            if~isempty(strfind(fcnName,'eml.'))||~isempty(strfind(fcnName,'coder.'))

                kind=LibFunctionSkipped;
            else

                kind=LibFunctionSimple;
            end
        end
    else

        kind=UserDefinedFunction;
    end
end
