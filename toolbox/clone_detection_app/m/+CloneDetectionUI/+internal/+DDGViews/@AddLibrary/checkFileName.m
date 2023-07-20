function valid=checkFileName(filename)


    if~isempty(filename)

        if length(filename)>63
            valid=0;
            errordlg(DAStudio.message('sl_pir_cpp:creator:IllegalName3'));
        elseif~isempty(regexp(filename,'\W','once'))
            valid=0;
            errordlg(DAStudio.message('sl_pir_cpp:creator:IllegalName1_lib'));
        elseif~isempty(regexp(filename,'^[\d_]','once'))
            valid=0;
            errordlg(DAStudio.message('sl_pir_cpp:creator:IllegalName2_lib'));
        else
            valid=1;
        end
    else
        valid=0;
    end

end

