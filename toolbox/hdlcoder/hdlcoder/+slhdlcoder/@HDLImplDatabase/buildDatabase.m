function buildDatabase(this,enableDeprecation,pluginList)









    if(nargin<2)
        enableDeprecation=true;
    end

    if(nargin<3)
        pluginList='all';
    end

    clearDatabase(this);

    plugins=findPluginsOnPath(pluginList);


    plugins=addSpecialPlugins(plugins);


    allClasses=loadImplementationClasses(plugins);
    allMCOSClasses=loadMCOSImplClasses(plugins);

    initConfigFiles(this,plugins);

    initLibraries(this,plugins);

    implInstances=getImplementationInstances(allClasses,allMCOSClasses);

    finalClasses=classifyImplementations(implInstances,enableDeprecation);

    registerImplementationClasses(this,finalClasses,enableDeprecation);

    initAbstractClasses(this);

end


function classes=classifyImplementations(implInstances,enableDeprecation)

    finalClasses=containers.Map;
    deprecatedClasses={};

    for ii=1:length(implInstances)
        impl=implInstances{ii};
        finalClasses(class(impl))=impl;
    end

    for ii=1:length(implInstances)
        impl=implInstances{ii};
        dlist=impl.Deprecates;
        for jj=1:length(dlist)
            dl=dlist{jj};
            deprecatedClasses{end+1}=dl;%#ok<AGROW>
        end
    end

    if enableDeprecation&&~isempty(deprecatedClasses)


        for ii=1:length(deprecatedClasses)
            if isKey(finalClasses,deprecatedClasses{ii})
                remove(finalClasses,deprecatedClasses{ii});
            else


            end
        end
    end

    classes=finalClasses.values;

end


function registerImplementationClasses(this,implInstances,enableDeprecation)



    for ii=1:length(implInstances)
        c=implInstances{ii};
        registerImplementationClass(this,c,enableDeprecation);
    end

end


function instance=getImplementationInstance(c)
    p=c.Package;
    cname=c.Name;
    pname=p.Name;
    classname=[pname,'.',cname];
    instance=eval(classname);
end

function instance=getMCOSImplInstance(c)
    instance=eval(c.Name);
end

function implInstances=getImplementationInstances(classes,MCOSclasses)
    implInstances={};
    for ii=1:length(classes)
        c=classes(ii);
        implInstances{end+1}=getImplementationInstance(c);%#ok<AGROW>
    end
    for ii=1:length(MCOSclasses)
        c=MCOSclasses(ii);
        implInstances{end+1}=getMCOSImplInstance(c);%#ok<AGROW>
    end
end


function classNames=initAbstractClasses(this)
    builtInPkgName='hdlbuiltinimpl';
    builtInPkgName2='hdlimplbase';

    p=findpackage(builtInPkgName);
    c=p.findclass;
    numUdd=length(c);
    classNames=cell(1,numUdd);
    for ii=1:numUdd
        classNames{ii}=[builtInPkgName,'.',c(ii).Name];
    end

    p=meta.package.fromName(builtInPkgName2);
    numMcos=length(p.ClassList);
    classNames2=cell(1,numMcos);
    for ii=1:numMcos
        classNames2{ii}=p.ClassList(ii).Name;
    end

    this.abstractClasses=[classNames,classNames2];
end











function plugins=findPluginsOnPath(pluginList)


    if isequal(pluginList,'all')
        w=which('-all','hdlblocks.m');
    else
        w=pluginList;
    end

    plugins={};

    for i=1:length(w)



        plugin=processPlugin(w{i});
        if~isempty(plugin)
            plugins{end+1}=plugin;%#ok<AGROW>
        end
    end
end


function classes=loadImplementationClasses(plugins)

    numclasses=0;
    pkglen=[];
    for ii=1:length(plugins)
        for jj=1:length(plugins{ii}.package)

            package=findpackage(plugins{ii}.package{jj});
            if~isempty(package)
                newclasses=length(package.findclass);
                pkglen(end+1)=newclasses;%#ok<AGROW>
                numclasses=numclasses+newclasses;
            end
        end
    end


    classes=handle(-ones(numclasses,1));
    classidx=1;
    pkgidx=1;
    for ii=1:length(plugins)

        for jj=1:length(plugins{ii}.package)
            package=findpackage(plugins{ii}.package{jj});
            if~isempty(package)
                classes(classidx:classidx+pkglen(pkgidx)-1)=package.findclass;
                classidx=classidx+pkglen(pkgidx);
                pkgidx=pkgidx+1;
            end
        end
    end
end



function classes=loadMCOSImplClasses(plugins)

    numclasses=0;
    pkglen=[];
    for ii=1:length(plugins)
        for jj=1:length(plugins{ii}.package)

            package=meta.package.fromName(plugins{ii}.package{jj});
            if~isempty(package)
                newclasses=length(package.ClassList);
                pkglen(end+1)=newclasses;%#ok<AGROW>
                numclasses=numclasses+newclasses;
            end
        end
    end

    classes=[];
    classidx=1;
    pkgidx=1;
    for ii=1:length(plugins)
        for jj=1:length(plugins{ii}.package)
            package=meta.package.fromName(plugins{ii}.package{jj});
            if~isempty(package)
                classes=[classes;package.ClassList];%#ok<AGROW>
                classidx=classidx+pkglen(pkgidx);
                pkgidx=pkgidx+1;
            end
        end
    end
end


function initConfigFiles(this,plugins)
    for ii=1:length(plugins)

        for jj=1:length(plugins{ii}.controlfile)
            if~isempty(plugins{ii}.controlfile{jj})
                this.ConfigFiles(end+1).Path='';
                this.ConfigFiles(end).FileName=plugins{ii}.controlfile{jj};
            end
        end
    end
end

function initLibraries(this,plugins)
    for ii=1:length(plugins)
        for jj=1:length(plugins{ii}.library)
            if~isempty(plugins{ii}.library{jj})


                if~any(strcmp(plugins{ii}.library{jj},this.LibraryDB))
                    this.LibraryDB{end+1}=plugins{ii}.library{jj};
                end
            end
        end
    end
end


function registerImplementationClass(this,implInstance,enableDeprecation)
    classname=class(implInstance);

    if~isa(implInstance,'hdlcoder.HDLImplementationM')
        warning(message('hdlcoder:engine:invalidHDLImplementationClassFound',classname));
        return;
    end

    blocks=implInstance.getBlocks;
    if isempty(blocks)


        return;
    end

    if~iscell(blocks)
        blocks={blocks};
    end

    description=buildDescriptionStruct(implInstance,blocks,enableDeprecation);

    for jj=1:length(blocks)
        currentBlock=blocks{jj};
        buildBlockToImplMapping(this,currentBlock,implInstance,description);
    end


    this.setDescription(classname,description);
end


function description=buildDescriptionStruct(implInstance,blocks,enableDeprecation)
    description=implInstance.getDescription;
    description.ClassName=class(implInstance);
    description.SupportedBlocks=blocks;
    description.ArchitectureNames={description.ClassName};

    if(~isempty(implInstance.ArchitectureNames))
        for i=1:length(implInstance.ArchitectureNames)
            description.ArchitectureNames{end+1}=implInstance.ArchitectureNames{i};
        end
    end


    if enableDeprecation
        if(~isempty(implInstance.Deprecates))
            for i=1:length(implInstance.Deprecates)
                description.ArchitectureNames{end+1}=implInstance.Deprecates{i};
            end
        end
    end

end


function buildBlockToImplMapping(this,slBlockPath,implClass,description)
    classname=class(implClass);

    blk=this.getBlock(slBlockPath);
    if isempty(blk)
        blk=struct(...
        'SimulinkPath',slBlockPath,...
        'Implementations',{{classname}});

        this.setBlock(slBlockPath,blk);
    else
        curImpls=blk.Implementations;
        dupClassName=checkForDuplicateShortListing(this,curImpls,description);
        if~isempty(dupClassName)
            warning(message('hdlcoder:engine:duplicateShortListing',...
            description.ShortListing,dupClassName,classname));
        end
        blk.Implementations=cat(1,curImpls,{classname});
        this.setBlock(slBlockPath,blk);
    end
end


function plugin=processPlugin(fileName)
    plugin={};

    fid=fopen(fileName,'r');
    if fid~=-1

        file=char(fread(fid)');
        fclose(fid);

        idx=min(strfind(file,'='));

        structname=deblank(file(9:idx-1));
        structname=strtrim(structname);


        idx=strfind(file,newline);
        if~isempty(idx)
            file(1:idx(1))=[];
        end
        try
            eval(file);
            pluginStruct=eval(structname);


            supported=true;
            if isfield(pluginStruct,'supportedplatforms')
                platform=computer;
                supported=find(strcmpi(platform,pluginStruct.supportedplatforms));
            end
            al=true;
            if isfield(pluginStruct,'license')
                al=pluginStruct.license;
            end
            if supported&&al
                plugin=pluginStruct;
            end
        catch me %#ok<NASGU>


        end
    end
end


function plugins=addSpecialPlugins(plugins)


    w=which('-all','hdlblocksspecial.m');
    for i=1:length(w)
        plugin=processPlugin(w{i});
        if~isempty(plugin)
            plugins{end+1}=plugin;%#ok<AGROW>
        end
    end
end



