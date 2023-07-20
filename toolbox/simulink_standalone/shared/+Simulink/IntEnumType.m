classdef(Abstract)IntEnumType<int32








































    methods(Static,Sealed,Hidden)
        function result=getIndexOfDefaultValue(className)

            metaClass=meta.class.fromName(className);
            [enumVals,enumNames]=enumeration(className);

            getDefaultMethod=findobj(metaClass.MethodList,'Name','getDefaultValue');

            useFirstValue=true;
            if~isempty(getDefaultMethod)

                if((length(getDefaultMethod)==1)&&...
                    (getDefaultMethod.Static)&&...
                    (isequal(getDefaultMethod.Access,'public')))

                    useFirstValue=false;
                else
                    MSLDiagnostic('Simulink:utility:InvalidGetDefaultValueMethod',...
                    className,className,enumNames{1}).reportAsWarning;
                end
            end

            if useFirstValue
                result=1;
                return;
            end


            defaultValue=feval([className,'.getDefaultValue']);


            if(~isa(defaultValue,className)||...
                ~isequal(size(defaultValue),[1,1]))
                DAStudio.error('Simulink:utility:InvalidDefaultValue',className,className);
            end



            enumIdx=find(builtin('eq',defaultValue,enumVals));

            result=enumIdx(1);
        end
    end


    methods
        function hObj=IntEnumType(value)









            mlock;
            persistent ClassBeingLoaded
            persistent LoadedValues
            persistent NumEnumerations
            persistent PreserveDups

            try

                narginchk(1,1);


                if((~isscalar(value))||...
                    (~isnumeric(value))||...
                    (~isreal(value))||...
                    (~isfinite(value))||...
                    (~rem(value,1)==0)||...
                    (issparse(value)))
                    DAStudio.error('Simulink:utility:EnumsMustBeRealInt');
                end


                if((value<double(intmin))||...
                    (value>double(intmax)))
                    DAStudio.error('Simulink:utility:EnumsMustFitIntoInt32');
                end
            catch e

                ClassBeingLoaded='';
                LoadedValues=[];
                NumEnumerations=[];
                PreserveDups=[];
                rethrow(e);
            end

            if~isempty(ClassBeingLoaded)

                assert(~isempty(LoadedValues));
                assert(length(LoadedValues)<NumEnumerations);
                assert(~isempty(PreserveDups));
                if PreserveDups
                    differentiator=sum(eq(LoadedValues,value));
                    value=complex(value,differentiator);
                end
            end


            hObj=hObj@int32(value);


            hClass=metaclass(hObj);
            className=class(hObj);

            if isempty(ClassBeingLoaded)

                assert(isempty(LoadedValues));
                assert(isempty(NumEnumerations));
                assert(isempty(PreserveDups));


                nEnums=length(hClass.EnumerationMemberList);
                if(nEnums==0)
                    DAStudio.error('Simulink:utility:IntEnumTypeNoEnums',className);
                end



                ClassBeingLoaded=className;
                LoadedValues=real(value);
                NumEnumerations=nEnums;
                if isdeployed

                    PreserveDups=0;
                else
                    try
                        PreserveDups=slfeature('PreserveEnumsWithDuplicateValues');
                    catch ME


                        assert(strcmpi(ME.identifier,'MATLAB:UndefinedFunction'));
                        PreserveDups=0;
                    end
                end
                assert(~isempty(PreserveDups));
            else

                assert(isequal(className,ClassBeingLoaded));
                assert(~isempty(LoadedValues));
                assert(length(LoadedValues)<NumEnumerations);
                assert(~isempty(PreserveDups));


                LoadedValues=[LoadedValues,real(value)];
            end


            if(length(LoadedValues)==NumEnumerations)
                ClassBeingLoaded='';
                LoadedValues=[];
                NumEnumerations=[];
                PreserveDups=[];
            end
        end
    end


    methods(Sealed)

        function result=double(this)
            result=double(real(this));
        end

        function result=single(this)
            result=single(real(this));
        end

        function result=int64(this)
            result=int64(real(this));
        end

        function result=int32(this)
            result=int32(real(this));
        end

        function result=int16(this)
            result=int16(real(this));
        end

        function result=int8(this)
            result=int8(real(this));
        end

        function result=uint64(this)
            result=uint64(real(this));
        end

        function result=uint32(this)
            result=uint32(real(this));
        end

        function result=uint16(this)
            result=uint16(real(this));
        end

        function result=uint8(this)
            result=uint8(real(this));
        end

        function result=logical(this)
            result=logical(real(this));
        end

        function result=sparse(varargin)
            if(nargin==1)
                result=sparse@int32(varargin{:});
            else
                varargin=l_real(varargin);
                result=sparse(varargin{:});
            end
        end


        function result=abs(this)
            result=abs(real(this));
        end

        function result=bitcmp(varargin)
            varargin=l_real(varargin);
            result=bitcmp(varargin{:});
        end

        function result=ceil(this)
            result=ceil(real(this));
        end

        function result=cell(this)
            result=cell(real(this));
        end

        function result=complex(this,other)
            if(nargin==2)
                result=complex(l_real(this),l_real(other));
            else
                result=complex(real(this));
            end
        end

        function result=conj(this)
            result=conj(real(this));
        end

        function result=cummax(varargin)
            varargin=l_real(varargin);
            result=cummax(varargin{:});
        end

        function result=cummin(varargin)
            varargin=l_real(varargin);
            result=cummin(varargin{:});
        end

        function result=cumprod(varargin)
            varargin=l_real(varargin);
            result=cumprod(varargin{:});
        end

        function result=cumsum(varargin)
            varargin=l_real(varargin);
            result=cumsum(varargin{:});
        end

        function result=diag(varargin)
            varargin=l_real(varargin);
            result=diag(varargin{:});
        end

        function result=diff(varargin)
            varargin=l_real(varargin);
            result=diff(varargin{:});
        end

        function result=fix(this)
            result=fix(real(this));
        end

        function result=floor(this)
            result=floor(real(this));
        end

        function result=full(this)
            result=full(real(this));
        end

        function result=imag(this)
            result=imag(real(this));
        end

        function result=isreal(this)%#ok
            result=true;
        end

        function result=issorted(varargin)
            varargin=l_real(varargin);
            result=issorted(varargin{:});
        end

        function result=issortedrows(varargin)
            varargin=l_real(varargin);
            result=issortedrows(varargin{:});
        end

        function result=max(varargin)
            varargin=l_real(varargin);
            result=max(varargin{:});
        end

        function varargout=maxk(varargin)
            varargin=l_real(varargin);
            [varargout{1:nargout}]=maxk(varargin{:});
        end

        function result=min(varargin)
            varargin=l_real(varargin);
            result=min(varargin{:});
        end

        function varargout=mink(varargin)
            varargin=l_real(varargin);
            [varargout{1:nargout}]=mink(varargin{:});
        end

        function result=nonzeros(this)
            result=nonzeros(real(this));
        end

        function result=not(this)
            result=not(real(this));
        end

        function result=prod(varargin)
            varargin=l_real(varargin);
            result=prod(varargin{:});
        end

        function result=round(varargin)
            varargin=l_real(varargin);
            result=round(varargin{:});
        end

        function result=sign(this)
            result=sign(real(this));
        end

        function result=sum(varargin)
            varargin=l_real(varargin);
            result=sum(varargin{:});
        end










        function result=tril(varargin)
            varargin=l_real(varargin);
            result=tril(varargin{:});
        end

        function result=triu(varargin)
            varargin=l_real(varargin);
            result=triu(varargin{:});
        end

        function result=uminus(this)
            result=uminus(real(this));
        end

        function result=uplus(this)
            result=uplus(real(this));
        end


        function result=all(varargin)
            varargin=l_real(varargin);
            result=all(varargin{:});
        end

        function result=and(this,other)
            result=and(l_real(this),l_real(other));
        end

        function result=any(varargin)
            varargin=l_real(varargin);
            result=any(varargin{:});
        end

        function result=bitand(varargin)
            varargin=l_real(varargin);
            result=bitand(varargin{:});
        end

        function result=bitor(varargin)
            varargin=l_real(varargin);
            result=bitor(varargin{:});
        end

        function result=bitxor(varargin)
            varargin=l_real(varargin);
            result=bitxor(varargin{:});
        end

        function result=eq(varargin)
            if(nargin~=2)

                txt=DAStudio.message('MATLAB:class:UndefinedMethod','eq',class(varargin{1}));
                error('MATLAB:UndefinedFunction',txt);
            end


            varargin=l_cast2string_if_needed(varargin);

            varargin=l_real(varargin);
            result=eq(varargin{:});
        end

        function result=find(varargin)
            varargin=l_real(varargin);
            result=find(varargin{:});
        end

        function result=ge(this,other)
            result=ge(l_real(this),l_real(other));
        end

        function result=gt(this,other)
            result=gt(l_real(this),l_real(other));
        end

        function result=isequal(varargin)
            varargin=l_real(varargin);
            result=isequal(varargin{:});
        end

        function result=isequaln(varargin)
            varargin=l_real(varargin);
            result=isequaln(varargin{:});
        end

        function result=isequalwithequalnans(varargin)
            result=isequaln(varargin{:});
        end

        function result=lt(this,other)
            result=lt(l_real(this),l_real(other));
        end

        function result=le(this,other)
            result=le(l_real(this),l_real(other));
        end

        function result=ne(varargin)
            if(nargin~=2)

                txt=DAStudio.message('MATLAB:class:UndefinedMethod','ne',class(varargin{1}));
                error('MATLAB:UndefinedFunction',txt);
            end


            varargin=l_cast2string_if_needed(varargin);

            varargin=l_real(varargin);
            result=ne(varargin{:});
        end

        function result=or(this,other)
            result=or(l_real(this),l_real(other));
        end

        function result=xor(this,other)
            result=xor(l_real(this),l_real(other));
        end


        function result=accumarray(varargin)
            varargin=l_real(varargin);
            result=accumarray(varargin{:});
        end

        function result=conv2(varargin)
            varargin=l_real(varargin);
            result=conv2(varargin{:});
        end

        function result=fft(varargin)
            varargin=l_real(varargin);
            result=fft(varargin{:});
        end

        function result=fftn(varargin)
            varargin=l_real(varargin);
            result=fftn(varargin{:});
        end

        function varargout=filter(varargin)
            varargin=l_real(varargin);
            [varargout{1:nargout}]=filter(varargin{:});
        end

        function result=ifft(varargin)
            varargin=l_real(varargin);
            result=ifft(varargin{:});
        end

        function result=ifftn(varargin)
            varargin=l_real(varargin);
            result=ifftn(varargin{:});
        end

        function result=ldivide(this,other)
            result=ldivide(l_real(this),l_real(other));
        end

        function result=mldivide(this,other)
            result=mldivide(l_real(this),l_real(other));
        end

        function result=mrdivide(this,other)
            result=mrdivide(l_real(this),l_real(other));
        end

        function result=minus(this,other)
            result=minus(l_real(this),l_real(other));
        end

        function result=mod(this,other)
            result=mod(l_real(this),l_real(other));
        end

        function result=mtimes(this,other)
            result=mtimes(l_real(this),l_real(other));
        end

        function result=norm(varargin)
            varargin=l_real(varargin);
            result=norm(varargin{:});
        end

        function result=plus(this,other)
            result=plus(l_real(this),l_real(other));
        end

        function result=power(this,other)
            result=power(l_real(this),l_real(other));
        end

        function result=rdivide(this,other)
            result=rdivide(l_real(this),l_real(other));
        end

        function result=rem(this,other)
            result=rem(l_real(this),l_real(other));
        end

        function result=times(this,other)
            result=times(l_real(this),l_real(other));
        end


        function result=bitget(varargin)
            varargin=l_real(varargin);
            result=bitget(varargin{:});
        end

        function result=bitset(varargin)
            varargin=l_real(varargin);
            result=bitset(varargin{:});
        end

        function result=bitshift(varargin)
            varargin=l_real(varargin);
            result=bitshift(varargin{:});
        end

        function result=bsxfun(fcn,val1,val2)
            val1=l_real(val1);
            val2=l_real(val2);
            if isa(fcn,'Simulink.IntEnumType')

                result=bsxfun@int32(fcn,val1,val2);
            else
                result=bsxfun(fcn,val1,val2);
            end
        end


        function result=cat(dim,varargin)
            if isa(dim,'Simulink.IntEnumType')

                result=cat(real(dim),varargin{:});
            else
                if(slfeature('PreserveEnumsWithDuplicateValues')>0)

                    for idx=1:nargin-1
                        if(isnumeric(varargin{idx})&&~isreal(varargin{idx}))

                            for idx2=1:nargin-1
                                if isa(varargin{idx2},'Simulink.IntEnumType')
                                    className=class(varargin{idx2});
                                    break;
                                end
                            end
                            DAStudio.error('MATLAB:class:InvalidEnum',className);
                        end
                    end
                end


                result=cat@int32(dim,varargin{:});
            end
        end

        function result=circshift(this,varargin)
            varargin=l_real(varargin);
            if isa(this,'Simulink.IntEnumType')

                result=circshift@int32(this,varargin{:});
            else
                result=circshift(this,varargin{:});
            end
        end

        function result=ctranspose(this)
            result=transpose(this);
        end

        function result=flip(this,varargin)
            varargin=l_real(varargin);
            if isa(this,'Simulink.IntEnumType')

                result=flip@int32(this,varargin{:});
            else
                result=flip(this,varargin{:});
            end
        end

        function result=horzcat(varargin)
            result=cat(2,varargin{:});
        end

        function result=permute(this,order)
            if isa(order,'Simulink.IntEnumType')
                result=permute(this,real(order));
            else

                result=permute@int32(this,order);
            end
        end

        function result=repelem(this,varargin)
            varargin=l_real(varargin);
            if isa(this,'Simulink.IntEnumType')

                result=repelem@int32(this,varargin{:});
            else
                result=repelem(this,varargin{:});
            end
        end

        function result=repmat(this,varargin)
            varargin=l_real(varargin);
            if isa(this,'Simulink.IntEnumType')

                result=repmat@int32(this,varargin{:});
            else
                result=repmat(this,varargin{:});
            end
        end

        function result=reshape(this,varargin)
            varargin=l_real(varargin);
            if isa(this,'Simulink.IntEnumType')

                result=reshape@int32(this,varargin{:});
            else
                result=reshape(this,varargin{:});
            end
        end

        function varargout=size(varargin)
            varargin=l_real(varargin);
            [varargout{1:nargout}]=size(varargin{:});
        end

        function varargout=sort(this,varargin)

            if(nargout>2)
                DAStudio.error('MATLAB:maxlhs');
            end


            varargin=l_real(varargin);

            if l_isEnumWithComplexUnderlyingValue(this)

                if~ismatrix(this)
                    DAStudio.error('Simulink:DataType:EnumType_InvalidValueForSort');
                end


                [~,indices]=sort(l_real(this),varargin{:});

                if(nargin==1)
                    if isrow(this)
                        dim=2;
                    else
                        dim=1;
                    end
                else
                    dim=varargin{1};
                end


                result=this;
                if(dim==1)
                    for idx=1:size(result,2)
                        result(:,idx)=result(indices(:,idx),idx);
                    end
                elseif(dim==2)
                    for idx=1:size(result,1)
                        result(idx,:)=result(idx,indices(idx,:));
                    end
                end

                varargout={result,indices};
            elseif isa(this,'Simulink.IntEnumType')

                [varargout{1:2}]=sort@int32(this,varargin{:});
            else

                [varargout{1:2}]=sort(this,varargin{:});
            end
        end

        function result=sortrowsc(varargin)
            varargin=l_real(varargin);
            result=sortrowsc(varargin{:});
        end

        function result=subsindex(this,varargin)

            if l_isEnumWithComplexUnderlyingValue(this)
                this=feval(class(this),real(this));
            end
            result=subsindex@int32(this,varargin{:});
        end

        function result=vertcat(varargin)
            result=cat(1,varargin{:});
        end


        function result=plot(varargin)
            varargin=l_real(varargin);
            result=plot(varargin{:});
        end
    end
end


function result=l_isEnumWithComplexUnderlyingValue(this)
    if isa(this,'Simulink.IntEnumType')
        result=~builtin('isreal',this);
    else
        result=false;
    end
end

function obj=l_real(obj)
    if isa(obj,'Simulink.IntEnumType')
        obj=real(obj);
    elseif iscell(obj)
        for idx=1:numel(obj)
            obj{idx}=l_real(obj{idx});
        end
    end
end

function result=l_isString(obj)
    result=ischar(obj)||isstring(obj)||iscellstr(obj);
end

function args=l_cast2string_if_needed(args)
    if l_isString(args{2})

        args{1}=string(args{1});
    elseif(isa(args{2},'Simulink.IntEnumType')&&l_isString(args{1}))

        args{2}=string(args{2});
    end
end


