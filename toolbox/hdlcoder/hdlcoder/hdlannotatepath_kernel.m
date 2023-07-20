

function out=hdlannotatepath_kernel(varargin)

















































    persistent baDriver;

    if nargin==0
        error(message('hdlcoder:makehdl:NoArgument'));
    end
    i=0;
    if strcmpi(varargin{1},'model')
        modelName=varargin{2};
        i=2;
    else
        if~isempty(baDriver)
            modelName=baDriver.getModelName;
        else
            modelName='';
        end
    end



    if strcmp(varargin{i+1},'reset')...
        ||strcmp(varargin{i+1},'printOriginalCP')...
        ||strcmp(varargin{i+1},'printAbstractCP')...
        ||strcmp(varargin{i+1},'printColoredObjects')
        if isempty(baDriver)
            error(message('hdlcoder:makehdl:InvalidArgumentBA'));
        end
        out=baDriver.annotatePath(varargin{i+1});
        return;
    end

    if isempty(modelName)
        error(message('hdlcoder:makehdl:modelnotready'));
    end

    hdriver=hdlmodeldriver(modelName);
    hCLI=hdriver.getCLI;
    if~strcmp(hCLI.Backannotation,'on')

        error(message('hdlcoder:makehdl:FeaturedOff'));
    end

    if nargin>1
        if nargin>=i+2&&strcmpi(varargin{i+2},'externalparser')
            baDriver=BA.Main.baDriver(modelName,'externalParser',varargin{i+2:end});
        end

        if mod(nargin,2)==0

            baDriver=BA.Main.baDriver(modelName,varargin{i+2:end});
        else
            if nargin>=i+2

                baDriver.setparameters(varargin{i+2:end});
            end
        end
    end

    if isempty(baDriver)
        error(message('hdlcoder:makehdl:InvalidArgument'));
    end

    p=pir;
    rootNode=p.getTopNetwork.Name;
    if~isempty(rootNode)&&~strcmp(rootNode,baDriver.getRootNode)
        error(message('hdlcoder:makehdl:ModelHasChanged'));
    end

    out=baDriver.annotatePath(str2double(varargin{i+1}));
end



