function destroy(obj,~,~)






    if isa(obj.Dlg,'DAStudio.Dialog')
        delete(obj.Dlg);
    end
    if~isempty(obj.CEF)
        obj.CEF.close();
    end

