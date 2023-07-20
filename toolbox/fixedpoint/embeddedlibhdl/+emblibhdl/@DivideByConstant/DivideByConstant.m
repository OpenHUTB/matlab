classdef DivideByConstant<hdlimplbase.EmlImplBase































    methods
        function this=DivideByConstant(block)






            this@hdlimplbase.EmlImplBase();

            supportedBlocks={...
            sprintf('embmathops/Divide by Constant\nHDL Optimized')...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Divide by Constant',...
            'HelpText','HDL Support for Divide by Constant');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);



        end

    end

    methods

        function hCNew=elaborate(this,hN,hC)






            blkInfo=this.getBlockInfo(hC);

            topNet=pirelab.createNewNetworkWithInterface(...
            'Network',hN,...
            'RefComponent',hC,...
            'InportNames',{'X','validIn'},...
            'OutportNames',{'Y','validOut'},...
            'Name','div_by_constant');
            for ii=1:length(topNet.PirInputSignals)
                topNet.PirOutputSignals(ii).SimulinkRate=...
                hC.PirOutputSignals(ii).SimulinkRate;
            end

            mulRndIn=topNet.PirInputSignals(1);
            mulRndOut=topNet.PirOutputSignals(1);

            this.makeMulRndDatapath(topNet,mulRndIn,mulRndOut,blkInfo);
            this.makeValidLine(topNet,topNet.PirInputSignals(2),topNet.PirOutputSignals(2),blkInfo);

            hCNew=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,'rounded_div_by_const');

        end

        function blkInfo=getBlockInfo(~,hC)









            blkInfo.Latency=5;

            ratPack=makeRatPack(hC);
            inputType=getInputType(hC);
            blkInfo.typesTable=fixed.system.RoundToMultiple.getTypesTable(ratPack,inputType,false);
            blkInfo.typesTable=emblibhdl.pirutils.toPirTypesTable(blkInfo.typesTable);
            blkInfo.constTable=fixed.system.RoundToMultiple.getConstantsTable(ratPack,inputType);
            blkInfo.roundingMethod=get_param(hC.SimulinkHandle,'RoundingMethod');

        end



        function makeMulRndDatapath(~,hN,inSignal,outSignal,blkInfo)

















            typesTable=blkInfo.typesTable;
            constTable=blkInfo.constTable;
            roundingMethod=blkInfo.roundingMethod;
            [qPositiveInputs,qNegativeInputs]=selectRationalValues(roundingMethod,constTable.qRationalGreater,constTable.qRationalLesser);

            fid=fopen(fullfile(matlabroot,'toolbox','fixedpoint','embeddedlibhdl',...
            '+emblibhdl','@DivideByConstant','cgireml','MulRnd.m'));
            h=onCleanup(@()fclose(fid));
            fcnBody=fread(fid,inf,'char=>char');
            mulRnd=hN.addComponent2(...
            'kind','cgireml',...
            'Name','mulrnd',...
            'InputSignals',inSignal,...
            'OutputSignals',outSignal,...
            'EMLFileName','MulRnd',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{typesTable.pRatPrototype,typesTable.pProductPrototype,typesTable.pRoundViaCastPrototype,qPositiveInputs,qNegativeInputs,roundingMethod},...
            'ExternalSynchronousResetSignal','',...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'BlockComment','cgireml component');
            mulRnd.runConcurrencyMaximizer(0);
            mulRnd.resetNone(true);

        end


        function varargout=makeValidLine(~,hN,inSignal,outSignal,blkInfo)















            latency=blkInfo.Latency;

            validComp=pirelab.getIntDelayComp(hN,inSignal,outSignal,latency,...
            'valid_reg',0);
            if nargout==1
                varargout{1}=validComp;
            end

        end
    end


    methods(Hidden)

        function registerImplParamInfo(this)





            baseRegisterImplParamInfo(this);

        end

    end

end

function ratPack=makeRatPack(hC)


    h=hC.SimulinkHandle;
    maskWS=get_param(h,'MaskWSVariables');
    idx=strcmp({maskWS.Name},'Denominator');
    ratPack=struct('Numerator',1,...
    'Denominator',maskWS(idx).Value,...
    'Multiple',1);

end

function inputType=getInputType(hC)


    inputPort=hC.PirInputPorts();
    inputType=fixed.internal.type.extractNumericType(inputPort(1).getSLTypeInfo);

end

function[qRatGreater,qRatLesser]=selectRationalValues(roundingMethod,qGreater,qLesser)

    if strcmpi(roundingMethod,'floor')
        qRatGreater=qGreater;
        qRatLesser=qLesser;
    elseif strcmpi(roundingMethod,'ceiling')
        qRatGreater=qLesser;
        qRatLesser=qGreater;
    else
        qRatGreater=qGreater;
        qRatLesser=qGreater;
    end

end
