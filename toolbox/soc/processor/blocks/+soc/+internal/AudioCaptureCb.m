function varargout=AudioCaptureCb(func,blkH,varargin)





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
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    try
        codeGenBlk=[blkPath,'/Variant/CODEGEN/Audio Capture'];
        if isequal(get_param(codertarget.utils.getModelForBlock(blkH),'SimulationStatus'),'stopped')
            hwMsgRcvBlk=[blkPath,'/Variant/SIM/HWSW Message Receive'];
            dataTypeStr=locGetDataTypeStr(blkP);
            set_param(hwMsgRcvBlk,...
            'DataTypeStr',dataTypeStr,...
            'Dimensions',num2str(blkP.SamplesPerFrame*blkP.NumberOfChannels));
            set_param(codeGenBlk,'NumberOfChannels',num2str(blkP.NumberOfChannels));
            set_param(codeGenBlk,'SamplesPerFrame',num2str(blkP.SamplesPerFrame));
            set_param(codeGenBlk,'DataType',dataTypeStr);
            set_param(codeGenBlk,'SampleTime',num2str(blkP.SampleTime));
        end





        set_param(blkPath,'BlockSID',codertarget.peripherals.utils.getBlockSID(blkH,false));


        blockSID=codertarget.peripherals.utils.getBlockSID(blkH,true);
        set_param(codeGenBlk,'BlockID',blockSID);
        soc.internal.setBlockIcon(blkH,'socicons.AudioCapture');
        locSetMaskHelp(blkH);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function setPeripheralConfigButtonVisibility(blkH)

    codertarget.peripherals.utils.setBlockMaskButtonVisibility(blkH,'PeripheralConfigBtn');
end


function res=locGetDataTypeStr(blkP)
    switch(blkP.DataType)
    case '8-bit integer'
        res='int8';
    case '16-bit integer'
        res='int16';
    case '32-bit integer'
        res='int32';
    end
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_audiocapture'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end
