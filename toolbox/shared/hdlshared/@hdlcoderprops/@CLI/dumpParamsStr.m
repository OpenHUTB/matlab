function str=dumpParamsStr(this,includeHidden)





    str=[];

    allParamNames=this.getAllHDLCoderProps(includeHidden);
    nonDefParamNames=this.getNonDefaultHDLCoderProps;

    maxParamWidth=max(cellfun(@length,allParamNames));
    totalWidth=maxParamWidth+10;
    fmtStr=sprintf('%%-%d.%ds : %%s\n',totalWidth,maxParamWidth);


    str=[str,repmat('%%',1,35),sprintf('\n')];
    str=[str,sprintf('All HDL code generation parameters\n')];
    str=[str,repmat('%%',1,35),sprintf('\n\n')];

    for ii=1:length(allParamNames)
        paramName=allParamNames{ii};
        val=this.(paramName);
        str=[str,sprintf(fmtStr,paramName,this.toString(val,paramName))];%#ok<*AGROW>
    end


    if~isempty(nonDefParamNames)
        str=[str,sprintf('\n')];
        str=[str,[repmat('%%',1,35),sprintf('\n')]];
        str=[str,sprintf('Non default settings\n')];
        str=[str,repmat('%%',1,35),sprintf('\n\n')];

        for ii=1:length(nonDefParamNames)
            paramName=nonDefParamNames{ii};
            val=this.(paramName);
            str=[str,sprintf(fmtStr,paramName,this.toString(val,paramName))];
        end
    end
