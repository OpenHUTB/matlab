function[sid,html,docTable]=makeContents(varargin)




    html='';
    docTable=cell(0,2);
    checkSubRoot=false;

    obj=varargin{1};
    if ischar(obj)&&(rmisl.isSidString(obj)||exist(obj,'file')==4)
        sid=obj;
        [mdlName,id]=strtok(obj,':');
        try
            objH=Simulink.ID.getHandle(obj);
        catch




            return;
        end
        [objName,objType]=rmi.objname(objH);

        if nargin<2
            reqs=localGetReqs(objH,mdlName,id);

        elseif nargin==2&&islogical(varargin{2})
            reqs=localGetReqs(objH,mdlName,id);
            checkSubRoot=varargin{2};

        else
            reqs=varargin{2};
        end
    else

        reqs=varargin{2};
        if nargin<3
            [isSf,objH]=rmi.resolveobj(obj);
        else
            objH=obj;
            isSf=varargin{3};
        end
        if isSf
            sfRoot=Stateflow.Root;
            sid=Simulink.ID.getSID(sfRoot.idToHandle(objH));
        else
            sid=Simulink.ID.getSID(objH);
        end
        [objName,objType]=rmi.objname(objH);
        mdlName=strtok(sid,':');
    end

    if isempty(reqs)&&~checkSubRoot
        return;
    end

    objType=displayedObjType(objType);

    doCache=(exist(rmi.Informer.cache('cacheDir'),'dir')==7);

    for i=1:length(reqs)
        [linkHtml,docTable]=reqToHtml(i,reqs(i),mdlName,docTable);
        html=[html,linkHtml];%#ok<AGROW>
    end

    if checkSubRoot&&any(strcmp(objType,{'MATLAB Function','EMFunction'}))
        if rmiml.hasLinks(sid)
            [mllinkHtml,docTable]=rmi.Informer.linksToHtml(sid,docTable);
            if~isempty(mllinkHtml)
                mfunctionHeader=getString(message('Slvnv:rmi:informer:MFunctionLinks',objName));
                coloredHeader=rmi.Informer.wrapRmiColor(mfunctionHeader);
                html=[html,'<hr>',newline,'<h3>',coloredHeader,'</h3>',newline,mllinkHtml,newline];
            end
        end
    end

    if~isempty(html)

        objLabel=['"',objName,'" <i>(',objType,')</i>'];
        if length(reqs)>1
            numLinksStr=getString(message('Slvnv:rmi:informer:NLinks',num2str(length(reqs))));
            objLabel=strrep(objLabel,')</i>',[numLinksStr,')</i>']);
        end
        headerString=rmi.Informer.wrapRmiColor(objLabel);
        html=['<h2>',headerString,'</h2>',newline,html];


        if doCache
            rmi.Informer.cacheContents(sid,html);
        end
    end
end

function[html,docTable]=reqToHtml(i,req,mdlName,docTable)

    if strcmp(req.reqsys,'other')
        linkType=rmi.linktype_mgr('resolveByFileExt',req.doc);
    else
        linkType=rmi.linktype_mgr('resolveByRegName',req.reqsys);
    end
    if isempty(linkType)
        unsupportedInfo=unsupportedTypeHtml(i,req);
        html=['<hr>',newline,unsupportedInfo,newline];
        redDoc=['<font color="red">',req.doc,'</font>'];
        docTable=rmiut.updateDocTable(docTable,{redDoc,1});
        return;
    end

    [thisLinkInfo,docUrl]=rmi.Informer.linkInfoToHtml(i,req,linkType,mdlName);

    html=[thisLinkInfo,newline];


    if linkType.IsFile||strcmp(linkType.Registration,'linktype_rmi_slreq')
        doc=rmi.locateFile(req.doc,mdlName);
        if isempty(doc)
            targetNotFound=getString(message('Slvnv:rmi:informer:TargetNotFound',req.doc));
            html=[html,targetNotFound,newline];
            redDoc=['<font color="red">',req.doc,'</font>'];
            docTable=rmiut.updateDocTable(docTable,{redDoc,1});
            return;
        end
    elseif any(strcmp(linkType.Registration,{'linktype_rmi_matlab','linktype_rmi_simulink'}))
        doc=req.doc;



        [fDir,fName,fExt]=fileparts(doc);
        if isempty(fDir)&&isempty(fExt)
            fullPathToFile=which(fName);
            if~isempty(fullPathToFile)
                refPath=fileparts(get_param(mdlName,'FileName'));
                doc=rmiut.relative_path(fullPathToFile,refPath);
            end
        end
    else
        doc=req.doc;
    end

    if~isempty(linkType.HtmlViewFcn)
        myHtml=feval(linkType.HtmlViewFcn,doc,req.id);
        if~isempty(myHtml)
            html=[html,myHtml,newline];
        end
    end

    html=['<hr>',newline,html];


    hyperlink=['<a href="',docUrl,'">',doc,'</a>'];
    docTable=rmiut.updateDocTable(docTable,{hyperlink,1});
end

function displayedType=displayedObjType(objType)
    switch objType
    case 'block_diagram'
        displayedType='Block Diagram';
    case 'block'
        displayedType='Block';
    otherwise
        displayedType=objType;
    end
end

function html=unsupportedTypeHtml(idx,req)

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

    if isempty(req.doc)
        docLabel=req.description;
    else
        docLabel=req.doc;
    end
    if strcmp(req.reqsys,'other')
        docData=['"',docLabel,'"'];
    else
        docData=[docLabel,' (',req.reqsys,')'];
    end
    docInfo=getString(message('Slvnv:consistency:errorUnableToResolveType',docData));

    html=['<h3>',num2str(idx),'. ',label,'</h3>',newline...
    ,'<font color="red">',docInfo,'</font>',newline];

    html=rmi.Informer.wrapRmiColor(html);
end

function reqs=localGetReqs(objH,mdlName,id)

    isExternalStorage=rmidata.storageModeCache('get',mdlName);
    if isExternalStorage
        artifactPath=get_param(mdlName,'FileName');
        reqs=slreq.getReqs(artifactPath,id,'linktype_rmi_simulink');
    else
        reqs=rmisl.getEmbeddedReqs(objH,[]);
    end
end


