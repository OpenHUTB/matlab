function out=transposeImpl(in,conj)
%#codegen




    coder.allowpcode('plain');
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);
    narginchk(2,2);
    coder.internal.allowEnumInputs;
    coder.internal.allowHalfInputs;

    if coder.target('MATLAB')
        if conj;out=in';else;out=in.';end
    else
        if coder.gpu.internal.isGpuTransposeSupported()


            eml_invariant(nargin>0,'MATLAB:minrhs');


            eml_invariant(~iscell(in),'Coder:builtins:TransposeCellUnsupported');


            eml_invariant(ismatrix(in),'Coder:builtins:TransposeND');

            nrows=coder.internal.indexInt(size(in,1));
            ncols=coder.internal.indexInt(size(in,2));

            if ischar(in)
                out=coder.nullcopy(repmat(blanks(nrows),[ncols,1]));
            else
                out=coder.nullcopy(zeros(ncols,nrows,'like',in));
            end

            if~isempty(in)
                if coder.internal.isConst(nrows)&&...
                    coder.internal.isConst(ncols)&&...
                    (nrows==1||ncols==1)
                    if coder.const(conj);out=in';else;out=in.';end
                else
                    if~coder.const(conj)||coder.const(isreal(in)||ischar(in))
                        coder.ceval('-layout:any','-gpuhostdevicefcn','gpu_shared_mem_transpose',...
                        coder.rref(in(1),'gpu'),...
                        coder.wref(out(1),'gpu'),...
                        nrows,...
                        ncols,...
                        coder.isRowMajor);
                    else
                        coder.ceval('-layout:any','-gpuhostdevicefcn','gpu_shared_mem_ctranspose',...
                        coder.rref(in(1),'gpu'),...
                        coder.wref(out(1),'gpu'),...
                        nrows,...
                        ncols,...
                        coder.isRowMajor);
                    end
                end
            end
        else
            if coder.const(conj);out=in';else;out=in.';end
        end

    end

end
