function cmdWindowDDG_cb(hObj,cmdStr,userData)




    ws=userData.ws;
    url=userData.url;
    prompt=userData.prompt;
    nodeName=userData.nodeName;



    if(isempty(nodeName)||isempty(ws))
        return;
    end


    newStr=execute_clc(cmdStr,url);
    if isempty(newStr)
        return
    end


    newStr=double_quote(newStr);






    switch nodeName
    case{'Base','Model'}
        cmd=['evalc('' ',newStr,' '', '''')'];
        lasterr('');
        rstStr.log=evalin(ws,cmd);
        if~isempty(lasterr)
            err=strsplit(lasterr,newline);
            rstStr.err=err{2};
        else
            rstStr.err='';
        end
    case 'DD'
        try
            cmd=['evalin(ws, '' ',newStr,' '')'];
            rstStr.log=evalc(cmd);
            rstStr.err='';
        catch e
            rstStr.log='';
            rstStr.err=e.message;
        end
    otherwise
        warning('Invalid node name')
        return
    end


    append_result({newStr,prompt},rstStr,url);


    refresh_html_file(url);
    hObj.refresh;
end

function newStr=execute_clc(str,url)







    newStr=strtrim(str);
    expr='clc *[,;]|clc *';
    [startId,endId]=regexp(str,expr);


    if(isempty(startId))
        return
    end


    if(exist(url,'file')==2)
        delete(url);
    end
    create_html_file(url);
    refresh_html_file(url);


    newStr=newStr(endId(1)+1:end);
    newStr=strtrim(newStr);
end

function newstr=double_quote(str)
    newstr=strrep(str,'''','''''');
end




function str=rst_to_html(str,isErr)
    if(isequal(str,''))
        return
    end

    str=strrep(str,'\n','<br>');
    str=strrep(str,newline,'<br>');
    str=strrep(str,char(215),'&#215;');
    if(isErr)
        str=['<pre style="color:red;font-weight:bold">',str,'<br></pre>'];
    else
        str=['<pre>',str,'</pre>'];
    end
end

function str=cmd_to_html(str,prompt)
    prompt=strrep(prompt,'>>','&gt;&gt; ');

    str=strrep(str,'\n','<br>');
    str=strrep(str,newline,'<br>');
    str=['<pre>',prompt,str,'</pre>'];
end

function append_result(cmdCell,rst,url)
    cmd=cmd_to_html(cmdCell{1},cmdCell{2});
    rstLog=rst_to_html(rst.log,false);
    rstErr=rst_to_html(rst.err,true);
    rst=[cmd,rstLog,rstErr];


    if~(exist(url,'file')==2)
        if(create_html_file(url)<0)
            fprintf('Cannot create file %s.\n',url);
            return
        end
    end


    if(append_section(url,rst)<0)
        fprintf('Cannot record results to file %s.\n',url);
        return
    end
end

function fid=append_section(url,rst)
    fid=fopen(url,'r+');
    if(fid<0)
        return
    end


    fseek(fid,-14,'eof');
    fprintf(fid,'%s',' '*ones(1,14));


    fseek(fid,-14,'eof');
    fprintf(fid,'%s',rst);


    fseek(fid,0,'eof');
    fprintf(fid,'\n%s','</body></html>');
    fclose(fid);
end

function fid=create_html_file(url)
    fid=fopen(url,'w+');
    if(fid<0)
        return
    end
    fprintf(fid,'%s\n','<html>');
    fprintf(fid,'%s\n','  <style>');
    fprintf(fid,'%s\n','    pre {margin:0;font-size:15px;font-familiy:"Courier New",Courier,monospace;}');
    fprintf(fid,'%s\n','    body {margin:3px;}');
    fprintf(fid,'%s\n','  </style>');
    fprintf(fid,'%s\n','  <script>');
    fprintf(fid,'%s\n','    function init() {');
    fprintf(fid,'%s\n','      window.scrollTo(0, document.body.scrollHeight);');
    fprintf(fid,'%s\n','    }');
    fprintf(fid,'%s\n','    window.onload = init;');
    fprintf(fid,'%s\n','  </script>');
    fprintf(fid,'%s\n','  <body>');
    fprintf(fid,'%s','</body></html>');
    fclose(fid);
end

function refresh_html_file(url)
    wb=gleeTestInternal.GLWebBrowser2.find('cmdWebbrowser');
    wb.Url=url;
end