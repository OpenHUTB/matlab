function sortNet=elabOptSorter(this,topNet,blockInfo,dataRate)
    listLength=blockInfo.listLength;
    pathType=blockInfo.pathType;
    pathVecType=pirelab.createPirArrayType(pathType,[1,listLength]);
    metricType=blockInfo.metricType;
    metricVecType=pirelab.createPirArrayType(metricType,[1,listLength]);

    sorterOps=blockInfo.sorterOps;
    sorterPipes=blockInfo.sorterPipes;


    inportNames={'unsorted'};
    inTypes=metricVecType;
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'sorted','indices'};
    outTypes=[metricVecType,pathVecType];

    sortNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Sorter',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );



    unsorted=sortNet.PirInputSignals(1);

    sorted=sortNet.PirOutputSignals(1);
    indices=sortNet.PirOutputSignals(2);

    unsortedInd=sortNet.addSignal(pathVecType,'unsortedInd');
    unsortedInd.SimulinkRate=dataRate;
    pirelab.getConstComp(sortNet,unsortedInd,0:listLength-1);


    if sorterPipes(1)
        unsorted_reg=sortNet.addSignal(metricVecType,'unsorted_reg');
        pirelab.getUnitDelayComp(sortNet,unsorted,unsorted_reg);

        stageIn=pirelab.demuxSignal(sortNet,unsorted_reg);
    else
        stageIn=pirelab.demuxSignal(sortNet,unsorted);
    end
    indsIn=pirelab.demuxSignal(sortNet,unsortedInd);


    for ii=1:length(sorterOps)
        stageComps=sorterOps{ii};

        for jj=1:size(stageComps,2)
            [sortNet,stageOut(stageComps(:,jj)),indsOut(stageComps(:,jj))]=elabSorterComp(sortNet,stageIn(stageComps(:,jj)),indsIn(stageComps(:,jj)),ii,jj,blockInfo);%#ok
        end

        if sorterPipes(ii+1)
            for jj=1:length(stageIn)
                stageOut_reg(jj)=sortNet.addSignal(metricType,['stage_',num2str(ii-1),'_compOut_',num2str(jj-1),'_reg']);%#ok
                idxOut_reg(jj)=sortNet.addSignal(pathType,['stage_',num2str(ii-1),'_idxOut_',num2str(jj-1),'_reg']);%#ok
                pirelab.getUnitDelayComp(sortNet,stageOut(jj),stageOut_reg(jj));
                pirelab.getUnitDelayComp(sortNet,indsOut(jj),idxOut_reg(jj));
            end
            stageIn=stageOut_reg;
            indsIn=idxOut_reg;
        else
            stageIn=stageOut;
            indsIn=indsOut;
        end
    end

    pirelab.getConcatenateComp(sortNet,stageIn,sorted,'Multidimensional array',2);
    pirelab.getConcatenateComp(sortNet,indsIn,indices,'Multidimensional array',2);

end

function[sortNet,compOut,indicesOut]=elabSorterComp(sortNet,compIn,indIn,stageIdx,compIdx,blockInfo)
    boolType=pir_boolean_t();
    metricType=blockInfo.metricType;
    pathType=blockInfo.pathType;

    comp=sortNet.addSignal(boolType,['stage_',num2str(stageIdx-1),'_comp_',num2str(compIdx-1)]);
    pirelab.getRelOpComp(sortNet,[compIn(1),compIn(2)],comp,'<=');

    compOut(1)=sortNet.addSignal(metricType,['stage_',num2str(stageIdx-1),'_comp_',num2str(compIdx-1),'_out_0']);
    compOut(2)=sortNet.addSignal(metricType,['stage_',num2str(stageIdx-1),'_comp_',num2str(compIdx-1),'_out_1']);
    indicesOut(1)=sortNet.addSignal(pathType,['stage_',num2str(stageIdx-1),'_idx_',num2str(compIdx-1),'_out_0']);
    indicesOut(2)=sortNet.addSignal(pathType,['stage_',num2str(stageIdx-1),'_idx_',num2str(compIdx-1),'_out_1']);

    pirelab.getMultiPortSwitchComp(sortNet,[comp,compIn(2),compIn(1)],compOut(1),1);
    pirelab.getMultiPortSwitchComp(sortNet,[comp,compIn(1),compIn(2)],compOut(2),1);
    pirelab.getMultiPortSwitchComp(sortNet,[comp,indIn(2),indIn(1)],indicesOut(1),1);
    pirelab.getMultiPortSwitchComp(sortNet,[comp,indIn(1),indIn(2)],indicesOut(2),1);
end