function testBenchComponentsEML(this,emlDutInterface,streamInfo)




    signalNames=containers.Map;
    hN=emlDutInterface.topNtwk;

    numInMATLAB=numel(emlDutInterface.inportNames);
    numOutMATLAB=numel(emlDutInterface.outportNames);



    streamedInPorts=streamInfo.streamedInPorts;
    streamedOutPorts=streamInfo.streamedOutPorts;
    inValidReadyIdxs=[streamedInPorts.valid,streamedOutPorts.ready];
    outValidReadyIdxs=[streamedOutPorts.valid,streamedInPorts.ready];

    numIn=numInMATLAB+numel(inValidReadyIdxs);
    numOut=numOutMATLAB+numel(outValidReadyIdxs);


    this.OutportSnk=[];
    if numOut==0
        this.DutHasOutputs=false;
    end
    for m=1:numOut
        snkComponent=this.getComponentStruct;

        if m<=numOutMATLAB
            HDLPortName=hN.getHDLOutputPortNames(m-1);

            if iscell(HDLPortName)
                HDLPortNameUniqueStr=this.uniquifyName(HDLPortName{1},signalNames);
            else
                HDLPortNameUniqueStr=this.uniquifyName(HDLPortName,signalNames);
            end

            emlName=emlDutInterface.outportNames{m};
        else
            portIdx=outValidReadyIdxs(m-numOutMATLAB);
            HDLPortName=hN.PirOutputPorts(portIdx).Name;
            HDLPortNameUniqueStr=this.uniquifyName(HDLPortName,signalNames);
            emlName=HDLPortNameUniqueStr;
        end

        tp=hN.getDUTOrigOutputPortType(m-1);
        outtypeinfo=pirgetdatatypeinfo(tp);

        snkComponent.HDLPortName{end+1}=HDLPortName;

        snkComponent.SLBlockName=emlName;
        snkComponent.loggingPortName=emlName;


        snkComponent.loggingPortName=HDLPortNameUniqueStr;
        snkComponent.dataIsComplex=outtypeinfo.iscomplex;

        this.OutportSnk=[this.OutportSnk,snkComponent];
    end


    this.InportSrc=[];
    for m=1:numIn
        srcComponent=this.getComponentStruct;

        if m<=numInMATLAB
            HDLPortName=hN.getHDLInputPortNames(m-1);
            emlName=emlDutInterface.inportNames{m};
        else
            portIdx=inValidReadyIdxs(m-numInMATLAB);
            HDLPortName=hN.PirInputPorts(portIdx).Name;
            emlName=this.uniquifyName(HDLPortName,signalNames);
        end

        srcComponent.SLBlockName=emlName;
        srcComponent.loggingPortName=emlName;
        srcComponent.SLPortHandle=m;
        srcComponent.feedBackPort=0;
        srcComponent.hasFeedBack='';

        tp=hN.getDUTOrigInputPortType(m-1);
        intypeinfo=pirgetdatatypeinfo(tp);

        srcComponent.HDLPortName{end+1}=HDLPortName;
        srcComponent.dataIsComplex=intypeinfo.iscomplex;

        this.InportSrc=[this.InportSrc,srcComponent];
    end
end
