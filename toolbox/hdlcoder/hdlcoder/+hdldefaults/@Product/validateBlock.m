function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    [rnd,sat,inputSigns,~,nfpOptions,blockOptions]=this.getBlockInfo(hC);
    multKind=blockOptions.mulKind;
    sat=strcmpi(sat,'Saturate');

    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    out=hC.SLOutputSignals(1);
    in1signal=hC.PirInputPorts(1).Signal;
    numInputPorts=hC.NumberOfPirInputPorts;
    insigType=in1signal.Type;


    if(numInputPorts==1&&insigType.isMatrix)
        blkName=get_param(hC.SimulinkHandle,'Name');
        if(~insigType.is2DMatrix&&out.Type.isArrayType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:toomanydimsforblock',...
            blkName,insigType.NumberOfDimensions,in1signal.Name));
        end
    end


    if targetmapping.mode(out)
        complexType=out.Type.isComplexType;


        complexBaseType=out.Type.BaseType.isComplexType;
        if numInputPorts==1
            if any(strcmpi({'*','1'},inputSigns))
                if nfpMode

                    if(in1signal.Type.isArrayType)&&(prod(in1signal.Type.Dimensions)>3)
                        v(end+1)=hdlvalidatestruct(3,...
                        message('hdlcommon:nativefloatingpoint:TreeArchHasLessLatency'));
                    end
                else
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:OnlyTreeArchSupported'));
                end
            elseif strcmpi(inputSigns,'/')
                if targetcodegen.targetCodeGenerationUtils.isXilinxMode()
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:ReciprocalNotSupportedByXilinx'));
                elseif nfpMode&&complexType
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:NfpComplexPortDataUnsupported'));
                end
                if strcmp(multKind,'Matrix(*)')
                    in1signal=hC.PirInputSignals(1);
                    in1Type=in1signal.Type;
                    in1Dim=in1Type.getDimensions;
                    in1MI1x1=(in1Dim(1)==1);
                    in1MI2x2=(in1Dim(1)==2&&in1Dim(2)==2);
                    if(~in1MI1x1&&~in1MI2x2)
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcoder:validate:MatrixReciprocalUnsupportedForInputSizeMoreThan2x2'));
                    end
                    if complexBaseType
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcommon:nativefloatingpoint:NfpComplexPortDataUnsupported'));
                    end
                end
            end
        else
            if strcmp(inputSigns,'//')
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unsupportedfloatingpointinputsign'));
            end

            mulKind=get_param(hC.SimulinkHandle,'Multiplication');







            signCount=count(inputSigns,'*');
            isMulKindisMatrix=(strcmpi(mulKind,'Matrix(*)'));

            isSignCountNotEqual=~(signCount==numInputPorts);


            isSignNumberNotEqual=~strcmpi(inputSigns,num2str(numInputPorts));
            if(isMulKindisMatrix)




                if(isSignCountNotEqual&&isSignNumberNotEqual)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:UnsupportedSignsMatrixMultiplication'));
                end
            end
            if nfpMode


                if((complexType)&&(numInputPorts>2))
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:NfpComplexPortDataGtTwoUnsupported'));
                end





                if(complexType||complexBaseType)...
                    &&((isSignCountNotEqual...
                    &&isSignNumberNotEqual...
                    &&~isMulKindisMatrix)...
                    ||(isMulKindisMatrix&&~strcmpi(inputSigns,'2')&&~strcmpi(inputSigns,'**')))
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:NfpComplexPortDataUnsupported'));
                end

                if~(strcmp(this.getMatMulKind,'linear')||strcmp(this.getMatMulKind,'scalarized'))&&(isMulKindisMatrix)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:UnsupportedDotProductStrategy'));
                end

                inType=in1signal.Type;
                if isMulKindisMatrix&&isHalfType(inType.getLeafType)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:UnsupportedHalfMatrixMultiply'));
                end
            end

        end
        out1=hC.PirOutputSignals;
        outType=out1.Type.getLeafType;
        if outType.isSingleType
            dataType='SINGLE';
        elseif outType.isHalfType
            dataType='HALF';
        else
            dataType='DOUBLE';
        end

        if nfpOptions.Latency~=int8(0)&&nfpMode
            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            if contains(inputSigns,'/')
                ipSettings=fc.IPConfig.getIPSettings('Div',dataType);
                if(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                    dataType,'Div'));
                end

                if strcmpi(dataType,'HALF')
                    if nfpOptions.Radix==4
                        maxLatency=14;
                    else
                        maxLatency=ipSettings.MaxLatency;
                    end
                elseif strcmpi(dataType,'DOUBLE')
                    if nfpOptions.Radix==4
                        maxLatency=35;
                    else
                        maxLatency=ipSettings.MaxLatency;
                    end
                else
                    maxLatency=ipSettings.MaxLatency-24+12*(4/nfpOptions.Radix);
                end
            else
                ipSettings=fc.IPConfig.getIPSettings('Mul',dataType);
                if(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                    dataType,'Mul'));
                end
                maxLatency=ipSettings.MaxLatency;
            end

            if(nfpOptions.Latency==int8(4))&&(nfpOptions.CustomLatency>maxLatency)
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
                hC.getBlockPath,num2str(maxLatency)));
            end
        end

        if nfpMode


            if(strcmpi(dataType,'HALF'))
                localMultiplyStrategyCheck=nfpOptions.MantMul==uint8(2);
            else
                localMultiplyStrategyCheck=((nfpOptions.MantMul==uint8(2)||nfpOptions.MantMul==uint8(3)));
            end


            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            mantissaMultiplyStrategy=fc.LibrarySettings.MantissaMultiplyStrategy;

            if(strcmpi(dataType,'HALF'))
                globalMutliplyStrategyCheck=strcmpi(mantissaMultiplyStrategy,'PartMultiplierPartAddShift');
            else
                globalMutliplyStrategyCheck=strcmpi(mantissaMultiplyStrategy,'PartMultiplierPartAddShift')||...
                strcmpi(mantissaMultiplyStrategy,'NoMultiplierFullAddShift');
            end
            if(strcmpi(inputSigns,'2')||strcmpi(inputSigns,'**'))
                if(strcmpi(dataType,'DOUBLE'))



                    if((nfpOptions.MantMul==uint8(0)&&globalMutliplyStrategyCheck)||localMultiplyStrategyCheck)
                        v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:InvalidMantissaMultiplyStrategyForDouble'));
                    end


                elseif(strcmpi(dataType,'HALF'))



                    if((nfpOptions.MantMul==uint8(0)&&globalMutliplyStrategyCheck)||localMultiplyStrategyCheck)
                        v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:InvalidMantissaMultiplyStrategyForHalf'));
                    end
                end
            end
        end
        return;
    end


    if contains(inputSigns,'/')
        if numInputPorts==1
            if~in1signal.Type.isComplexType
                outsignal=hC.PirOutputSignals(1);
                recip=hdl.reciprocal;
                v=[v,recip.validateBlock(in1signal,outsignal,sat,rnd)];
            end

        else
            if~strcmp(inputSigns,'*/')
                mcnt=count(inputSigns,"*");
                dcnt=count(inputSigns,"/");
                if(mcnt>1)||(dcnt>1)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:unsupportedfixedpointinputsign'));
                end
            end
        end
    end

    v=[v,this.validateDSPStyle(hC)];
end





