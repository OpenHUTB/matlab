function varargout=StreamDataSourceCb(varargin)




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

function StopFcn(blkH)


    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    vble=get_param(blkH,'VbleName');
    evalin('base',['clear ',vble,'Temp;']);

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


        [ChWidth,~,~,ChContainerType,~]=hsb.blkcb2.cbutils('GetChWidths',blkP.ChType,1,'src');

        blkDP.ChWidth=ChWidth;
        blkDP.ChContainerType=ChContainerType;
        blkDP.ChLength=prod(blkP.ChDimensions);
        blkDP.ChCompLength=1;
        blkDP.ChTLASTCount=ceil(blkP.BufferLen/blkDP.ChLength);
        blkDP.CHFLATTENLEN=blkDP.ChLength*blkDP.ChCompLength;

        if(blkP.EMProb<0)
            blkDP.EMProb=0;
        elseif(blkP.EMProb>1)
            blkDP.EMProb=1;
        end

        blkDP.CntrInitValue=soc.internal.validateValueByDT(blkP.CntrInitValue,blkP.ChType);

        blkDP.DataVbleName=['"',get_param(blkH,'VbleName'),'"'];


        cellfun(@(x)(set_param(blkH,x,num2str(blkDP.(x)))),fieldnames(blkDP));


        Simulink.suppressDiagnostic([blkPath,'/A4S Source BFM'],'Stateflow:Runtime:DataOverflowErrorMSLD');

        SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.StreamDataSource');

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=DataGenModeCb(~,val,vis,ens,idxMap)
    if contains(val,'counter')
        vis{idxMap('CntrInitValue')}='on';
    else
        vis{idxMap('CntrInitValue')}='off';
    end
    if contains(val,'workspace')
        vis{idxMap('VbleName')}='on';
    else
        vis{idxMap('VbleName')}='off';
    end
end

function[vis,ens]=ErraticModeCb(~,val,vis,ens,idxMap)
    ens{idxMap('EMProb')}=val;
end

function[vis,ens]=RandomDelayITCb(~,val,vis,ens,idxMap)
    vis{idxMap('minDelay')}=val;
    vis{idxMap('maxDelay')}=val;
    if strcmp(val,'off')
        vis{idxMap('trnsfrdelay')}='on';
    else
        vis{idxMap('trnsfrdelay')}='off';
    end
end

function SetMaskHelp(blkH)

    helpTopic='soc_streamdatasource';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'');',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH)

    set_param(blkH,'MaskDisplay','');
end



