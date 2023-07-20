function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    if strcmp(this.Blocks,'built-in/MinMax')
        modestring=get_param(bfp,'Function');
        fcn_string='Value';
        operOver='unknown';
    elseif strcmp(this.Blocks,'dspstat3/Minimum')
        modestring='min';
        fcn_string=get_param(bfp,'fcn');
        operOver=get_param(bfp,'operateOver');
    elseif strcmp(this.Blocks,'dspstat3/Maximum')
        modestring='max';
        fcn_string=get_param(bfp,'fcn');
        operOver=get_param(bfp,'operateOver');
    else
        modestring='unknown';
        fcn_string='unknown';
        operOver='unknown';
    end

    blkName=get_param(hC.SimulinkHandle,'Name');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    isFloatType=inType.isFloatType;

    if strcmpi(hdlget_param(hC.getBlockPath,'Architecture'),'Cascade')


        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:DeprecateCascade',blkName));
    end

    if~isNFPMode||...
        (isNFPMode&&~isFloatType)
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    elseif isNFPMode&&isFloatType
        v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:CascadeArchNotSupportedOnlyTree'));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));

    if isNFPMode&&inType.isFloatType()
        if~strcmpi(fcn_string,'Value')
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:UnsupportedMinMaxMode'));
        end
    end

    if any(strcmpi(modestring,{'min','max'}))
        if strcmpi(fcn_string,'Running')
            v(end+1)=hdlvalidatestruct(1,...
            'The min/max block does not support ''Running'' option mode.',...
            'hdlcoder:validate:unsupportedblock');
        elseif strcmpi(operOver,'Entire input')
            v(end+1)=hdlvalidatestruct(1,...
            'The min/max block does not support ''Entire input'' option mode.',...
            'hdlcoder:validate:unsupportedEntireInputMode');
        else
            ninputs=length(hC.PirInputPorts);
            if ninputs~=1
                basesltype=hdlsignalsltype(hC.PirInputPorts(1).Signal);
                basevectorsize=hdlsignalvector(hC.PirInputPorts(1).Signal);
                for ii=1:ninputs
                    sig=hC.PirInputPorts(ii).Signal;
                    if~isequal(hdlsignalvector(sig),basevectorsize)
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultipleInputsDimensions'));
                        break;
                    elseif~strcmpi(hdlsignalsltype(sig),basesltype)
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultipleInputDatatypes'));
                        break;
                    end
                end
            end





            if ninputs==1
                hCInSignal=hC.PirInputSignals(1);
                if isVectorOfUfix1(hCInSignal.Type)
                    [fcnString,compType,blockType]=this.getBlockInfo(bfp);
                    isDspVectorOut=this.isDspMinmaxVectorOut(bfp,hCInSignal,blockType);
                    if isDspVectorOut
                        v(end+1)=hdlvalidatestruct(1,...
                        'The min/max block does not support 1-bit vector input datatype when input is row vector and finding min/max along column.',...
                        'hdlcoder:validate:Vectorof1BitDatatypes');

                    end
                end
            end
        end
    else
        v(end+1)=hdlvalidatestruct(1,...
        'This block mode for hdlminmaxblock is not supported',...
        'hdlcoder:validate:unsupportblock');
    end

    if(strcmpi(fcn_string,'Value and Index')&&strcmpi(hdlsignalsltype(hC.SLOutputPorts(2).Signal),'double'))||...
        (strcmpi(fcn_string,'Index')&&strcmpi(hdlsignalsltype(hC.SLOutputPorts(1).Signal),'double'))
        status=1;
        msg='The cascade implementation of Min/Max does not support double-precision Index output ports.  Please select another implementation architecture.';
        id='hdlcoder:validate:UnhandledDoubleIndex';
        v(end+1)=hdlvalidatestruct(status,msg,id);
    end


    hInSignals=hC.PirInputSignals;
    inputRate=hInSignals(1).SimulinkRate;
    if isequal(inputRate,Inf)
        v(end+1)=hdlvalidatestruct(1,'MinMax Cascade implementation does not allow Constant(Inf) input sample time.',...
        'hdlcoder:validate:InfInputRate');
    end

end

function out=isVectorOfUfix1(hT)
    out=false;

    hBT=hT.getLeafType;
    dimLen=double(max(hT.getDimensions));

    if~(hBT.isFloatType())
        out=hBT.WordLength==1&&dimLen>1;
    end

end



