function isEnabled=isOpNameEnabled(hSource,~)






    isEnabled=~strcmpi(hSource.InitializeFromOperatingPoint,'on');

end
