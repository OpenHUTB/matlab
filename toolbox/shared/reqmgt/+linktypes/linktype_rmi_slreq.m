function linkType=linktype_rmi_slreq








    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;


    linkType.Label=getString(message('Slvnv:slreq:RequirementSetDomainLabel'));


    linkType.IsFile=0;
    linkType.Extensions={'.slreqx'};


    linkType.LocDelimiters='@';
    linkType.Version='';


    linkType.NavigateFcn=@Navigate;
    linkType.BrowseFcn=@Browse;
    linkType.ContentsFcn=@Contents;
    linkType.HtmlViewFcn=@HtmlViewFcn;
    linkType.ItemIdFcn=@ItemIdFcn;
    linkType.CreateURLFcn=@CreateURLFcn;
    linkType.DocDateFcn=@DocDateFcn;
    linkType.DetailsFcn=@DetailsFcn;


    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.SelectionLinkLabel=getString(message('Slvnv:slreq:SelectionLinkLabel'));


    linkType.IsValidDocFcn=@IsValidDocFcn;
    linkType.IsValidIdFcn=@IsValidIdFcn;



    function Navigate(reqSetNameOrOReqObj,id,caller)
        if ischar(reqSetNameOrOReqObj)


            [refUri,~]=slreq.internal.LinkUtil.getReqSetUri(reqSetNameOrOReqObj,id);
            reqSet=slreq.data.ReqData.getInstance.getReqSet(refUri);
            if isempty(reqSet)
                [~,~,fExt]=fileparts(reqSetNameOrOReqObj);
                if strcmp(fExt,'.slx')
                    load_system(reqSetNameOrOReqObj)
                else
                    slreq.data.ReqData.getInstance.loadReqSet(refUri);
                end


            end
        end
        slreq.adapters.SLReqAdapter.navigate(reqSetNameOrOReqObj,id,caller,'select');
    end

    function reqSetPath=Browse()
        reqSetPath='';
        r=slreq.data.ReqData.getInstance();
        reqSets=r.getLoadedReqSets();



        if~isempty(reqSets)
            selectionDlg=slreq.gui.DialogSelectRequirementSet({reqSets.filepath});
            DAStudio.Dialog(selectionDlg);
            reqSetPath=' ';
        else
            [filename,pathname]=uigetfile('*.slreqx',...
            getString(message('Slvnv:slreq:SelectTheRequirementSetFile')));
            if~isequal(filename,0)
                reqSetPath=fullfile(pathname,filename);
                slreq.utils.loadReqSet(reqSetPath);
            end
        end
    end

    function[labels,depths,locations]=Contents(filePath)
        reqData=slreq.data.ReqData.getInstance();

        reqSet=reqData.getReqSet(filePath);
        if isempty(reqSet)
            reqSet=reqData.loadReqSet(filePath);
            if isempty(reqSet)
                labels{1}=getString(message('Slvnv:slreq:EmptyReqSet'));
                depths(1)=0;
                locations{1}='';
                return;
            end
        end



        labels={reqSet.name};
        depths=0;
        locations={''};


        populateChildItems(reqSet.children,1,0);

        function populateChildItems(items,parentIdx,thisDepth)
            lab={items.id}';
            dep=zeros(size(lab))+thisDepth;
            loc=arrayfun(@(x)num2str(x),cell2mat({items.sid}'),'UniformOutput',false);
            labels=[labels(1:parentIdx);lab;labels(parentIdx+1:end)];
            depths=[depths(1:parentIdx);dep;depths(parentIdx+1:end)];
            locations=[locations(1:parentIdx);loc;locations(parentIdx+1:end)];
            for i=length(items):-1:1
                children=items(i).children;
                if~isempty(children)
                    populateChildItems(children,parentIdx+i,thisDepth+1);
                end
            end
        end




        if numel(labels)>1
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            for j=2:numel(labels)
                labels{j}=adapter.getSummary(reqSet.name,locations{j});
            end



            locations(2:end)=strcat('#',locations(2:end));
        end



        labels(1)=[];
        depths(1)=[];
        locations(1)=[];
    end

    function label=ItemIdFcn(doc,id,mode)


        reqData=slreq.data.ReqData.getInstance;
        reqSet=reqData.getReqSet(doc);
        if isempty(reqSet)


            label=id;
            return;
        end
        if isempty(id)
            label=[reqSet.name,'.slreqx'];
            return;
        end
        if~mode&&id(1)==linkType.LocDelimiters(1)
            label=id(2:end);
            return;
        end
        try

            req=reqSet.getRequirementById(id);
        catch ex
            if any(strcmp(ex.identifier,...
                {'Slvnv:slreq:NotAValidReqID','MATLAB:builtins:NonScalarInput'}))


                req=reqSet.find('customId',id);
            else
                throwAsCaller(ex);
            end
        end
        if isempty(req)

            label=id;
            return;
        end
        if mode

            label=sprintf('%d',req.sid);
        else


            label=req.id;
        end
    end

    function html=HtmlViewFcn(doc,id)
        if isempty(id)
            html='';
            return;
        end
        reqData=slreq.data.ReqData.getInstance;
        reqSet=reqData.getReqSet(doc);
        req=reqSet.getRequirementById(id);

        if isempty(req)

            html='';
            return;
        end



        html=reqSet.unpackImages(req.description);



        if~isempty(req.summary)&&~contains(req.description,req.summary)
            html=['<h3>',req.summary,'</h3>',newline,html];
        end

        if~isempty(req.rationale)
            rationale=reqSet.unpackImages(req.rationale);
            html=[html,'<br/>',newline,'<b>Rationale:</b> ',rationale,newline];
        end

        if~isempty(req.keywords)
            keywords=join(req.keywords,', ');
            html=[html,'<br/>',newline,'<b>Keywords:</b> ',keywords{1},newline];
        end

        attributes=reqSet.CustomAttributeRegistry;
        if~isempty(attributes)
            attributesHtml='';
            data=keys(attributes);
            for i=1:length(data)
                value=req.getAttribute(data{i},false);
                if~isempty(value)
                    if isdatetime(value)
                        value=slreq.utils.getDateStr(value);
                    end
                    attributesHtml=[attributesHtml,data{i},'=',value,', '];%#ok<AGROW>
                end
            end
            if~isempty(attributesHtml)
                html=[html,'<br/><br/>',newline,'<b>Custom Attributes:</b> ',attributesHtml(1:end-2)];
            end
        end
    end

    function reqs=SelectionLinkFcn(objH,~)
        appmgr=slreq.app.MainManager.getInstance;
        dasObjs=appmgr.getCurrentObject();
        if~isa(dasObjs,'slreq.das.Requirement')
            errordlg(...
            getString(message('Slvnv:slreq:RequirementShouldBeSelected')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkingError')));
            reqs=[];
            return;
        end
        dataReqs=arrayfun(@(x)x.dataModelObj,dasObjs);

        reqs=arrayfun(@(x)slreq.internal.makeReq(x,objH),dataReqs);











    end

    function success=IsValidDocFcn(doc,srcRef)

        reqSetFilePath=findReqSet(doc,srcRef);
        success=(exist(reqSetFilePath,'file')==2);
    end

    function reqSetPath=findReqSet(reqSetFile,srcRef)
        [reqDir,reqSetName]=fileparts(reqSetFile);

        loadedReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
        if~isempty(loadedReqSet)

            reqSetPath=loadedReqSet.filepath;
        else

            if rmiut.isCompletePath(reqSetFile)
                reqSetPath=reqSetFile;
            else

                reqSetPath=rmi.locateFile(reqSetFile,srcRef);
                if isempty(reqSetPath)

                    if isempty(reqDir)
                        reqSetPath=which(reqSetFile);
                    else
                        reqSetPath=rmiut.simplifypath(fullfile(pwd,reqSetFile));
                    end
                end
            end
        end
    end

    function success=IsValidIdFcn(doc,id,srcRef)

        reqSet=findAndLoadReqSet(doc,srcRef);


        item=findItemInReqSet(reqSet,id);
        success=~isempty(item);
    end

    function item=findItemInReqSet(reqSet,id)
        if~isempty(str2num(id))%#ok<ST2NM>

            item=reqSet.getItemFromID(id);
            if~isempty(item)
                return;
            end
        end

        item=reqSet.find('id',id);
        if isempty(item)
            item=reqSet.find('customId',id);
        end
    end

    function dataReqSet=findAndLoadReqSet(reqSetPath,srcRef)

        [~,reqSetName]=fileparts(reqSetPath);
        dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
        if~isempty(dataReqSet)
            return;
        end
        reqSetFilePath=findReqSet(reqSetPath,srcRef);
        if isempty(reqSetFilePath)
            error(message('Slvnv:slreq:UnableToLocateReqSet',reqSetPath));
        else
            dataReqSet=slreq.utils.loadReqSet(reqSetFilePath);
        end
    end






















    function url=CreateURLFcn(docPath,~,location)
        if isempty(location)
            url=sprintf('matlab:slreq.open(''%s'');',docPath);
        else
            url=sprintf('matlab:rmi.navigate(''%s'',''%s'',''%s'','''')','linktype_rmi_slreq',docPath,location);
        end
    end


    function dateString=DocDateFcn(doc)
        [reqPath,reqName,reqExt]=fileparts(doc);

        if slreq.utils.isArtifactLoaded('linktype_rmi_slreq',doc)
            rdata=slreq.data.ReqData.getInstance;
            reqSet=rdata.getReqSet(reqName);

            dateString=datestr(reqSet.modifiedOn,'ddd mmm dd HH:MM:SS yyyy');
        else
            if isempty(reqPath)||isempty(reqExt)
                mInfo=dir(which([reqName,'.slreqx']));
            else
                mInfo=dir(doc);
            end
            if isempty(mInfo)
                dateString='';
            else
                dateString=mInfo.date;
            end
        end
    end

    function[depths,items]=DetailsFcn(reqSetArg,reqItemId,detailsLevel)












        depths=[];
        items={};

        if nargin>2&&detailsLevel==0
            return;
        end

        if isnumeric(reqItemId)
            reqItemId=num2str(reqItemId);
        end

        dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetArg);
        if isempty(dataReqSet)
            rmiut.warnNoBacktrace('Slvnv:rmi:informer:TargetNotFound',reqSetArg);
            return;
        end
        dataReq=dataReqSet.getItemFromID(reqItemId);
        if isempty(dataReq)
            rmiut.warnNoBacktrace('Slvnv:reqmgt:NotFoundIn',reqItemId,reqSetArg);
            return;
        end

        if~isempty(dataReq.description)
            depths(end+1)=0;
            items{end+1}=sprintf('%s: %s',getString(message('Slvnv:slreq:Description')),slreq.cpputils.htmlToText(dataReq.description));
        end

        if~isempty(dataReq.rationale)
            depths(end+1)=0;
            items{end+1}=sprintf('%s: %s',getString(message('Slvnv:slreq:Rationale')),slreq.cpputils.htmlToText(dataReq.rationale));
        end


        if rmipref('ReportIncludeTags')
            keywords=dataReq.keywords;
            if~isempty(keywords)
                depths(end+1)=0;
                allKeywords=sprintf('%s,',keywords{:});
                items{end+1}=sprintf('%s: %s',getString(message('Slvnv:slreq:Keywords')),allKeywords(1:end-1));
            end
        end


        attributes=dataReqSet.CustomAttributeNames;
        if~isempty(attributes)
            items{end+1}=[getString(message('Slvnv:slreq:Attributes')),':'];
            depths(end+1)=0;
            for i=1:length(attributes)
                attrName=attributes{i};
                attrValue=dataReq.getAttribute(attrName,true);
                if~isempty(attrValue)
                    items{end+1}=sprintf(' %s: %s',attrName,attrValue);%#ok<AGROW>
                    depths(end+1)=1;%#ok<AGROW>
                end
            end
        end

    end

end
