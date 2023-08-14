function hiliteLine(varargin)








    last_line=hilitedSystem;

    if(~isempty(last_line))
        try
            hilite_system(last_line,'none');
        catch %#ok<CTCH>
            last_line={};
            hilitedSystem(last_line);
        end
    end
    try
        last_line=str2double(varargin{1});
        hilite_system(last_line,'find');
        hilitedSystem(last_line);
    catch %#ok<CTCH>
        warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
        return;
    end