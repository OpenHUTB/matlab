function disp(this)



    hCP=this.getCPObj;

    if~isempty(hCP)
        disp(sprintf('           ModelName : %s',this.ModelName));
        disp(sprintf('       StartNodeName : %s',this.getStartNodeName));
        disp(sprintf('      TargetLanguage : %s',hCP.CLI.TargetLanguage));
        disp(sprintf('    CodeGenDirectory : %s',hCP.CLI.TargetDirectory));
        disp(sprintf('           TimeStamp : %s',this.TimeStamp));
    end

    if this.CodeGenSuccessful
        disp(sprintf('   CodeGenSuccessful : yes '));
    end

    disp(' ');

