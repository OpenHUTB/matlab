


function html=configmgr(args)

    title=getString(message('Slvnv:oslc:ManageLinkedConfigurations'));

    switch args.action
    case 'report'
        html=slreq.connector.dngConfigMgr('report');

    case 'select'
        html=slreq.connector.dngConfigMgr('select',args.type,args.id);

    case 'update'
        html=slreq.connector.dngConfigMgr('update',args.old,args.new);

    case 'save'
        html=slreq.connector.dngConfigMgr('save',args.artifact);

    otherwise
        html=displayError(['Unsupported action name: ',args.action],title);
    end

    webPageStyle=oslc.dngStyle();
    html=['<html><head><title>',title,'</title>',newline...
    ,webPageStyle,newline,'</head>',newline...
    ,'<body class="claro">',newline,'<blockquote>',newline...
    ,html,newline,'</blockquote>',newline...
    ,'</body></html>'];
end

function html=displayError(message,title)
    html=['<html><head><title>',title,'</title>',newline...
    ,'</head><body>'...
    ,errorInRedFont(message),newline...
    ,'</body></html>'];
end

function errorText=errorInRedFont(msgText)
    errorText=['<font color="red">',msgText,'</font>'];
end

