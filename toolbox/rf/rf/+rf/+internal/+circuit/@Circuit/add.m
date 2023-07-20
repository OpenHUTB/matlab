function elem=add(ckt,nodes,elem,varargin)





    if ischar(elem)||isa(elem,'sparameters')
        elem=nport(elem);
    end

    if~isscalar(elem)||iscell(elem)
        validateattributes(elem,{'resistor','capacitor','inductor',...
        'lcladder','nport','circuit'},{'scalar'},'add','Element',3)
    end


    if isa(elem,'rfpcb.PCBComponent')||isa(elem,'rfpcb.internal.rfComponent')
        elem=pcbElement(elem);
    end
    if~isa(elem,'rf.internal.circuit.Element')
        val=[sprintf('%s, ',ckt.ElementTypes{1:end-1}),ckt.ElementTypes{end}];
        error(message('rf:rfcircuit:circuit:add:InvalidElement',class(elem),val))
    end


    if~isempty(elem.Parent)

        error(message('rf:rfcircuit:circuit:add:AlreadyInCircuit',class(elem),elem.Name,ckt.Name,class(elem),elem.Name))
    end


    if isa(elem,'circuit')
        topckt=ckt;
        while~isempty(topckt.Parent)
            topckt=topckt.Parent;
        end
        if topckt==elem

            error(message('rf:rfcircuit:circuit:add:AddToItself'))
        end
    end

    eterms=elem.Terminals;

    if~(isempty(nodes)&&isempty(eterms))

        validateattributes(nodes,{'numeric'},{'nonempty','integer','vector',...
        'nonnegative'},'add','Nodes')
    end


    numnodes=numel(nodes);
    numreq=getNumRequiredTerminals(elem);
    if numnodes<numreq

        error(message('rf:rfcircuit:circuit:add:TooFewNodes',sprintf('%d',numreq)))
    end

    numelemterms=numel(eterms);
    switch nargin
    case 3


        if numnodes>numelemterms

            error(message('rf:rfcircuit:circuit:add:MismatchNumNodesDefTerminals',class(elem),elem.Name))
        end


        elemnodes=zeros(1,numelemterms);
        elemnodes(1:numnodes)=nodes(:).';
    case 4

        interms=varargin{1};
        validateattributes(interms,{'cell'},{'row'},'add','the Terminal List')
        cellfun(@(x)validateattributes(x,{'char','string'},{'row'},'add',...
        'Terminal Name'),interms)
        for k=1:numel(interms)
            interms{k}=convertStringsToChars(interms{k});
        end
        numinterms=numel(interms);

        if numnodes~=numinterms

            error(message('rf:rfcircuit:circuit:add:MismatchNumNodesUserTerminals'))
        end


        if numinterms<numelemterms
            for n=1:numreq
                if~any(strcmp(eterms{n},interms))

                    error(message('rf:rfcircuit:circuit:add:MissingRequiredTerminal',eterms{n}))
                end
            end
        end

        elemnodes=zeros(1,numelemterms);
        for n=1:numinterms

            idx=find(strcmp(interms{n},eterms),1,'first');

            if isempty(idx)

                error(message('rf:rfcircuit:circuit:add:NotATerminal',interms{n},elem.Name))
            else

                if any(strcmp(interms{n},interms((n+1):numinterms)))

                    error(message('rf:rfcircuit:element:validateCellNameList:NamesNotUnique','Terminal'))

                else
                    elemnodes(idx)=nodes(n);
                end
            end
        end
    end





    newname=insertName(ckt.NamingObject,elem.Name);
    updateParentInfo(elem,newname,ckt,elemnodes);


    ckt.Elements(end+1)=elem;
    ckt.Nodes=unique([ckt.Nodes,elemnodes]);
