function html=itemToHtmlDefault(moduleId,item,includeAttributes)

    if nargin<3
        includeAttributes=true;
    end


    html='';
    textAsHtml=rmidoors.getObjAttribute(moduleId,item,'textAsHtml');

    if includeAttributes

        [depths,data]=rmiref.DoorsUtil.getObjAttributes(moduleId,item);
        subLevel=getItemDepth(moduleId,item);
        if~isempty(data)
            for i=1:length(depths)
                depth=depths(i);
                if ischar(data{i})
                    if depth~=1
                        html=[html,htmlHeader(data{i},subLevel+depth),newline];%#ok<AGROW>
                    elseif~isempty(textAsHtml)
                        html=[html,textAsHtml,newline];%#ok<AGROW>
                        textAsHtml='';
                    else
                        html=[html,data{i},newline];%#ok<AGROW>
                    end
                elseif~isempty(data{i})

                    html=[html,'<blockquote>',newline...
                    ,htTable(data{i},1),newline,'</blockquote>',newline];%#ok<AGROW>
                end
            end
        end
    else
        html=textAsHtml;
    end


    pictureHtml=rmiref.DoorsUtil.pictureObjToHtml(moduleId,item);
    if~isempty(pictureHtml)
        html=[html,newline,pictureHtml];
    end


    linksHtml=rmidoors.externalLinksToHtml(moduleId,item);
    if~isempty(linksHtml)
        html=[html,newline,linksHtml];
    end
end

function subLevel=getItemDepth(moduleId,item)

    labelText=rmidoors.getObjAttribute(moduleId,item,'labelText');
    sectionNumber=strtok(labelText,'- ');
    subLevel=1+sum(sectionNumber=='.');
end

function html=htmlHeader(text,depth)
    if isempty(strtrim(text))||any(strcmp(text,{...
        getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoHeading')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoText'))}))
        html='';
        return;
    end
    depthStr=num2str(depth);
    html=['<h',depthStr,'>',text,'</h',depthStr,'>',newline];
end

function html=htTable(contents,spacing)











    if nargin<2
        spacing=5;
    end
    html=[sprintf('<table cellpadding="%d">',spacing)];
    for i=1:size(contents,1)
        html=[html,'<tr>',newline];%#ok<AGROW>
        for j=1:size(contents,2)
            html=[html,'<td>',contents{i,j},'</td>',newline];%#ok<AGROW>
        end
        html=[html,'</tr>',newline];%#ok<AGROW>
    end
    html=[html,'</table>',newline];
end
