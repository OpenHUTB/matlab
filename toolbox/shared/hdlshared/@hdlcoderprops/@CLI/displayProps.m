function displayProps(this,modelName,nonDefaults)%#ok<INUSL>





    if nargin<3
        nonDefaults=true;
    end





    if nonDefaults
        paramNames=this.getNonDefaultHDLCoderProps;
    else
        paramNames=this.getAllHDLCoderProps(false);
    end

    maxParamWidth=max(cellfun(@length,paramNames));
    totalWidth=maxParamWidth+10;
    fmtStr=sprintf('%%-%d.%ds : %%s\n',totalWidth,maxParamWidth);



    if nonDefaults
        hdrTxt='HDL CodeGen Parameters (non-default)';
    else
        hdrTxt='HDL CodeGen Parameters';
    end






    repStr=repmat('%',1,length(hdrTxt)+3);
    str=sprintf('\n%s\n%s\n%s\n\n',repStr,hdrTxt,repStr);


    if~isempty(paramNames)
        for ii=1:length(paramNames)
            paramName=paramNames{ii};
            val=this.(paramName);
            str=[str,sprintf(fmtStr,paramName,this.toString(val,paramName))];%#ok<AGROW>
        end
    end

    disp(str);

end
