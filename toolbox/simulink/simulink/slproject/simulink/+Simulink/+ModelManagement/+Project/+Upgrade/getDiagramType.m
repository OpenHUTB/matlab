function jType=getDiagramType(file)




    try
        path=sls_resolvename(char(file));
        type=Simulink.MDLInfo(path).BlockDiagramType;
        jType=com.mathworks.toolbox.slprojectsimulink.upgrade.DiagramType.valueOf(upper(type));
    catch
        jType=com.mathworks.toolbox.slprojectsimulink.upgrade.DiagramType.MODEL;
    end

end

