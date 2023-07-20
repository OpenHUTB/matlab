function[html,cachedHtmlFile]=itemToHtml(module,item,includeAttributes)




    if nargin<3
        includeAttributes=true;
    end

    moduleId=strtok(module);


    cachedHtmlFile=rmiref.DoorsUtil.htmlFileName(moduleId,item);
    if rmiref.DoorsUtil.isUpToDate(cachedHtmlFile,moduleId,item)
        fid=fopen(cachedHtmlFile,'r');
        html=fread(fid,'*char')';
        fclose(fid);
    else

        cols=rmidoors.getModuleAttribute(moduleId,'columns');
        if isDefaultView(cols)
            html=makeDefaultView(moduleId,item,includeAttributes);
        else
            html=rmiref.DoorsUtil.itemToHtmlCustom(moduleId,item,cols);
        end

        fid=fopen(cachedHtmlFile,'w');
        fwrite(fid,html,'*char');
        fclose(fid);

        colsFid=fopen([cachedHtmlFile,'.cols'],'w');
        colsString=strcat(cols{:});
        fwrite(colsFid,colsString,'*char');
        fclose(colsFid);
    end
end

function yesno=isDefaultView(cols)
    if length(cols)==2
        yesno=strcmp(cols{1},'Object Identifier')&&isempty(cols{2});
    else
        yesno=false;
    end
end


function html=makeDefaultView(moduleId,item,includeAttributes)

    html=rmiref.DoorsUtil.itemToHtmlDefault(moduleId,item,includeAttributes);
    if includeAttributes

        html=[html,rmiref.DoorsUtil.childItemsToHtml(moduleId,item,1)];
    end
end


