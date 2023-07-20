function setCS(h,cs,dlg,~)

    h.Fail=false;

    if h.IsSelected
        h.Status='InProgress';
        h.setDlg(dlg);
        if isa(h.Diff,'DAStudio.Dialog')
            delete(h.Diff);
        end
        try
            delete(h.ErrDlg);
        catch %#ok
        end

        try
            oldCS=replaceConfigSet(h.Name,cs.copy);
            h.PreCS=oldCS.copy;
            h.PostCS=cs.copy;


            [c1,t1]=resolveConfigSet(h.PreCS,h.Name);
            [c2,t2]=resolveConfigSet(h.PostCS,h.Name);

            if t2
                if t1


                    [~,d]=isequal(c1,c2);
                    h.DiffNum=length(d);
                else


                    h.DiffNum=[];
                end
            else

                h.DiffNum=NaN;
            end

            h.Status='Converted';
            h.Fail=false;
        catch e
            h.Status='Initial';
            h.Fail=true;
            h.ErrMessage=e;
            if~h.GUI
                disp(configset.util.message(e));
            end
        end
    else
        h.Status='Skipped';
        h.Fail=false;
    end

    h.setDlg(dlg);


