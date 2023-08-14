function registerVariableParser(className)



    parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    parser.registerVariableParser(className);
end
