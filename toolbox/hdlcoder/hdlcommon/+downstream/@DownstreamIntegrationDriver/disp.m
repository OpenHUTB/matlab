function disp(obj,varargin)





    if~obj.cmdDisplay||obj.cliDisplay
        return;
    end



    fprintf('------------------ Downstream Integration Driver ------------------\n\n');
    obj.hToolDriver.hEngine.engineDisp(varargin{:});


    fprintf('         TargetTool : %s\n',[obj.get('Tool'),' ',obj.hToolDriver.getToolVersion]);
    if~obj.isBoardEmpty
        fprintf('     TargetPlatform : %s\n',obj.get('Board'));
    end
    fprintf('     TargetToolPath : %s\n',obj.hToolDriver.getToolPath);
    fprintf('        ProjectName : <a href="matlab:downstream.handle(''Model'',''%s'').openTargetTool;">%s</a>\n',obj.hCodeGen.ModelName,obj.hToolDriver.hTool.ProjectFileName);
    fprintf('        ProjectPath : %s\n',obj.getProjectPath);
    fprintf('      CustomHDLFile : %s\n',obj.getCustomHDLFile);
    fprintf('      StartNodeName : %s\n',obj.hCodeGen.StartNodeName);
    fprintf('        CodeGenPath : %s\n',obj.hCodeGen.CodegenDir);
    fprintf('   CodeGenTimeStamp : %s\n',obj.hCodeGen.TimeStamp);


    obj.dispButton;

end