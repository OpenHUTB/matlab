function srcRoot=addRoot(this,srcName,reqFileName)

    if~ischar(srcName)

        if nargin>2
            srcRoot=this.addModel(srcName,reqFileName);
        else
            srcRoot=this.addModel(srcName);
        end
    else
        if nargin>2

            if exist(reqFileName,'file')~=2
                error('No such file: %s',reqFileName);
            end
            srcRoot=this.readRoot(reqFileName,srcName);
        else
            rootDataArray=rmimap.initRootData(srcName);
            if isempty(rootDataArray)
                error('Unsupported source type: %s',srcName);
            end

            tr=M3I.Transaction(this.graph);
            srcRoot=rmidd.Root(this.graph);
            this.graph.roots.append(srcRoot);
            srcRoot.url=srcName;
            for i=1:size(rootDataArray,1)
                srcRoot.setProperty(rootDataArray{i,1},rootDataArray{i,2});
            end
            tr.commit;
        end
    end

    rmimap.RMIRepository.getRoot([],'');
end


