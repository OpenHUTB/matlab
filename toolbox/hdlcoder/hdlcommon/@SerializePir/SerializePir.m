classdef SerializePir<handle




    properties(Access=protected)
hPir
hTypeMap
hFiMathMap
hNumericTypeMap
hSlRateMap
outFile
indentSpace
fid
    end

    methods(Static)
        outStr=serializeAbs(hC);
        outStr=serializeAnnotation(hC);
        outStr=serializeBitSlice(hC);
        outStr=serializeBitExtract(hC);
        outStr=serializeBitConcat(hC);
        outStr=serializeBitReduce(hC);
        outStr=serializeBitRotate(hC);
        outStr=serializeBitShift(hC);
        outStr=serializeBitShiftLib(hC);
        outStr=serializeBitSet(hC);
        outStr=serializeBufferComp(hC);
        outStr=serializeCounterComp(hC);
        outStr=serializeDTCComp(hC);
        outStr=serializeDynamicBitShift(hC);
        outStr=serializeMinMax(hC);
        outStr=serializeMultiply(hC);
        outStr=serializeMultiPortSwitch(hC);
        outStr=serializeLogic(hC);
        outStr=serializeNIC(hC);
        outStr=serializeRelOp(hC);
        outStr=serializeSwitch(hC);
        outStr=serializeUnaryMinusComp(hC);
        outStr=printCompInputs(hC);
        outStr=printCompOutputs(hC);
        outStr=printPirType(slType);
        outStr=printFormatString(inStr);
    end

    methods



        function this=SerializePir(p,outFileName)
            this.hPir=p;
            this.hTypeMap=containers.Map();
            this.hFiMathMap=containers.Map();
            this.hNumericTypeMap=containers.Map();
            this.hTypeMap=containers.Map();
            this.outFile=outFileName;
            this.indentSpace='';
            this.fid=-1;
        end




        function doit(this)
            this.fid=fopen(this.outFile,'w');
            if(this.fid==-1)
                error(message('hdlcoder:engine:writedotgenfile'));
            end
            genPir(this);
            fclose(this.fid);
        end




        function setIndent(this,val)
            this.indentSpace='';
            for i=1:val
                this.indentSpace=[this.indentSpace,' '];
            end
        end

        function outStr=genStr(this,inStr,newStr)
            outStr=[inStr,this.indentSpace,newStr,'\n'];
        end





        function genPir(this)
            setIndent(this,1);
            modelName=this.hPir.ModelName;
            outPirStr=genStr(this,'',['function p = ',modelName,'_serialized()']);
            setIndent(this,4);




            outPirStr=genStr(this,outPirStr,['p = pir(''',this.hPir.Name,''');']);
            outPirStr=genStr(this,outPirStr,'hTopN = addNetworks(p);');
            outPirStr=genStr(this,outPirStr,'p.setTopNetwork(hTopN);');
            outPirStr=genStr(this,outPirStr,'createNetworks(p);');
            setIndent(this,1);
            outPirStr=genStr(this,outPirStr,'end\n');
            outPirStr=genStr(this,outPirStr,'function hTopN = addNetworks(p)');
            setIndent(this,4);
            vNtwks=this.hPir.Networks;
            numNetworks=length(vNtwks);
            for i=1:numNetworks
                hN=vNtwks(i);
                setIndent(this,4);
                outPirStr=genStr(this,outPirStr,'hN = p.addNetwork;');
                remain=hN.Name;
                while true
                    [hNName,remain]=strtok(remain,'/');%#ok<STTOK>
                    if isempty(remain),break;end
                end
                hNFullPath=hN.FullPath;
                outPirStr=genStr(this,outPirStr,['hN.Name = ','''',hNName,'''',';']);
                outPirStr=genStr(this,outPirStr,['hN.FullPath = ','''',hNFullPath,'''',';']);
                if i==1
                    outPirStr=[outPirStr,'\thTopN = hN;\n'];
                end
            end
            setIndent(this,1);
            outPirStr=genStr(this,outPirStr,'end\n');
            outPirStr=genStr(this,outPirStr,'function createNetworks(p)');
            setIndent(this,4);
            for i=numNetworks:-1:1
                hN=vNtwks(i);
                setIndent(this,4);
                hNFullPath=hN.FullPath;
                outPirStr=genStr(this,outPirStr,['hN_',hN.refNum,' = p.findNetwork(''fullname'', ','''',hNFullPath,'''',');']);
                outPirStr=genStr(this,outPirStr,['createNetwork_',hN.refNum,'(p, hN_',hN.refNum,');']);
            end
            setIndent(this,1);
            outPirStr=genStr(this,outPirStr,'end');
            fprintf(this.fid,sprintf(outPirStr));


            for i=numNetworks:-1:1
                hN=vNtwks(i);
                genNetwork(this,hN);
            end


            outStr='\nfunction hS = addSignal(hN, sigName, pirTyp, simulinkRate)\n';
            outStr=genStr(this,outStr,'\thS = hN.addSignal;');
            outStr=genStr(this,outStr,'\thS.Name = sigName;');
            outStr=genStr(this,outStr,'\thS.Type = pirTyp;');
            outStr=genStr(this,outStr,'\thS.SimulinkHandle = 0;');
            outStr=genStr(this,outStr,'\thS.SimulinkRate = simulinkRate;');
            outStr=[outStr,'end\n'];














            fprintf(this.fid,sprintf(outStr));
        end

        function outStr=genNetwork(this,hN)
            this.hTypeMap=containers.Map();
            this.hFiMathMap=containers.Map();
            this.hNumericTypeMap=containers.Map();
            this.hSlRateMap=containers.Map();
            setIndent(this,4);
            outInportStr=genInports(this,hN);
            outOutportStr=genOutports(this,hN);
            outSignalStr=genSignals(this,hN);
            [outCompStr,hasNIC]=genComponents(this,hN);
            outTypes=genTypes(this);
            outFiMaths=genFiMaths(this);
            outNTypes=genNumericTypes(this);
            outSlRates=genSLRates(this);
            setIndent(this,1);
            firstArg='~';
            if hasNIC
                firstArg='p';
            end
            outStr=genStr(this,'',['\nfunction hN = createNetwork_',hN.refNum,'(',firstArg,', hN)']);
            outStr=genStr(this,outStr,[outTypes,outFiMaths,outNTypes,outSlRates]);
            outStr=genStr(this,outStr,[outInportStr,outOutportStr,outSignalStr,outCompStr]);
            comment=hN.getComment();
            if~isempty(comment)
                ssStr=SerializePir.printFormatString(comment);
                outStr=genStr(this,outStr,['hN.addComment(',ssStr,');\n']);
            end
            setIndent(this,1);
            outStr=genStr(this,outStr,'end');
            fprintf(this.fid,sprintf(outStr));
        end

        function outStr=genTypes(this)
            setIndent(this,4);
            outStr=[];
            keys=this.hTypeMap.keys;
            for jj=1:numel(keys)
                k=keys{jj};
                pt=SerializePir.printPirType(k);
                outStr=genStr(this,outStr,[this.hTypeMap(k),' = ',pt,';']);
            end
            outStr=genStr(this,outStr,'');
        end

        function value=getType(this,key)
            if isKey(this.hTypeMap,key)
                value=this.hTypeMap(key);
            else
                value=['pirTyp',num2str(this.hTypeMap.length+1)];
                this.hTypeMap(key)=value;
            end
        end


        function outStr=genSLRates(this)
            setIndent(this,4);
            outStr=[];
            keys=this.hSlRateMap.keys;
            for jj=1:numel(keys)
                k=keys{jj};
                outStr=genStr(this,outStr,[this.hSlRateMap(k),' = ',k,';']);
            end
            outStr=genStr(this,outStr,'');
        end

        function value=getSLRate(this,rate)
            key=num2str(rate);
            if isKey(this.hSlRateMap,key)
                value=this.hSlRateMap(key);
            else
                value=['slRate',num2str(this.hSlRateMap.length+1)];
                this.hSlRateMap(key)=value;
            end
        end

        function outStr=genFiMaths(this)
            setIndent(this,4);
            outStr=[];
            keys=this.hFiMathMap.keys;
            for jj=1:numel(keys)
                k=keys{jj};
                outStr=genStr(this,outStr,[this.hFiMathMap(k),' = fimath(',k,');']);
            end
            outStr=genStr(this,outStr,'');
        end

        function value=getFiMath(this,key)
            if isKey(this.hFiMathMap,key)
                value=this.hFiMathMap(key);
            else
                value=['fiMath',num2str(this.hFiMathMap.length+1)];
                this.hFiMathMap(key)=value;
            end
        end

        function outStr=genNumericTypes(this)
            setIndent(this,4);
            outStr=[];
            keys=this.hNumericTypeMap.keys;
            for jj=1:numel(keys)
                k=keys{jj};
                outStr=genStr(this,outStr,[this.hNumericTypeMap(k),' = numerictype(',k,');']);
            end
            outStr=genStr(this,outStr,'');
        end

        function value=getNumericType(this,key)
            if isKey(this.hNumericTypeMap,key)
                value=this.hNumericTypeMap(key);
            else
                value=['nt',num2str(this.hNumericTypeMap.length+1)];
                this.hNumericTypeMap(key)=value;
            end
        end

        function outStr=genInports(this,hN)
            setIndent(this,4);
            numInports=hN.NumberOfPirInputPorts;
            hInPorts=hN.PirInputPorts;
            hInSignals=hN.PirInputSignals;
            outStr=[];
            for i=1:numInports
                hInSig=hInSignals(i);
                inportName=SerializePir.printFormatString(hInPorts(i).Name);
                insigName=SerializePir.printFormatString(hInSig.Name);
                sigType=pirgetdatatypeinfo(hInSig.Type);
                simulinkRate=hInSig.SimulinkRate;
                sigRefName=[matlab.lang.makeValidName(hInSig.Name),'_',hInSig.RefNum];
                outStr=genStr(this,outStr,['hN.addInputPort(',inportName,');']);%#ok<*AGROW>
                if~sigType.isvector
                    outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                    ,insigName,',',getType(this,sigType.sltype)...
                    ,',',getSLRate(this,simulinkRate),');']);
                else
                    dims=['[',num2str(sigType.vector),']'];
                    outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                    ,insigName,', pirelab.createPirArrayType(',getType(this,sigType.sltype),',',dims,')'...
                    ,',',getSLRate(this,simulinkRate),');']);
                end

                outStr=genStr(this,outStr,[sigRefName,'.addDriver(hN, ',num2str(i-1),');\n']);
                comment=hInSig.getComment();
                if~isempty(comment)
                    ssStr=SerializePir.printFormatString(comment);
                    outStr=genStr(this,outStr,[sigRefName,'.addComment(',ssStr,');\n']);
                end
            end

            numGenericPorts=hN.NumberOfPirGenericPorts;
            if numGenericPorts>0
                for ii=0:(numGenericPorts-1)
                    genericPortName=hN.getGenericPortName(ii);
                    genericPortValue=hN.getGenericPortValue(ii);

                    outStr=[outStr,'\t\t hN.addGenericPort(','''',genericPortName,'''',','...
                    ,this.printConstantValue([],genericPortValue),', pir_unsigned_t(32));\n'];
                end
            end
        end

        function outStr=genOutports(this,hN)
            setIndent(this,4);
            numOutports=hN.NumberOfPirOutputPorts;
            hOutSignals=hN.PirOutputSignals;
            hOutPorts=hN.PirOutputPorts;
            outStr=[];
            for i=1:numOutports
                hOutSig=hOutSignals(i);
                outportName=SerializePir.printFormatString(hOutPorts(i).Name);
                outsigName=SerializePir.printFormatString(hOutSig.Name);
                sigType=pirgetdatatypeinfo(hOutSig.Type);
                simulinkRate=hOutSignals(i).SimulinkRate;
                sigRefName=[matlab.lang.makeValidName(hOutSig.Name),'_',hOutSig.RefNum];
                outStr=genStr(this,outStr,['hN.addOutputPort(',outportName,');']);
                drivers=hOutSig.getDrivers;
                if((numel(drivers)~=1)||~(drivers.isNetworkPort))
                    if sigType.isvector
                        dims=['[',num2str(sigType.vector),']'];
                        outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                        ,outsigName,', pirelab.createPirArrayType(',getType(this,sigType.sltype),',',dims,')'...
                        ,',',getSLRate(this,simulinkRate),');']);
                    else
                        outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                        ,outsigName,',',getType(this,sigType.sltype)...
                        ,',',getSLRate(this,simulinkRate),');']);
                    end
                end

                outStr=genStr(this,outStr,[sigRefName,'.addReceiver(hN, ',num2str(i-1),');\n']);
                comment=hOutSig.getComment();
                if~isempty(comment)
                    ssStr=SerializePir.printFormatString(comment);
                    outStr=genStr(this,outStr,[sigRefName,'.addComment(',ssStr,');\n']);
                end
            end
        end

        function outStr=genSignals(this,hN)
            hSignals=hN.Signals;
            numSignals=length(hSignals);
            outStr=[];
            setIndent(this,4);
            for ii=1:numSignals
                hS=hSignals(ii);
                if hS.isNetworkInput||hS.isNetworkOutput
                    continue;
                end
                sigName=SerializePir.printFormatString(hS.Name);
                sigType=pirgetdatatypeinfo(hS.Type);
                simulinkRate=hS.SimulinkRate;
                sigRefName=[matlab.lang.makeValidName(hS.Name),'_',hS.RefNum];
                if~sigType.isvector
                    outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                    ,sigName,',',getType(this,sigType.sltype)...
                    ,',',getSLRate(this,simulinkRate),');']);
                else
                    dims=['[',num2str(sigType.vector),']'];
                    outStr=genStr(this,outStr,[sigRefName,' = addSignal(hN,'...
                    ,sigName,', pirelab.createPirArrayType(',getType(this,sigType.sltype),',',dims,')'...
                    ,',',getSLRate(this,simulinkRate),');']);
                end

                comment=hS.getComment();
                if~isempty(comment)
                    ssStr=SerializePir.printFormatString(comment);
                    outStr=genStr(this,outStr,[sigRefName,'.addComment(',ssStr,');\n']);
                end
            end
            outStr=[outStr,'\n'];
        end

        function[outStr,hasNIC]=genComponents(this,hN)
            vComps=hN.Components;
            numComps=length(vComps);
            outStr=[];
            hasNIC=false;
            for ii=1:numComps
                hC=vComps(ii);
                comment=hC.getComment();
                compStr=genComp(this,hN,hC);

                if~isempty(comment)&&~strcmp(hC.ClassName,'ntwk_instance_comp')&&~isempty(compStr)
                    ssStr=SerializePir.printFormatString(comment);
                    hCName=['hC_',num2str(ii)];
                    outStr=genStr(this,outStr,[hCName,' = ',compStr]);
                    outStr=genStr(this,outStr,[hCName,'.addComment(',ssStr,');\n']);
                else
                    outStr=genStr(this,outStr,compStr);
                end
                if strcmp(hC.ClassName,'ntwk_instance_comp')
                    hasNIC=true;
                end
            end
        end

        function outStr=genComp(this,hN,hC)
            className=hC.ClassName;
            outStr=[];

            if strcmp(className,'black_box_comp')
                return;
            end

            switch className
            case{...
                'not_comp',...
                'and_comp',...
                'or_comp',...
                'nand_comp',...
                'nor_comp',...
                'xor_comp',...
                'xnor_comp',...
                'logic_comp'}
                outStr=SerializePir.serializeLogic(hC);
            case{...
                'eq_comp',...
                'ne_comp',...
                'lt_comp',...
                'le_comp',...
                'gt_comp',...
                'ge_comp',...
                'relop_comp'}
                outStr=SerializePir.serializeRelOp(hC);
            case 'abs_comp'
                outStr=SerializePir.serializeAbs(hC);
            case 'add_comp'
                outStr=serializeAdd(this,hC);
            case 'annotation_comp'
                outStr=SerializePir.serializeAnnotation(hC);
            case 'bitconcat_comp'
                outStr=SerializePir.serializeBitConcat(hC);
            case 'bitextract_comp'
                outStr=SerializePir.serializeBitExtract(hC);
            case 'bitreduce_comp'
                outStr=SerializePir.serializeBitReduce(hC);
            case 'bitrotate_comp'
                outStr=SerializePir.serializeBitRotate(hC);
            case 'bitset_comp'
                outStr=SerializePir.serializeBitSet(hC);
            case 'bitshift_comp'
                outStr=SerializePir.serializeBitShift(hC);
            case 'bitshiftlib_comp'
                outStr=SerializePir.serializeBitShiftLib(hC);
            case 'bitslice_comp'
                outStr=SerializePir.serializeBitSlice(hC);
            case 'bitwiseop_comp'
                outStr=this.serializeBitwiseOp(hC);
            case 'buffer_comp'
                outStr=SerializePir.serializeBufferComp(hC);
            case 'c2ri_comp'
                outStr=' pirelab.getComplex2RealImag(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t','''','Real and imag','''',',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),');\n'];
            case 'comparetoconst_comp'
                outStr=this.serializeCompareToConstant(hC);
            case 'concat_comp'
                outStr=' pirelab.getMuxComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),');\n'];
            case 'const_comp'
                outStr=[outStr,' pirelab.getConstComp(hN, ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
                outStr=[outStr,'\t\t ',hC.getValue,',...\n'];
                outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),');\n'];
            case 'cordic_postquadcorrection_comp'
                outStr='hN.addComponent2( ...\n';
                outStr=[outStr,'\t\t ''kind'', ''cgireml'', ...\n'];
                outStr=[outStr,'\t\t ''Name'', ''quad_correction_after'', ...\n'];
                outStr=[outStr,'\t\t ''InputSignals'',',SerializePir.printCompInputs(hC),', ...\n'];
                outStr=[outStr,'\t\t ''OutputSignals'',',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t ''EMLFileName'', ''eml_al_cordic_quad_correction_after'', ...\n'];
                outStr=[outStr,'\t\t ''BlockComment'', ''CORDIC Quad Correction After'');\n'];
            case 'cordic_prequadcorrection_comp'
                outStr=' hN.addComponent2( ...\n';
                outStr=[outStr,'\t\t ''kind'', ''cgireml'', ...\n'];
                outStr=[outStr,'\t\t ''Name'', ''quad_correction_before'', ...\n'];
                outStr=[outStr,'\t\t ''InputSignals'', ',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t ''OutputSignals'', ',SerializePir.printCompOutputs(hC),',...\n'];
                outStr=[outStr,'\t\t ''EMLFileName'', ''eml_al_cordic_quad_correction_before'', ...\n'];
                outStr=[outStr,'\t\t ''EMLParams'', {',this.printConstantValue(hC,hC.getKConstant()),'},...\n'];
                outStr=[outStr,'\t\t ''BlockComment'', ''CORDIC Quad Correction Before'');\n'];
            case 'cordic_rotation_comp'
                iter=hC.getIteration();
                outStr=' hN.addComponent2( ...\n';
                outStr=[outStr,'\t\t ''kind'', ''cgireml'', ...\n'];
                outStr=[outStr,'\t\t ''Name'', ''kernel_iter',this.printConstantValue(hC,iter),''', ...\n'];
                outStr=[outStr,'\t\t ''InputSignals'', ',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t ''OutputSignals'', ',SerializePir.printCompOutputs(hC),',...\n'];
                outStr=[outStr,'\t\t ''EMLFileName'', ''eml_al_cordic_rotation_hdl'', ...\n'];
                outStr=[outStr,'\t\t ''EMLParams'', {',this.printConstantValue(hC,hC.getLookupTableConstant()),',',this.printConstantValue(hC,hC.getIteration()),'},...\n'];
                outStr=[outStr,'\t\t ''BlockComment'', sprintf(''CORDIC kernel iteration stage ',this.printConstantValue(hC,iter),'''));\n'];
            case 'data_conv_comp'
                outStr=SerializePir.serializeDTCComp(hC);
            case 'dynamic_shift_comp'
                outStr=SerializePir.serializeDynamicBitShift(hC);
            case 'gain_comp'
                outStr=this.serializeGain(hC);
            case 'hdlcounter_comp'
                outStr=SerializePir.serializeCounterComp(hC);
            case 'integerdelay_comp'
                outStr=this.serializeIntegerDelay(hC);
            case 'integerdelayenabledresettable_comp'
                outStr=this.serializeIntDelayEnabledResettableComp(hC);
            case 'math_comp'
                outStr=' pirelab.getMathComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', ...\n'];
                outStr=[outStr,'\t\t  -1, ...\n'];
                outStr=[outStr,'\t\t','''',hC.getFunctionName,'''',');\n'];
            case 'mconstant_comp'
                outStr=this.serializeMConstant(hC);
            case 'minmax_comp'
                outStr=SerializePir.serializeMinMax(hC);
            case 'mul_comp'
                outStr=SerializePir.serializeMultiply(hC);
            case 'multiportswitch_comp'
                outStr=SerializePir.serializeMultiPortSwitch(hC);
            case 'ntwk_instance_comp'
                outStr=SerializePir.serializeNIC(hC);
            case 'ram_dual_comp'
                initialValStr=' [] ';
                initVal=hC.getInitialVal;
                if~isempty(initVal)
                    initialValStr=initVal;
                end
                outStr=' pirelab.getDualPortRamComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', 1, 0, ...\n'];
                outStr=[outStr,'\t\t','''',num2str(hC.getReadNewData),'''',', -1, [], ...\n'];
                outStr=[outStr,'\t\t',initialValStr,');\n'];
            case 'ram_simple_dual_comp'
                initialValStr=' [] ';
                initVal=hC.getInitialVal;
                if~isempty(initVal)
                    initialValStr=initVal;
                end
                outStr=' pirelab.getSimpleDualPortRamComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', 1, ...\n'];
                outStr=[outStr,'\t\t  -1, [], '' '', ...\n'];
                outStr=[outStr,'\t\t',initialValStr,');\n'];
            case 'ram_single_comp'
                initialValStr=' [] ';
                initVal=hC.getInitialVal;
                if~isempty(initVal)
                    initialValStr=initVal;
                end
                outStr=' pirelab.getSinglePortRamComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', 1,0, ...\n'];
                outStr=[outStr,'\t\t  -1, [], '' '', ...\n'];
                outStr=[outStr,'\t\t',initialValStr,');\n'];
            case 'ratechange_comp'
                outStr=this.serializeRepeat(hC);
            case 'ratetransition_comp'
                outStr=this.serializeRTComp(hC);
            case 'ri2c_comp'
                outStr=' pirelab.getRealImag2Complex(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t','''','Real and imag','''',',...\n'];
                outStr=[outStr,'\t\t 0, ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),');\n'];
            case 'saturation_comp'
                outStr=this.serializeSaturation(hC);
            case 'scalarmac_comp'
                rndMode=hC.getRoundingMode;
                ovMode=hC.getOverflowMode;
                if~ischar(ovMode)
                    assert(false,"Unexpected type for overflow mode");
                end
                adderSigns=hC.getAdderSign;
                hwModeDelays=hC.getHwModeDelays;
                outStr=' pirelab.getScalarMACComp(hN, ... \n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t','''',rndMode,'''',',','''',ovMode,'''',','...
                ,SerializePir.printFormatString(hC.Name)...
                ,', '' '' , -1, ...\n'];
                outStr=[outStr,'\t\t','''',hwModeDelays,'''',',','''',adderSigns,'''',');\n'];
            case 'selector_comp'
                indexParam=cell2mat(hC.getIndexParamArray);
                indexOption=cell2mat(hC.getIndexOptionArray);
                outputSize=cell2mat(hC.getOutputSizeArray);
                if numel(indexParam)==1
                    outStr=['indexParamArray = {',num2str(indexParam(1)),'};\n'];
                else
                    outStr=['indexParamArray = {',num2str(indexParam(1)),':',num2str(indexParam(2)),'};\n'];
                end
                outStr=[outStr,'\t\t pirelab.getSelectorComp( hN, ...\n'];
                outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),', ...\n'];
                outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t ','''',hC.getIndexMode,'''',', {','''',indexOption,'''','},...\n'];
                outStr=[outStr,'\t\t  indexParamArray ,...\n'];
                outStr=[outStr,'\t\t {','''',num2str(outputSize),'''','},','''',hC.getNumberOfDimensions,'''',',...\n'];
                outStr=[outStr,'\t\t ','''',hC.Name,'''',');\n'];
            case 'split_comp'
                outStr=' pirelab.getDemuxComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),');\n'];
            case 'sqrt_comp'
                outStr=' pirelab.getSqrtComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', ...\n'];
                outStr=[outStr,'\t\t  -1, ...\n'];
                outStr=[outStr,'\t\t','''',hC.getFunctionName,'''',');\n'];
            case 'switch_comp'
                outStr=SerializePir.serializeSwitch(hC);
            case 'deserializer1d_comp'
                outStr=' pirecore.getDeserializer1DComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',num2str(hC.getRatio),',',num2str(hC.getIdleCycles),',',num2str(hC.getInitialValue),',',num2str(hC.getStartInPort),',',num2str(hC.getValidInPort),',',num2str(hC.getValidOutPort),',',num2str(hC.getResetInitVal),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),'); ...\n'];

            case 'serializer1d_comp'
                outStr=' pirecore.getSerializer1DComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',num2str(hC.getRatio),',',num2str(hC.getIdleCycles),',',num2str(hC.getValidInPort),',',num2str(hC.getStartOutPort),',',num2str(hC.getValidOutPort),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),'); ...\n'];
            case 'trig_comp'
                outStr=' pirelab.getTrigonometricComp(hN, ...\n';
                outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
                outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),', ...\n'];
                outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),', ...\n'];
                outStr=[outStr,'\t\t  -1, ...\n'];
                outStr=[outStr,'\t\t','''',hC.getFunctionName,'''',');\n'];
            case 'uminus_comp'
                outStr=SerializePir.serializeUnaryMinusComp(hC);
            case 'upsample_comp'
                outStr=this.serializeUpSample(hC);
            case 'unitdelay_comp'
                outStr=this.serializeUnitDelay(hC);
            case 'vectormac_comp'

            otherwise
                errMsg=message('hdlcoder:engine:pirserializenotimpl',...
                className,hC.Name,hC.RefNum,hN.Name,hN.FullPath);
                fprintf(errMsg.getString());
                mEx=MException(errMsg);
                throw(mEx);
            end


            if hC.hasGeneric&&~contains(['ntwk_instance_comp','mconstant_comp','gain_comp'],className)
                errMsg=message('hdlcoder:engine:pirserializenotimpl',...
                'Generics',hC.Name,hC.RefNum,hN.Name,hN.FullPath);
                fprintf(errMsg.getString());
                mEx=MException(errMsg);
                throw(mEx);
            end
        end
    end
end
