


function[inData,outData,hInst]=createBlackBoxForDut(this,topN,DUT,globalSigs)




    inPorts=DUT.PirInputPorts;
    numPorts=numel(inPorts);

    inSigs=DUT.PirInputSignals;
    inportNames=cell(1,numPorts);
    inData=hdlhandles(1,numPorts);
    for ii=1:numPorts
        inportNames{ii}=inPorts(ii).Name;
        switch inPorts(ii).Kind
        case 'clock'
            hS=topN.findSignal('name',inPorts(ii).Name);
        case 'reset'
            hS=topN.findSignal('name',inPorts(ii).Name);
            if isempty(hS)

                hS=topN.addSignal(globalSigs(2).Type,inPorts(ii).Name);
                pirelab.getWireComp(topN,globalSigs(2),hS);
            end
        case 'clock_enable'

            cte=this.clockTable(arrayfun(@(x)strcmp(inPorts(ii).Name,x.Name),this.clockTable));
            if isempty(cte)
                clk=topN.findSignal('name',inPorts(ii).Name);
                if(isempty(clk))


                    bitT=topN.getType('FixedPoint','Signed',0,'WordLength',1,'FractionLength',0);
                    hS=topN.addSignal(bitT,inPorts(ii).Name);
                else

                    [~,hS,~]=topN.getClockBundle(clk,1,1,0);
                end
            else

                clkEntry=this.clockTable(arrayfun(@(x)(x.Ratio==cte.Ratio&&x.Kind==0),this.clockTable));

                clk=topN.findSignal('name',clkEntry.Name);

                [~,hS,~]=topN.getClockBundle(clk,1,1,0);

                hS.Name=inPorts(ii).Name;
            end
        case 'data'
            hS=topN.addSignal(inSigs(ii));
        otherwise
        end
        inData(ii)=hS;
    end

    outPorts=DUT.PirOutputPorts;
    outSigs=DUT.PirOutputSignals;
    numPorts=numel(outPorts);
    outportNames=cell(1,numPorts);
    outData=hdlhandles(1,numPorts);
    for ii=1:numPorts
        outportNames{ii}=outPorts(ii).Name;
        outData(ii)=topN.addSignal(outSigs(ii));
    end

    gp=pir;
    ctx=gp.getTopPirCtx();

    hInst=pirelab.getInstantiationComp('Network',topN,...
    'Name',DUT.Name,'EntityName',DUT.Name,...
    'InportNames',inportNames,'OutportNames',outportNames,...
    'InportSignals',inData,'OutportSignals',outData,...
    'AddClockPort','off','AddClockEnablePort','off',...
    'AddResetPort','off','VHDLArchitectureName',ctx.getParamValue('vhdl_architecture_name'));
end
