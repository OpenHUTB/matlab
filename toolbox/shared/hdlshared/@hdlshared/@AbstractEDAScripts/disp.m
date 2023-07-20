function disp(this)




    disp(sprintf('SLHDLC Script Generator\n'));

    disp(sprintf('          TopLevelEntity : %s',this.TopLevelName));
    disp(sprintf('          TargetLanguage : %s',this.TargetLanguage));
    disp(sprintf('        CodeGenDirectory : %s',this.CodeGenDirectory));

    disp(sprintf('   GenerateCompileDoFile : %d',this.GenerateCompileDoFile));
    disp(sprintf('       GenerateSimDoFile : %d',this.GenerateSimDoFile));
    disp(sprintf('  GenerateSimProjectFile : %d',this.GenerateSimProjectFile));
    disp(sprintf('   GenerateSynthesisFile : %d',this.GenerateSynthesisFile));
    disp(sprintf('         GenerateMapFile : %d',this.GenerateMapFile));


    if this.ScriptGenSuccessful
        disp(sprintf('ScriptGenSuccessful : yes '));
    end

    disp('');

