function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;
    hasidxport=strcmpi(get_param(slbh,'IdxMode'),'Variable');
    hasfillvalues=strcmpi(get_param(slbh,'FillMode'),'on');

    if hasidxport

        sel=hC.SLInputSignals(end);


        selsltype=hdlsignalsltype(sel);
        [selsize,~,~]=hdlwordsize(selsltype);

        if(selsize==1&&~hasfillvalues)
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:VariableSelector:validateBlock:fillmodeoff'));
        end

        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
        if nfpMode&&sel.Type.baseType.isFloatType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcommon:nativefloatingpoint:unsupportedfloatindex'));
        end
    end
end
