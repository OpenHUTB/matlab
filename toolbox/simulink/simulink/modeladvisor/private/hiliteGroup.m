function hiliteGroup(varargin)









    last_Group=hilitedSystem;

    if(~isempty(last_Group))
        try
            hilite_system(last_Group,'none');
        catch %#ok<CTCH>
            last_Group={};
            hilitedSystem(last_Group);
        end
    end
    try
        last_Group=varargin{1};



        last_Group=strsplit(last_Group,'|');
        Simulink.ID.hilite(last_Group,'find');
        hilitedSystem(last_Group);
    catch %#ok<CTCH>
        warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
        return;
    end