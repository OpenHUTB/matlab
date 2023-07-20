classdef(Hidden)PublishInputParser<...
    comparisons.internal.api.ComparisonsInputParser






    properties(Constant,Access=private)
        SupportedFormats={'html','docx','pdf'};
        DefaultFormat='html';

        Format='Format';
        Name='Name';
        OutputFolder='OutputFolder';
    end

    properties(Access=private)
        DefaultOutputFolder;
        Parser;
        JavaDriver;
    end

    methods(Access=public)

        function obj=PublishInputParser(javaDriver)
            obj.JavaDriver=javaDriver;
            obj.DefaultOutputFolder=pwd;
            obj.Parser=obj.createInputParser();
        end

        function options=parse(this,varargin)
            if(nargin==2&&~isa(varargin{1},'struct'))
                varargin={this.Format,varargin{1}};
            end
            this.Parser.parse(varargin{:});
            options=this.convertOptionValuesToChar(this.Parser.Results);
            options=this.validateOptions(options);
        end

    end

    methods(Access=private)

        function parser=createInputParser(this)
            parser=inputParser();
            parser.addParameter(...
            this.Format,...
            this.DefaultFormat,...
            @(x)this.validateStringArgument(x,this.Format)...
            );
            parser.addParameter(...
            this.Name,...
            this.getDefaultName(),...
            @(x)this.validateStringArgument(x,this.Name)...
            );
            parser.addParameter(...
            this.OutputFolder,...
            this.DefaultOutputFolder,...
            @(x)this.validateStringArgument(x,this.OutputFolder)...
            );
        end

        function name=getDefaultName(this)
            left=this.getSourceName(this.JavaDriver.getLeftSource());
            right=this.getSourceName(this.JavaDriver.getRightSource());
            name=strcat(left,'_',right);
        end

        function name=getSourceName(~,source)
            import comparisons.internal.util.APIUtils;
            nameProperty=APIUtils.getSourceName(source);
            [~,name]=slfileparts(nameProperty);
        end

        function options=convertOptionValuesToChar(~,options)
            options.Format=char(options.Format);
            options.Name=char(options.Name);
            options.OutputFolder=char(options.OutputFolder);
        end

        function options=validateOptions(this,options)
            [pathname,options.Name,extension]=slfileparts(options.Name);
            options.OutputFolder=fullfile(options.OutputFolder,pathname);
            options.Format=this.validateFormat(options,extension);
            options.Name=this.validateName(options);
        end

        function format=validateFormat(this,options,extension)
            requested=this.retrieveFormat(options,extension);
            format=validatestring(requested,this.SupportedFormats);
        end

        function format=retrieveFormat(~,options,extension)
            if isempty(extension)
                format=options.Format;
                return;
            end

            parts=strsplit(extension,'.');
            format=parts{end};
        end

        function name=validateName(~,options)
            parts=strsplit(options.Name,'.');
            if strcmp(parts{end},options.Format)
                name=options.Name;
                return;
            end

            name=strcat(options.Name,'.',options.Format);
        end

    end

end

