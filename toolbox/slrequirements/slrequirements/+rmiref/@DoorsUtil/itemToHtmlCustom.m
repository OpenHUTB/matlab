function html=itemToHtmlCustom(moduleId,item,cols)
    modulePrefix=rmidoors.getModuleAttribute(moduleId,'Prefix');
    data={'ID';[modulePrefix,item(item~='#')]};
    if isempty(cols{2})
        moduleDescription=rmidoors.getModuleAttribute(moduleId,'Description');
        objHeading=rmidoors.getObjAttribute(moduleId,item,'Object Heading');
        objText=rmidoors.getObjAttribute(moduleId,item,'textAsHtml');
        value=['<font size="+1">',objHeading,'</font><br/>',objText];
        data(:,end+1)={moduleDescription;value};
    else
        value=rmidoors.getObjAttribute(moduleId,item,'textAsHtml');
        data(:,end+1)={'Object Text';value};
    end
    for i=1:length(cols)
        attr=cols{i};
        if isempty(attr)||any(strcmp(attr,{'Object Identifier'}))
            continue;
        else
            value=rmidoors.getObjAttribute(moduleId,item,sprintf('@%d',i-1));
            data(:,end+1)={attr;value};%#ok<AGROW>
        end
    end


    pictureHtml=rmiref.DoorsUtil.pictureObjToHtml(moduleId,item);
    if~isempty(pictureHtml)
        data{2,2}=[data{2,2},newline,pictureHtml];
    end

    html=rmiut.arrayToHtmlTable(data,struct('header',true));

end
