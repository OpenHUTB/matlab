function out=cumsumImpl(in,dim,rev,omitnan)
%#codegen



    coder.allowpcode('plain');
    coder.inline('always');
    narginchk(1,inf);
    coder.internal.allowEnumInputs;

    coder.internal.assert(coder.internal.isConst(dim)||...
    coder.const(~strcmp(eml_option('VariableSizing'),'DisableInInference')),...
    'Coder:toolbox:dimNotConst');

    inNDims=coder.internal.indexInt(ndims(in));
    inDims=coder.internal.indexInt(size(in));
    nelem=coder.internal.indexInt(numel(in));

    out=in;

    if omitnan
        out(isnan(out))=0;
    end

    if nelem>1&&dim<=inNDims&&inDims(dim)~=1
        if inNDims==2&&(inDims(1)==1||inDims(2)==1)

            coder.ceval('-layout:any','-gpuhostdevicefcn','callThrustScan1D',...
            coder.ref(out(1),'gpu'),...
            rev,...
            nelem);
        elseif(dim==1&&~coder.isRowMajor)||(dim==inNDims&&coder.isRowMajor)

            coder.ceval('-layout:any','-gpuhostdevicefcn','callThrustScanNDEdge',...
            coder.ref(out(1),'gpu'),...
            inDims(dim),...
            rev,...
            nelem);
        else

            coder.ceval('-layout:any','-gpuhostdevicefcn','callThrustScanNDOther',...
            coder.ref(out(1),'gpu'),...
            inNDims,...
            coder.rref(inDims(1)),...
            dim-1,rev,...
            nelem,coder.isRowMajor);
        end
    end
end

