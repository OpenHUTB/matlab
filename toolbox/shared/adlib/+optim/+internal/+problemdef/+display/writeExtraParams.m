function extraParamsStr=writeExtraParams(extraParams,showLink)





















    extraParamsStr="";


    if numel(extraParams)==0
        return
    end


    for i=1:numel(extraParams)
        thisParam=extraParams{i};
        truncatedSign="";
        if numel(thisParam)>20


            thisParam=thisParam(1:20);%#ok<NASGU> used in evalc below
            truncatedSign="    :"+newline+"    :"+newline;
        end

        thisStr=string(evalc('display(thisParam);'));

        thisStr=extractAfter(thisStr,"="+optionalPattern(whitespacePattern)...
        +newline)+truncatedSign;
        thisStr=replace(thisStr,newline,'\n');

        thisStr=i_removeHTMLTags(thisStr);


        if showLink
            thisStr=replace(thisStr,"'","''");
        end

        extraParamsStr=extraParamsStr+"  extraParams{"+i+"}:"+...
        "\n"+"\n"+thisStr+"\n";
    end


    if showLink&&numel(extraParams)>0&&matlab.internal.display.isHot&&~isdeployed
        extraParamsStr=sprintf('<a href="matlab: fprintf(''%s'')">',extraParamsStr)+"extraParams</a>";
    else



        extraParamsStr=replace(extraParamsStr,"\n",newline);
    end

    function output=i_removeHTMLTags(input)

        output=regexprep(input,'<(\w+).*?>','');
        output=regexprep(output,'</a>','');

