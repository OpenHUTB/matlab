function[docs,sys,counts]=countDependeeRoots(this,srcKey)




    docs={};
    sys={};
    counts=[];
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcKey);
    if~isempty(srcRoot)
        dRootCounts=containers.Map('KeyType','char','ValueType','uint32');
        dRootSys=containers.Map('KeyType','char','ValueType','char');
        myLinks=srcRoot.links;
        for i=1:myLinks.size
            link=myLinks.at(i);
            if strcmp(link.getProperty('linked'),'0')
                continue;
            end
            req=link.dependeeNode;
            if isempty(req)
                continue;
            end
            if isa(req,'rmidd.Root')
                root=req;
            else
                root=req.root;
            end
            doc=root.url;
            if isKey(dRootCounts,doc)
                dRootCounts(doc)=dRootCounts(doc)+1;
            else
                dRootCounts(doc)=1;
                dRootSys(doc)=root.getProperty('source');
            end
        end
        docs=keys(dRootCounts);
        counts=zeros(size(docs));
        sys=cell(size(docs));
        for i=1:length(docs)
            counts(i)=dRootCounts(docs{i});
            sys{i}=dRootSys(docs{i});
        end
    end
end


