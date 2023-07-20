function plc_clean_temp_project_dir



    if slfeature('rtwcgir')<6&&(~plcfeature('PLCPPLevel'))&&exist(fullfile(pwd,'rtwgen_tlc'),'dir')
        rmdir('rtwgen_tlc','s');
    end
end


