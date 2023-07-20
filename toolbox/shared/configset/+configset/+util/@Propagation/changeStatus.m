function changeStatus(h,ori,des)

    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        if strcmp(v.Status,ori)
            v.Status=des;
            v.setDlg(h.Dialog);
        end
    end
