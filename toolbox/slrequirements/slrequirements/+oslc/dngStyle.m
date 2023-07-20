function result=dngStyle(html)






    dngServer=rmipref('OslcServerAddress');
    suffix=rmipref('OslcServerRMRoot');
    styleUri=jazzServerStyleUri(dngServer,suffix);

    style=[newline...
    ,'<link type="text/css" rel="stylesheet" href="'...
    ,dngServer,styleUri,'">',newline...
    ,'<link rel="shortcut icon" href="'...
    ,dngServer,'/',suffix,'/web/com.ibm.rdm.web/common/images/icons/favicon.ico">',newline...
    ,'<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>',newline...
    ,'<style type="text/css">',newline...
    ,'#mwCompact {',newline...
    ,'margin: 0;',newline...
    ,'padding: 0;',newline...
    ,'font: 12px Arial,clean,sans-serif;',newline...
    ,'font-family: Arial, sans-serif;',newline...
    ,'font-size: 9pt;',newline...
    ,'width: 100%;',newline...
    ,'min-width: 50px;',newline...
    ,'}',newline...
    ,'</style>',newline];

    if nargin==0
        result=style;
    else

        html=strrep(html,'<td>','<td><div id="mwCompact">');
        html=strrep(html,'</td>','</div></td>');
        result=['<html><head>',style,'</head><body>',newline,html,'</body></html>'];
    end
end

function styleUri=jazzServerStyleUri(dngServer,suffix)
    persistent styleEtag
    if isempty(styleEtag)
        connection=oslc.connection();
        dngUrl=[dngServer,'/',suffix,'/web'];
        serverResponse=connection.get(dngUrl);


        matched=regexp(serverResponse,'&etag=([^"]+)"','tokens');
        if isempty(matched)


            styleEtag='tagNotKnown_en_US&_proxyURL=%2Frm&ss=XXXXX';
        else
            styleEtag=matched{1}{1};
        end
    end
    styleUri=sprintf('/%s/web/_style/?include=A~&etag=%s',suffix,styleEtag);
end

