function isBuiltIn=util_is_simulink_builtin(dataStr)
    isBuiltIn=sl('sldtype_is_builtin',dataStr)||...
    fixed.internal.type.is64BitIntPattern(dataStr);
end