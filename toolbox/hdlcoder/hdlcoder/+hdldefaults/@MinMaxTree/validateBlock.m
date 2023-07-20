function v=validateBlock(this,hC)


    v=hdlvalidatestruct;
    blockDSPInfo=[];

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=this.getSysObjInfo(sysObjHandle);
        if~strcmpi(blockInfo.fcnString,'Running')
            operOver=sysObjHandle.Dimension;
        else
            operOver='unknown';
        end

        if strcmp(blockInfo.blockType,'dsp')
            [blockDSPInfo,v]=this.getSysObjInfoDSP(hC,v);
        end
    else
        blockInfo=this.getBlockInfo(hC);
        if strcmpi(blockInfo.blockType,'dsp')
            operOver=get_param(hC.SimulinkHandle,'operateOver');
        else
            operOver='unknown';
        end

        if strcmp(blockInfo.blockType,'dsp')
            blockDSPInfo=this.getBlockInfoDSP(hC);
        end

    end

    fcn_string=blockInfo.fcnString;

    inType=getPirSignalLeafType(hC.PirInputSignals(1).Type);
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    if isNFPMode&&inType.isFloatType()
        if~strcmpi(fcn_string,'Value')
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:UnsupportedMinMaxMode'));
        end
    end

    if strcmpi(fcn_string,'Running')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportblock'));
    elseif any(strcmpi(operOver,{'Entire input','All'}))
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedEntireInputMode'));
    else
        ninputs=length(hC.SLInputPorts);
        if ninputs~=1
            basevectorsize=hdlsignalvector(hC.PirInputPorts(1).Signal);
            for ii=1:ninputs
                sig=hC.PirInputPorts(ii).Signal;
                if~isequal(hdlsignalvector(sig),basevectorsize)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:MinMaxMultipleInputsDimensions'));%#ok<AGROW>
                    break;
                end
            end
        else




            hCInSignal=hC.PirInputSignals(1);

            if isVectorOfUfix1(hCInSignal.Type)
                blockType=blockInfo.blockType;
                if~isempty(blockDSPInfo)
                    isDspVectorOut=this.isDspMinmaxVectorOut(blockDSPInfo,hCInSignal,blockType);
                    if isDspVectorOut
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcoder:validate:Vectorof1BitDatatypes'));
                    end
                end
            end
        end
    end
end

function out=isVectorOfUfix1(pirSignalType)

    pirSignalLeafType=getPirSignalLeafType(pirSignalType);

    dimLen=max(pirSignalType.getDimensions);

    if~(pirSignalLeafType.isFloatType())

        out=(pirSignalLeafType.WordLength==1)&&(dimLen>1);
    else

        out=false;
    end
end


