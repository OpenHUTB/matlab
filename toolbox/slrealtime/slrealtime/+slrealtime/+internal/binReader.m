classdef binReader






    properties(Constant,GetAccess=private)
        typeSizes=struct('double',8,'single',4,...
        'uint64',8,'int64',8,...
        'uint32',4,'int32',4,...
        'uint16',2,'int16',2,...
        'uint8',1,'int8',1);
    end
    properties(SetAccess=private,GetAccess=private)
inpSpec
nInputs
    end
    properties(SetAccess=private,GetAccess=public)
bytesPerRec
nOutputs
    end

    methods
        function br=binReader(varargin)






            last=0;
            br.nInputs=nargin;
            br.nOutputs=0;
            c=cell(1,br.nInputs);







            br.inpSpec=struct('size',c,'type',c,...
            'dims',c,'bits',c,'bytes',c);
            for i=1:br.nInputs
                [sz,type,dims,bits]=br.parseInputSpec(varargin{i});
                br.inpSpec(i)=struct('size',sz,'type',type,...
                'dims',dims,'bits',{bits},'bytes',last+(1:sz));
                if dims>0
                    br.nOutputs=br.nOutputs+1;
                end
                last=last+sz;
            end
            br.bytesPerRec=last;
        end

        function varargout=decode(br,d)


            nargoutchk(br.nOutputs,br.nOutputs);
            if rem(numel(d),br.bytesPerRec)~=0
                error(message('slrealtime:profiling:invalidDataSize',...
                numel(d),br.bytesPerRec));
            end
            dMat=reshape(d,br.bytesPerRec,[]);
            varargout=cell(1,br.nOutputs);
            oIdx=0;
            for i=1:br.nInputs
                if br.inpSpec(i).dims<=0
                    continue
                end
                oIdx=oIdx+1;
                slice=reshape(dMat(br.inpSpec(i).bytes,:),[],1);
                v=typecast(slice,br.inpSpec(i).type);
                if(br.inpSpec(i).dims>1)
                    v=reshape(v,br.inpSpec(i).dims,[])';
                end
                if~isempty(br.inpSpec(i).bits)
                    v=getBits(v,br.inpSpec(i).bits);
                end
                varargout{oIdx}=v;
            end
        end
    end
    methods(Access=private)
        function[sz,baseType,dims,bits]=parseInputSpec(br,s)



























            baseType='';
            bits={};
            if iscell(s)
                baseType=s{1};
                bits=s(2:end);
                for i=1:numel(bits)
                    b=bits{i};
                    validateattributes(b,{'numeric'},...
                    {'size',[1,2],'nonnegative','integer','nondecreasing'});
                end
                s=s{1};
                dims=1;
            else
                discStr=regexp(s,'~(\d+)$','tokens');
                dimStr=regexp(s,'^((\d+)\*)?(\w+)$','tokens');
                if~isempty(discStr)
                    baseType='uint8';
                    dims=-str2double(discStr{1}{1});
                elseif~isempty(dimStr)
                    baseType=dimStr{1}{2};

                    if~isempty(dimStr{1}{1})
                        dims=str2double(dimStr{1}{1}(1:end-1));
                    else
                        dims=1;
                    end
                end
            end

            if isempty(baseType)||~isfield(br.typeSizes,baseType)
                error(message('slrealtime:profiling:invalidFormat',s));
            end
            sz=br.typeSizes.(baseType)*abs(dims);
        end
    end
end





function dl=getBits(d,bits)


    dl=cell(1,numel(bits));
    for i=1:numel(bits)
        lsb=bits{i}(1);
        msb=bits{i}(2);
        mask=cast(2^(msb-lsb+1)-1,'like',d);
        dl{i}=bitand(bitshift(d,-lsb),mask);
    end
end
