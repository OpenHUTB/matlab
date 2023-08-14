function varargout=ADCReadCb(func,blkH,varargin)





    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end


function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function InitFcn(~)
    soc.internal.HWSWMessageTypeDef();
end


function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function MaskInitFcn(blkH)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    locSetMaskHelp(blkH);

    try

        adcReadCgBlk=[blkPath,'/Variant/CODEGEN/ADC Read'];

        if isequal(get_param(codertarget.utils.getModelForBlock(blkH),'SimulationStatus'),'stopped')
            hwMsgRcvBlk=[blkPath,'/Variant/SIM/HWSW Message Receive'];
            set_param(hwMsgRcvBlk,...
            'DataTypeStr',get_param(blkH,'DataType'));

            set_param(adcReadCgBlk,...
            'DataType',get_param(blkH,'DataType'));

        end
        soc.internal.setBlockIcon(blkH,'socicons.ADC');
        inPort1=sprintf('port_label(''input'',1, '''')');
        outPort1=sprintf('port_label(''output'',1, '''')');





        set_param(blkPath,'BlockSID',codertarget.peripherals.utils.getBlockSID(blkH,false));


        BlockSID=codertarget.peripherals.utils.getBlockSID(blkH,true);
        set_param(adcReadCgBlk,'BlockID',BlockSID);
        fullLabel=sprintf('%s;\n %s;',...
        inPort1,outPort1);
        set_param(blkH,'MaskDisplay',fullLabel);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function setPeripheralConfigButtonVisibility(blkH)

    codertarget.peripherals.utils.setBlockMaskButtonVisibility(blkH,'PeripheralConfigBtn');
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_adcread'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


