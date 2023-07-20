function setSourceLocation(ref,location)











    if isa(ref,'Simulink.ConfigSetRef')
        if location=="base"
            ref.SourceLocation='Base Workspace';
            ref.DDName='';
        else
            ref.SourceLocation='Data Dictionary';
            ref.DDName=location;
        end
    end
