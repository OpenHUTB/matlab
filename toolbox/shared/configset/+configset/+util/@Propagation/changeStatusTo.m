function changeStatusTo(h,status)

    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        v.Fail=false;
        v.Status=status;
        if v.GUI
            v.setDlg(h.Dialog);
        end
    end
