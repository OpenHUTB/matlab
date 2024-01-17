function dialogExtensionCallback(hObj,hDlg,value,tag)

    propName=hObj.getPropFromTag(tag);

    switch propName
    case 'DPICustomizeSystemVerilogCode'
        hDlg.setEnabled('DPIGenerateTestBench',~value);
        hDlg.setEnabled('DPISystemVerilogTemplate',value);
        hDlg.setEnabled('EditDPISystemVerilogTemplate',value);
        hDlg.setEnabled('BrowseDPISystemVerilogTemplate',value);
        if value
            hDlg.setWidgetValue('DPIGenerateTestBench',false);

            hObj.DPIGenerateTestBench=false;

        end
    end

end

