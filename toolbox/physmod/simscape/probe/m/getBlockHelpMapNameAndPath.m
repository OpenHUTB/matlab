function varargout=getBlockHelpMapNameAndPath(blockType)




    import simscape.compiler.sli.internal.HelpMap;
    persistent MAP;
    if isempty(MAP)
        MAP=HelpMap('SimscapeProbe','simscapeprobe');
    end
    [varargout{1:nargout}]=MAP.getBlockHelpInfo(blockType);
end