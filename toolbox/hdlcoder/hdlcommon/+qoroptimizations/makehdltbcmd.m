function cmd=makehdltbcmd(model,chip,codeFolder)



    cmd=sprintf('makehdltb(''%s/%s'', ''TargetDirectory'', ''%s'');',...
    model,chip,codeFolder);
end

