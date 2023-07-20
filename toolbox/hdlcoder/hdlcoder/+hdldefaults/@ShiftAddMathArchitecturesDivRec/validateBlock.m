function v=validateBlock(this,hC)






    ports=this.getAllSLInputPorts(hC);


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);
    blockInfo=this.getBlockInfo(hC);

    rnd=blockInfo.rndMode;
    sat=blockInfo.ovMode;
    inputSigns=blockInfo.inputSigns;







    if contains(inputSigns,'/')
        in1signal=hC.PirInputSignals(1);
        outsignal=hC.PirOutputSignals(1);
        numInputPorts=hC.NumberOfPirInputPorts;
        in1BaseType=getPirSignalBaseType(in1signal.Type);
        outBaseType=getPirSignalBaseType(outsignal.Type);
        if in1signal.Type.isRecordType
            invectsize=numel(in1signal.Type.MemberTypesFlattened);
        else
            invectsize=max(hdlsignalvector(in1signal));
        end

        bfp=hC.SimulinkHandle;

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

        if(isPortTypeFloat)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:InvalidArchdivide',hC.Name));
            return;
        end
        if(isPortTypeComplex)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:produnsupportedcomplexdivide'));
            return;
        end

        if numInputPorts==1
            if(~strcmpi(rnd,'zero'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipRnd'));
            end

            if(~strcmp(get_param(bfp,'SaturateOnIntegerOverflow'),'on'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipsat'));
            end
            if(invectsize>1)
                if(in1signal.Type.isRecordType)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipBus'));
                else
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorshiftadd'));
                end
            end
            WL=in1BaseType.Wordlength;
            if(WL>63)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:makehdl:unsupportedwordlengthShiftAddDivision',WL,hC.Name));
            else
                if(blockInfo.numeratorTypeInfo.zWL>63)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:wordlengthOverflowDivideReciprocal'));
                end
            end

        elseif numInputPorts==2
            if strcmpi(inputSigns,'//')
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unsupportedfixedpointinputsign'));
            end
            if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))
                WL=max(in1BaseType.Wordlength,in2BaseType.Wordlength);
                if(WL>63)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:makehdl:unsupportedwordlengthShiftAddDivision',WL,hC.Name));
                end
            else
                if(blockInfo.maxWl+abs(blockInfo.fractiondiff+1)>63)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:wordlengthOverflowDivideReciprocal'));
                end

            end

            checkTargetDivRound=isfield(get_param(bdroot,'ObjectParameters'),'TargetIntDivRoundTo');
            if~(strcmpi(rnd,'Zero')||(strcmpi(rnd,'Simplest')&&...
                checkTargetDivRound&&~strcmpi(get_param(bdroot(getfullname(hC.SimulinkHandle)),...
                'TargetIntDivRoundTo'),'Floor')))
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:produnsupportedrnd'));
            end

            if strcmpi(sat,'Wrap')
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:produnsupportedsat'));
            end
            in1Type=in1signal.Type;
            in2Type=in2signal.Type;
            outType=outsignal.Type;
            if in1signal.Type.isRecordType
                in1Dim=numel(in1Type.MemberTypesFlattened);
                in2Dim=numel(in2Type.MemberTypesFlattened);
                outDim=outType.getDimensions;
            else
                in1Dim=in1Type.getDimensions;
                in2Dim=in2Type.getDimensions;
                outDim=outType.getDimensions;
            end




            if any(in1Dim~=outDim)||(any(in2Dim~=outDim)&&~isscalar(in2Dim))
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:prodmixedscalarvector'));
            end

        else
            mcnt=count(inputSigns,"*");
            dcnt=count(inputSigns,"/");
            if(mcnt>1)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unsupportedfixedpointinputsign'));
            elseif(dcnt>1)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unsupportedfixedpointinputsign'));
            end
        end

        if strcmpi(blockInfo.inputSigns,'/')
            if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))
                iterNum=outBaseType.Wordlength;
            else
                Input1WordLength=in1BaseType.Wordlength;
                iterNum=Input1WordLength+abs(blockInfo.fractiondiff);
            end
        else

            sig1Signedness=in1BaseType.Signed;
            sig2Signedness=in2BaseType.Signed;
            if(strcmpi(blockInfo.OutType,'Inherit: Inherit via internal rule'))

                iterNum=outBaseType.Wordlength;
            else
                Input1FractionLength=in1BaseType.Fractionlength;
                Input2FractionLength=in2BaseType.Fractionlength;
                outputFractionLength=outBaseType.Fractionlength;
                fractiondiff=Input1FractionLength-Input2FractionLength-outputFractionLength;
                Input1WordLength=in1BaseType.Wordlength;
                Input2WordLength=in2BaseType.Wordlength;
                iterNum=max(Input1WordLength,Input2WordLength)+abs(fractiondiff)+1;
            end

            if((sig1Signedness==1&&sig2Signedness==0)||(sig1Signedness==0&&sig2Signedness==1))
                iterNum=iterNum+1;
            end
        end
        if(strcmpi(blockInfo.latencyStrategy,'CUSTOM'))
            totalPipelinestages=iterNum+4;
            if(blockInfo.customLatency>totalPipelinestages)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:fixedpointAddShiftCustomLatencyError',num2str(blockInfo.customLatency),hC.Name,num2str(totalPipelinestages),num2str(outBaseType.Wordlength)));
            end
        end
    end
end





