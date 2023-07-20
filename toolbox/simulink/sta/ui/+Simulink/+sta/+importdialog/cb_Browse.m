function fullfilename=cb_Browse





    titleString=getString(message('sl_web_widgets:importdialog:ImportDataTitle'));




    [fullfilename]=Simulink.sta.util.browseForFile(true,titleString);

end

