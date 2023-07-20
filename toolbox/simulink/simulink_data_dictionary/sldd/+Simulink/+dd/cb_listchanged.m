function cb_listchanged(h,other)

    if isempty(h.getListSelection)
        h.UserData.tb_LinkAction.enabled='off';
        h.UserData.tb_DictEdit.setEnabled(false);
    else
        h.UserData.tb_LinkAction.enabled='on';
        h.UserData.tb_DictEdit.setEnabled(true);
    end

end