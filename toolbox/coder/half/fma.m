










%#codegen

function out=fma(a,b,c)

    coder.internal.allowHalfInputs;
    if coder.target('MATLAB')
        out=hdl.fma(a,b,c);
    else
        assertSupportedType(a);
        assertSupportedType(b);
        assertSupportedType(c);

        coder.allowpcode('plain');

        SCALARA=coder.const(coder.internal.isConst(isscalar(a))&&isscalar(a));
        SCALARB=coder.const(coder.internal.isConst(isscalar(b))&&isscalar(b));
        SCALARC=coder.const(coder.internal.isConst(isscalar(c))&&isscalar(c));

        VECTORA=coder.const(coder.internal.isConst(isvector(a))&&isvector(a));
        VECTORB=coder.const(coder.internal.isConst(isvector(b))&&isvector(b));
        VECTORC=coder.const(coder.internal.isConst(isvector(c))&&isvector(c));

        ALLVECTORS=coder.const(VECTORA&&VECTORB&&VECTORC);


        DOPARALLEL=coder.internal.scalexpCompatible(a,b)&&...
        coder.internal.scalexpCompatible(b,c)&&coder.internal.scalexpCompatible(a,c)...
        &&(ALLVECTORS||~coder.internal.avoidArrayFlattening);


        if SCALARA&&SCALARB&&SCALARC
            out=fmaScalar(a(1),b(1),c(1));
        elseif DOPARALLEL
            example=coder.internal.scalarEg(a,b,c);
            out=coder.internal.scalexpAllocNoCheck(example,a,b,c);
            n=coder.internal.indexInt(numel(out));
            parfor k=1:n
                out(k)=fmaScalar(...
                coder.internal.scalexpSubsref(a,k),...
                coder.internal.scalexpSubsref(b,k),...
                coder.internal.scalexpSubsref(c,k));
            end
        else
            out=coder.internal.ixfunDynamic(@fmaScalar,a,b,c);
        end
    end
end



function out=fmaScalar(a,b,c)
    coder.inline('always');

    intermHalf=coder.const(allOfAre(a,b,c,'half'));
    outHalf=coder.const(anyOfAre(a,b,c,'half'));

    intermDouble=coder.const(anyOfAre(a,b,c,'double'));
    outDouble=coder.const(allOfAre(a,b,c,'double'));

    intermSingle=coder.const(~(intermHalf||intermDouble));
    outSingle=coder.const(~(outHalf||outDouble));

    if intermHalf
        out=fmaHalf(a,b,c);
    elseif intermSingle
        a_single=single(a);
        b_single=single(b);
        c_single=single(c);

        if outHalf
            out=half(fmaSingle(a_single,b_single,c_single));
        else
            out=fmaSingle(a_single,b_single,c_single);
        end
    else
        a_double=double(a);
        b_double=double(b);
        c_double=double(c);

        if outHalf
            out=half(fmaDouble(a_double,b_double,c_double));
        elseif outSingle
            out=single(fmaDouble(a_double,b_double,c_double));
        else
            out=fmaDouble(a_double,b_double,c_double);
        end
    end
end




function out=fmaHalf(a,b,c)

    out=half(double(a)*double(b)+double(c));

end



function out=fmaSingle(a,b,c)
    out=coder.nullcopy(single(0));
    ctx=eml_option('CodegenBuildContext');
    targetLang=coder.const(feval('getTargetLang',ctx));

    codingForC=coder.const(strcmp('C',targetLang));

    if codingForC
        coder.cinclude('math.h');
        fun='fmaf';
    else
        coder.cinclude('<cmath>');
        fun='std::fma';
    end

    out=coder.ceval(fun,a,b,c);
end



function out=fmaDouble(a,b,c)

    out=coder.nullcopy(0);
    ctx=eml_option('CodegenBuildContext');
    targetLang=coder.const(feval('getTargetLang',ctx));

    codingForC=coder.const(strcmp('C',targetLang));

    if codingForC
        coder.cinclude('math.h');
        fun='fma';
    else
        coder.cinclude('<cmath>');
        fun='std::fma';
    end

    out=coder.ceval(fun,a,b,c);

end



function assertSupportedType(x)
    eml_invariant(isfloat(x),'Coder:toolbox:unsupportedClass','fma',...
    class(x));
end



function out=allOfAre(a,b,c,class)
    out=isa(a,class)&&isa(b,class)&&isa(c,class);
end



function out=anyOfAre(a,b,c,class)
    out=isa(a,class)||isa(b,class)||isa(c,class);
end


