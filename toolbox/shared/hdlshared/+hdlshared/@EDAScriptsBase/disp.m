function disp(this)


    fprintf('SLHDLC Script Generator\n');

    fprintf('          TopLevelEntity : %s\n',this.TopLevelName);
    fprintf('          TargetLanguage : %s\n',this.TargetLanguage);
    fprintf('        CodeGenDirectory : %s\n',this.CodeGenDirectory);

    fprintf('   GenerateCompileDoFile : %d\n',this.GenerateCompileDoFile);
    fprintf('       GenerateSimDoFile : %d\n',this.GenerateSimDoFile);
    fprintf('  GenerateSimProjectFile : %d\n',this.GenerateSimProjectFile);
    fprintf('   GenerateSynthesisFile : %d\n',this.GenerateSynthesisFile);
    fprintf('         GenerateMapFile : %d\n\n',this.GenerateMapFile);
end
