function v=validateBlock(this,hC)







    bfp=hC.SimulinkHandle;
    v=hdlvalidatestruct;

    in=hC.PirInputPorts(1).Signal;
    out=hC.PirOutputPorts(1).Signal;


    if isfinite(in.SimulinkRate)&&in.SimulinkRate~=out.SimulinkRate
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DTCMismatchedRates'));
    end


    if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
        [isInputValidFlt,~,isInputSingle,isInputDouble,isInputHalf]=targetmapping.isValidDataType(in.Type);
        [isOutputValidFlt,~,isOutputSingle,isOutputDouble,isOutputHalf]=targetmapping.isValidDataType(out.Type);
        if(isInputValidFlt||isOutputValidFlt)

            if(nfpMode)

                roundMode=get_param(bfp,'RndMeth');
                if(isInputDouble)&&(~isInputValidFlt||~isOutputValidFlt)&&strcmpi(roundMode,'Ceiling')
                    isBooleanType=out.Type.getLeafType.isBooleanType||in.Type.getLeafType.isBooleanType;
                    if~isBooleanType
                        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPDataConvFixedError'));
                    end
                end

                convtype=get_param(bfp,'ConvertRealWorld');


                if~(isInputValidFlt&&isOutputValidFlt)
                    if strcmpi(convtype,'Stored Integer (SI)')
                        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPDataConvSIError'));
                    end
                end



                sat=get_param(bfp,'DoSatur');
                if strcmp(sat,'on')
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPDataConvSatError'));
                end


                if(isInputValidFlt&&~isOutputValidFlt)
                    outType=out(1).Type.getLeafType;
                    if(outType.isNumericType())
                        FL=abs(outType.FractionLength);
                        WL=outType.WordLength;
                        if isInputHalf
                            flprecision=11;
                        elseif isInputSingle
                            flprecision=24;
                        else
                            flprecision=53;
                        end

                        if FL<flprecision
                            guardbits=flprecision-FL;
                        else
                            guardbits=0;
                        end



                        if(WL+guardbits)>127
                            msgObj=message('hdlcommon:nativefloatingpoint:DTCLargeWL',WL);
                            v(end+1)=hdlvalidatestruct(1,msgObj);

                        end
                    end
                end

                nfpOptions=this.getNFPImplParamInfo;
                if nfpOptions.Latency~=int8(0)
                    in=hC.SLInputSignals(1);
                    out1=hC.PirOutputSignals;
                    outType=out1.Type.getLeafType;
                    in1=hC.PirInputSignals;
                    inType=in1.Type.getLeafType;
                    if inType.isSingleType
                        dataType='SINGLE';
                    elseif inType.isHalfType
                        dataType='HALF';
                    elseif inType.isDoubleType
                        dataType='DOUBLE';
                    else
                        dataType='NUMERICTYPE';
                    end

                    dataType=[dataType,'_TO_'];

                    if outType.isSingleType
                        dataType=[dataType,'SINGLE'];
                    elseif outType.isHalfType
                        dataType=[dataType,'HALF'];
                    elseif outType.isDoubleType
                        dataType=[dataType,'DOUBLE'];
                    else
                        dataType=[dataType,'NUMERICTYPE'];
                    end

                    fc=hdlgetparameter('FloatingPointTargetConfiguration');
                    ipSettings=fc.IPConfig.getIPSettings('Convert',dataType);
                    if~isempty(ipSettings)&&(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                        dataType,'Convert'));
                    end
                    if~isempty(ipSettings)&&(nfpOptions.Latency==int8(4))&&(nfpOptions.CustomLatency>ipSettings.MaxLatency)
                        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
                        hC.getBlockPath,num2str(ipSettings.MaxLatency)));
                    end



                    if~isempty(ipSettings)&&(nfpOptions.Latency==int8(4))&&(isInputHalf||isOutputHalf)
                        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomizedLatencyIPError',...
                        dataType,'Convert'));
                    end
                end


                if(isInputHalf&&isOutputDouble)||(isInputDouble&&isOutputHalf)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPDataConvHalfDoubleUnsupported'));
                end
            else




                if(isInputSingle&&isOutputDouble)||(isInputDouble&&isOutputSingle)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:singleDoubleDtcUnsupported'));
                end


                roundMode=get_param(bfp,'RndMeth');
                if~strcmpi(roundMode,'Nearest')
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:RoundModeMustBeNearest'));
                end
                if(in.Type.isComplexType||out.Type.isComplexType)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NfpComplexPortDataUnsupported'));
                end

                if isOutputValidFlt&&isUfixType(in.Type)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InputDataTypeCannotBeUnsigned'));
                end
                if isInputValidFlt&&isUfixType(out.Type)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:OutputDataTypeCannotBeUnsigned'));
                end



                if targetcodegen.targetCodeGenerationUtils.isXilinxMode()
                    fixType=[];
                    if targetmapping.isValidDataType(in.Type)&&~targetmapping.isValidDataType(out.Type)

                        fixType=out.Type;
                    elseif targetmapping.isValidDataType(out.Type)&&~targetmapping.isValidDataType(in.Type)

                        fixType=in.Type;
                    end
                    if~isempty(fixType)
                        if fixType.isArrayType
                            fixType=fixType.BaseType;
                        end
                        if fixType.WordLength<4

                            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedWordLengthForXilinx'));
                        end
                    end
                end


            end
        end
    else
        isdouble=hdlsignalisdouble([in,out]);
        if any(isdouble==true)&&any(isdouble==false)
            bfph=get_param(bfp,'Handle');
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:illegalconversiondtc',...
            [get(bfph,'Path'),'/',get(bfph,'Name')]));
        end

        isenum=[in.Type.BaseType.isEnumType,out.Type.BaseType.isEnumType];
        if any(isenum==true)&&any(isenum==false)
            isMatrixType=[in.Type.isMatrix,out.Type.isMatrix];
            if any(isMatrixType==true)
                bfph=get_param(bfp,'Handle');
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unsupportedconversiondtcenummatrix',...
                [get(bfph,'Path'),'/',get(bfph,'Name')]));
            end
        end
    end

    in1signal=hC.PirInputPorts(1).Signal;
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end

end

function flag=isUfixType(type)
    flag=false;
    if type.isArrayType
        type=type.BaseType;
    end
    if type.isFloatType()||type.isComplexType
        return;
    end
    flag=~type.Signed;
end


