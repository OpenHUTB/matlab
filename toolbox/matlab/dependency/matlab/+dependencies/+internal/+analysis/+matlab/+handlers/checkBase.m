function workspace=checkBase(analyzer,ref,factory)




    func=ref.Function.Value;
    arg=ref.InputArguments(1);

    if~arg.IsString

        workspace=dependencies.internal.analysis.matlab.Workspace.createBaseWorkspace;
        key='MATLAB:dependency:analysis:FirstArgNotLiteralString';
        factory.warning(key,message(key,func).getString,num2str(arg.Line));

    elseif~strcmp(arg.Value,'base')

        workspace=dependencies.internal.analysis.matlab.Workspace.createBaseWorkspace;
        key='MATLAB:dependency:analysis:FirstArgNotBase';
        factory.warning(key,message(key,func).getString,num2str(arg.Line));

    else

        workspace=analyzer.BaseWorkspace;
    end

end
