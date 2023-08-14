function valid=engineLicenseCheck()







    valid=~isempty(builtin('license','inuse','Signal_Integrity_Toolbox'));
end