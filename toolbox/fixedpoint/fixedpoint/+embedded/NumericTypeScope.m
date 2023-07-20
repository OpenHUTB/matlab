classdef(StrictDefaults)NumericTypeScope<matlabshared.scopes.UnifiedSystemScope


























































































































    properties(Nontunable)
        Name='NumericTypeScope';
    end


    properties(Access=private)

        InputNeedsValidation=false;
    end

    methods
        function obj=NumericTypeScope
            obj@matlabshared.scopes.UnifiedSystemScope();
        end
    end

    methods(Access=protected)
        function setScopeName(obj,value)
            validateattributes(value,...
            {'char'},{'nonsparse'},'','Name');
            if isScopeLaunched(obj)

                obj.pSource.Name=value;
            end
        end

        function validateInputsImpl(obj,varargin)
            try
                checkInputDataType(obj,varargin{:});
            catch e
                [msg,id]=uiservices.cleanErrorMessage(e);
                error(id,msg);
            end
        end

        function checkInputDataType(~,varargin)
            if nargin>1
                mdata=varargin{1};
                if issparse(mdata)
                    dt='sparse';
                else
                    dt=class(mdata);
                end
            else
                mdata=ones(1);
                dt=class(mdata);
            end


            if strcmp(dt,'embedded.fi')
                nt=mdata.numerictype;
                x=fi(mdata,nt);
            else
                x=feval(dt,mdata);
            end


            if~isempty(x)
                if~isnumeric(x)
                    error(message('fixed:NumericTypeScope:incorrectInputType'));
                elseif all(isinf(x(:)))||all(isnan(x(:)))||issparse(x)
                    error(message('fixed:NumericTypeScope:invalidData'));
                end
            end
        end


        function updateImpl(obj,data)

            if~isa(obj.pFramework,'matlabshared.scopes.UnifiedScope')
                launchScope(obj);
            end

            if(obj.InputNeedsValidation)
                obj.checkInputDataType(data);
                obj.InputNeedsValidation=false;
                if~obj.HideCalled
                    show(obj);
                end
            end

            if isempty(obj.pSource.Name)
                argNames={inputname(1),inputname(2)};

                srcName=uiservices.cacheFcnArgNames(argNames,'-fullpath');
                obj.pSource.Name=srcName{2};

                idx=strfind(srcName{2},':');
                if isempty(idx)
                    obj.pSource.NameShort=srcName{2};
                else
                    obj.pSource.NameShort=srcName{2}(idx(end)+1:end);
                end


                updateTitleBar(obj.pFramework);
                notify(obj.pFramework,'SourceNameChanged');
            end
            update(obj.pSource,data);
        end

        function resetImpl(obj)

            resetImpl@matlabshared.scopes.UnifiedSystemScope(obj);


            obj.pSource.Name='';
            obj.pSource.NameShort='';
            obj.InputNeedsValidation=true;
        end

        function hScopeCfg=getScopeCfg(~)
            hScopeCfg=embedded.NumericTypeScopeComponentCfg;
        end
    end

    methods(Hidden)
        function name=getSystemObjectScopeName(obj)%#ok
            name='NumericTypeScope';
        end
    end
end


