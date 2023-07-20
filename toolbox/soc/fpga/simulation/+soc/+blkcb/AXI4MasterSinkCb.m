function varargout=AXI4MasterSinkCb(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end


function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH);
end


function InitFcn(blkH)


    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    hsb.blkcb2.defineTypes(bdroot(blkH));

end



function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    SetMaskHelp(blkH);

    try

        try
            validateattributes(blkP.ChFrameSampleTime,{'numeric'},{'row'});
            if numel(blkP.ChFrameSampleTime)>2,throw();end
            validateattributes(blkP.ChFrameSampleTime(1),{'numeric'},{'positive'});
            if numel(blkP.ChFrameSampleTime)>1
                validateattributes(blkP.ChFrameSampleTime(2),{'numeric'},{'nonnegative','<',blkP.ChFrameSampleTime(1)});
            end
        catch
            error(message('Simulink:SampleTime:InvTsParamSetting_Vector',blkPath,'SampleTime'));
        end


        [ChLength,ChCompLength,~]=hsb.blkcb2.cbutils('GetChLength',blkP.ChDimensions,blkP.ChBitPacked);
        [ChWidth,~,~,ChContainerType,~]=hsb.blkcb2.cbutils('GetChWidths',blkP.ChType,ChCompLength,'src');

        blkDP.ChWidth=ChWidth;
        blkDP.ChContainerType=ChContainerType;
        blkDP.ChLength=ChLength;
        blkDP.ChCompLength=ChCompLength;
        blkDP.CHFLATTENLEN=blkDP.ChLength*blkDP.ChCompLength;

        max=uint32(4096/ceil(blkDP.ChWidth/8));
        if(blkP.MaxRandomTL<1)
            blkDP.MaxRandomTL=1;
        elseif(blkP.MaxRandomTL>max)
            blkDP.MaxRandomTL=max;
        end

        if(blkP.EMProb<0)
            blkDP.EMProb=0;
        elseif(blkP.EMProb>1)
            blkDP.EMProb=1;
        end

        if strcmp(blkP.SaveData,'on')
            vs='Logger';
        else
            vs='NoLogger';
        end
        set_param([blkPath,'/Log/LogInput'],'OverrideUsingVariant',vs);


        cellfun(@(x)(set_param(blkH,x,num2str(blkDP.(x)))),fieldnames(blkDP));

        SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.AXIMasterSink');

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=RandomTLCb(~,val,vis,ens,idxMap)
    if strcmpi(val,'on')
        ens{idxMap('TransferLen')}='off';
    else
        ens{idxMap('TransferLen')}='on';
    end
    ens{idxMap('MaxRandomTL')}=val;
end

function[vis,ens]=SaveDataCb(~,val,vis,ens,idxMap)
    vis{idxMap('SavedName')}=val;
end

function[vis,ens]=ErraticModeCb(~,val,vis,ens,idxMap)
    ens{idxMap('EMProb')}=val;
end

function SetMaskHelp(blkH)

    helpTopic='soc_a4msink';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'');',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH)

    set_param(blkH,'MaskDisplay','');
end



