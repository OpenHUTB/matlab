function cktOut=richards(cktIn,opFreq)
    if length(cktIn.TerminalNodes)==length(cktIn.Terminals)
        negPortTerm=unique(cktIn.TerminalNodes(...
        contains(cktIn.Terminals,"-")));
    else
        negPortTerm=[];
    end
    if numel(negPortTerm)~=1
        error(message('rf:rfcircuit:circuit:richards:NotAllowedOnCkt'))
    end
    validateattributes(opFreq,{'numeric'},...
    {'nonempty','nonnan','finite','real','positive','scalar'},...
    'richards','opFreq')
    [cktOut,warningMsgs]=functionalClone(cktIn,@cloneRichards,@remapNodesRichards);%#ok<ASGLU>
    [cktChain,~]=getChain(cktOut,true);
    if~isempty(cktChain)

        terms=cktOut.Terminals;
        ports=cktOut.Ports;
        cktOut=circuit(cktChain);
        cktOut.Ports=ports;
        cktOut.Terminals=terms;
    end


    if isequal(cktIn,cktOut)
        warning(message('rf:rfcircuit:circuit:richards:NotAppliedOnCkt'));
    end

    function[elemOut,varargout]=cloneRichards(ckt,elemInd)
        warningMsg=[];
        varargout={};
        elemIn=ckt.Elements(elemInd);
        switch class(elemIn)
        case 'capacitor'



            nonNegNode=elemIn.ParentNodes~=negPortTerm;
            if sum(nonNegNode)==1
                stubMode='Shunt';






                nodes=[elemIn.ParentNodes(nonNegNode),-1...
                ,negPortTerm,negPortTerm];
            else
                stubMode='Series';
                nodes=[elemIn.ParentNodes,negPortTerm,negPortTerm];
            end
            elemOut=elemIn.richards(opFreq,'StubMode',stubMode);
            elemOut.ParentNodes=nodes;
        case 'inductor'
            nonNegNode=elemIn.ParentNodes~=negPortTerm;
            if sum(nonNegNode)==1
                stubMode='Shunt';
                nodes=[elemIn.ParentNodes(nonNegNode),-1...
                ,negPortTerm,negPortTerm];
            else
                stubMode='Series';
                nodes=[elemIn.ParentNodes,negPortTerm,negPortTerm];
            end
            elemOut=elemIn.richards(opFreq,'StubMode',stubMode);
            elemOut.ParentNodes=nodes;
        otherwise
            warningMsg=message(['rf:rfcircuit:circuit:richards:'...
            ,'NotAppliedOnElem'],class(elemIn)).string;
            elemOut=clone(elemIn);
        end
        if nargout>1
            varargout={warningMsg};
        end
    end
    function varargout=remapNodesRichards(cktOut,cktIn,elInInd)








        warningMsg=[];
        varargout={};
        switch class(cktIn.Elements(elInInd))
        case{'capacitor','inductor'}
            nonNegNodesLogInd=cktIn.Elements(elInInd).ParentNodes~=...
            negPortTerm;
            isShunt=sum(nonNegNodesLogInd)==1;
            nonNegNodes=cktIn.Elements(elInInd).ParentNodes(nonNegNodesLogInd);
            maxNodeNum=max([cktOut.Nodes,cktIn.Nodes]);
            remapped=0;






            elemOutNodes=cktIn.TerminalNodes;
            if isShunt
                elemOutNodes(elemOutNodes==nonNegNodes)=-1;
            end
            if any(elemOutNodes<0)
                if remapped==0
                    nodesOrig=cktIn.TerminalNodes;
                    ElementNumOrig=0;
                end
                elemOutNodes(elemOutNodes<0)=maxNodeNum+1;
                cktIn.TerminalNodes=elemOutNodes;
                remapped=remapped+1;
            end


            for m=1:numel(cktOut.Elements)
                elemOutNodes=cktOut.Elements(m).ParentNodes;
                if isShunt
                    elemOutNodes(elemOutNodes==nonNegNodes)=-1;
                end
                if any(elemOutNodes<0)
                    if remapped==0
                        nodesOrig=cktOut.Elements(m).ParentNodes;
                        ElementNumOrig=m;
                    end
                    elemOutNodes(elemOutNodes<0)=maxNodeNum+1;
                    cktOut.Elements(m).ParentNodes=elemOutNodes;
                    remapped=remapped+1;
                end
            end


            for m=elInInd+1:numel(cktIn.Elements)
                elemOutNodes=cktIn.Elements(m).ParentNodes;
                if isShunt
                    elemOutNodes(elemOutNodes==nonNegNodes)=-1;
                end
                if any(elemOutNodes<0)
                    if remapped==0
                        nodesOrig=cktIn.Elements(m).ParentNodes;
                        ElementNumOrig=m;
                    end
                    elemOutNodes(elemOutNodes<0)=maxNodeNum+1;
                    cktIn.Elements(m).ParentNodes=elemOutNodes;
                    remapped=remapped+1;
                end
            end



            if remapped>1
                if ElementNumOrig<elInInd+1
                    if ElementNumOrig==0
                        cktIn.TerminalNodes=nodesOrig;
                    else
                        cktOut.Elements(ElementNumOrig).ParentNodes=nodesOrig;
                    end
                else
                    cktIn.Elements(ElementNumOrig).ParentNodes=nodesOrig;
                end
            end
        end
        if nargout>0
            varargout={warningMsg};
        end
    end
end