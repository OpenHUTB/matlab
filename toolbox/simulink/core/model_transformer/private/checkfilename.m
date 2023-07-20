function filename=checkfilename(filename,defaultname,libname)
    if nargin<3
        libname=false;
    end

    if~isempty(filename)
        if length(filename)>63
            DAStudio.error('sl_pir_cpp:creator:IllegalName3');
        elseif~isempty(regexp(filename,'\W','once'))
            if libname
                DAStudio.error('sl_pir_cpp:creator:IllegalName1_lib');
            else
                DAStudio.error('sl_pir_cpp:creator:IllegalName1');
            end
        elseif~isempty(regexp(filename(1),'[\d_]','once'))
            if libname
                DAStudio.error('sl_pir_cpp:creator:IllegalName2_lib');
            else
                DAStudio.error('sl_pir_cpp:creator:IllegalName2');
            end
        end
    else
        filename=defaultname;
    end
end