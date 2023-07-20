%#codegen


function vec=dts_colon(start,stopOrStep,stop)
    coder.inline('always');
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    if nargin==2
        step=1;
        stop=stopOrStep;
    else
        step=stopOrStep;
    end
    coder.internal.prefer_const(start,stop,step);

    [start_t,step_t,stop_t]=dts_transform_colon_operands(start,step,stop);

    emitColonWarning(start_t,step_t,stop_t);
    vec=start_t:step_t:stop_t;
end

function emitColonWarning(a,d,b)
    coder.internal.prefer_const(a,d,b);
    if isfloat(a)&&isfloat(d)&&isfloat(b)
        if~(coder.internal.isConst(a)&&coder.internal.isConst(b)&&coder.internal.isConst(d))
            coder.internal.compileWarning('Coder:FXPCONV:DTS_ColonWarning');
        end
    end
end



