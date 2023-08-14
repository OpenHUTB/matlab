function closeCB(this,closeAction)




    hDlg=this.hHost;
    tag='Tag_ConfigSet_Objective_LaunchModelAdvisor';
    setEnabled(hDlg,tag,false);

    if strcmpi(closeAction,'ok')

        rootStr='^Simulink Root/';
        system=regexprep(this.SelectedSystem,rootStr,'');

        try
            coder.advisor.internal.runBuildAdvisor(system,true,true);
        catch E
            setEnabled(hDlg,tag,true);
            err=errordlg(E.message);

            set(err,'tag','CGA_error_dialog');
            setappdata(err,'MException',E);
        end

    end

    setEnabled(hDlg,tag,true);

