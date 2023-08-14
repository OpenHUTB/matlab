function printIncrementalCodeGenInfo(this,p)


    gp=pir;
    if(isequal(p.ModelName,gp.getTopPirCtx.ModelName))
        hdldisp(message('hdlcoder:makehdl:IncrementalCodeGenTop',p.ModelName));
    else
        hdldisp(message('hdlcoder:makehdl:IncrementalCodeGen',p.ModelName));
    end

    hdlFiles=this.cgInfo.hdlFiles;
    for i=1:length(this.cgInfo.hdlFiles)
        hdldisp(sprintf('<a href="matlab:edit(''%s'');">%s</a>',fullfile(this.hdlGetCodegendir,hdlFiles{i}),hdlFiles{i}));
    end
end
