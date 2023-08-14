function section=createFileDetailsFromIndex(this,index,docType)





    fileNode=this.FileNodes(index);
    location=fileNode.Location{1};

    section=dependencies.internal.report.DependencyAnalyzerReportPart(docType);
    target=mlreportgen.dom.LinkTarget(string(index));
    [~,name,ext]=fileparts(location);
    fileName=strcat(name,ext);
    target.append(fileName);
    section.append(mlreportgen.dom.Heading2(target));

    if fileNode.Resolved
        fileInfo=dir(location);
        fileType=dependencies.internal.viewer.getFileType(location);
        root=i_getRootFolderIfUnique(this.RootFolders);
        thePath=this.getFilePath(index,root,docType);

        fileInfoTable=mlreportgen.dom.Table({...
        getResource("FileDetailsPathPrompt"),thePath;
        getResource("FileDetailsTypePrompt"),fileType;
        getResource("FileDetailsTimeStampPrompt"),fileInfo.date;
        getResource("FileDetailsSizePrompt"),fileInfo.bytes});
        fileInfoTable=setPropertyTableStyle(fileInfoTable);
        section.append(fileInfoTable);
    end

    problems=this.Problems(location);

    if~isempty(problems)
        section.append(mlreportgen.dom.Heading3(...
        getResource("FileDetailsProblemsTitle")));
        problems=formatProblems(problems);
        section.append(mlreportgen.dom.UnorderedList(problems));
    end

    upstreamDeps=this.Graph.getUpstreamDependencies(fileNode);
    if~isempty(upstreamDeps)
        section.append(mlreportgen.dom.Heading3(...
        getResource("FileDetailsImpactedFilesTitle")));
        names=arrayfun(...
        @(dep)getNameFromFileNode(dep.UpstreamNode),upstreamDeps);
        [~,indices]=sort(names);
        upstreamDepTable=i_getDependencyTable(...
        upstreamDeps(indices),...
        this.DependencyTableHeaders,...
        @(dep)this.getUpstreamDependencyRow(dep,docType));
        section.append(upstreamDepTable);
    end

    [fileDeps,allProdDeps,tbxDeps]=...
    this.getDownstreamDependencies(fileNode);

    if~isempty(fileDeps)
        section.append(mlreportgen.dom.Heading3(...
        getResource("FileDetailsRequiredFilesTitle")));
        names=arrayfun(...
        @(dep)getNameFromFileNode(dep.DownstreamNode),...
        fileDeps);
        [~,indices]=sort(names);
        downstreamDepTable=i_getDependencyTable(...
        fileDeps(indices),...
        this.DependencyTableHeaders,...
        @(dep)this.getDownstreamDependencyRow(dep,docType));
        section.append(downstreamDepTable);
    end

    isMultiFilter=arrayfun(...
    @(dep)isMultiProduct(dep.DownstreamNode),allProdDeps);
    prodDeps=allProdDeps(~isMultiFilter);
    optionalProdDeps=allProdDeps(isMultiFilter);

    if~isempty(allProdDeps)
        section.append(mlreportgen.dom.Heading3(...
        getResource("FileDetailsRequiredProductsTitle")));
        prodNames=arrayfun(...
        @(dep)getSortedProductNames(dep.DownstreamNode),prodDeps);
        [~,prodIndices]=sort(prodNames);
        optionalProdNames=arrayfun(...
        @(dep)getJointSortedProductNames(dep.DownstreamNode),...
        optionalProdDeps);
        [~,optionalProdIndices]=sort(optionalProdNames);
        prodDepsTable=i_getDependencyTable(...
        [prodDeps(prodIndices),optionalProdDeps(optionalProdIndices)],...
        this.ProductDependencyTableHeaders,...
        @(dep)i_getProductDependencyRow(...
        dep,@getJointSortedProductNames,docType));
        section.append(prodDepsTable);
    end

    if~isempty(tbxDeps)
        section.append(mlreportgen.dom.Heading3(getResource(...
        "FileDetailsRequiredExternalToolboxesTitle")));
        tbxDepsTable=i_getDependencyTable(...
        tbxDeps,...
        this.ExternalToolboxDependencyTableHeaders,...
        @(dep)i_getProductDependencyRow(...
        dep,@getNameFromToolboxNode,docType));
        section.append(tbxDepsTable);
    end

    section=applyMargin(section,docType);
end



function rootFolder=i_getRootFolderIfUnique(rootFolders)
    rootFolder=string.empty;
    if length(rootFolders)==1
        rootFolder=rootFolders(1);
    end
end


function table=i_getDependencyTable(theDependencies,headers,getRowFunction)
    rows=arrayfun(getRowFunction,theDependencies,"UniformOutput",false);
    rows=vertcat(rows{:});

    table=mlreportgen.dom.FormalTable(headers,rows);
    table=setFileListTableStyle(table);
end


function row=i_getProductDependencyRow(dependency,getNameFunction,docType)
    upComp=getUpstreamComponent(dependency,docType);
    names=sort(getNameFunction(dependency.DownstreamNode));
    namesString=join(names,", ");
    row={namesString,upComp,dependency.Type.Leaf.Name};
end
