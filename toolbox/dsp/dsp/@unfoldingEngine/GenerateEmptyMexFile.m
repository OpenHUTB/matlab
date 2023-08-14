function GenerateEmptyMexFile(obj)



    pStr=StringWriter();

    objDataFname=obj.data.fname;
    objDataTmpNm=obj.data.tempname;

    pStr.addcr('#include <%s.h>',objDataFname)

    pStr.addcr();
    pStr.addcr('void %s_xil_terminate(void)',objDataFname);
    pStr.addcr('{');
    pStr.addcr('}');

    pStr.addcr('void %s_xil_shutdown(void)',objDataFname);
    pStr.addcr('{');
    pStr.addcr('}');

    pStrFile=StringWriter();
    filename=fullfile(obj.data.workdirectory,'codegen',...
    [objDataTmpNm,'original'],[objDataFname,'.h']);

    readfile(pStrFile,filename);

    hfile=cellstr(pStrFile);
    startln=find(contains(hfile,[' ',objDataFname,'(']));
    endline=find(contains(hfile(startln:end),';'));


    coder.internal.errorIf((isempty(startln)||isempty(endline)),...
    'dsp:dspunfold:InternalError');

    declaration=[hfile{startln:startln+endline-1}];
    declaration=strrep(declaration,'extern ','');
    declaration=strrep(declaration,';','');

    pStr.addcr();
    pStr.addcr('%s',declaration);
    pStr.addcr('{');
    pStr.addcr('}');


    if(chars(pStr)>0)
        indentCode(pStr,'c');
        write(pStr,fullfile(obj.data.workdirectory,...
        [objDataTmpNm,'_empty_mex.c']));
    end

end
