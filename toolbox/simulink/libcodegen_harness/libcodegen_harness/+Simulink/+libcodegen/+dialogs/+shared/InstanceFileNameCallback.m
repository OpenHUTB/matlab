function InstanceFileNameCallback(dlgSrc)
    if exist(dlgSrc.instanceFileName,'file')
        [fullpath,~,ext]=fileparts(dlgSrc.instanceFileName);
        if isempty(fullpath)||isempty(ext)
            dlgSrc.instanceFileName=which(dlgSrc.instanceFileName);
        end
    end
    Simulink.libcodegen.dialogs.shared.populateDropdown(dlgSrc);
end

