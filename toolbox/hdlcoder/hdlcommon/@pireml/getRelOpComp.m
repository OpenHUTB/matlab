function relopComp=getRelOpComp(hN,hSignalsIn,hSignalsOut,opName,compName)







    if(nargin<5)
        compName=opName;
    end

    maxdimlen=1;
    for ii=1:length(hSignalsIn)
        [dimlen,~]=pirelab.getVectorTypeInfo(hSignalsIn(ii));
        if dimlen>maxdimlen
            maxdimlen=dimlen;
        end
    end

    hAllSignals=hdlhandles(length(hSignalsIn),maxdimlen);
    for ii=1:length(hSignalsIn)
        [dimlen,~]=pirelab.getVectorTypeInfo(hSignalsIn(ii));
        if(dimlen>1)
            hDemux=pirelab.getDemuxCompOnInput(hN,hSignalsIn(ii));
            hAllSignals(ii,:)=hDemux.PirOutputSignals;
        else
            hAllSignals(ii,:)=repmat(hSignalsIn(ii),1,maxdimlen);
        end
    end

    hRelopOut=hdlhandles(maxdimlen,1);
    [~,outType]=pirelab.getVectorTypeInfo(hSignalsOut);

    for ii=1:maxdimlen
        hRelopOut(ii)=hN.addSignal(pir_boolean_t,sprintf('%s_relop%d',compName,ii));
        relopComp=createRelOpComp(hN,hAllSignals(:,ii),hRelopOut(ii),opName,sprintf('%s_%d',compName,ii));
        hRelopOut(ii)=pireml.insertDTCCompOnInput(hN,hRelopOut(ii),outType,'Nearest','Saturate');
    end

    connectToOutputPorts(hN,hRelopOut,hSignalsOut,compName);

end


function connectToOutputPorts(hN,hInSignals,hOutSignals,compName)
    if(length(hInSignals)==1)
        if(hInSignals(1)~=hOutSignals(1))
            hWC=pirelab.getWireComp(hN,hInSignals(1),hOutSignals(1),compName);%#ok
        end
    else
        hMC=pireml.getMuxComp(hN,hInSignals,hOutSignals,sprintf('%s_concat',compName));%#ok
    end
end


function relopComp=createRelOpComp(hN,hSignalsIn,hSignalsOut,opName,compName)

    switch lower(opName)
    case{'eq_comp','=='}
        mode=1;
    case{'ne_comp','~='}
        mode=2;
    case{'le_comp','<='}
        mode=3;
    case{'lt_comp','<'}
        mode=4;
    case{'ge_comp','>='}
        mode=5;
    case{'gt_comp','>'}
        mode=6;
    otherwise
        error(message('hdlcommon:hdlcommon:NotSupportedOp',opName));
    end

    relopComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hSignalsOut,...
    'EMLFileName','hdleml_relop',...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLParams',{mode});
end


