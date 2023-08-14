function setports(obj,varargin)


    if~isempty(obj.Terminals)

        error(message('rf:rfcircuit:circuit:setterminals:AlreadySet'))
    else
        if~isempty(obj.Parent)

            error(message('rf:rfcircuit:circuit:setterminals:AlreadyInCircuit',obj.Name,obj.Parent.Name))
        end
    end



    validateattributes(varargin{1},{'numeric'},{'integer','vector','nonnegative','numel',2},'setports','NodePair',2)


    for n=2:(nargin-2)

        validateattributes(varargin{n},{'numeric'},{'integer','vector','nonnegative','numel',2},'setports','NodePair',n+1)
    end

    if nargin>2

        if iscell(varargin{end})
            for k=1:numel(varargin{end})
                varargin{end}{k}=convertStringsToChars(varargin{end}{k});
            end

            rf.internal.circuit.Element.validateCellNameList(varargin{end},'Port');
            numports=nargin-2;
            portnames=varargin{end};
        elseif isnumeric(varargin{end})


            validateattributes(varargin{end},{'numeric'},{'integer','vector','nonnegative','numel',2},'setports','NodePair',nargin)
        else

            validateattributes(varargin{end},{'numeric','cell'},{'vector'},'setports','',nargin)
        end
    end

    if isnumeric(varargin{end})

        numports=nargin-1;
        portnames=cell(1,numports);
        for n=1:numports
            portnames{n}=sprintf('p%d',n);
        end
    end


    termnames=cell(1,2*numports);
    termnodes=zeros(1,2*numports);
    for n=1:numports
        pos=varargin{n}(1);
        neg=varargin{n}(2);
        termnames{n}=sprintf('%s+',portnames{n});
        termnames{n+numports}=sprintf('%s-',portnames{n});
        termnodes(n)=pos;
        termnodes(n+numports)=neg;
        cktnodes=obj.Nodes;
        if~any(neg==cktnodes)||~any(pos==cktnodes)
            obj.Nodes=unique(horzcat(cktnodes,pos,neg));
        end
    end

    obj.Ports=portnames;
    obj.Terminals=termnames;
    obj.TerminalNodes=termnodes;