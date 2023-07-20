function cktOut=insertUnitElement(cktIn,elem,port,opFreq,Z0)
    if length(cktIn.TerminalNodes)==length(cktIn.Terminals)
        negPortTerm=unique(cktIn.TerminalNodes(...
        contains(cktIn.Terminals,"-")));
    else
        negPortTerm=[];
    end
    if numel(negPortTerm)~=1
        error(message('rf:rfcircuit:circuit:insert_unitelement:NotAllowedOnCkt'))
    end
    if isempty(elem)
        elemNum=0;
    else
        if isnumeric(elem)
            if numel(elem)==1&&elem>=0&&elem<=numel(cktIn.Elements)+1
                elemNum=elem;
            else
                error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElIndex'))
            end
        elseif numel(elem)==1&&isa(elem,'rf.internal.circuit.Element')
            elemNum=find(cktIn.Elements==elem,1);
            if isempty(elemNum)
                error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElObj'))
            end
        elseif ischar(elem)||isstring(elem)
            [~,elemNum]=ismember(elem,{cktIn.Elements.Name});
            if~elemNum
                error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElName'))
            end
        else
            error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElType'))
        end
    end

    if elemNum>0&&elemNum<=numel(cktIn.Elements)
        if cktIn.Elements(elemNum).NumPorts<=1
            error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElNumPorts'))
        end
        validateattributes(port,{'numeric'},...
        {'nonempty','nonnan','integer','scalar'},...
        'insertUnitElement','port')
        if port<1||port>cktIn.Elements(elemNum).NumPorts
            error(message('rf:rfcircuit:circuit:insert_unitelement:WrongElPortNum'))
        end
    else
        validateattributes(port,{'numeric'},...
        {'nonempty','nonnan','integer','scalar'},...
        'insertUnitElement','port')
        if port<1||port>cktIn.NumPorts
            error(message('rf:rfcircuit:circuit:insert_unitelement:WrongCktPortNum'))
        end
    end
    validateattributes(opFreq,{'numeric'},...
    {'nonempty','nonnan','finite','real','positive','scalar'},...
    'insertUnitElement','opFreq')
    validateattributes(Z0,{'numeric'},...
    {'nonempty','nonnan','finite','real','positive','scalar'},...
    'insertUnitElement','Z0')
    [cktOut,warningMsgs]=functionalClone(cktIn,@cloneInsertUE,@remapNodesInsertUE);%#ok<ASGLU>
    [cktChain,~]=getChain(cktOut,true);
    if~isempty(cktChain)

        terms=cktOut.Terminals;
        ports=cktOut.Ports;
        cktOut=circuit(cktChain);
        cktOut.Ports=ports;
        cktOut.Terminals=terms;
    end



    function[elemOut,varargout]=cloneInsertUE(ckt,elemInd)
        warningMsg=[];
        varargout={};
        elemIn=ckt.Elements(elemInd);
        if elemNum==0&&elemInd==1
            tnodes=ckt.TerminalNodes;
            elemOut(1)=txlineElectricalLength(...
            'Z0',Z0,...
            'ReferenceFrequency',opFreq,...
            'Name',matlab.lang.makeValidName(['ckt_p',num2str(port),'_elem_UE']));
            elemOut(1).ParentNodes=[-1,tnodes(port),negPortTerm,negPortTerm];
            tnodesEl=elemIn.ParentNodes;
            elemOut(2)=clone(elemIn);
            elemOut(2).ParentNodes=tnodesEl;
        elseif elemNum==numel(ckt.Elements)+1&&elemInd==numel(ckt.Elements)
            tnodes=ckt.TerminalNodes;
            tnodesEl=elemIn.ParentNodes;
            elemOut(1)=clone(elemIn);
            elemOut(1).ParentNodes=tnodesEl;
            elemOut(2)=txlineElectricalLength(...
            'Z0',Z0,...
            'ReferenceFrequency',opFreq,...
            'Name',matlab.lang.makeValidName(['ckt_p',num2str(port),'_elem_UE']));
            elemOut(2).ParentNodes=[tnodes(port),-1,negPortTerm,negPortTerm];
        else
            if elemInd==elemNum
                tnodes=elemIn.ParentNodes;
                numports=numel(elemIn.Ports);
                tnodesEl=tnodes;
                tnodesEl([port,port+numports])=[-1,negPortTerm];
                if port==1
                    elemOut(1)=txlineElectricalLength(...
                    'Z0',Z0,...
                    'ReferenceFrequency',opFreq,...
                    'Name',matlab.lang.makeValidName([elemIn.Name,'_p',num2str(port),'_elem_UE']));
                    elemOut(1).ParentNodes=[-1,tnodes(port),negPortTerm...
                    ,negPortTerm];
                    elemOut(2)=clone(elemIn);
                    elemOut(2).ParentNodes=tnodesEl;
                else
                    elemOut(1)=clone(elemIn);
                    elemOut(1).ParentNodes=tnodesEl;
                    elemOut(2)=txlineElectricalLength(...
                    'Z0',Z0,...
                    'ReferenceFrequency',opFreq,...
                    'Name',matlab.lang.makeValidName([elemIn.Name,'_p',num2str(port),'_elem_UE']));
                    elemOut(2).ParentNodes=[-1,tnodes(port),negPortTerm...
                    ,negPortTerm];
                end
            else
                elemOut=clone(elemIn);
            end
        end
        if nargout>1
            varargout={warningMsg};
        end
    end

    function varargout=remapNodesInsertUE(cktOut,cktIn,elInInd)







        warningMsg=[];
        varargout={};






        if(elemNum==0&&elInInd==1)||...
            (elemNum==numel(cktIn.Elements)+1&&...
            elInInd==numel(cktIn.Elements))
            maxNodeNum=max([cktOut.Nodes,cktIn.Nodes]);
            numports=numel(cktIn.Ports);
            cktIn.TerminalNodes([port,port+numports])=...
            [maxNodeNum+1,negPortTerm];
        end
        if nargout>0
            varargout={warningMsg};
        end
    end
end