function init(this,varargin)










































































    if rem(length(varargin),2)
        error(message('hdlcoder:validate:invalidargs',class(this)));
    end

    block=localExtractPVPairs(this,varargin);

    if isempty(block)&&isempty(this.Blocks)
        error(message('hdlcoder:validate:nosupportedblock',class(this)));
    end





    if~isempty(block)
        if~isempty(this.Blocks)
            index=strcmp(block,this.Blocks);
            if~any(index)
                error(message('hdlcoder:validate:unsupportedblock',class(this),block));
            end
        end
        if iscell(block)
            this.Blocks=block;
        else
            this.Blocks={block};
        end
    end
end


function block=localExtractPVPairs(this,args)
    block=[];

    for i=1:2:length(args)
        switch lower(args{i})
        case 'supportedblocks'
            blocks=regexprep(args{i+1},newline,' ');
            this.Blocks=cellify(blocks);
        case 'block'
            block=regexprep(args{i+1},newline,' ');
        case 'codegenmode'
            this.CodeGenMode=args{i+1};
        case 'codegenfunc'
            this.CodeGenFunction=args{i+1};
        case 'handletype'
            this.FirstParam=args{i+1};
        case 'codegenparams'
            this.CodeGenParams=args{i+1};
        case 'description'
            this.Description=args{i+1};
        case 'generateslblock'
            this.generateSLBlock=args{i+1};
        case 'architecturenames'
            names=args{i+1};
            this.ArchitectureNames=cellify(names);
        case 'deprecatedarchname'
            name=args{i+1};
            this.DeprecatedArchName=cellify(name);
        case 'deprecates'
            archNames=args{i+1};
            this.Deprecates=cellify(archNames);
        case 'hidden'
            this.Hidden=args{i+1};
        end
    end

    if isempty(this.Description)
        this.Description.ShortListing=class(this);
        switch this.CodeGenMode
        case 'emission'
            this.Description.HelpText='HDL code generation via inline emission';
        case 'instantiation'
            this.Description.HelpText='HDL code generation via component instantiation';
        end
    end
end

function c=cellify(arg)

    if iscell(arg)
        c=arg;
    else
        c={arg};
    end
end


