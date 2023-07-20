function[out,ind]=sortImpl(in,varargin)




%#codegen
    coder.internal.prefer_const(varargin);
    coder.allowpcode('plain');
    coder.inline('always');

    narginchk(1,inf);
    coder.internal.allowEnumInputs;

    if(coder.target('MATLAB'))
        [out,ind]=sort(in,varargin{:});
    else
        out=coder.nullcopy(in);
        ind=coder.nullcopy(zeros(size(in)));
        if~isempty(in)
            if coder.gpu.internal.isGpuSortSupported()

                eml_invariant(nargin>0,'MATLAB:minrhs');


                eml_invariant(~iscell(in),'Coder:toolbox:CellArraysNotSupported','gpucoder.sort');


                eml_invariant(coder.internal.isBuiltInNumeric(in)||ischar(in)||islogical(in),...
                'Coder:toolbox:unsupportedClass','gpucoder.sort',class(in));


                coder.internal.assert(coder.const(isreal(in)),'gpucoder:common:GpucoderSortComplexInputs');

                ONE=coder.internal.indexInt(1);

                nv=coder.internal.indexInt(nargin-1);
                idx=ONE;

                if nv>=idx&&isnumeric(varargin{idx})
                    coder.internal.assertValidDim(varargin{idx});
                    sortDim=coder.internal.indexInt(varargin{idx});
                    coder.internal.assert(coder.internal.isConst(sortDim)||...
                    coder.const(~strcmp(eml_option('VariableSizing'),'DisableInInference')),...
                    'Coder:toolbox:dimNotConst');
                    idx=idx+1;
                else
                    sortDim=coder.internal.nonSingletonDim(in);
                end


                ASCEND=coder.const(coder.internal.sortDirectionStringToChar('ascend'));
                DESCEND=coder.const(coder.internal.sortDirectionStringToChar('descend'));
                sortDir=ASCEND;
                dirOK=true;
                if nv>=idx&&coder.internal.isTextRow(varargin{idx})
                    coder.internal.assert(coder.internal.isConst(varargin{idx}),...
                    'Coder:toolbox:SortDirMustBeConstant');
                    tmpdir=coder.const(coder.internal.sortDirectionStringToChar(varargin{idx}));
                    if coder.const(tmpdir==ASCEND||tmpdir==DESCEND)
                        sortDir=tmpdir;
                        idx=idx+1;
                    else
                        dirOK=false;
                    end
                end
                nleft=nv-idx+1;
                coder.internal.assert(dirOK,'MATLAB:sort:sortDirection');
                coder.internal.assert(nleft==0,'gpucoder:common:GpucoderIncorrectNumArgs','gpucoder.sort');
                inNDims=coder.internal.indexInt(ndims(in));
                inDims=coder.internal.indexInt(size(in));
                out=in;

                if nargout==1
                    coder.ceval('-layout:any','-gpuhostdevicefcn','gpu_thrust_sort',...
                    coder.ref(out(1),'gpu'),...
                    inNDims,...
                    coder.rref(inDims(1)),...
                    sortDim,sortDir,...
                    coder.isRowMajor);
                else
                    ind=zeros(size(in));
                    coder.ceval('-layout:any','-gpuhostdevicefcn','gpu_thrust_sort_with_index',...
                    coder.ref(out(1),'gpu'),...
                    coder.ref(ind(1),'gpu'),...
                    inNDims,...
                    coder.rref(inDims(1)),...
                    sortDim,sortDir,...
                    coder.isRowMajor);
                end

            else
                [out,ind]=sort(in,varargin{:});
            end
        end
    end

end
