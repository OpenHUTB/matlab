classdef(Hidden)FilterInputParser<...
    comparisons.internal.api.ComparisonsInputParser






    properties(Constant,Access=private)
        FilterDefinition='FilterDefinition';
    end

    properties(Access=private)
        SupportedFilters;
        Parser;
    end

    methods(Access=public)

        function obj=FilterInputParser(supportedFilters)
            obj.Parser=obj.createInputParser();
            obj.SupportedFilters=supportedFilters;
        end

        function name=parse(this,varargin)
            this.Parser.parse(varargin{:});
            name=this.getNameFromResults(this.Parser.Results);
            name=this.validateFilterDefinition(name);
        end

    end

    methods(Access=private)

        function parser=createInputParser(this)
            parser=inputParser();
            parser.addRequired(...
            this.FilterDefinition,...
            @(x)this.validateStringArgument(x,this.FilterDefinition)...
            );
        end

        function name=getNameFromResults(this,results)
            name=results.(this.FilterDefinition);

            if isa(name,'string')
                name=char(name);
            end
        end

        function name=validateFilterDefinition(this,name)
            name=validatestring(name,this.SupportedFilters);
        end

    end

end