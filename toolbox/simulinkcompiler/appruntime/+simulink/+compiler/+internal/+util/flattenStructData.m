function[Names,Values]=flattenStructData(Names,Values,name,val)




    import simulink.compiler.internal.util.flattenStructData;
    import matlab.internal.datatoolsservices.getWorkspaceDisplay;

    if isstruct(val)
        fieldNames=fieldnames(val);
        for fIdx=1:length(fieldNames)
            fn=fieldNames{fIdx};
            fv=val.(fn);
            [Names,Values]=flattenStructData(Names,Values,name+"."+fn,fv);
        end
    else
        Names=[Names;name];
        varDisplaydata=getWorkspaceDisplay({val},"value");
        strVal=varDisplaydata.Value;

        msgKey="simulinkcompiler:genapp:UnableToDisplayParameter";
        assert(isstring(strVal),"Simulink:Compiler:VariableValueIsNotString",...
        message(msgKey,name,strVal).getString);

        Values=[Values;strVal];
    end
end


