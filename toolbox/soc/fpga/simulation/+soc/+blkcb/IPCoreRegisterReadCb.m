function varargout=IPCoreRegisterReadCb(func,blkH,varargin)



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
    REG_MAX_WORDLEN=32;

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    l_SetMaskHelp(blkH);
    try
        switch(class(blkP.OutDataTypeStr))
        case 'Simulink.NumericType'
            assert(blkP.OutDataTypeStr.WordLength<=REG_MAX_WORDLEN,message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
        case 'Simulink.AliasType'
            DataType=numerictype(eval(blkP.OutDataTypeStr.BaseType));
            assert(DataType.WordLength<=REG_MAX_WORDLEN,message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
        case 'char'
            ;%#ok<NOSEMI> %do nothing
        otherwise
            error('Data type not supported');
        end


        ConstantBlk=[blkPath,'/Variant/CODEGEN/Constant'];
        WirelessReadBlk=[blkPath,'/Variant/SIM/Wireless Read'];
        set_param(WirelessReadBlk,'DataTypeStr',get_param(blkH,'OutDataTypeStr'));
        set_param(WirelessReadBlk,'Dimensions',get_param(blkH,'OutputVectorSize'));
        set_param(ConstantBlk,'Value',get_param(blkH,'RegisterName'));
        set_param(ConstantBlk,'SampleTime',get_param(blkH,'SampleTime'));
        set_param(ConstantBlk,'OutDataTypeStr',get_param(blkH,'OutDataTypeStr'));
        l_SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.RegisterRead');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function RegisterNameCb(blkH)
    RegisterName=get_param(blkH,'RegisterName');
    if~isvarname(RegisterName)
        error('soc:msgs:InvalidRegisterName',...
        'Register name must be a valid MATLAB variable name.');
    end
end

function InitFcnCb(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end



    registerName=get_param(blkH,'RegisterName');
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    evalin('base',registerName+" = Simulink.Parameter(zeros(1,"+...
    string(blkP.OutputVectorSize)+"));");
    evalin('base',registerName+".Description = 'Tunable parameter created for ''"+getfullname(blkH)+"'' block';");
    evalin('base',registerName+".CoderInfo.StorageClass = 'ExportedGlobal';");
    evalin('base',registerName+".DataType = '"+get_param(blkH,'OutDataTypeStr')+"';");
end

function l_SetMaskDisplay(blkH)
    fulltext1=sprintf('color(''black'')');
    fulltext2=sprintf('text(0.5, 0.85, ''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')',get_param(blkH,'RegisterName'));
    md=sprintf('%s;\n%s;',fulltext1,fulltext2);
    set_param(blkH,'MaskDisplay',md);
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_ipcoreregisterread'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end
