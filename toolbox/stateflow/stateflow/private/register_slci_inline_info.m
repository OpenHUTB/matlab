function register_slci_inline_info(hCodegenMgr,modelName)




    if~sf('Feature','SLCIInlineInfo')
        return;
    end

    infoStruct=infomatman('load','binary',modelName,modelName,'rtw');
    CGModel=get_param(modelName,'CGModel');

    if~isfield(infoStruct,'slciInlineInfo')||isempty(infoStruct.slciInlineInfo)
        return;
    end

    dmrFile=fullfile(hCodegenMgr.BuildDirectory,'codedescriptor.dmr');
    codeDesc=mf.zero.Model;
    mfdatasource.attachDMRDataSource(dmrFile,...
    codeDesc,mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);


    for i=1:numel(infoStruct.slciInlineInfo)
        info=infoStruct.slciInlineInfo{i};


        tablerec=coder.descriptor.SourceTagLocation(codeDesc);

        tablerec.SID=info.SID;
        tablerec.Filename=info.Filename;
        tablerec.Offset=info.Offset;
        tablerec.Length=info.Length;


        fcall=coder.descriptor.FunctionCallSourceLocation(codeDesc);

        fcall.FunctionCallID=info.FunctionCallID;
        fcall.SourceLocation=tablerec;


        nfcall=coder.descriptor.NonInlinedFunctionCalls(codeDesc);

        nfcall.ChartSID=info.ChartSID;
        nfcall.CallPath='';
        nfcall.FunctionCallID=info.FunctionCallID;
        nameToUse=info.FunctionName;

        renamed=CGModel.getRenamedFunctionForStateflow(info.FunctionID);
        if(~isempty(renamed))
            nameToUse=renamed;
        end
        nfcall.FunctionName=nameToUse;


    end


