function hyperlink=getHDLCoderHyperLink(filename,displayString)




    import matlab.internal.lang.capability.Capability;

    if nargin==1
        displayString=filename;
    end

    if Capability.isSupported(Capability.LocalClient)

        hyperlink=sprintf('<a href="matlab:web(''%s'')">%s</a>',...
        filename,displayString);
    else

        hyperlink=sprintf(...
        '<a href="matlab:hdlcoder.report.openDdg(''%s'')">%s</a>',...
        filename,displayString);
    end

end
