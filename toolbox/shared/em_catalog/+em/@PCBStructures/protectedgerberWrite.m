function[A,g]=protectedgerberWrite(obj,varargin)













































    nargoutchk(0,2);


    if~any(strcmpi(class(obj),{'pcbStack','pcbComponent'}))
        error(message('antenna:antennaerrors:PcbStackNotSpecified'));
    end


    if~isDielectricSubstrate(obj)
        error(message('antenna:antennaerrors:SubstrateNotSpecified'));
    end

    isPVPair=false;

    if nargin>1
        isVarInputsObj=cellfun(@(x)isobject(x),varargin);
        if~all(isVarInputsObj)

            if nargin==3
                if iscell(varargin{2})
                    isPVPair=false;
                end
            else
                isPVPair=true;
            end
        end
    end

    if isPVPair
        parserObj=inputParser;
        addParameter(parserObj,'Connector',[]);
        addParameter(parserObj,'Service','Writer');
        parse(parserObj,varargin{:});
        connector=parserObj.Results.Connector;
        service=parserObj.Results.Service;

        if strcmpi(parserObj.UsingDefaults,'Service')
            service=feval(strcat('Gerber',service));
        else
            try
                service=feval(strcat('PCBServices.',service));
            catch
                error(message('antenna:antennaerrors:UnsupportedPCBService'));
            end
        end

        if~isempty(connector)
            try
                connector=feval(strcat('PCBConnectors.',connector));
            catch
                error(message('antenna:antennaerrors:UnsupportedRFConnector'));
            end
        end
    else
        numObjs=numel(varargin);
        if numObjs==0
            service=feval('Gerber.Writer');
            connector=[];
        elseif numObjs==1
            if isa(varargin{1},'Gerber.Writer')
                service=varargin{1};
                connector=[];
            else
                service=Gerber.Writer;
                connector=varargin{1};
            end
        else
            if isa(varargin{1},'Gerber.Writer')
                service=varargin{1};
                connector=varargin{2};
            else
                service=varargin{2};
                connector=varargin{1};
            end
        end
    end

    createGeometry(obj);
    G=exportGeometry(obj);

    if isa(obj,'pcbComponent')&&numel(G.Layers)>2
        error(message('rfpcb:rfpcberrors:Unsupported','More than 2 layers of metal','generating gerber files'))
    end
    if isa(obj,'pcbStack')&&numel(G.Layers)>2
        error(message('antenna:antennaerrors:Unsupported','More than 2 layers of metal','generating gerber files'))
    end
    A=PCBWriter(G,service,connector);
    if~isempty(A.Writer)
        PostWriteFunction=A.Writer.PostWriteFcn;
    end
    update(A);

    A.Writer.PostWriteFcn=[];

    write(A.Writer);
    g=getFullyQualifiedFolder(A.Writer);
    A.Writer.PostWriteFcn=PostWriteFunction;

end