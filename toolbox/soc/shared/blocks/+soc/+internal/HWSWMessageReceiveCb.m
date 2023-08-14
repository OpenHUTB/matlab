function varargout=HWSWMessageReceiveCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function MaskInitFcn(blkH)%#ok<*DEFNU>

    persistent hadError
    if isempty(hadError)
        hadError=false;
    end



    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    try
        MessageType=get_param(blkH,'MessageType');
        set_param(blkH,'MessageID',['HWSWMetadataID.',MessageType]);
        set_param(blkH,'QueueLengthNum',num2str(blkP.QueueLength));

        EnableDonePort=get_param(blkH,'EnableDonePort');
        hDoneVariant=[blkPath,'/Done Variant'];
        switch EnableDonePort
        case 'on'
            set_param(hDoneVariant,'LabelModeActiveChoice','DoneOn');
        case 'off'
            set_param(hDoneVariant,'LabelModeActiveChoice','DoneOff');
        end

        hDataUnpack=[blkPath,'/Data Unpack'];
        valueSourceWhenQueueEmpty=get_param(blkH,'ValueSourceWhenQueueIsEmpty');
        if isequal(valueSourceWhenQueueEmpty,'Hold last value')
            set_param(hDataUnpack,'holdOutput','on');
        else
            set_param(hDataUnpack,'holdOutput','off');
        end
        set_param(hDataUnpack,'QueueLength',get_param(blkH,'QueueLengthNum'));
        set_param(hDataUnpack,'CheckQueueLength',EnableDonePort);

    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    soc.internal.HWSWMessageTypeDef();
end

