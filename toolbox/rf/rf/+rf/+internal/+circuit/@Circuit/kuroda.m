function cktOut=kuroda(cktIn,varargin)
    if length(cktIn.TerminalNodes)==length(cktIn.Terminals)
        negPortTerm=unique(cktIn.TerminalNodes(...
        contains(cktIn.Terminals,"-")));
    else
        negPortTerm=[];
    end
    if numel(negPortTerm)~=1
        error(message('rf:rfcircuit:circuit:kuroda:NotAllowedOnCkt'))
    end
    elemsIn=varargin;

    if numel(elemsIn)<2
        error(message('rf:rfcircuit:circuit:kuroda:NotEnoughInputElement'))
    elseif numel(elemsIn)>3
        error(message('rf:rfcircuit:circuit:kuroda:TooManyInputElement'))
    end
    elemNums=zeros(1,numel(elemsIn));

    for elemInd=1:numel(elemsIn)
        if isnumeric(elemsIn{elemInd})
            if elemsIn{elemInd}>0&&elemsIn{elemInd}<=numel(cktIn.Elements)
                elemNums(elemInd)=elemsIn{elemInd};
            else
                error(message('rf:rfcircuit:circuit:kuroda:WrongElIndex'))
            end
        elseif isa(elemsIn{elemInd},'rf.internal.circuit.Element')
            [~,elemNums(elemInd)]=ismember(elemsIn{elemInd},cktIn.Elements);
            if~elemNums(elemInd)
                error(message('rf:rfcircuit:circuit:kuroda:WrongElObj'))
            end
        elseif ischar(elemsIn{elemInd})||isstring(elemsIn{elemInd})
            [~,elemNums(elemInd)]=ismember(elemsIn{elemInd},{cktIn.Elements.Name});
            if~elemNums(elemInd)
                error(message('rf:rfcircuit:circuit:kuroda:WrongElName'))
            end
        else
            error(message('rf:rfcircuit:circuit:kuroda:WrongElType'))
        end
    end



    elems=circuit.empty(numel(elemsIn),0);
    portNum=zeros(1,numel(elemsIn));
    for elemInd=1:numel(elemsIn)

        if cktIn.Elements(elemNums(elemInd)).NumPorts~=2
            error(message('rf:rfcircuit:circuit:kuroda:ElNot2Port'))
        end
    end
    for elemInd=1:numel(elemsIn)
        elems(elemInd)=cktIn.Elements(elemNums(elemInd));
        if elemInd<numel(elemNums)
            if class(elems(elemInd))~="txlineElectricalLength"
                error(message('rf:rfcircuit:circuit:kuroda:TwoFirstElemsNottxlineEL'))
            end
            portNum(elemInd:elemInd+1)=whichPortConn2El(...
            elems(elemInd),cktIn.Elements(elemNums(elemInd+1)));




            nodeToChk=elems(elemInd).ParentNodes(portNum(elemInd));
            if ismember(nodeToChk,cktIn.TerminalNodes)
                error(message('rf:rfcircuit:circuit:kuroda:BadElemsConnectivity'))
            end
            for n=1:numel(cktIn.Elements)
                if n~=elemNums(elemInd)&&n~=elemNums(elemInd+1)
                    if ismember(nodeToChk,cktIn.Elements(n).ParentNodes)
                        error(message('rf:rfcircuit:circuit:kuroda:BadElemsConnectivity'))
                    end
                end
            end
        else
            if class(elems(2))~="txlineElectricalLength"
                error(message('rf:rfcircuit:circuit:kuroda:TwoFirstElemsNottxlineEL'))
            end
            if elemInd==3
                isIdealTrans=true;
                if class(elems(elemInd))=="nport"
                    nFreqs=numel(elems(elemInd).NetworkData.Frequencies);
                    dataS=elems(elemInd).NetworkData.Parameters;
                    if nFreqs>1
                        diffS=diff(dataS,[],3);
                    else
                        diffS=zeros(size(dataS(:,:,1)));
                    end
                    if max(abs(diffS)-2*max(eps(dataS),[],3))>0


                        isIdealTrans=false;
                    elseif~isreal(dataS(:,:,1))||...
                        (dataS(1,1,1)+dataS(2,2,1)>...
                        2*max(eps(dataS(1,1,1)),eps(dataS(2,2,1))))||...
                        (dataS(2,1,1)-dataS(1,2,1)>...
                        2*max(eps(dataS(2,1,1)),eps(dataS(1,2,1))))



                        isIdealTrans=false;
                    elseif~ispassive(dataS(:,:,1))

                        isIdealTrans=false;
                    end
                else
                    isIdealTrans=false;
                end
                if~isIdealTrans
                    error(message('rf:rfcircuit:circuit:kuroda:LastElemNotIdealTrans'))
                end
            end
        end
    end



    if abs(elems(1).LineLength*elems(2).ReferenceFrequency-...
        elems(2).LineLength*elems(1).ReferenceFrequency)>...
        10*eps(elems(1).LineLength*elems(2).ReferenceFrequency)
        error(message('rf:rfcircuit:circuit:kuroda:DifferentElectLen'))
    end
    txLineTypes=[elems(1).StubMode,elems(1).Termination,'&'...
    ,elems(2).StubMode,elems(2).Termination];
    replaceBy(1)=txlineElectricalLength('LineLength',...
    elems(1).LineLength,'ReferenceFrequency',...
    elems(1).ReferenceFrequency);
    replaceBy(2)=txlineElectricalLength('LineLength',...
    elems(2).LineLength,'ReferenceFrequency',...
    elems(2).ReferenceFrequency);
    switch txLineTypes
    case 'ShuntOpen&NotAStubNotApplicable'

        Z2=elems(1).Z0;
        Z1=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z2/N;
        replaceBy(1).StubMode='NotAStub';
        replaceBy(1).Termination='NotApplicable';
        replaceBy(2).Z0=Z1/N;
        replaceBy(2).StubMode='Series';
        replaceBy(2).Termination='Short';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),1,true);
    case 'NotAStubNotApplicable&SeriesShort'

        Z2=elems(1).Z0;
        Z1=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z2*N;
        replaceBy(1).StubMode='Shunt';
        replaceBy(1).Termination='Open';
        replaceBy(2).Z0=Z1*N;
        replaceBy(2).StubMode='NotAStub';
        replaceBy(2).Termination='NotApplicable';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),1,false);
    case 'SeriesShort&NotAStubNotApplicable'

        Z1=elems(1).Z0;
        Z2=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z1*N;
        replaceBy(1).StubMode='NotAStub';
        replaceBy(1).Termination='NotApplicable';
        replaceBy(2).Z0=Z2*N;
        replaceBy(2).StubMode='Shunt';
        replaceBy(2).Termination='Open';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),2,true);
    case 'NotAStubNotApplicable&ShuntOpen'

        Z1=elems(1).Z0;
        Z2=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z1/N;
        replaceBy(1).StubMode='Series';
        replaceBy(1).Termination='Short';
        replaceBy(2).Z0=Z2/N;
        replaceBy(2).StubMode='NotAStub';
        replaceBy(2).Termination='NotApplicable';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),2,false);
    case 'SeriesOpen&NotAStubNotApplicable'

        Z2=elems(1).Z0;
        Z1=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=N*Z1;
        replaceBy(1).StubMode='NotAStub';
        replaceBy(1).Termination='NotApplicable';
        replaceBy(2).Z0=N*Z2;
        replaceBy(2).StubMode='Series';
        replaceBy(2).Termination='Open';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),3,true);
        itS11=(N^2-1)/(1+N^2);
        itS21=2*N/(1+N^2);
        replaceBy(3)=...
        nport(sparameters([itS11,itS21;itS21,-itS11],1),...
        [replaceBy(2).Name,'_ideal_transformer']);
    case 'NotAStubNotApplicable&SeriesOpen'

        if numel(elems)~=3


            error(message(...
            'rf:rfcircuit:circuit:kuroda:ElemNotInKurodaTable'))
        end
        Z1=elems(1).Z0;
        Z2=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z2/N;
        replaceBy(1).StubMode='Series';
        replaceBy(1).Termination='Open';
        replaceBy(2).Z0=Z1/N;
        replaceBy(2).StubMode='NotAStub';
        replaceBy(2).Termination='NotApplicable';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),3,false);


        dataS=elems(3).NetworkData.Parameters;
        if abs(dataS(1,2,1)-N*(1-dataS(1,1,1)))>10*eps(dataS(1,2,1))
            error(message(['rf:rfcircuit:circuit:kuroda:'...
            ,'IdealTransWrongRatio'],'N:1',sprintf('%g',N)))
        end
    case 'ShuntShort&NotAStubNotApplicable'

        Z1=elems(1).Z0;
        Z2=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=Z2/N;
        replaceBy(1).StubMode='NotAStub';
        replaceBy(1).Termination='NotApplicable';
        replaceBy(2).Z0=Z1/N;
        replaceBy(2).StubMode='Shunt';
        replaceBy(2).Termination='Short';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),4,true);
        itS11=(1-N^2)/(1+N^2);
        itS21=2*N/(1+N^2);
        replaceBy(3)=...
        nport(sparameters([itS11,itS21;itS21,-itS11],1),...
        [replaceBy(2).Name,'_ideal_transformer']);
    case 'NotAStubNotApplicable&ShuntShort'

        if numel(elems)~=3


            error(message(...
            'rf:rfcircuit:circuit:kuroda:ElemNotInKurodaTable'))
        end
        Z2=elems(1).Z0;
        Z1=elems(2).Z0;
        N=1+Z2/Z1;
        replaceBy(1).Z0=N*Z1;
        replaceBy(1).StubMode='Shunt';
        replaceBy(1).Termination='Short';
        replaceBy(2).Z0=N*Z2;
        replaceBy(2).StubMode='NotAStub';
        replaceBy(2).Termination='NotApplicable';
        [replaceBy(1).Name,replaceBy(2).Name]=...
        processElNames(elems(1),elems(2),4,false);
        dataS=elems(3).NetworkData.Parameters;
        if abs(dataS(1,2,1)-N*(1+dataS(1,1,1)))>10*eps(dataS(1,2,1))
            error(message(['rf:rfcircuit:circuit:kuroda:'...
            ,'IdealTransWrongRatio'],'1:N',sprintf('%g',N)))
        end
    otherwise
        error(message('rf:rfcircuit:circuit:kuroda:ElemNotInKurodaTable'))
    end
    [cktOut,warningMsgs]=...
    functionalClone(cktIn,@cloneKuroda,@remapNodesKuroda);%#ok<ASGLU>
    [cktChain,~]=getChain(cktOut,true);
    if~isempty(cktChain)

        terms=cktOut.Terminals;
        ports=cktOut.Ports;
        cktOut=circuit(cktChain);
        cktOut.Ports=ports;
        cktOut.Terminals=terms;
    end



    function[el1Name,el2Name]=processElNames(el1,el2,KurodaId,isL2R)
        addedStr=['Kuroda',num2str(KurodaId)];
        if isL2R
            StrToChk=[addedStr,'_R2L_of_'];
            addedStr=[addedStr,'_L2R_of_'];
        else
            StrToChk=[addedStr,'_L2R_of_'];
            addedStr=[addedStr,'_R2L_of_'];
        end
        indE1=startsWith(el1.Name,StrToChk);
        indE2=startsWith(el2.Name,StrToChk);
        if indE1&&indE2
            el1Name=matlab.lang.makeValidName(el1.Name(length(StrToChk)+1:end));
            el2Name=matlab.lang.makeValidName(el2.Name(length(StrToChk)+1:end));
        else
            el1Name=matlab.lang.makeValidName([addedStr,el1.Name]);
            el2Name=matlab.lang.makeValidName([addedStr,el2.Name]);
        end
    end
    function portNum=whichPortConn2El(el1,el2)


        el1p1PosTerm=contains(el1.Terminals,[el1.Ports{1},'+']);
        el1p2PosTerm=contains(el1.Terminals,[el1.Ports{2},'+']);
        el2p1PosTerm=contains(el2.Terminals,[el2.Ports{1},'+']);
        el2p2PosTerm=contains(el2.Terminals,[el2.Ports{2},'+']);
        el1p1Conn=ismember(el1.ParentNodes(el1p1PosTerm),...
        [el2.ParentNodes(el2p1PosTerm),el2.ParentNodes(el2p2PosTerm)]);
        el1p2Conn=ismember(el1.ParentNodes(el1p2PosTerm),...
        [el2.ParentNodes(el2p1PosTerm),el2.ParentNodes(el2p2PosTerm)]);
        if xor(el1p1Conn,el1p2Conn)
            if el1p1Conn




                el2p1Conn=el2.ParentNodes(el2p1PosTerm)==...
                el1.ParentNodes(el1p1PosTerm);
                portNum=[1,el2p1Conn+1];
            else


                el2p1Conn=el2.ParentNodes(el2p1PosTerm)==...
                el1.ParentNodes(el1p2PosTerm);
                portNum=[2,el2p1Conn+1];
            end
        elseif and(el1p1Conn,el1p2Conn)
            error(message('rf:rfcircuit:circuit:kuroda:ElemsConnbyMoreThan1Port'))
        else
            error(message('rf:rfcircuit:circuit:kuroda:ElemsNotConnected'))
        end
    end

    function[elemOut,varargout]=cloneKuroda(ckt,elemInd)
        warningMsg=[];
        varargout={};
        elemIn=ckt.Elements(elemInd);
        elToReplace=find(elemNums==elemInd,1);
        if~isempty(elToReplace)
            if elToReplace==2&&numel(replaceBy)==3

                tnodes=elemIn.ParentNodes;
                tnodesEl1=tnodes;
                tnodesEl1([portNum(end),portNum(end)+2])=...
                [-1,negPortTerm];
                elemOut(1)=replaceBy(elToReplace);
                elemOut(1).ParentNodes=tnodesEl1;
                elemOut(2)=replaceBy(3);
                elemOut(2).ParentNodes=[-1,tnodes(portNum(end))...
                ,negPortTerm,negPortTerm];
            elseif elToReplace==3&&numel(replaceBy)==2

                elemOut=txlineElectricalLength.empty;
            else


                elemOut=replaceBy(elToReplace);
            end
        else
            elemOut=clone(elemIn);
        end
        if nargout>1
            varargout={warningMsg};
        end
    end

    function varargout=remapNodesKuroda(cktOut,cktIn,elInInd)







        warningMsg=[];
        varargout={};

        elToReplace=find(elemNums==elInInd,1);
        if~isempty(elToReplace)&&elToReplace==3&&numel(replaceBy)==2


            cktOut.Elements(elemNums(2)).ParentNodes(portNum(2))=...
            cktIn.Elements(elemNums(3)).ParentNodes(portNum(3));
        end
        if nargout>0
            varargout={warningMsg};
        end
    end
end