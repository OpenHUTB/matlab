function cgxe_delete_file(fileName,force)



    if nargin<2
        force=false;
    end

    if force
        if ispc
            cgxe_dos(['attrib -r "',fileName,'"']);
        else
            [~,~]=unix(['chmod +w ',fileName]);
        end
    end

    if ispc
        cgxe_dos(['del /f /q "',fileName,'"']);
    else
        [~,~]=unix(['\rm -f ',fileName]);
    end
