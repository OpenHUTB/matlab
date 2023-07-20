classdef ExportEngine<handle


    properties
        Indent=1;
    end

    properties(SetAccess=private)
        ModelExporter;
        BaseUrl;
        BaseDir;
        ProgressMonitor;
    end

    properties(Access=private)
        Snapshot;
        ImageSpriteWriter;
        m_enabledOptionalViews;

        Document;
        ModelSourceURL;
        ModelSourceFile;

        IconFileToCSSClass;
        ExportedDiagramCache;
        m_section;
        m_force;

        ItemToDiagramObj;
        ItemToElementObj;

        IconClassPrefix;

        NotesExporter;
HasNotesToExport
    end

    methods
        function this=ExportEngine(modelExporter,modelElement)

            this.ModelExporter=modelExporter;


            this.ImageSpriteWriter=slreportgen.webview.utils.ImageSpriteWriter(...
            "Width",16,...
            "Height",16);


            this.ItemToDiagramObj=containers.Map(...
            "KeyType","double",...
            "ValueType","any");
            this.ItemToElementObj=containers.Map(...
            "KeyType","double",...
            "ValueType","any");


            this.Snapshot=slreportgen.utils.internal.DiagramSnapshot([],...
            "Format","PNG",...
            "Scaling","Custom",...
            "Size",[200,200]);


            this.Document=modelElement.Document;
            docWorkingDir=this.Document.WorkingDir;

            modelSourceUrl=modelElement.SourceUrl;
            [modelSrcPath,modelSrcName,modelSrcExt]=fileparts(modelSourceUrl);
            modelBaseDirName=strcat(modelSrcName,'_files');

            this.BaseUrl=strcat(modelSrcPath,'/',modelBaseDirName);
            this.BaseDir=fullfile(docWorkingDir,modelSrcPath,modelBaseDirName);


            this.ModelSourceURL=strcat(modelSrcPath,'/',modelSrcName,modelSrcExt);
            this.ModelSourceFile=fullfile(docWorkingDir,modelSrcPath,strcat(modelSrcName,modelSrcExt));


            this.ProgressMonitor=slreportgen.webview.ProgressMonitor();
        end


        function export(this,modelHierarchy,homeItem,initialElement)



            backtraceStatus=warning('query','backtrace');
            if strcmp(backtraceStatus.state,'on')
                c=onCleanup(@()warning(backtraceStatus));
                warning('backtrace','off');
            end


            drawnow();


            if~builtin('license','checkout','SIMULINK_Report_Gen')
                error(message('slreportgen_webview:exporter:LicenseCheckoutFailed'));
            end


            pm=this.ProgressMonitor;
            setMessage(pm,...
            message('slreportgen_webview:exporter:ExportingSystem',getName(homeItem)),...
            pm.ImportantMessagePriority);
            setMinValue(pm,0);
            setMaxValue(pm,...
            getNumberOfItems(modelHierarchy)+...
            1);


            if~isfolder(this.BaseDir)
                mkdir(this.BaseDir);
            end








            this.ExportedDiagramCache=containers.Map();
            this.m_section=containers.Map();
            this.IconFileToCSSClass=containers.Map();
            this.HasNotesToExport=this.ModelExporter.IncludeNotes...
            &&slreportgen.webview.NotesExporter.hasNotes(homeItem.getRoot().getDiagramHierarchyId());

            if this.HasNotesToExport
                this.NotesExporter=slreportgen.webview.NotesExporter(this);
            end


            rootObj=getDiagramSlProxyObjectFromItem(this,homeItem);


            this.IconClassPrefix=strrep(getObjectId(this,rootObj),':','_');


            imageSpriteFile=strcat(getObjectBaseName(this,rootObj),'_icons.png');
            imageCSSFile=strcat(getObjectBaseName(this,rootObj),'_icons.css');
            imageCSSUrl=strcat(getObjectBaseUrl(this,rootObj),'_icons.css');
            imageSpriteWriter=this.ImageSpriteWriter;
            open(imageSpriteWriter,imageSpriteFile,imageCSSFile);


            this.m_enabledOptionalViews=-1;


            appWriter=slreportgen.webview.JSONWriter(this.ModelSourceFile);
            appWriter.Indent=this.Indent;

            beginObject(appWriter);


            name(appWriter,'baseUrl');
            value(appWriter,this.BaseUrl);


            name(appWriter,'homeHid');
            value(appWriter,homeItem.ID);


            initialElementPath='';
            name(appWriter,'initialElement');
            if~isempty(initialElement)
                slobj=slreportgen.webview.SlProxyObject(initialElement);
                initialElementPath=strcat(char(getPath(homeItem)),'/',regexprep(getName(slobj),'/','//'));
            end
            value(appWriter,initialElementPath);


            name(appWriter,'sections');
            exportModelHierarchy(this,appWriter,modelHierarchy)


            name(appWriter,'optViews');
            exportOptViewData(this,appWriter)


            name(appWriter,'display');
            beginObject(appWriter);
            name(appWriter,'informer');
            value(appWriter,hasInformer(this));
            name(appWriter,'notes');
            value(appWriter,this.HasNotesToExport);
            endObject(appWriter);


            name(appWriter,'iconsUrl');
            value(appWriter,imageCSSUrl);


            endObject(appWriter);
            close(appWriter);


            addFile(this.Document,this.ModelSourceFile,this.ModelSourceURL);


            close(imageSpriteWriter);
            if exist(imageSpriteFile,'file')

                addFile(this,imageSpriteFile);
                addFile(this,imageCSSFile);
            end


            this.ExportedDiagramCache=[];
            this.m_section=[];
            this.IconFileToCSSClass=[];


            this.m_enabledOptionalViews=-1;


            done(pm);
        end

        function id=getObjectId(~,obj)
            if isa(obj,'slreportgen.webview.SlProxyObject')
                id=getId(obj);
            else
                slobj=slreportgen.webview.SlProxyObject(obj);
                id=getId(slobj);
            end
        end

        function fileName=getObjectBaseName(this,obj)
            objId=strrep(getObjectId(this,obj),':','_');
            fileName=fullfile(this.BaseDir,objId);
        end

        function fileName=getObjectBaseUrl(this,obj)
            objId=strrep(getObjectId(this,obj),':','_');
            fileName=strcat(this.BaseUrl,'/',objId);
        end

        function iconClass=getIconClass(this,iconFile)



            iconFile=char(iconFile);
            try
                iconClass=this.IconFileToCSSClass(iconFile);
            catch
                iconClass=[this.IconClassPrefix,int2str(this.IconFileToCSSClass.Count)];
                this.IconFileToCSSClass(iconFile)=iconClass;
                add(this.ImageSpriteWriter,iconClass,iconFile);
            end
        end

        function addFile(this,file,url,varargin)
            if(nargin<3)
                [~,fName,fExt]=fileparts(file);
                url=strcat(this.BaseUrl,'/',fName,fExt);
            end

            addFile(this.Document,file,url,varargin{:});
        end

        function enabledOptionalViews=getEnabledOptionalViews(this)
            if~iscell(this.m_enabledOptionalViews)
                optionalViews=this.ModelExporter.OptionalViews;
                if(~isempty(optionalViews)&&~iscell(optionalViews))
                    optionalViews={optionalViews};
                end

                enabledOptionalViews={};
                nOptionalViews=length(optionalViews);
                for i=1:nOptionalViews
                    optionalView=optionalViews{i};
                    if isEnabled(optionalView)
                        enabledOptionalViews{end+1}=optionalView;%#ok
                    end
                end
                this.m_enabledOptionalViews=enabledOptionalViews;
            end

            enabledOptionalViews=this.m_enabledOptionalViews;
        end
    end

    methods(Static,Access=private)

        function mapping=sliceModelHierarchy(modelHierarchy)



            mapping={};

            i=1;


            mStack=fliplr(getRootItems(modelHierarchy));
            while~isempty(mStack)

                modelItem=mStack(end);
                mStack=mStack(1:end-1);

                mapping{i,1}=[];%#ok



                hStack=modelItem;
                while~isempty(hStack)

                    hItem=hStack(end);
                    hStack=hStack(1:end-1);

                    if(~isempty(mapping{i,1})&&isModelReference(hItem))

                        mStack=[mStack,hItem];%#ok
                    else
                        cItems=getChildren(hItem);
                        hStack=[hStack,fliplr(cItems)];%#ok
                    end


                    mapping{i,1}=[mapping{i},hItem];
                end
                i=i+1;
            end
        end
    end

    methods(Access=private)
        function exportModelHierarchy(this,writer,modelHierarchy)


            if this.ProgressMonitor.isCanceled()
                return
            end

            modelSections=this.sliceModelHierarchy(modelHierarchy);

            beginArray(writer);
            nModelParts=size(modelSections,1);
            for i=1:nModelParts
                exportSectionItems(this,writer,modelSections{i});
            end

            endArray(writer);
        end

        function exportSectionItems(this,writer,sectionItems)






            if this.ProgressMonitor.isCanceled()
                return
            end

            nSectionItems=numel(sectionItems);
            sectionRootItem=sectionItems(1);
            sectionRootDiagramObj=getDiagramSlProxyObjectFromItem(this,sectionRootItem);

            descendantPartItems=sectionItems(2:end);


            if~isempty(descendantPartItems)
                descendantPartItems([descendantPartItems.CheckState]==descendantPartItems(1).UNCHECKED)=[];
            end


            beginObject(writer)


            name(writer,'hid');
            value(writer,sectionRootItem.ID);


            name(writer,'sid');
            value(writer,sectionRootDiagramObj.SID);


            name(writer,'name');
            value(writer,getName(sectionRootDiagramObj));


            name(writer,'fullname');
            value(writer,getPath(sectionRootItem));


            name(writer,'label');
            value(writer,getDisplayLabel(sectionRootDiagramObj));


            parentItem=getParent(sectionRootItem);
            name(writer,'parent');
            if isempty(parentItem)
                value(writer,0);
            else
                value(writer,parentItem.ID);
            end


            name(writer,'descendants');
            nDescendants=nSectionItems-1;
            if(nDescendants>1)
                value(writer,[sectionItems(2:end).ID]);


            elseif((nDescendants==1)&&(numel(descendantPartItems)>0))
                beginArray(writer)
                value(writer,descendantPartItems.ID);
                endArray(writer);


            else
                value(writer,[]);
            end


            modelRootItem=getRoot(sectionItems(1));
            modelRootDiagramObj=getDiagramSlProxyObjectFromItem(this,modelRootItem);
            hid=int2str(sectionRootItem.ID);
            hierarchyFile=strcat(getObjectBaseName(this,modelRootDiagramObj),'_h_',hid,'.json');
            hierarchyUrl=strcat(getObjectBaseUrl(this,modelRootDiagramObj),'_h_',hid,'.json');

            name(writer,'hierarchyUrl');
            value(writer,hierarchyUrl);

            hierarchyWriter=slreportgen.webview.JSONWriter(hierarchyFile);
            hierarchyWriter.Indent=this.Indent;




            beginArray(hierarchyWriter);
            if isRoot(sectionRootItem)
                exportHierarchyItem(this,hierarchyWriter,sectionRootItem)
            end
            for j=2:nSectionItems
                exportHierarchyItem(this,hierarchyWriter,sectionItems(j))
            end
            endArray(hierarchyWriter);

            close(hierarchyWriter);
            addFile(this,hierarchyFile,hierarchyUrl);


            name(writer,'backingUrl');
            exportSectionBackingObjects(this,writer,sectionItems);


            endObject(writer);
        end

        function exportHierarchyItem(this,writer,hierarchyItem)
            if this.ProgressMonitor.isCanceled()
                return
            end

            if~isUnchecked(hierarchyItem)
                diagramObj=getDiagramSlProxyObjectFromItem(this,hierarchyItem);
                elementObj=getElementSlProxyObjectFromItem(this,hierarchyItem);

                beginObject(writer);


                name(writer,'hid');
                value(writer,hierarchyItem.ID);


                name(writer,'sid');
                value(writer,diagramObj.SID);


                name(writer,'esid');
                if~isempty(elementObj)
                    value(writer,elementObj.SID);
                else
                    value(writer,'');
                end


                name(writer,'parent');
                parentHierarchyItem=getParent(hierarchyItem);
                if isempty(parentHierarchyItem)
                    value(writer,0);
                else
                    value(writer,parentHierarchyItem.ID);
                end


                name(writer,'children');
                children=getChildren(hierarchyItem);
                n=numel(children);
                beginArray(writer);
                for i=1:n
                    if~isUnchecked(children(i))
                        value(writer,children(i).ID);
                    end
                end
                endArray(writer);


                name(writer,'name');
                value(writer,getName(hierarchyItem));


                name(writer,'fullname');
                value(writer,getPath(hierarchyItem));


                name(writer,'label');
                value(writer,getDisplayLabel(hierarchyItem));


                name(writer,'icon');
                if isModelReference(hierarchyItem)
                    displayIcon=slreportgen.utils.getDisplayIcon(elementObj.Handle);
                else
                    displayIcon=slreportgen.utils.getDisplayIcon(diagramObj.Handle);
                end
                if~isempty(displayIcon)
                    value(writer,getIconClass(this,displayIcon));
                else
                    value(writer,'');
                end

                if isChecked(hierarchyItem)
                    exportDiagramBackingObject(this,writer,diagramObj,true);


                    if this.HasNotesToExport
                        name(writer,'notes');
                        value(writer,export(this.NotesExporter,hierarchyItem));
                    end
                end


                name(writer,'sameAsElement')
                value(writer,(~isempty(elementObj)&&(elementObj==diagramObj)));

                pm=this.ProgressMonitor;
                setValue(pm,pm.Value+1);

                endObject(writer);
            end
        end

        function exportSectionBackingObjects(this,writer,sectionItems)
            if this.ProgressMonitor.isCanceled()
                return
            end

            sectionRoot=sectionItems(1);
            sectionRootDiagramObj=getDiagramSlProxyObjectFromItem(this,sectionRoot);

            if~isKey(this.m_section,sectionRootDiagramObj.SID)
                backingFile=strcat(getObjectBaseName(this,sectionRootDiagramObj),'_m.json');
                backingUrl=strcat(getObjectBaseUrl(this,sectionRootDiagramObj),'_m.json');

                backingWriter=slreportgen.webview.JSONWriter(backingFile);
                backingWriter.Indent=this.Indent;
                beginArray(backingWriter);
                nSectionItems=numel(sectionItems);
                for i=1:nSectionItems
                    sectionItem=sectionItems(i);

                    if isChecked(sectionItem)
                        sectionBackingObject=getDiagramSlProxyObjectFromItem(this,sectionItem);
                        parentItem=getParent(sectionItem);
                        parentBackingObject=[];
                        if~isempty(parentItem)
                            parentBackingObject=getDiagramSlProxyObjectFromItem(this,parentItem);
                        end
                        exportBackingObjectData(this,backingWriter,sectionBackingObject,parentBackingObject);
                    end
                end
                endArray(backingWriter);

                close(backingWriter);
                addFile(this,backingFile);

                this.m_section(sectionRootDiagramObj.SID)=backingUrl;
                value(writer,backingUrl);
            else
                value(writer,this.m_section(sectionRootDiagramObj.SID));
            end
        end

        function exportDiagramBackingObject(this,writer,diagramObj,firstTry)
            if this.ProgressMonitor.isCanceled()
                return
            end

            if~isKey(this.ExportedDiagramCache,diagramObj.SID)
                diagramObjBaseName=getObjectBaseName(this,diagramObj);
                diagramObjBaseUrl=getObjectBaseUrl(this,diagramObj);


                svgFile=strcat(diagramObjBaseName,'_d.svg');
                svgUrl=strcat(diagramObjBaseUrl,'_d.svg');


                svgWriter=slreportgen.webview.SvgWriter(getHandle(diagramObj));
                svgWriteArgs=GLUE2.SvgWriteArguments;
                generate(svgWriter,svgFile,svgWriteArgs);
                addFile(this,svgFile);


                thumbnailFile=strcat(diagramObjBaseName,'_d.png');
                thumbnailUrl=strcat(diagramObjBaseUrl,'_d.png');

                snapshot=this.Snapshot;
                snapshot.Source=getHandle(diagramObj);
                snapshot.Filename=thumbnailFile;
                snap(snapshot);
                addFile(this,thumbnailFile);


                backingFile=strcat(diagramObjBaseName,'_d.json');
                backingUrl=strcat(diagramObjBaseUrl,'_d.json');

                elementObjs=getGroupedSlProxyObjs(svgWriter);
                nElementObjs=numel(elementObjs);
                backingWriter=slreportgen.webview.JSONWriter(backingFile);
                backingWriter.Indent=this.Indent;

                separatorIdx=numel(strtok(diagramObj.SID,':'))+1;
                beginArray(backingWriter);
                elements=cell(1,nElementObjs);
                try
                    j=0;
                    for i=1:nElementObjs
                        elementObj=elementObjs{i};
                        elementId=getId(elementObj);

                        if~strcmp(elementId,diagramObj.SID)
                            exportBackingObjectData(this,backingWriter,elementObj,diagramObj);
                            shortSID=elementId(separatorIdx:end);
                            j=j+1;
                            elements{j}=shortSID;
                        end
                    end
                    elements(j+1:end)=[];

                catch ME
                    state=warning('off','slreportgen_webview:json_writer:MalformedJSONFile');
                    scopeRestoreState=onCleanup(@()warning(state));
                    close(backingWriter);
                    if firstTry
                        exportDiagramBackingObject(this,writer,diagramObj,false);
                        return
                    else
                        rethrow(ME);
                    end
                end
                endArray(backingWriter);
                close(backingWriter);
                addFile(this,backingFile);

                name(writer,'svg');
                value(writer,svgUrl);

                name(writer,'thumbnail');
                value(writer,thumbnailUrl);

                name(writer,'backingUrl');
                value(writer,backingUrl);

                name(writer,'elements');
                value(writer,elements);

                this.ExportedDiagramCache(diagramObj.SID)=struct(...
                'svg',svgUrl,...
                'thumbnail',thumbnailUrl,...
                'backingUrl',backingUrl,...
                'elements',{elements}...
                );
            else
                exported=this.ExportedDiagramCache(diagramObj.SID);

                name(writer,'svg');
                value(writer,exported.svg);

                name(writer,'thumbnail');
                value(writer,exported.thumbnail);

                name(writer,'backingUrl');
                value(writer,exported.backingUrl);

                name(writer,'elements');
                value(writer,exported.elements);
            end
        end

        function exportBackingObjectData(this,writer,obj,parentObj)
            if this.ProgressMonitor.isCanceled()
                return
            end


            beginObject(writer);


            name(writer,'sid');
            value(writer,getId(obj));


            name(writer,'className');
            value(writer,obj.ClassName);


            name(writer,'icon');
            displayIcon=slreportgen.utils.getDisplayIcon(obj.Handle);
            if~isempty(displayIcon)
                value(writer,getIconClass(this,displayIcon));
            else
                value(writer,'');
            end


            name(writer,'name');
            value(writer,getName(obj));


            name(writer,'label');
            value(writer,getDisplayLabel(obj));


            name(writer,'parent');
            if~isempty(parentObj)
                value(writer,parentObj.SID);
            else
                value(writer,'');
            end


            export(this.ModelExporter.SystemView,writer,obj);


            optionalViews=getEnabledOptionalViews(this);
            if~isempty(optionalViews)
                name(writer,'views');
                beginObject(writer);

                nOptionalViews=numel(optionalViews);
                for i=1:nOptionalViews
                    optionalView=optionalViews{i};


                    name(writer,optionalView.Id)


                    beginObject(writer);
                    export(optionalView,writer,obj);
                    endObject(writer);
                end
                endObject(writer);
            end


            endObject(writer);
        end

        function exportOptViewData(this,writer)
            if this.ProgressMonitor.isCanceled()
                return
            end


            optionalViews=getEnabledOptionalViews(this);
            nOptionalViews=length(optionalViews);


            beginArray(writer);

            for i=1:nOptionalViews

                optionalView=optionalViews{i};
                beginObject(writer);


                name(writer,'id')
                value(writer,optionalView.Id)


                name(writer,'name');
                value(writer,optionalView.Name);


                if exist(optionalView.Icon,'file')
                    name(writer,'icon');
                    value(writer,getIconClass(this,optionalView.Icon));
                end


                endObject(writer);
            end


            endArray(writer);
        end

        function tf=hasInformer(this)
            tf=~isempty(this.ModelExporter.SystemView.InformerDataExporter);
            if~tf
                optionalViews=getEnabledOptionalViews(this);
                n=length(optionalViews);
                for i=1:n
                    optionalView=optionalViews{i};
                    tf=~isempty(optionalView.InformerDataExporter);
                    if tf
                        break
                    end
                end
            end
        end

        function verifyUncheckedItemsAreNotCheckedElsewhere(this,modelHierarchy)

            checkedItems=getCheckedItems(modelHierarchy);
            nCheckedItems=numel(checkedItems);
            checkedObjs=repmat(slreportgen.webview.SlProxyObject,1,nCheckedItems);
            for i=1:nCheckedItems
                checkedObjs(i)=getDiagramSlProxyObjectFromItem(this,checkedItems(i));
            end

            unCheckedItems=getUncheckedItems(modelHierarchy);
            nUncheckedItems=numel(unCheckedItems);
            uncheckedObjs=repmat(slreportgen.webview.SlProxyObject,1,nUncheckedItems);
            for i=1:nUncheckedItems
                uncheckedObjs(i)=getDiagramSlProxyObjectFromItem(this,unCheckedItems(i));
            end

            this.m_force=false(1,getNumberOfItems(modelHierarchy));


            for i=1:nUncheckedItems
                for j=1:nCheckedItems
                    if(uncheckedObjs(i)==checkedObjs(j))
                        warning(message('slreportgen_webview:exporter:UnselectedSysExported',...
                        getPath(unCheckedItems(i)),...
                        getPath(checkedItems(j))));
                        this.m_force(unCheckedItems{i}.ID)=true;
                    end
                end
            end
        end

        function dobj=getDiagramSlProxyObjectFromItem(this,item)
            if~isKey(this.ItemToDiagramObj,item.ID)
                diagH=getDiagramBackingHandle(item);
                if~isempty(diagH)
                    this.ItemToDiagramObj(item.ID)=slreportgen.webview.SlProxyObject(diagH);
                else
                    this.ItemToDiagramObj(item.ID)=[];
                end
            end
            dobj=this.ItemToDiagramObj(item.ID);
        end

        function dobj=getElementSlProxyObjectFromItem(this,item)
            if~isKey(this.ItemToElementObj,item.ID)
                elemH=getElementBackingHandle(item);
                if~isempty(elemH)
                    this.ItemToElementObj(item.ID)=slreportgen.webview.SlProxyObject(elemH);
                else
                    this.ItemToElementObj(item.ID)=[];
                end
            end
            dobj=this.ItemToElementObj(item.ID);
        end

    end
end
