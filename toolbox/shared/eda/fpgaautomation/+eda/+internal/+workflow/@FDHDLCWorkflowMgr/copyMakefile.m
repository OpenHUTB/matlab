function copyMakefile(h,makeFile,fpgaSrc)








    str=fileread(makeFile);




    expr='(?<=ISE_HELPER *:= *)\S+';
    newdef='ise_helper.tcl';
    str=regexprep(str,expr,newdef);


    expr='(?<=BUILD_DIR *:= *)\S+';
    newdef='./';
    str=regexprep(str,expr,newdef);


    expr='(?<=PROJ_FILE *:= *)\S+';
    newdef=['$(BUILD_DIR)',h.mWorkflowInfo.userParam.projectName,'.ise'];
    str=regexprep(str,expr,newdef);


    expr='(?<=SOURCE_ROOT *:= *)\S+';
    newdef=fpgaSrc;
    str=regexprep(str,expr,newdef);





    expr_src='export SOURCES *:= *.*?(?<![\\\n\r])[\n\r]+';
    [srcdef,idx1,idx2]=regexp(str,expr_src,'match','start','end');
    srcdef=srcdef{1};




    expr='[\w/]*?dsp_core_tx.v *\\?[\r\n]+';
    srcdef=regexprep(srcdef,expr,'');
    expr='[\w/]*?dsp_core_rx.v *\\?[\r\n]+';
    srcdef=regexprep(srcdef,expr,'');





    expr='coregen/[\w/]+\.\w+ *\\?[\n\r]+';
    corefiles=regexp(srcdef,expr,'match');
    srcdef=regexprep(srcdef,expr,'');


    line1=sprintf('export SOURCES_CORE := \\\n');
    lastcorefile=regexprep(corefiles{end},'\\','\n');
    coresrcdef=[line1,corefiles{1:end-1},lastcorefile];


    str=[str(1:idx1-1),srcdef,coresrcdef,str(idx2+1:end)];


    h.writeTclScript('Makefile',str,'',false);

