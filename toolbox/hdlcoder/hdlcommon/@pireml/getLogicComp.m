function cgirComp=getLogicComp(hN,hSignalsIn,hSignalsOut,op,compName)


    if(nargin<5)
        compName=op;
    end

    switch op
    case{'&','&&'}
        op='and_comp';
    case{'|','||'}
        op='or_comp';
    case{'~&','~&&'}
        op='nand_comp';
    case{'~|','~||'}
        op='nor_comp';
    case '^'
        op='xor_comp';
    case{'~','!'}
        op='not_comp';
    case '~^'
        op='xnor_comp';
    end

    maxdimlen=1;
    hInSignals=hdlhandles(length(hSignalsIn),1);
    for ii=1:length(hSignalsIn)
        hInSignals(ii)=pireml.getCompareToZero(hN,hSignalsIn(ii),'~=');
        [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(ii));
        if dimlen>maxdimlen
            maxdimlen=dimlen;
        end
    end


    unaryOp=opIsUnary(op);
    negatedOp=opIsNegation(op);
    shortckted=false;


    if length(hSignalsIn)==1

        [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
        if(dimlen==1)
            if~unaryOp

                if(negatedOp)
                    unaryOp=true;
                    op='not_comp';
                else
                    cgirComp=pirelab.getWireComp(hN,hInSignals(1),hSignalsOut,compName);
                end
                shortckted=true;
            end
        else

            hDemux=pirelab.getDemuxCompOnInput(hN,hInSignals(ii));
            hInSignals=hDemux.PirOutputSignals;
        end

        if unaryOp

            if length(hInSignals)==1
                cgirComp=createLogicComp(hN,hInSignals,hSignalsOut,op,compName);
            else
                hLogicOut=hdlhandles(length(hInSignals),1);
                for ii=1:length(hInSignals)
                    hLogicOut(ii)=hN.addSignal(hInSignals(ii));
                    cgirComp=createLogicComp(hN,hInSignals(ii),hLogicOut(ii),op,sprintf('%s_%d',compName,ii));
                end
                connectToOutputPorts(hN,hLogicOut,hSignalsOut,compName);
            end
        end
        maxdimlen=1;
    end


    if~unaryOp&&~shortckted
        hAllSignals=hdlhandles(length(hInSignals),maxdimlen);
        for ii=1:length(hInSignals)
            [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(ii));
            if(dimlen>1)
                hDemux=pirelab.getDemuxCompOnInput(hN,hInSignals(ii));
                hAllSignals(ii,:)=hDemux.PirOutputSignals;
            else
                hAllSignals(ii,:)=repmat(hInSignals(ii),1,maxdimlen);
            end
        end

        if maxdimlen==1
            cgirComp=createLogicComp(hN,hAllSignals,hSignalsOut,op,compName);
        else
            for ii=1:maxdimlen
                hLogicOut(ii)=hN.addSignal(hAllSignals(1,ii));
                cgirComp=createLogicComp(hN,hAllSignals(:,ii),hLogicOut(ii),op,sprintf('%s_%d',compName,ii));
            end
            connectToOutputPorts(hN,hLogicOut,hSignalsOut,compName);
        end
    end
end


function connectToOutputPorts(hN,hInSignals,hOutSignals,compName)
    if(length(hInSignals)==1)
        if(hInSignals(1)~=hOutSignals(1))
            hWC=pirelab.getWireComp(hN,hInSignals(1),hOutSignals(1),compName);
        end
    else
        hMC=pirelab.getMuxComp(hN,hInSignals,hOutSignals,sprintf('%s_concat',compName));
    end
end


function isUnary=opIsUnary(op)
    isUnary=strcmp(op,'not_comp');
end

function retval=opIsNegation(op)
    retval=strcmp(op,'not_comp')||strcmp(op,'nand_comp')||strcmp(op,'nor_comp')||strcmp(op,'xnor_comp')||strcmp(op,'nxor_comp');
end





function cgirComp=createLogicComp(hN,hSignalsIn,hSignalsOut,opMode,compName)

    switch opMode
    case 'and_comp'
        emlFile='hdleml_bitand';
    case 'or_comp'
        emlFile='hdleml_bitor';
    case 'nand_comp'
        emlFile='hdleml_bitnand';
    case 'nor_comp'
        emlFile='hdleml_bitnor';
    case 'xor_comp'
        emlFile='hdleml_bitxor';
    case 'not_comp'
        emlFile='hdleml_bitnot';
    case{'xnor_comp','nxor_comp'}
        emlFile='hdleml_bitxnor';
    end

    cgirComp=hN.addComponent2('kind','cgireml',...
    'Name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hSignalsOut,...
    'EMLFileName',emlFile,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLParams',{});
end
