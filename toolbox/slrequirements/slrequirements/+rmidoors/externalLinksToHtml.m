function html=externalLinksToHtml(moduleId,item)




    html='';

    links=rmidoors.getObjAttribute(moduleId,item,'ExternalLinks');
    if~isempty(links)
        direction=cell2mat(links(:,1));
        if any(direction==1)
            html=[html,htmlListLinks(links(direction==1,:),...
            getString(message('Slvnv:slreq_import:OutgoingExternalLinks')))];
        end
        if any(direction==0)
            html=[html,htmlListLinks(links(direction==0,:),...
            getString(message('Slvnv:slreq_import:IncomingExternalLinks')))];
        end
    end
end

function html=htmlListLinks(links,header)
    html=['<h3>',header,'</h3><ul>',newline];
    for i=1:size(links,1)
        htmlLink=['<a href="',links{i,4},'">',links{i,3},'</a>'];
        html=[html,'<li>',htmlLink,' (',links{i,2},')</li>',newline];%#ok<AGROW>
    end
    html=[html,'</ul>',newline];
end

