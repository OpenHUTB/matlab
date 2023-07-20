%#codegen

function logStmts
    coder.allowpcode('plain');
    coder.extrinsic('custom_logger_lib');

    [typesLen]=coder.const(@custom_logger_lib,'getNumTypes');

    for ii=coder.unroll(uint32(1):uint32(typesLen))
        [tmp,isVarDims]=coder.const(@custom_logger_lib,'getExampleVal',ii);
        if coder.const(isVarDims)
            [m,t]=varyingSize(coder.const(tmp),coder.const(@custom_logger_lib,'getDimensions',ii),coder.const(@custom_logger_lib,'getVarDimInfo',ii));
            custom_mex_logger(m,t);
        else
            t=coder.ignoreConst(tmp);
            m=coder.ignoreConst(uint32(0));

            custom_mex_logger(m,t);
        end
    end
end

function[m,t]=varyingSize(tmp,dim,varyingDimInfo)
    coder.inline('never');
    coder.varsize('t',dim,varyingDimInfo);

    t=coder.ignoreConst(tmp);
    m=coder.ignoreConst(uint32(0));
end