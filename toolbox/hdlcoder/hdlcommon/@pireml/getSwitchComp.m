function switchComp=getSwitchComp(hN,inSignals,outSignals,zeroBasedIndex,roundingMode,overflowMode,compName)








    if nargin<7
        compName='';
    end

    if nargin<6
        overflowMode='wrap';
    end

    if nargin<5
        roundingMode='floor';
    end

    if nargin<4
        zeroBasedIndex=0;
    end



    outType=outSignals(1).Type;



    tcOut=hdlhandles(numel(inSignals),1);
    tcOut(1)=inSignals(1);
    for ii=2:numel(inSignals)
        inType=inSignals(ii).Type;
        inLeafType=inType.getLeafType;
        if outType.isArrayType
            outLeafType=outType.getLeafType;
            if inType.isArrayType

                if~outLeafType.isEqual(inLeafType)
                    tcOut(ii)=pireml.insertDTCCompOnInput(hN,inSignals(ii),...
                    outType,roundingMode,overflowMode);
                else
                    tcOut(ii)=inSignals(ii);
                end
            else

                if~outLeafType.isEqual(inLeafType)
                    scalarIn=pireml.insertDTCCompOnInput(hN,inSignals(ii),...
                    outLeafType,roundingMode,overflowMode);
                else
                    scalarIn=inSignals(ii);
                end

                tcOut(ii)=pirelab.scalarExpand(hN,scalarIn,outType.getDimensions);
            end
        elseif~outType.isEqual(inLeafType)
            tcOut(ii)=pireml.insertDTCCompOnInput(hN,inSignals(ii),...
            outType,roundingMode,overflowMode);
        else
            tcOut(ii)=inSignals(ii);
        end
    end

    if numel(inSignals)>3

        error(message('hdlcommon:hdlcommon:MPSwitchNotSupported'));
    elseif numel(inSignals)==3

        bmp={1,zeroBasedIndex};
        if tcOut(1).Type.isArrayType
            sels=pirelab.demuxSignal(hN,tcOut(1));
            in1s=pirelab.demuxSignal(hN,tcOut(2));
            in2s=pirelab.demuxSignal(hN,tcOut(3));
            muxComp=pirelab.getMuxOnOutput(hN,outSignals);
            outs=muxComp.InputSignals;
            for ii=1:tcOut(1).Type.getDimensions
                switchComp=hN.addComponent2(...
                'kind','cgireml',...
                'Name',compName,...
                'InputSignals',[sels(ii),in1s(ii),in2s(ii)],...
                'OutputSignals',outs(ii),...
                'EMLFileName','hdleml_switch_multiport',...
                'EMLParams',bmp,...
                'EMLFlag_ParamsFollowInputs',false);
                switchComp.runWebRenaming(false);
                if targetmapping.isValidDataType(outSignals(1).Type)
                    switchComp.setSupportTargetCodGenWithoutMapping(true);
                end
            end
        else
            switchComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',compName,...
            'InputSignals',tcOut,...
            'OutputSignals',outSignals,...
            'EMLFileName','hdleml_switch_multiport',...
            'EMLParams',bmp,...
            'EMLFlag_ParamsFollowInputs',false);
            switchComp.runWebRenaming(false);
            if targetmapping.isValidDataType(outSignals(1).Type)
                switchComp.setSupportTargetCodGenWithoutMapping(true);
            end
        end
    else


        bmp={0,zeroBasedIndex,0};
        switchComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',tcOut,...
        'OutputSignals',outSignals,...
        'EMLFileName','hdleml_switch_multiport',...
        'EMLParams',bmp,...
        'EMLFlag_ParamsFollowInputs',false);
        switchComp.runWebRenaming(false);
        if targetmapping.isValidDataType(outSignals(1).Type)
            switchComp.setSupportTargetCodGenWithoutMapping(true);
        end
    end
