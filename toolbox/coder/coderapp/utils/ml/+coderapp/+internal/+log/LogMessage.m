classdef(Sealed)LogMessage
    properties
        Text(1,:)char
        Level(1,1)uint8=coderapp.internal.log.LogLevel.Info
        Caller struct{mustBeScalarOrEmpty(Caller)}
        Data struct{mustBeScalarOrEmpty(Data)}
        SourceId(1,:)char
        SourceLabel(1,:)char
        ScopeId(1,:)char
        Time(1,1)datetime
    end

    properties(Dependent,SetAccess=immutable)
        IsScope(1,1)logical
        CallerName char
        CallerFile char
        CallerLine(1,1)uint32
    end

    methods
        function isScope=get.IsScope(this)
            isScope=~isempty(this.ScopeId);
        end

        function name=get.CallerName(this)
            if~isempty(this.Caller)
                name=this.Caller.name;
            else
                name='';
            end
        end

        function file=get.CallerFile(this)
            if~isempty(this.Caller)
                file=this.Caller.file;
            else
                file='';
            end
        end

        function name=get.CallerLine(this)
            if~isempty(this.Caller)
                name=this.Caller.line;
            else
                name=0;
            end
        end
    end
end