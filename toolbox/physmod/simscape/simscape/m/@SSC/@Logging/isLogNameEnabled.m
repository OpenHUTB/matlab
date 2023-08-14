function isEnabled=isLogNameEnabled(hSource,~)






    isEnabled=~strcmpi(hSource.SimscapeLogType,'none');

end
