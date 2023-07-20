classdef Informer<handle



    properties(SetObservable=true)
        infrmObj=[]
        windowTitle=''
        defaultWindowText=''
        objToTextMap=[]
        summaryMap=[]
        docListMap=[];
    end


    methods(Static=true)

        function instance=getInstance(doInit)
            persistent singleInformer
            if isempty(singleInformer)&&(nargin==0||doInit)
                singleInformer=rmi.Informer(true);
            end
            instance=singleInformer;
        end

        function close()

            if rmi.Informer.exists()
                rmi.Informer.getInstance.hide();
            end
        end

        function yesno=exists()
            yesno=~isempty(rmi.Informer.getInstance(false));
        end

        function yesno=isVisible()
            yesno=rmi.Informer.exists()&&rmi.Informer.getInstance.visible();
        end

        function makeVisible()
            if rmi.Informer.exists()
                rmi.Informer.getInstance.show();
            else
                warning(message('Slvnv:rmi:informer:IsNotInitialized'));
            end
        end

        function closeModel(modelName)
            if~rmi.Informer.exists()
                return;
            end
            includedModels=keys(rmi.Informer.getInstance.summaryMap);
            matchMdl=strcmp(includedModels,modelName);
            if any(matchMdl)

                remove(rmi.Informer.getInstance.summaryMap,modelName);
                includedModels(matchMdl)=[];
            end
            if isempty(includedModels)

                rmi.Informer.close();
            else


                rmi.Informer.setCurrent(includedModels{1});
            end
        end

        function out=wrapRmiColor(in)
            out=['<font color="#993300">',in,'</font>'];
        end

        function cmd=matlabNavCmd(linktype,doc,id,ref)
            cmd=sprintf('matlab:rmi.navigate(''%s'',''%s'',''%s'',''%s'');',linktype.Registration,doc,id,ref);
        end

        function docTable=updateEntry(varargin)

            if length(varargin)==3

                obj=varargin{1};
                reqs=varargin{2};
                isSf=varargin{3};

                modelName=rmidata.getRmiKeys(obj,isSf);
                if~rmi.Informer.hasData(modelName)
                    return;
                end
                rmi.Informer.cache('incrementSessionId');
                [sid,myHtml,docTable]=rmi.Informer.makeContents(obj,reqs,isSf);



                if isempty(myHtml)
                    rmi.Informer.getInstance.addInfo(sid,'',true);
                    return;
                end
            else

                [sid,myHtml,docTable]=rmi.Informer.makeContents(varargin{:});
            end







            if~isempty(sid)&&~isempty(myHtml)
                msgString=getString(message('Slvnv:rmi:informer:ClickToReload'));
                hyperlink=rmi.Informer.hyperlinkToRefresh(strtok(sid,':'),msgString);
                rmi.Informer.getInstance.addInfo(sid,[myHtml,'<hr/>',hyperlink],true);
            end
        end

        function setSummary(modelName,objCount,docData)
            rmi.Informer.getInstance.updateSummary(modelName,objCount,docData)
        end

        function invalidateSummary(objH,isSf)
            if isSf
                modelH=rmisf.getmodelh(objH);
            else
                modelH=get_param(bdroot(objH),'Handle');
            end
            if~rmi.objHasReqs(modelH)
                modelName=get_param(modelH,'Name');
                summary=rmi.Informer.getSummary(modelName);
                if~contains(summary,'#cccccc')
                    if~isempty(summary)
                        summary=regexprep(summary,...
                        '<font color="#993300"><h2>',...
                        '<font color="#cccccc"><h2>');
                        summary=regexprep(summary,...
                        getString(message('Slvnv:rmi:informer:ClickToDisplay')),...
                        ['<font color="#cc0000">',getString(message('Slvnv:rmi:informer:StaleData')),'</font>']);
                        rmi.Informer.getInstance.addInfo(modelName,summary,true);
                    end
                end
            end
        end

        function summary=getSummary(modelName)
            if rmi.Informer.exists&&isKey(rmi.Informer.getInstance.summaryMap,modelName)
                summary=rmi.Informer.getInstance.summaryMap(modelName);
            else
                summary='';
            end
        end

        function docs=getDocs(modelName)
            if rmi.Informer.exists&&isKey(rmi.Informer.getInstance.docListMap,modelName)
                docString=rmi.Informer.getInstance.docListMap(modelName);
                docs=strsplit(docString,newline);
            else
                docs={};
            end
        end

        function yesno=hasData(modelName)
            yesno=rmi.Informer.exists&&isKey(rmi.Informer.getInstance.summaryMap,modelName);
        end

        function setCurrent(modelName)
            rmi.Informer.getInstance.currentSummary(modelName);
        end


        display(slMdlName)
        html=htmlFileToString(htmlFilePath)
        [html,docUrl,reqUrl]=linkInfoToHtml(idx,req,linkType,ref)
        [sid,html,docTable]=makeContents(obj,reqs,isSf)
        cacheContents(cacheDir,sid,html)
        result=cache(option)
        [mllinkHtml,docTable]=linksToHtml(sid,docTable)
        htmlFilePath=tmpExcerptFile(parentDir,fileName)
        url=makeUrl(linkType,doc,id,ref)
    end


    methods(Static=true,Access='private')

        function defaultText=makeDefaultText(modelName,hasData)
            if hasData
                headerText=getString(message('Slvnv:rmi:informer:TraceabilityFor',modelName));
                header=['<h2>',headerText,'</h2>'];
                msgString=getString(message('Slvnv:rmi:informer:ClickToReload'));
                hyperlink=rmi.Informer.hyperlinkToRefresh(modelName,msgString);
                clickHint=getString(message('Slvnv:rmi:informer:ClickToDisplay'));
                defaultText=[...
'<blockquote>'...
                ,rmi.Informer.wrapRmiColor(header),newline...
                ,'<p>'...
                ,rmi.Informer.wrapRmiColor(clickHint)...
                ,'</p>'...
                ,'<h3>',hyperlink,'</h3>',newline...
                ,'</blockquote>'];

            else
                headerText=getString(message('Slvnv:rmi:informer:SimulinkModelHasLinks',modelName));
                header=['<h2>',headerText,'</h2>'];
                msgString=getString(message('Slvnv:rmi:informer:ClickToLoad'));
                hyperlink=rmi.Informer.hyperlinkToRefresh(modelName,msgString);
                defaultText=[...
'<blockquote>'...
                ,rmi.Informer.wrapRmiColor(header),newline...
                ,'<h3>',hyperlink,'</h3>',newline...
                ,'<p><i>'...
                ,rmi.Informer.wrapRmiColor(getString(message('Slvnv:rmi:informer:RmiMayTakeTime')))...
                ,'</i></p>'...
                ,'</blockquote>'];
            end
        end

        function hyperlink=hyperlinkToRefresh(modelName,msgString)
            cmdString=['matlab:rmi.populateInformerData(''',modelName,''',true);'];
            hyperlink=['<p><a href="',cmdString,'">',msgString,'</a></p>'];
        end

    end


    methods
        function this=Informer(doMakeWindow)

            this.windowTitle=getString(message('Slvnv:rmi:informer:RmiInformer'));
            defaultText=getString(message('Slvnv:rmi:informer:ClickToDisplay'));
            this.defaultWindowText=rmi.Informer.wrapRmiColor(defaultText);

            if doMakeWindow
                this.makeWindow();
            end

            this.objToTextMap=containers.Map('KeyType','char','ValueType','char');
            this.summaryMap=containers.Map('KeyType','char','ValueType','char');
            this.docListMap=containers.Map('KeyType','char','ValueType','char');
        end

        function hide(this)
            if~isempty(this.infrmObj)&&ishandle(this.infrmObj)
                this.infrmObj.preCloseFcn='';
                this.infrmObj.hide;
                if~isempty(this.objToTextMap)
                    this.unhighlightDiagrams();
                end
            end
        end

        function show(this)
            if~isempty(this.infrmObj)&&ishandle(this.infrmObj)
                this.infrmObj.visible=true;
                this.infrmObj.preCloseFcn='rmi.Informer.close();';
            else
                this.makeWindow();
            end
        end

        function res=getSelectedText(this)
            res=this.infrmObj.text;
        end

        function res=mode(this)
            res=this.infrmObj.mode;
        end

        function addInfo(this,objId,htmlStr,reset)


            if rmi.settings_mgr('get','filterSettings','enabled')
                htmlStr=[htmlStr,getString(message('Slvnv:rmi:informer:TagFiltersApplied'))];
            end

            if~reset&&this.objToTextMap.isKey(objId)
                htmlStr=[this.objToTextMap(objId),'<BR><BR>',htmlStr];
            end
            this.objToTextMap(objId)=htmlStr;

            udiObj=Simulink.ID.getHandle(objId);
            if isa(udiObj,'double')
                udiObj=get_param(udiObj,'Object');
                if~isempty(udiObj)&&contains(objId,'::')

                    sfUddH=Stateflow.SLINSF.SimfcnMan.getSLFunction(udiObj);
                    if~isempty(sfUddH)
                        this.addToInformerMap(sfUddH,htmlStr);
                    end
                end
            end
            if~isempty(udiObj)
                this.addToInformerMap(udiObj,htmlStr);
            end

        end

        function updateSummary(this,modelName,objCount,docData)
            headerText=getString(message('Slvnv:rmi:informer:TraceabilityFor',modelName));
            linkCount=sum([docData{:,2}]);
            docCount=size(docData,1);
            subHeaderText=getString(message('Slvnv:rmi:informer:ObjectAndLinkCounts',...
            num2str(objCount),num2str(linkCount),num2str(docCount)));
            headers=['<h2>',headerText,'</h2>',newline,'<h3>',subHeaderText,'</h3>'];
            if~isempty(docData)
                docs=docData(:,1);
                linkCounts=docData(:,2);
                [sortedDocs,index]=sort(docs);
                sortedCounts=linkCounts(index);
                sortedCountStrings=cell(size(sortedCounts));
                for i=1:length(sortedCounts)
                    sortedCountStrings{i}=num2str(sortedCounts{i});
                end
                docNameCol=getString(message('Slvnv:rmi:informer:Document'));
                numLinksCol=getString(message('Slvnv:rmi:informer:NumLinks'));
                docTableString=rmiut.arrayToHtmlTable([...
                [docNameCol;sortedDocs],[numLinksCol;sortedCountStrings]]);
                allDocs=rmiut.docListToString(sortedDocs,modelName,true);
            else
                docTableString='';
                allDocs='';
            end

            thisModelInfo=[headers,newline,docTableString,newline];
            msgString=getString(message('Slvnv:rmi:informer:ClickToReload'));
            hyperlink=rmi.Informer.hyperlinkToRefresh(modelName,msgString);
            this.summaryMap(modelName)=[...
            rmi.Informer.wrapRmiColor(thisModelInfo)...
            ,'<p>',this.defaultWindowText,'</p>',newline,hyperlink];

            this.docListMap(modelName)=allDocs;
        end

        function hasData=currentSummary(this,modelName)
            if isKey(this.summaryMap,modelName)
                hasData=true;


                try
                    if~rmi.objHasReqs(modelName)
                        this.addInfo(modelName,this.summaryMap(modelName),true);
                    end
                catch

                    remove(this.summaryMap,modelName);
                    this.hide();
                    hasData=false;
                end
            else
                hasData=false;
            end
            this.infrmObj.defaultText=rmi.Informer.makeDefaultText(modelName,hasData);
        end
    end


    methods(Access='private')

        function makeWindow(this)
            this.infrmObj=DAStudio.Informer;
            this.infrmObj.visible=false;
            this.infrmObj.mode='ClickMode';
            this.infrmObj.position=[10,100,400,250];
            this.infrmObj.preCloseFcn='rmi.Informer.close();';
            this.infrmObj.title=this.windowTitle;
            this.infrmObj.defaultText=this.defaultWindowText;
        end

        function addToInformerMap(this,udiObj,htmlStr)
            if ishandle(udiObj)
                this.infrmObj.mapData(udiObj,htmlStr);
            end
        end

        function res=visible(this)
            res=this.infrmObj.visible;
        end

        function unhighlightDiagrams(this)
            allKeys=keys(this.objToTextMap);
            diagNames=strtok(allKeys,':');
            uniqueNames=unique(diagNames);
            for i=1:length(uniqueNames)
                mdlName=uniqueNames{i};
                try
                    if strcmp(get_param(mdlName,'ReqHilite'),'on')
                        rmisl.unhighlight(get_param(mdlName,'Handle'));
                    end
                catch

                end
            end
        end

    end

end

