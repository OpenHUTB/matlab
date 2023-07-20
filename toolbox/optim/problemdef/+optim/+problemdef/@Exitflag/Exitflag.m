classdef Exitflag<double&matlab.mixin.CustomDisplay









    properties(Hidden,Access=private)
ExitflagImpl
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagVersion=1;
    end

    methods(Hidden)

        function obj=Exitflag(eflag,solver,problemType)














            obj=obj@double(eflag);
            if nargin==2
                obj.ExitflagImpl=solver;
            else
                vals=double(eflag);
                solver=string(solver);
                problemType=string(problemType);
                nElem=numel(vals);
                exout=cell(nElem,1);
                for i=1:nElem
                    exout{i}=optim.internal.problemdef.exitflag.createExitflagImpl(...
                    vals(i),solver(i),problemType(i));
                end
                obj.ExitflagImpl=reshape(exout,size(vals));
            end
        end



        function out=char(obj)
            out=char(string(obj));
        end

        function out=cellstr(obj)
            out=cellstr(string(obj));
        end




        function str=string(obj)
            val=double(obj);
            if~isempty(obj.ExitflagImpl)
                str=strings(size(val));
                for i=1:numel(val)
                    str(i)=obj.ExitflagImpl{i}.DisplayName(val(i)+obj.ExitflagImpl{i}.Offset);
                end
            else
                str=string(val);
            end
        end






        function out=subsasgn(obj,S,B)
            if isempty(obj)


                obj=optim.problemdef.Exitflag(NaN,...
                {optim.internal.problemdef.exitflag.ExitflagUndefinedImpl});
            end

            deleting=isnumeric(B)&&builtin('_isEmptySqrBrktLiteral',B);
            if deleting
                vals=subsasgn(double(obj),S,B);
                eflagImpls=subsasgn(obj.ExitflagImpl,S,...
                {optim.internal.problemdef.exitflag.ExitflagUndefinedImpl});
            else
                [Bflags,BflagImpls]=getProperties(B);

                vals=subsasgn(double(obj),S,Bflags);
                eflagImpls=subsasgn(obj.ExitflagImpl,S,BflagImpls);


                emptyIdx=cellfun(@isempty,eflagImpls);
                if any(emptyIdx)
                    vals(emptyIdx)=NaN;
                    eflagImpls(emptyIdx)={optim.internal.problemdef.exitflag.ExitflagUndefinedImpl};
                end
            end
            out=optim.problemdef.Exitflag(vals,eflagImpls);
        end

        function out=subsref(obj,S)

            vals=subsref(double(obj),S);
            eflagImpls=subsref(obj.ExitflagImpl,S);
            out=optim.problemdef.Exitflag(vals,eflagImpls);
        end

        function out=cat(dim,varargin)

            [argsVal,argsImpl]=cellfun(@(flag)getProperties(flag),varargin,'UniformOutput',false);
            out=optim.problemdef.Exitflag(cat(dim,argsVal{:}),cat(dim,argsImpl{:}));
        end

        function out=horzcat(varargin)
            out=cat(2,varargin{:});
        end

        function out=vertcat(varargin)
            out=cat(1,varargin{:});
        end

        function out=reshape(obj,varargin)

            vals=reshape(double(obj),varargin{:});
            eflagImpls=reshape(obj.ExitflagImpl,varargin{:});
            out=optim.problemdef.Exitflag(vals,eflagImpls);
        end

        function out=transpose(obj)

            vals=transpose(double(obj));
            eflagImpls=transpose(obj.ExitflagImpl);
            out=optim.problemdef.Exitflag(vals,eflagImpls);
        end

        function out=ctranspose(obj)

            out=transpose(obj);
        end

        function out=permute(obj,order)

            vals=permute(double(obj),order);
            eflagImpls=permute(obj.ExitflagImpl,order);
            out=optim.problemdef.Exitflag(vals,eflagImpls);
        end

        function out=flip(obj,varargin)


            out=matlab.internal.builtinhelper.flip(obj,varargin{:});
        end

        function out=repmat(obj,varargin)


            out=matlab.internal.builtinhelper.repmat(obj,varargin{:});
        end

        function out=circshift(obj,p,varargin)


            out=matlab.internal.builtinhelper.circshift(obj,p,varargin{:});
        end

        function out=repelem(obj,varargin)


            out=matlab.internal.builtinhelper.repelem(obj,varargin{:});
        end
    end

    methods(Hidden,Access=protected)



        function displayScalarObject(obj)

            body=string(obj);
            disp("    "+body+newline);
        end

        function displayNonScalarObject(obj)

            body=string(obj);%#ok<NASGU>
            dispStr=evalc('disp(body)');
            dispStr=strrep(dispStr,'"','');

            dispStr(end)=[];
            disp(dispStr);
        end

    end

    methods(Hidden,Static)
        exout=loadobj(exin);
    end
end



function[flag,flagImpl]=getProperties(input)
    if isa(input,'optim.problemdef.Exitflag')
        flag=double(input);
        flagImpl=input.ExitflagImpl;
    else
        flag=double(input);

        nElem=numel(flag);
        flagImpl=cell(nElem,1);
        for i=1:nElem
            flagImpl{i}=optim.internal.problemdef.exitflag.createExitflagImpl(...
            flag(i),'unknown','unknown');
        end
        flagImpl=reshape(flagImpl,size(flag));
    end
end