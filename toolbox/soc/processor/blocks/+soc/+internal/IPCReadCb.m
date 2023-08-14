function varargout=IPCReadCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end


function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH)
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

    locSetMaskHelp(blkH);

    try
        validateattributes(blkP.DataLength,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0},'','Queue length');
        validateattributes(blkP.NumBuffers,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0},'','Number of buffers');
        ipcReadDataPort=[blkPath,'/data'];
        hwMsgRcvBlk=[blkPath,'/Variant/SIM/HWSW Message Receive'];
        set_param(hwMsgRcvBlk,...
        'QueueLength',num2str(blkP.NumBuffers),...
        'DataTypeStr',get_param(blkH,'DataType'),...
        'Dimensions',num2str(blkP.DataLength));



        set_param(ipcReadDataPort,'OutDataTypeStr',get_param(blkH,'DataType'));
        set_param(ipcReadDataPort,'PortDimensions',num2str(blkP.DataLength));

        ipcReadCgBlk=[blkPath,'/Variant/CODEGEN/IPC Read'];
        set_param(ipcReadCgBlk,...
        'NumBuff',num2str(blkP.NumBuffers),...
        'DataType',get_param(blkH,'DataType'),...
        'BuffSize',num2str(blkP.DataLength));
        soc.internal.setBlockIcon(blkH,'socicons.IPCRead');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_ipcread'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function[vis,ens]=DataTypeCb(blkH,val,vis,ens,~)
    if(startsWith(val,'Bus: '))






        try
            equivalentStruct=Simulink.Bus.createMATLABStruct(extractAfter(val,'Bus: '));
        catch



            return;
        end

        structCmd=getStructCmd(equivalentStruct);
        set_param(blkH,'StructForBus',char(structCmd));
    end
end


function out=getStructCmd(structIn)

    out="struct(";
    fieldNames=fieldnames(structIn);
    for i=1:numel(fieldNames)
        name=fieldNames{i};
        value=structIn.(name);

        if(isstruct(value))
            out=out+strjoin(["'",name,"'",",",getStructCmd(value)],'');
        else
            out=out+strjoin(["'",name,"'",",",class(value),"(zeros(",string(size(value,1)),",",string(size(value,2)),"))"],'');
        end

        if(i~=numel(fieldNames))
            out=out+",";
        end
    end
    out=out+")";
end


