function htmlStr=make_table_map_legend(fileNames,brkValues,varargin)






    isJustified=false;
    if 3==nargin
        isJustified=varargin{1};
    end

    htmlStr='<table cellpadding="2" border="0"> <tr>';

    label='0';
    file=fileNames{1};
    if isJustified
        label=getString(message('Slvnv:simcoverage:cvhtml:Justified'));
    end

    htmlStr=[htmlStr,sprintf('<td width="16" align="left"> <img src="%s" width="12" height="12" border="1"/> </td> <td> %s </td>',file,label)];

    htmlStr=[htmlStr,'</tr>  <tr>'];
    for i=2:length(brkValues)
        label=[num2str(brkValues(i-1)+1),' - ',num2str(brkValues(i))];
        file=fileNames{i};
        htmlStr=[htmlStr,sprintf('<td width="16" align="left"> <img src="%s" width="12" height="12" border="1"/> </td> <td> %s </td>',file,label)];
        htmlStr=[htmlStr,sprintf('</tr>  <tr>')];

    end

    label=['> ',num2str(brkValues(end))];
    file=fileNames{end};
    htmlStr=[htmlStr,sprintf('<td width="16" align="left"> <img src="%s" width="12" height="12" border="1"/> </td> <td> %s </td>',file,label)];
    htmlStr=[htmlStr,'</tr> </table>'];
