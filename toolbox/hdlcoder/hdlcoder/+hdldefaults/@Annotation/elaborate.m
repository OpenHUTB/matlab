function hNewC=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;

    [isDoc,isMdlInfo]=getBlockInfo(this,hC);

    txtStr='';
    if isMdlInfo
        txtStr=get_param(slbh,'MaskDisplayString');
        txtStr=strrep(txtStr,'\n',char(10));
    elseif isDoc
        dtype=get_param(slbh,'DocumentType');
        if strcmp(dtype,'Text')
            txtStr=docblock('getContent',slbh);
        end
    else
        try
            annotObj=get_param(slbh,'Object');
            txtStr=annotObj.PlainText();
        catch mEx
            txtStr=get_param(slbh,'Text');
        end
    end

    if~isempty(txtStr)&&ischar(txtStr)
        desc=txtStr;
    else
        desc='';
    end

    hNewC=pirelab.getAnnotationComp(hN,hC.Name,desc,slbh);

    hN.removeComponent(hC);

end
