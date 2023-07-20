function str=printHtml(obj)



    str='';
    cmp=obj;
    str=sprintf('%s<p><b>Name: </b>%s</p>',str,cmp.Name);
    str=sprintf('%s<p><b>Class: </b>%s</p>',str,cmp.Class);
    str=sprintf('%s<p><b>Number of parameters: </b>%d</p>',str,length(cmp.ParamList));

    str=sprintf('%s<table border="1"><thead><tr>',str);

    ps={'Name','ID','Default Value','Type',...
    'FullParent','FullChildren','Dependency'};
    for i=1:length(ps)
        str=sprintf('%s<th>%s</th>',str,ps{i});
    end
    str=sprintf('%s</tr></thead>',str);

    for i=1:length(cmp.ParamList)
        p=cmp.ParamList{i};
        str=sprintf('%s<tr>',str);
        for j=1:length(ps)
            prop=ps{j};
            if strcmp(prop(1:2),'Fu')
                nowrap='';
            else
                nowrap='nowrap';
            end
            str=sprintf('%s<td %s>%s</td>',str,nowrap,configset.dialog.HTMLView.getPropHtml(p,prop));
        end
        str=sprintf('%s<tr>',str);
    end
    str=sprintf('%s</table>',str);


