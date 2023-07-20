function blockInfo=getBlockInfo(this,hC)





    slbh=hC.SimulinkHandle;
    sat=get_param(slbh,'DoSatur');
    originalBlkPath=getfullname(slbh);
    blockInfo.OutType=get_param(originalBlkPath,'OutDataTypeStr');
    if strcmp(sat,'on')
        blockInfo.ovMode='Saturate';
    else
        blockInfo.ovMode='Wrap';
    end
    blockInfo.rndMode=get_param(slbh,'RndMeth');
    blockInfo.inputSigns=strtrim(get_param(slbh,'Inputs'));

    if strcmp(blockInfo.inputSigns,'/*')
        blockInfo.firstInputSignDivide=true;
        blockInfo.inputSigns='*/';
    else
        blockInfo.firstInputSignDivide=false;
    end


    blockInfo.networkName=get_param(slbh,'Name');

    if(isempty(this.getImplParams('UsePipelines')))
        blockInfo.pipeline='on';
    else
        blockInfo.pipeline=this.getImplParams('UsePipelines');
    end

    if(isempty(this.getImplParams('CustomLatency')))
        blockInfo.customLatency=0;
    else
        blockInfo.customLatency=this.getImplParams('CustomLatency');
    end

    if(isempty(this.getImplParams('LatencyStrategy')))
        blockInfo.latencyStrategy='MAX';
    else
        blockInfo.latencyStrategy=this.getImplParams('LatencyStrategy');
    end

    if contains(blockInfo.inputSigns,'/')
        in1signal=hC.PirInputSignals(1);
        outsignal=hC.PirOutputSignals(1);
        numInputPorts=hC.NumberOfPirInputPorts;
        in1BaseType=getPirSignalBaseType(in1signal.Type);
        outBaseType=getPirSignalBaseType(outsignal.Type);
        if(numInputPorts==2)
            in2signal=hC.PirInputSignals(2);
            in2BaseType=getPirSignalBaseType(in2signal.Type);
        end

        if(in1BaseType.isFloatType||outBaseType.isFloatType)
            isPortTypeFloat=true;
        elseif(numInputPorts==2)
            isPortTypeFloat=in2BaseType.isFloatType;
        else
            isPortTypeFloat=false;
        end

        if(in1BaseType.isComplexType||outBaseType.isComplexType)
            isPortTypeComplex=true;
        elseif(numInputPorts==2)
            isPortTypeComplex=in2BaseType.isComplexType;
        else
            isPortTypeComplex=false;
        end



        if(~(isPortTypeFloat||isPortTypeComplex))
            if(numInputPorts==2)


                if(blockInfo.firstInputSignDivide)
                    in1signal=hC.PirInputSignals(2);
                    in2signal=hC.PirInputSignals(1);
                    in1BaseType=getPirSignalBaseType(in1signal.Type);
                    in2BaseType=getPirSignalBaseType(in2signal.Type);
                end

                Input1FractionLength=in1BaseType.Fractionlength;
                Input2FractionLength=in2BaseType.Fractionlength;
                outputFractionLength=outBaseType.Fractionlength;
                fractiondiff=Input1FractionLength-Input2FractionLength-outputFractionLength;
                blockInfo.numeratorTypeInfo.zType=in1BaseType;
                blockInfo.numeratorTypeInfo.zWL=blockInfo.numeratorTypeInfo.zType.WordLength;
                blockInfo.numeratorTypeInfo.zSign=blockInfo.numeratorTypeInfo.zType.Signed;
                blockInfo.denominatorTypeInfo.dType=in2BaseType;
                blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dType.WordLength;
                blockInfo.denominatorTypeInfo.dSign=blockInfo.denominatorTypeInfo.dType.Signed;
                blockInfo.quotientTypeInfo.QType=outBaseType;
                blockInfo.quotientTypeInfo.QWL=blockInfo.quotientTypeInfo.QType.WordLength;
                blockInfo.quotientTypeInfo.QFL=blockInfo.quotientTypeInfo.QType.FractionLength;
                blockInfo.fractiondiff=fractiondiff;


                Input1WordLength=blockInfo.numeratorTypeInfo.zWL;
                Input2WordLength=blockInfo.denominatorTypeInfo.dWL;
                if(Input1WordLength>=Input2WordLength)
                    maxWl=Input1WordLength;
                else
                    maxWl=Input2WordLength;
                end
                blockInfo.maxWl=maxWl;
                if(~strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))

















                    if(fractiondiff>0)

                        if(blockInfo.numeratorTypeInfo.zSign)
                            blockInfo.numeratorTypeInfo.zType=hdlcoder.tp_sfixpt(blockInfo.numeratorTypeInfo.zWL+abs(fractiondiff),Input1FractionLength);
                            blockInfo.numeratorTypeInfo.zWL=blockInfo.numeratorTypeInfo.zWL+(fractiondiff);
                        else
                            blockInfo.numeratorTypeInfo.zType=hdlcoder.tp_ufixpt(blockInfo.numeratorTypeInfo.zWL+abs(fractiondiff),Input1FractionLength);
                            blockInfo.numeratorTypeInfo.zWL=blockInfo.numeratorTypeInfo.zWL+(fractiondiff);
                        end
                    else

                        if(blockInfo.denominatorTypeInfo.dSign)
                            blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_sfixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input2FractionLength);
                            blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
                        else
                            blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_ufixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input2FractionLength);
                            blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
                        end
                    end




                    if(blockInfo.numeratorTypeInfo.zSign==blockInfo.denominatorTypeInfo.dSign)
                        if(abs(fractiondiff)~=0)
                            blockInfo.quotientTypeInfo.QType=hdlcoder.tp_ufixpt(maxWl+abs(fractiondiff)+1,outputFractionLength);
                        else
                            blockInfo.quotientTypeInfo.QType=hdlcoder.tp_ufixpt(maxWl+1,outputFractionLength);
                        end
                        blockInfo.quotientTypeInfo.QWL=blockInfo.quotientTypeInfo.QType.WordLength;
                        blockInfo.quotientTypeInfo.QFL=blockInfo.quotientTypeInfo.QType.FractionLength;
                    else
                        if(abs(fractiondiff)~=0)
                            blockInfo.quotientTypeInfo.QType=hdlcoder.tp_sfixpt(maxWl+abs(fractiondiff)+1,outputFractionLength);
                        else
                            blockInfo.quotientTypeInfo.QType=hdlcoder.tp_sfixpt(maxWl+1,outputFractionLength);
                        end
                        blockInfo.quotientTypeInfo.QWL=blockInfo.quotientTypeInfo.QType.WordLength;
                        blockInfo.quotientTypeInfo.QFL=blockInfo.quotientTypeInfo.QType.FractionLength;
                    end

                end
            else

                Input1FractionLength=in1BaseType.Fractionlength;
                outputFractionLength=outBaseType.Fractionlength;
                blockInfo.denominatorTypeInfo.dType=in1BaseType;
                blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dType.WordLength;
                blockInfo.denominatorTypeInfo.dSign=blockInfo.denominatorTypeInfo.dType.Signed;
                fractiondiff=-Input1FractionLength-outputFractionLength;
                blockInfo.fractiondiff=fractiondiff;
                if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))
                    maxWl=outBaseType.WordLength;
                else
                    maxWl=blockInfo.denominatorTypeInfo.dWL;
                end
                blockInfo.numeratorTypeInfo.zWL=maxWl;
                if(~strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))

                    if(blockInfo.denominatorTypeInfo.dSign)
                        blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_sfixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input1FractionLength);
                        blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
                    else
                        blockInfo.denominatorTypeInfo.dType=hdlcoder.tp_ufixpt(blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff),Input1FractionLength);
                        blockInfo.denominatorTypeInfo.dWL=blockInfo.denominatorTypeInfo.dWL+abs(fractiondiff);
                    end
                    blockInfo.numeratorTypeInfo.zWL=maxWl+abs(fractiondiff);
                end
            end
        end
    end
end
