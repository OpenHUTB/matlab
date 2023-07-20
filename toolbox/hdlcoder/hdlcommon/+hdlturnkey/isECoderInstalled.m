function isInstalled=isECoderInstalled




    isInstalled=license('test','RTW_Embedded_Coder')...
    &&~isempty(ver('embeddedcoder'));

end


