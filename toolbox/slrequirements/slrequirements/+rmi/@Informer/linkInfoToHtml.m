function[html,docUrl,reqUrl]=linkInfoToHtml(idx,req,linkType,ref)



    if~ischar(idx)

        if isempty(req.description)
            label=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
            label=strrep(label,'<','&lt;');
            label=strrep(label,'>','&gt;');
        else
            label=req.description;
            if length(label)>50
                label=[label(1:50),'...'];
            end
        end
        [document,docUrl]=makeDocumentItem(req,linkType,ref);
        [location,reqUrl]=makeLocationItem(req,linkType,ref);
        if isempty(req.keywords)
            tags='';
        else
            usrTagsRow=getString(message('Slvnv:rmi:informer:UsrTagRow'));
            tags=[usrTagsRow,' <i>',req.keywords,'</i><br/>',newline];
        end
        linkToRow=getString(message('Slvnv:rmi:informer:LinkToRow',linkType.Label));
        html=['<h3>',num2str(idx),'. ',label,'</h3>',newline...
        ,linkToRow,'<br/>',newline...
        ,document,'<br/>',newline...
        ,location,'<br/>',newline...
        ,tags];
    else




        doc=idx;
        ids=req;
        reqSys=linkType;
        if strcmp(reqSys,'other')
            linkType=rmi.linktype_mgr('resolveByFileExt',doc);
        else
            linkType=rmi.linktype_mgr('resolveByRegName',reqSys);
        end
        reqs=rmi.createEmptyReqs(size(ids,1));
        reqUrl=0;
        locations='';
        for i=1:length(reqs)
            reqs(i).doc=doc;



            if strcmp(linkType.Registration,'linktype_rmi_simulink')
                [~,reqs(i).doc]=fileparts(reqs(i).doc);
            end
            reqs(i).id=ids{i,1};
            reqs(i).reqsys=reqSys;
            if i==1
                [document,docUrl]=makeDocumentItem(reqs(i),linkType,ref);
            end
            count=ids{i,2};
            reqUrl=reqUrl+count;
            oneLocation=makeLocationItem(reqs(i),linkType,ref);
            if count>1
                numLinks=getString(message('Slvnv:rmi:informer:NLinks',num2str(count)));
            else
                numLinks='';
            end
            locations=[locations,'<li>',oneLocation,numLinks,'</li>',newline];%#ok<AGROW>
        end
        if reqUrl>1
            linkToRow=getString(message('Slvnv:rmi:informer:LinksToRow',linkType.Label));
        else
            linkToRow=getString(message('Slvnv:rmi:informer:LinkToRow',linkType.Label));
        end
        html=[linkToRow,' ',document,'<ul>',newline,locations,'</ul>',newline];
    end

    html=rmi.Informer.wrapRmiColor(html);
end

function[docItem,docUrl]=makeDocumentItem(req,linkType,ref)
    docUrl=rmi.Informer.makeUrl(linkType,req.doc,'',ref);
    if~isempty(linkType.ItemIdFcn)
        docLabel=feval(linkType.ItemIdFcn,req.doc,'',false);
        if isempty(docLabel)

            docLabel=req.doc;
        end
    else
        docLabel=req.doc;
    end
    docLink=['<a href="',docUrl,'">',docLabel,'</a>'];
    docRowLabel=getString(message('Slvnv:rmi:informer:DocumentRow'));
    docItem=[docRowLabel,' ',docLink];
end

function[locItem,reqUrl]=makeLocationItem(req,linkType,ref)
    if isempty(req.id)
        reqUrl='';
        locItem=getString(message('Slvnv:rmi:informer:NoLocation'));
    else
        reqUrl=rmi.Informer.makeUrl(linkType,req.doc,req.id,ref);
        if~isempty(linkType.ItemIdFcn)
            idLabel=feval(linkType.ItemIdFcn,req.doc,req.id,false);
        else
            idLabel=req.id;
        end
        reqLink=['<a href="',reqUrl,'">',idLabel,'</a>'];
        locRowLabel=getString(message('Slvnv:rmi:informer:LocationRow'));
        locItem=[locRowLabel,' ',reqLink];
    end
end

