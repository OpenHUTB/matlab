function populatePulseParameters(psObj)



























    for psIdx=1:numel(psObj)


        idxLoad=reshape([psObj(psIdx).Pulse.idxLoad],2,[])';
        idxRelax=reshape([psObj(psIdx).Pulse.idxRelax],2,[])';
        idxShift=[psObj(psIdx).Pulse.idxPulseSequence]'-1;


        idxLoad=idxLoad+[idxShift,idxShift];
        idxRelax=idxRelax+[idxShift,idxShift];


        psObj(psIdx).idxLoad=idxLoad;
        psObj(psIdx).idxRelax=idxRelax;
        psObj(psIdx).idxEdge=unique([idxLoad(:);idxRelax(:)]);


        NumPulses=numel(psObj(psIdx).Pulse);


        NumRC=psObj(psIdx).Pulse(1).Parameters(end).NumRC;
        RCBranchesUse2TimeConstants=psObj(psIdx).Pulse(1).Parameters(end).NumTimeConst>1;
        Param=Battery.Parameters(NumPulses+1,NumRC,RCBranchesUse2TimeConstants);



        SOCBreaks=[
        psObj(psIdx).SOC(psObj(psIdx).idxRelax(1:end,1))
        psObj(psIdx).SOC(1)];


        Param.SOC=sort(SOCBreaks)';


        psObj(psIdx).Parameters=Param;

    end