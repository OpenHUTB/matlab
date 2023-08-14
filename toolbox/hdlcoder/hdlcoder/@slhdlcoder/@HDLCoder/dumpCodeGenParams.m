function dumpCodeGenParams(this)


    this.hdlMakeCodegendir;
    dumpBaseName=this.ModelName;
    outputDir=this.hdlGetCodegendir;
    fullPath=fullfile(outputDir,[this.getParameter('module_prefix'),dumpBaseName,'_params.txt']);

    cli=this.getCLI;
    mcc=this.getConfigManager.MergedConfigContainer;
    db=this.getImplDatabase;

    str1=cli.dumpParamsStr(false);
    str2=mcc.dumpConfigStr(db);
    dumpStr=[str1,sprintf('\n'),str2];

    disp(' ');
    hdldisp(message('hdlcoder:hdldisp:DumpParams',hdlgetfilelink(fullPath)));

    pfid=fopen(fullPath,'w');
    if pfid
        fprintf(pfid,'%s',dumpStr);
        fclose(pfid);
    else
        error(message('hdlcoder:engine:FileNotFound',fullPath));
    end
end
