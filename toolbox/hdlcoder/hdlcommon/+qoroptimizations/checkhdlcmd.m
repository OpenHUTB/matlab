function cmd=checkhdlcmd(model,chip)



    cmd=sprintf('checkhdl(''%s/%s'',''GuidedRetiming'', ''on'');',...
    model,chip);
end

