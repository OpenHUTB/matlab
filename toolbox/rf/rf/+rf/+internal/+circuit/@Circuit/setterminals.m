function setterminals(obj,tnodes,varargin)


    if~isempty(obj.Terminals)

        error(message('rf:rfcircuit:circuit:setterminals:AlreadySet'))
    else
        if~isempty(obj.Parent)

            error(message('rf:rfcircuit:circuit:setterminals:AlreadyInCircuit',obj.Name,obj.Parent.Name))
        end
    end


    validateattributes(tnodes,{'numeric'},{'integer','vector','nonnegative'},'setterminals','Nodes')
    checkNodesAreInCircuit(obj,tnodes)
    numnodes=numel(tnodes);

    switch nargin
    case 2

        termnames=cell(1,numnodes);
        for n=1:numnodes
            termnames{n}=sprintf('t%d',n);
        end
    case 3

        termnames=varargin{1};
        rf.internal.circuit.Element.validateCellNameList(termnames,'Terminal');
        for k=1:numel(termnames)
            termnames{k}=convertStringsToChars(termnames{k});
        end
        if numel(termnames)~=numnodes

            error(message('rf:rfcircuit:circuit:add:MismatchNumNodesUserTerminals'))

        end
    end

    obj.TerminalNodes=tnodes(:).';
    obj.Terminals=termnames;