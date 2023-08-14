function customError(varargin)





    narginchk(1,intmax);
    persistent ip;
    if isempty(ip)
        ip=inputParser();
        ip.addParameter('Namespace','CoderApp',@ischar);
        ip.addParameter('StackOffset',1,@isnumeric);
    end
    ip.parse(varargin{2:end});
    opts=ip.Results;
    mainArg=varargin{1};

    msgStruct.identifier='';
    if isa(mainArg,'MException')
        msgStruct.identifier=mainArg.identifier;
        msgStruct.message=mainArg.message;
    elseif isstruct(mainArg)
        msgStruct.message=mainArg.message;
        if isfield(msgStruct,'identifier')
            msgStruct.identifier=mainArg.identifier;
        end
    elseif isa(mainArg,'message')
        msgStruct.message=mainArg.getString();
        if~isempty(mainArg.Identifier)
            msgStruct.identifier=mainArg.Identifier;
        end
    elseif iscell(mainArg)
        msgStruct.message=getString(message(mainArg{:}));
    else
        validateattributes(mainArg,{'char','string'},{'scalartext'});
        msgStruct.message=mainArg;
    end

    if isinf(opts.StackOffset)
        msgStruct.stack=[];
    else
        msgStruct.stack=dbstack('-completenames',opts.StackOffset);
    end

    if~isempty(opts.Namespace)
        if~isempty(msgStruct.identifier)
            msgStruct.identifier=[opts.Namespace,':',msgStruct.identifier];
        else
            msgStruct.identifier=[opts.Namespace,':Generic'];
        end
    end

    error(msgStruct);
end