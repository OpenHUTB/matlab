function optionDlg=openOptionDlg(reqset,preSelect)



    optionDlg=slreq.report.OptionDlg.getOptionDlg('create',reqset,preSelect);
    optionDlg.show(preSelect);
end

