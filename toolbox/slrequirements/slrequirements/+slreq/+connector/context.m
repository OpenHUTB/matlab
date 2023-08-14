


function html=context(urlQueryParama)

    persistent previousContext
    if isempty(previousContext)
        previousContext='';
    end

    [currentContext,currentProjName]=oslc.getCurrentContext();
    if isempty(currentContext)
        html=htmlRed(currentProjName);
        return;
    end

    if~strcmp(currentContext.uri,previousContext)
        previousContext=currentContext.uri;
        updated=true;
    else
        updated=false;
    end

    [wantedConfig,slProjName]=slreq.dngGetSessionConfig();
    if isempty(wantedConfig)
        error(message('Slvnv:oslc:UnresolvedInProjName',slProjName));
    end

    if isfield(urlQueryParama,'action')&&strcmp(urlQueryParama.action,'update')




        if rmipref('OslcMatchBrowserContext')

            proj=oslc.Project.get(currentProjName);
            proj.setContext(wantedConfig.url,wantedConfig.name);
            currentContext=proj.getContext();
            updated=true;
        else

            updated=oslc.config.confirmUpdate(currentProjName,wantedConfig);
            if updated
                currentContext=oslc.getCurrentContext();
            end
        end





        matched=updated;

    else

        matched=strcmp(currentContext.uri,wantedConfig.url);
    end

    slProjectRow=getString(message('Slvnv:oslc:ProjectColon'));
    slContextRow=getString(message('Slvnv:oslc:ContextColon'));
    contextNotSpecified=getString(message('Slvnv:oslc:NOT_SPECIFIED'));

    if isempty(currentContext.uri)
        tableData={...
        slProjectRow,nbsp(currentProjName);...
        slContextRow,nbsp(contextNotSpecified)};
    else
        tableData={...
        slProjectRow,nbsp(currentProjName);...
        slContextRow,nbsp(currentContext.name)};
    end

    if~matched

        tableData=addContextSwitch(tableData);

    elseif updated

        tableData{2,1}=htmlGreen(tableData{2,1});
        tableData{2,2}=htmlGreen(tableData{2,2});
    end

    html=htmlTable(tableData);
    html=oslc.dngStyle(html);
end

function html=htmlTable(data)
    html=['<table>',newline];
    for i=1:size(data,1)
        html=[html,'<tr>'];%#ok<AGROW>
        for j=1:size(data,2)
            html=[html,'<td>',data{i,j},'</td>'];%#ok<AGROW>
        end
        html=[html,'</tr>',newline];%#ok<AGROW>
    end
    html=[html,'</table>',newline];
end

function str=nbsp(str)
    str=regexprep(str,'\s','&nbsp;');
end

function data=addContextSwitch(data)




    data{2,1}=sprintf('<a href="%s" title="%s">%s</a>',...
    makeActionUrlForContextUpdate(),'Click to update',htmlRed(data{2,1}));
    data{2,2}=sprintf('<a href="%s" title="%s">%s</a>',...
    makeActionUrlForContextUpdate(),'Click to update',htmlRed(data{2,2}));
end

function url=makeActionUrlForContextUpdate()
    cmd=slreq.connector.baseUrl('context',true);
    url=sprintf('%s?action=update',cmd);
end

function out=htmlRed(in)
    out=htmlFontColor(in,'red');
end

function out=htmlGreen(in)
    out=htmlFontColor(in,'darkGreen');
end

function out=htmlFontColor(in,htmlColor)
    out=sprintf('<font color="%s">%s</font>',htmlColor,in);
end



