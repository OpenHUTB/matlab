classdef(Sealed)ConfigurationSchema



    properties(SetAccess=immutable)
ParamGroups
Params
Productions
Controllers
        ParamGraph digraph

        ValidationErrors cell={}
        ValidationWarnings cell={}
    end

    properties(Dependent,SetAccess=immutable)
        IsValid logical
    end

    methods(Access=?coderapp.internal.config.ConfigurationFactory)
        function this=ConfigurationSchema(raw)
            if nargin==0
                raw=[];
            end
            [result,this.ValidationErrors,this.ValidationWarnings]=this.validate(raw);
            for field=reshape(string(fieldnames(result)),1,[])
                this.(field)=result.(field);
            end
        end
    end

    methods
        function valid=get.IsValid(this)
            valid=isempty(this.ValidationErrors);
        end
    end

    methods(Hidden)
        function assertNoErrors(this)
            if~isempty(this.ValidationErrors)
                error('Invalid schema: \n%s',joinMessages(this.ValidationErrors));
            end
        end

        function verifyNoWarnings(this)
            if~isempty(this.ValidationWarnings)
                warning('Schema validated with warnings: \n%s',joinMessages(this.ValidationWarnings));
            end
        end
    end

    methods(Static)
        function varargout=validate(raw)
            if isempty(raw)
                if nargout>0
                    varargout=cell(0,2);
                end
            else
                [result,errors,warnings]=validateRawSchema(raw);
                if nargout==0
                    this.assertNoErrors();
                    this.verifyNoWarnings();
                else
                    varargout={result,errors,warnings};
                end
            end
        end
    end
end


function str=joinMessages(messages)
    str=strcat({sprintf('\t')},strjoin(messages,newline()));
end