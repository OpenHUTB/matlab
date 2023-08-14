function newRoot=readRoot(this,reqFileName,srcName)





    persistent isInitialized
    if isempty(isInitialized)
        rmi('init');
        isInitialized=true;
    end






    dependentLinks={};
    myRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if~isempty(myRoot)
        if myRoot.links.size>0


            newRoot=myRoot;
            return;
        else




            [dependentLinks,dependeeIds]=rmimap.RMIRepository.getDependentLinks(myRoot);
            this.removeRoot(srcName,true);
        end
    end


    rf=M3I.XmiReaderFactory();
    rdr=rf.createXmiReader();
    this.graph=rdr.read(reqFileName,this.graph,this.graph,'roots');
    delete(rdr);


    newRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(newRoot)


        if~isempty(fileparts(srcName))
            [newRoot,matched]=rmimap.RMIRepository.findSource(this.graph,srcName,'',true);
            if~isempty(newRoot)

                t0=M3I.Transaction(this.graph);
                newRoot.setProperty('lastLoaded',num2str(now));

                filesepName=strrep(newRoot.url,'\',filesep);
                if~isempty(fileparts(filesepName))



                    newRoot.url=srcName;
                end
                t0.commit;
            end
            if~isempty(matched)

                this.proxies(srcName)=matched;
            end
        end
    end


    if isempty(newRoot)
        error(message('Slvnv:rmigraph:NoModelInFile',srcName,reqFileName));

    else
        t1=M3I.Transaction(this.graph);

        isSimulink=strcmp(newRoot.getProperty('source'),'linktype_rmi_simulink');
        if isSimulink

            [childRoots,subRootIdx]=this.extractSubRoots(newRoot);
        end


        this.merge(newRoot);

        if isSimulink&&~isempty(childRoots)
            for i=1:length(childRoots)
                subRoot=childRoots{i};
                if subRootIdx(i)>0
                    dealSubRootData(subRoot,newRoot.nodeData.at(subRootIdx(i)));
                end
                this.merge(subRoot);
            end
        end



        if~isempty(dependentLinks)
            for i=1:length(dependentLinks)
                dependeeId=dependeeIds{i};
                if isempty(dependeeId)
                    dependentLinks{i}.dependeeNode=newRoot;%#ok<AGROW>
                else
                    node=rmimap.RMIRepository.getNode(newRoot,dependeeId);
                    if isempty(node)
                        node=this.addNode(newRoot,dependeeId);
                    end
                    dependentLinks{i}.dependeeNode=node;%#ok<AGROW>
                end
            end
        end

        t1.commit;
    end



    rmimap.RMIRepository.getRoot([],'');
end



function dealSubRootData(subRoot,nodeDataFromParent)

    dataCount=nodeDataFromParent.names.size;


    if isempty(subRoot.data)
        subRoot.addData();
    else
        error('RMIRepository.addTextRootData(): just created a child Root %s but root.data is not empty!',subRoot.url);
    end
    for i=1:dataCount
        name=nodeDataFromParent.names.at(i);
        value=nodeDataFromParent.values.at(i);
        subRoot.data.names.append(name);
        subRoot.data.values.append(value);
    end
end



