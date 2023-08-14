function myRoot=findOrAddRoot(this,rootUrl,docKind)


















    myRoot=rmimap.RMIRepository.getRoot(this.graph,rootUrl);
    if~isempty(myRoot)
        return;
    end






    if shouldTryShortNameMatch(docKind,rootUrl)
        [srcRoot,matched]=rmimap.RMIRepository.findSource(this.graph,rootUrl,docKind,false);
        if~isempty(srcRoot)

            if isempty(fileparts(rootUrl))

                this.proxies(srcRoot.url)=[matched,rootUrl];
            elseif~exist(rootUrl,'file')

                myRoot=srcRoot;
                return;
            end
        end
    end

    function yesno=shouldTryShortNameMatch(docKind,rootUrl)



        if any(strcmp(docKind,{'linktype_rmi_url','linktype_rmi_doors','linktype_rmi_simulink'}))
            yesno=false;
        elseif rmisl.isDocBlockPath(rootUrl)


            yesno=false;
        else

            yesno=true;
        end
    end




    isHarnessID=rmisl.isHarnessIdString(rootUrl);

    if~isHarnessID&&isempty(fileparts(rootUrl))

        resolvedPath='';
        if strcmp(docKind,'linktype_rmi_testmgr')
            resolvedPath=rmitm.getFilePath(rootUrl);
        end



        if~isempty(resolvedPath)
            rootUrl=resolvedPath;

            myRoot=rmimap.RMIRepository.getRoot(this.graph,resolvedPath);
        end
    end

    if isempty(myRoot)
        myRoot=rmidd.Root(this.graph);
        this.graph.roots.append(myRoot);
        myRoot.url=rootUrl;

        myRoot.setProperty('source',docKind);

        if isHarnessID



            parentName=strtok(rootUrl,':');
            if~strcmp(parentName,'$ModelName$')
                parentRoot=this.findOrAddRoot(parentName,docKind);
                if~isempty(parentRoot)


                    harnessData.id=rootUrl;
                    try
                        harnessName=rmisl.harnessIdToEditorName(rootUrl,false);
                        harnessData.handle=get_param(harnessName,'Handle');
                    catch

                        harnessData.handle=[];
                    end
                    this.updateHarnessNodeData(parentRoot,harnessData);
                end
            end
        end
    end
end


