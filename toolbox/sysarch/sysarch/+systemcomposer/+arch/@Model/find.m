function[varargout]=find(this,varargin)
































    if nargin<2
        error('MATLAB:narginchk:notEnoughInputs',...
        message('MATLAB:narginchk:notEnoughInputs').getString);
    end

    nargoutchk(0,2);

    constraint=varargin{1};
    if(~isa(constraint,'systemcomposer.query.Constraint'))
        error('systemcomposer:API:FindConstraintInvalidInput',...
        message('SystemArchitecture:API:FindConstraintInvalidInput').getString);
    end

    recurseOpt=true;
    flattenRefsOpt=false;
    rootArch=this.Architecture;
    elemKind='Component';
    if(nargin>2)

        startIdx=2;
        if(isa(varargin{2},'systemcomposer.arch.Architecture'))
            rootArch=varargin{2};
            startIdx=3;
        elseif(~isstring(varargin{2})&&~ischar(varargin{2}))
            error('systemcomposer:API:FindArchInvalidInput',...
            message('SystemArchitecture:API:FindArchInvalidInput').getString);
        end

        for k=startIdx:2:numel(varargin)
            if strcmp(varargin{k},"Recurse")
                recurseOpt=varargin{k+1};
            elseif strcmp(varargin{k},"IncludeReferenceModels")
                flattenRefsOpt=varargin{k+1};
            elseif strcmp(varargin{k},"ElementType")
                elemKind=varargin{k+1};
                if(~strcmpi(elemKind,'Component')&&~strcmpi(elemKind,'Port')&&~strcmpi(elemKind,'Connector'))
                    error('systemcomposer:API:FindElemKindInvalidInput',...
                    message('SystemArchitecture:API:FindArchInvalidInput').getString);
                end
            else
                error('systemcomposer:API:FindNVPairInvalid',...
                message('SystemArchitecture:API:FindConstraintInvalidInput').getString);
            end
        end
    end

    runner=systemcomposer.query.internal.QueryRunner(rootArch,constraint,recurseOpt,flattenRefsOpt,elemKind);
    runner.execute;

    if strcmpi(elemKind,'Component')
        varargout{1}=runner.CompPaths';
        if nargout==2
            varargout{2}=runner.Elems;
        end
    else
        varargout{1}=runner.Elems';
    end

end

