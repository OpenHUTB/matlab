function common_block_setup(blkHandle)







    saveEdCB='simmechanics.sli.internal.model_editor_callback(bdroot(gcbh),''save'');';
    closeEdCB='simmechanics.sli.internal.model_editor_callback(bdroot(gcbh),''close'');';

    cbacks.LoadFcn={rtmCB('LoadFcn')};
    cbacks.PreDeleteFcn={rtmCB('PreDeleteFcn')};
    cbacks.DeleteFcn={rtmCB('DeleteFcn')};
    cbacks.PreCopyFcn={rtmCB('PreCopyFcn')};
    cbacks.CopyFcn={rtmCB('CopyFcn')};
    cbacks.PreSaveFcn={rtmCB('PreSaveFcn')};
    cbacks.PostSaveFcn={saveEdCB,rtmCB('PostSaveFcn')};

    cbacks.ModelCloseFcn={closeEdCB,rtmCB('ModelCloseFcn')};

    cbfs=fields(cbacks);
    for idxA=1:length(cbfs);
        cbStr=get_param(blkHandle,cbfs{idxA});
        cbss=cbacks.(cbfs{idxA});
        for idxB=1:length(cbss)
            if isempty(cbStr)
                cbStr=sprintf('%s',cbStr,cbss{idxB});
            else
                cbStr=sprintf('%s\n%s',cbStr,cbss{idxB});
            end
        end
        set_param(blkHandle,cbfs{idxA},cbStr);
    end

end

function rcb=rtmCB(cb)

    rcb=['simmechanics.sli.internal.rtm_callback(''',cb,''',gcbh)'];
end
