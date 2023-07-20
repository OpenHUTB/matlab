classdef(Abstract)ClassDiagramFactory<handle




    properties(GetAccess=public,SetAccess=protected)
        idToObjectMap;
        App;
        GlobalSettingsFcn;
    end

    properties(Access=protected)
        public="public";
        private="private";
        readonly="readonly";
        immutable="immutable";
        accessKey="access";

        relationshipMapBySrc;
        relationshipMapByDst;

        child2parentMap;
        parent2ChildMap;
    end

    properties(Access=private)
        packageInDiagramCache;
    end

    methods(Sealed=true)
        function applyDataFrom(self,otherFactory)
            self.idToObjectMap=otherFactory.idToObjectMap;
            self.packageInDiagramCache=otherFactory.packageInDiagramCache;
            self.relationshipMapBySrc=otherFactory.relationshipMapBySrc;
            self.relationshipMapByDst=otherFactory.relationshipMapByDst;
            self.child2parentMap=otherFactory.child2parentMap;
            self.parent2ChildMap=otherFactory.parent2ChildMap;
            self.resetSuperclassesLoaded();
        end

        function updateInCanvasStates(self,classes,incanvas)
            if islogical(incanvas)&&~isempty(classes)
                arrayfun(@(c)c.setInCanvas(incanvas),classes);
                for c=classes

                    self.updateParentInCanvas(c,incanvas);
                end
            end
        end

        function updateParentChildMaps(self,parent,children)
            if isempty(children)
                return;
            end

            pID=parent.getObjectID;
            childIDs=arrayfun(@(child)child.getObjectID,children);

            if self.parent2ChildMap.isKey(pID)
                self.parent2ChildMap(pID)=[self.parent2ChildMap(pID),childIDs];
            else
                self.parent2ChildMap(pID)=childIDs;
            end

            for cID=childIDs
                if self.child2parentMap.isKey(cID)
                    self.child2parentMap(cID)=[self.child2parentMap(cID),pID];
                else
                    self.child2parentMap(cID)=pID;
                end
            end
        end

        function domainObject=getDomainObject(self,objName)
            domainObject=self.virtualGetDomainObject(objName);
        end

        function resetDiagramElements(self)
            for ob=self.idToObjectMap.values
                el=ob{:};
                el.setDiagramElementUUID('');
            end
        end

        function newNode=retrieveNonCachedObject(self,node)
            import classdiagram.app.core.domain.*;

            newNode=[];
            if isa(node,"BaseObject")
                switch node.getType
                case Package.ConstantType
                    newNode=self.virtualGetPackage(node.getName());
                case Class.ConstantType
                    newNode=self.virtualGetClass(node.getName());
                case Enum.ConstantType
                    newNode=self.virtualGetEnum(node.getName());
                case Folder.ConstantType
                    newNode=self.virtualGetFolder(node.getName());
                case Project.ConstantType
                    newNode=self.virtualGetProject(node.getName());
                end

                if~isempty(newNode)
                    newNode=self.insertObjectIntoMap(newNode);
                end
            end

        end

        function newChildNodes=retrieveNonCachedChildren(self,node)
            import classdiagram.app.core.domain.*;

            newChildNodes=[];
            if isa(node,"BaseObject")
                switch node.getType
                case Package.ConstantType
                    subPackages=self.virtualGetSubPackages(node);
                    subPackages=arrayfun(@(p)self.insertObjectIntoMap(p),subPackages);
                    classes=self.virtualGetClasses(node);
                    classes=arrayfun(@(c)self.insertObjectIntoMap(c),classes);
                    enums=self.virtualGetEnums(node);
                    enums=arrayfun(@(e)self.insertObjectIntoMap(e),enums);

                    newChildNodes={subPackages,classes,enums};

                case{Folder.ConstantType,...
                    Project.ConstantType}
                    subfolders=self.virtualGetSubFolders(node);
                    subfolders=arrayfun(@(f)self.insertObjectIntoMap(f),subfolders);

                    [classNames,enumNames]=node.getClassFullNames();
                    classes=Class.empty;
                    for i=1:length(classNames)
                        c=self.virtualGetClass(classNames{i});
                        if isempty(c)
                            c=self.virtualGetPlaceholderClass(classNames{i},...
                            ElementState.NotOnPath);
                            classes(i)=c;
                        else
                            classes(i)=self.insertObjectIntoMap(c);
                        end
                    end

                    enums=Enum.empty;
                    for i=1:length(enumNames)
                        e=self.virtualGetEnum(enumNames{i});
                        if isempty(e)
                            e=self.virtualGetPlaceholderEnum(enumNames{i},...
                            ElementState.NotOnPath);
                            enums(i)=e;
                        else
                            enums(i)=self.insertObjectIntoMap(e);
                        end
                    end
                    newChildNodes={subfolders,classes,enums};
                end
            end
        end

        function pkgs=getPackages(self)
            pkgs=self.virtualGetPackages();
        end

        function folder=getFolder(self,folderPath)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateFolderID(folderPath);
            if(self.idToObjectMap.isKey(id))
                folder=self.idToObjectMap(id);
            else
                folder=self.virtualGetFolder(folderPath);
                if~isempty(folder)
                    self.insertObjectIntoMap(folder);
                end
            end
        end

        function project=getProject(self,projectName)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateProjectID(projectName);
            if(self.idToObjectMap.isKey(id))
                project=self.idToObjectMap(id);
            else
                project=self.virtualGetProject(projectName);
                if~isempty(project)
                    project=self.insertObjectIntoMap(project);
                end
            end
        end

        function subFolders=getSubFolders(self,folderOrProject)
            subFolders=self.virtualGetSubFolders(folderOrProject);
            subFolders=arrayfun(@(f)self.insertObjectIntoMap(f),subFolders);
            self.updateParentChildMaps(folderOrProject,subFolders);
        end

        function folders=getFolders(self,folderPaths)


            folders=arrayfun(@(fp)self.getFolder(fp{:}),folderPaths,'uni',0);
            folders=[folders{:}];
        end

        function projects=getProjects(self,projectNames)


            projects=arrayfun(@(pn)self.getProject(pn{:}),projectNames,'uni',0);
            projects=[projects{:}];
        end

        function classes=getFolderOrProjectClasses(self,folderOrProject,recurse)

            import classdiagram.app.core.domain.*;

            classes=PackageElement.empty;
            if isempty(folderOrProject)
                return;
            end

            function names=getFolderOrProjectClassNames(folder)
                [cl,enums]=folder.getClassFullNames;
                names=vertcat(cl,enums)';
            end

            allFolders=Folder.empty;
            projectClassNames={};
            if isa(folderOrProject,'Folder')
                allFolders=folderOrProject;
            else
                projectClassNames=getFolderOrProjectClassNames(folderOrProject);
            end

            if recurse
                newFolders=self.getSubFolders(folderOrProject);
                while~isempty(newFolders)
                    newFolders(isempty(newFolders))=[];
                    allFolders(end+1:end+numel(newFolders))=newFolders;
                    t=Folder.empty;
                    newFolders=arrayfun(@(f)cat(2,t,self.getSubFolders(f)),newFolders,'uni',0);
                    newFolders=classdiagram.app.core.utils.removeEmptyCells(newFolders);
                    newFolders=[newFolders{:}];
                end
            end

            folderClassNames=classdiagram.app.core.utils.removeEmptyCells(...
            arrayfun(@(folder){getFolderOrProjectClassNames(folder)},allFolders));
            if isempty(folderClassNames)
                classNames=projectClassNames;
            else
                classNames=[projectClassNames,folderClassNames{:}];
            end


            classes=cellfun(@(n)self.getPackageElement(n{:}),classNames,'uni',0);
            classes=[classes{:}];
        end

        function class=getPlaceholderClass(self,className,state)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateClassID(className);
            if(self.idToObjectMap.isKey(id))
                class=self.idToObjectMap(id);
                class.setState(state);
            else
                class=self.virtualGetPlaceholderClass(className,state);
                if~isempty(class)&&self.isObjectOnPath(class)
                    self.insertObjectIntoMap(class);
                end
            end
        end

        function enum=getPlaceholderEnum(self,enumName,state)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumID(className);
            if(self.idToObjectMap.isKey(id))
                enum=self.idToObjectMap(id);
                enum.setState(state);
            else
                enum=self.virtualGetPlaceholderEnum(enumName,state);
                if~isempty(enum)&&self.isObjectOnPath(enum)
                    self.insertObjectIntoMap(enum);
                end
            end
        end



        function pkg=getPackage(self,packageName)
            id=classdiagram.app.core.utils.ObjectIDUtility.generatePackageID(packageName);
            if(self.idToObjectMap.isKey(id))
                pkg=self.idToObjectMap(id);
            else
                pkg=self.virtualGetPackage(packageName);
                if~isempty(pkg)
                    self.insertObjectIntoMap(pkg);
                end
            end
        end

        function cls=getClass(self,className)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateClassID(className);
            if(self.idToObjectMap.isKey(id))
                cls=self.idToObjectMap(id);
            else














                enumId=classdiagram.app.core.utils.ObjectIDUtility.generateEnumID(className);
                if(self.idToObjectMap.isKey(enumId))
                    cls=classdiagram.app.core.domain.Class.empty;
                    return;
                end


                cls=self.virtualGetClass(className);





                if~isempty(cls)&&self.isObjectOnPath(cls)
                    self.insertObjectIntoMap(cls);
                end
            end
        end

        function enum=getEnum(self,enumName)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumID(enumName);
            if(self.idToObjectMap.isKey(id))
                enum=self.idToObjectMap(id);
            else

                clsId=classdiagram.app.core.utils.ObjectIDUtility.generateClassID(enumName);
                if(self.idToObjectMap.isKey(clsId))
                    enum=classdiagram.app.core.domain.Enum.empty;
                    return;
                end

                enum=self.virtualGetEnum(enumName);
                if~isempty(enum)&&self.isObjectOnPath(enum)
                    self.insertObjectIntoMap(enum);
                end
            end
        end

        function enumLiteral=getEnumLiteral(self,enumLiteralName,enum)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumLiteralID(enum.getName(),enumLiteralName);
            if enum.literalsLoaded()&&self.idToObjectMap.isKey(id)
                enumLiteral=self.idToObjectMap(id);
            else
                enumLiteral=self.virtualGetEnumLiteral(enumLiteralName,enum);
                if~isempty(enumLiteral)
                    replace=true;
                    self.insertObjectIntoMap(enumLiteral,replace);
                end
            end
        end



        function pkgs=getSubPackages(self,package)
            if package.subpackagesLoaded()
                pkgs=package.Subpackages;
            else
                pkgs=self.virtualGetSubPackages(package);
                pkgs=arrayfun(@(p)self.insertObjectIntoMap(p),pkgs);
                package.Subpackages=pkgs;
                self.updateParentChildMaps(package,pkgs);
            end
        end

        function pkg=getParentPackage(self,package)
            if package.parentLoaded()
                pkg=package.ParentPackage;
            else
                pkg=self.virtualGetParentPackage(package);
                package.ParentPackage=pkg;
            end
        end

        function classes=getClasses(self,package)
            if isempty(package)

                classes=self.virtualGetClasses(package);
                classes=arrayfun(@(c)self.insertObjectIntoMap(c),classes);
                return;
            end
            if package.classesLoaded()
                classes=package.Classes;
            else
                classes=self.virtualGetClasses(package);
                classes=arrayfun(@(c)self.insertObjectIntoMap(c),classes);
                package.Classes=classes;
                self.updateParentChildMaps(package,classes);
            end
        end

        function enums=getEnums(self,package)
            if isempty(package)

                enums=self.virtualGetEnums(package);
                enums=arrayfun(@(c)self.insertObjectIntoMap(c),enums);
                return;
            end
            if package.enumsLoaded()
                enums=package.Enums;
            else
                enums=self.virtualGetEnums(package);
                enums=arrayfun(@(e)self.insertObjectIntoMap(e),enums);
                package.Enums=enums;
                self.updateParentChildMaps(package,enums);
            end
        end




        function mths=getMethods(self,class)
            if class.methodsLoaded()
                mths=class.Methods;
            else
                mths=self.virtualGetMethods(class);
                class.Methods=mths;
            end
        end

        function props=getProperties(self,class)
            if class.propertiesLoaded()
                props=class.Properties;
            else
                props=self.virtualGetProperties(class);
                class.Properties=props;
            end
        end

        function evts=getEvents(self,class)
            if class.eventsLoaded()
                evts=class.Events;
            else
                evts=self.virtualGetEvents(class);
                class.Events=evts;
            end
        end

        function classes=getSuperclasses(self,class)
            if class.superclassesLoaded()
                classes=class.Superclasses;
            else
                classes=self.virtualGetSuperclasses(class);
                class.Superclasses=classes;
            end
        end

        function method=getMethod(self,class,methodName,metadata)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateMethodID(class.getName(),methodName);
            if class.methodsLoaded()&&self.idToObjectMap.isKey(id)
                method=self.idToObjectMap(id);
            else
                replace=true;
                method=virtualGetMethod(self,class,methodName,metadata);
                self.insertObjectIntoMap(method,replace);
            end
        end

        function property=getProperty(self,class,propertyName,metadata,domainProperty)
            id=classdiagram.app.core.utils.ObjectIDUtility.generatePropertyID(class.getName(),propertyName);
            if class.propertiesLoaded()&&self.idToObjectMap.isKey(id)
                property=self.idToObjectMap(id);
            else
                replace=true;
                property=virtualGetProperty(self,class,propertyName,metadata,domainProperty);
                self.insertObjectIntoMap(property,replace);
            end
        end

        function evt=getEvent(self,class,eventName,metadata)
            id=classdiagram.app.core.utils.ObjectIDUtility.generateEventID(class.getName(),eventName);
            if class.eventsLoaded()&&self.idToObjectMap.isKey(id)
                evt=self.idToObjectMap(id);
            else
                replace=true;
                evt=virtualGetEvent(self,class,eventName,metadata);
                self.insertObjectIntoMap(evt,replace);
            end
        end



        function literals=getEnumLiterals(self,enum)
            if enum.literalsLoaded()
                literals=enum.Literals;
            else
                literals=self.virtualGetEnumLiterals(enum);
                enum.Literals=literals;
            end
        end


        function pos=getLoadedPositions(self,classes)
            pos=self.virtualGetLoadedPositions(classes);
        end

        function expandState=getLoadedExpandStates(self,classes)
            expandState=self.virtualGetLoadedExpandStates(classes);
        end

        function settings=getLoadedSettings(self)
            settings=self.virtualGetLoadedSettings();
        end

        function roots=getBrowserRoots(self)
            roots=self.virtualGetBrowserRoots();
        end



        function report=getOutOfDateElements(self)
            report=self.virtualGetOutOfDateElements();
        end

        function updateTypes(self,objects)
            function updateType(el)
                wasClass=isa(el,'classdiagram.app.core.domain.Class');
                try
                    mcosMetadata=meta.class.fromName(el.getName());
                catch e
                    return;
                end
                el.clearCaches();
                if wasClass~=isempty(mcosMetadata.EnumerationMemberList)
                    self.idToObjectMap.remove(el.getObjectID);
                    if wasClass
                        newEl=self.getEnum(el.getName());
                    else
                        newEl=self.getClass(el.getName());
                    end
                    newEl.setDiagramElementUUID(el.getDiagramElementUUID);
                    el.setDiagramElementUUID([]);
                end
            end
            arrayfun(@(obj)updateType(obj),objects);
        end

        function clearCaches(self)
            objs=self.idToObjectMap.values;
            for obj=objs
                o=obj{:};
                o.clearCaches();
            end
        end

    end

    methods(Abstract,Access=protected)
        virtualGetDomainObject(self,objName);
        virtualGetPackage(self,packageName);
        virtualGetPackages(self);
        virtualGetSubPackages(self,package);
        virtualGetParentPackage(self,package);
        virtualGetClass(self,className);
        virtualGetMethods(self,class);
        virtualGetMethod(self,class,methodName,metadata);
        virtualGetProperties(self,class);
        virtualGetProperty(self,class,propertyName,metadata,domainProperty);
        virtualGetEvents(self,class);
        virtualGetEvent(self,class,eventName,metadata);
        virtualGetEnum(self,enumName);
        virtualGetEnumLiteral(self,enumLiteralName,enum);

        virtualGetEnums(self,package);
        virtualGetEnumLiterals(self,enum);
        virtualGetClasses(self,package);
        virtualGetSuperclasses(self,class);

        virtualGetAssociationRelationships(self,class);

        virtualGetFolder(self,folderPath);
        virtualGetProject(self,projectName);
        virtualGetSubFolders(self,folderOrProject);
        virtualGetPlaceholderClass(self,className,state);
        virtualGetPlaceholderEnum(self,enumName,state);
    end

    methods(Abstract)
        getPropertySchema(self,element);
    end

    methods(Access=protected)
        getAssociationRelationships(self,class);

        function pos=virtualGetLoadedPositions(~,classes)
            [pos{1:numel(classes)}]=deal([0,0]);
        end

        function expandState=virtualGetLoadedExpandStates(~,~)
            expandState=[];
        end

        function settings=virtualGetLoadedSettings(~)
            settings=struct();
        end

        function roots=virtualGetBrowserRoots(~)
            roots=struct(Package=string.empty,Class=string.empty,Enum=string.empty,Folder=string.empty,Project=string.empty);
        end
    end

    methods
        function obj=ClassDiagramFactory()
            obj.idToObjectMap=containers.Map;
            obj.relationshipMapBySrc=containers.Map;
            obj.relationshipMapByDst=containers.Map;
            obj.packageInDiagramCache=containers.Map;
            obj.child2parentMap=containers.Map;
            obj.parent2ChildMap=containers.Map;
        end

        function obj=getObject(self,objectID)

            if(self.idToObjectMap.isKey(objectID))
                obj=self.idToObjectMap(objectID);
            else
                obj=[];
            end
        end

        function isInDiagram=isObjectInDiagram(self,object)
            if isa(object,'classdiagram.app.core.domain.Package')
                isInDiagram=self.isPackageInDiagram(object);
            else
                isInDiagram=~isempty(object.getDiagramElementUUID);
            end
        end

        function resetInDiagramCache(self)
            self.packageInDiagramCache=containers.Map;
        end

        function isInDiagram=isPackageInDiagram(self,package)






            isInDiagram=true;
            if isempty(package)
                isInDiagram=false;
                return;
            end
            packageId=package.getObjectID;
            if self.packageInDiagramCache.isKey(packageId)
                isInDiagram=self.packageInDiagramCache(packageId);
                return;
            end
            classes=self.getClasses(package);
            if self.anyNotInDiagram(classes)
                isInDiagram=false;
                self.packageInDiagramCache(packageId)=false;
                return;
            end
            enums=self.getEnums(package);
            if self.anyNotInDiagram(enums)
                isInDiagram=false;
                self.packageInDiagramCache(packageId)=false;
                return;
            end

            packagesInPackage=self.getSubPackages(package);
            for inestedPackage=1:numel(packagesInPackage)
                nestedPackage=packagesInPackage(inestedPackage);
                isInDiagram=self.isPackageInDiagram(nestedPackage);
                if~isInDiagram
                    return;
                end
            end
            self.packageInDiagramCache(packageId)=true;
        end

        function onPath=isObjectOnPath(~,object)
            import classdiagram.app.core.domain.*;
            onPath=true;
            if isa(object,'Folder')
                onPath=Folder.isOnPath(object.getName);
            elseif isa(object,'Project')
                onPath=object.isOnPath();
            elseif isa(object,'Class')||isa(object,'Enum')
                onPath=~(object.getState==ElementState.NotOnPath);
            end
        end

        function updatePackageInDiagramCache(self,classOrPackageId,isInDiagram)
            if isa(classOrPackageId,'classdiagram.app.core.domain.PackageElement')
                packages=arrayfun(@(c)c.getOwningPackage,classOrPackageId,'uni',false);
                packages=[packages{:}];
                packageIds=arrayfun(@(p)p.getObjectID,packages);
            else
                metadata=meta.package.fromName(extractAfter(classOrPackageId,8));
                if isempty(metadata)


                    return;
                end
                packagesMeta=metadata.ContainingPackage;
                if isempty(packagesMeta)
                    return;
                end
                packageNames=string({packagesMeta.Name});
                packageIds='Package|'+packageNames;
            end

            cacheKeys=keys(self.packageInDiagramCache);
            if isempty(packageIds)||isempty(cacheKeys)
                return;
            end
            [E,~]=ismember(packageIds,cacheKeys);
            packageIds=packageIds(E);
            if~isInDiagram
                for ip=1:numel(packageIds)
                    p=packageIds(ip);
                    self.packageInDiagramCache(p)=false;
                    self.updatePackageInDiagramCache(p,isInDiagram);
                end
            end
            if isInDiagram
                for ip=1:numel(packageIds)
                    p=packageIds(ip);
                    remove(self.packageInDiagramCache,p);
                    self.updatePackageInDiagramCache(p,isInDiagram);
                end
            end
        end

        function packageElements=getDiagramedEntities(self)
            objects=values(self.idToObjectMap);
            idx=cellfun(@(o)~isempty(o.getDiagramElementUUID)...
            &&isa(o,'classdiagram.app.core.domain.PackageElement'),objects);
            objects=objects(idx);
            packageElements=cat(1,objects{:})';
        end

        function relationships=getDiagramedRelationships(self,class)
            relationships=[self.getRelationshipsBySrc(class),self.getRelationshipsByDst(class)];
            idx=arrayfun(@(r)~isempty(r.getDiagramElementUUID),relationships);
            relationships=relationships(idx);
        end

        function[toCreate,toRemove,toUpdate]=getInheritance(self,classNames)
            inheritance=self.setExistingRelationshipsStale('^Relationship\|.*INHERITANCE$');
            [G,Gdirect,Gindirect,Gnonexpandable]=...
            classdiagram.app.core.graphSuperclasses(classNames,self);
            toUpdate=classdiagram.app.core.InheritanceFlags.analyzeInheritance(self,...
            classNames,G,Gdirect,Gindirect);
            direct=self.makeInheritanceRelationships(Gdirect.Edges,"INHERITANCE");
            indirect=self.makeInheritanceRelationships(Gindirect.Edges,"INDIRECTINHERITANCE",G,Gnonexpandable);
            toCreate=[direct,indirect];


            toRemove=classdiagram.app.core.domain.Relationship.empty;
            for iid=1:numel(inheritance)
                id=inheritance(iid);
                rel=self.idToObjectMap(id{:});
                if rel.getIsStale

                    toRemove(end+1)=rel;%#ok<AGROW>
                end
            end
        end

        function relationships=makeInheritanceRelationships(self,edges,rType,varargin)
            if~isempty(varargin)
                G=varargin{1};
                Gnonexpandable=varargin{2};
            end

            function setIndirectHierarchy(rel,edge)
                path=shortestpath(G,edge{:});
                hierarchy=struct();
                hierarchy.path=path(2:end-1);
                [idxOut,m]=findedge(Gnonexpandable,edge{1},edge{2});
                hierarchy.mixinsOnly=logical(idxOut);
                rel.setInheritanceHierarchy(hierarchy);
            end

            relationships=classdiagram.app.core.domain.Relationship.empty;
            for ii=1:height(edges)
                edge=edges{ii,1};
                relId="Relationship|"+edge{2}+"|"+edge{1}+"$"+rType;
                if self.idToObjectMap.isKey(relId)
                    rel=self.idToObjectMap(relId);
                    rel.setIsStale(false);
                    self.addToRelationshipMap(rel);
                    if exist('G','var')
                        setIndirectHierarchy(rel,edge);
                    end
                    if isempty(rel.getDiagramElementUUID)||exist('G','var')
                        relationships(end+1)=rel;%#ok<AGROW>
                    end
                else

                    srcEnd=self.makeRelationshipEnd(edge{2},edge{1},rType);
                    dstEnd=self.makeRelationshipEnd(edge{1},edge{2},rType);

                    rel=self.makeRelationship(srcEnd,dstEnd,rType);
                    if exist('G','var')
                        setIndirectHierarchy(rel,edge);
                    end
                    relationships(end+1)=rel;%#ok<AGROW>
                end
            end
        end

        function class=getPackageElement(self,className)
            class=self.getClass(className);
            if isempty(class)
                class=self.getEnum(className);
            end
        end

        function class=getNonCachedPackageElement(self,className)
            class=self.virtualGetClass(className);
            if isempty(class)
                class=self.virtualGetEnum(className);
            end
            if~isempty(class)
                self.insertObjectIntoMap(class,true);
            end
        end

        function rEnd=makeRelationshipEnd(self,srcName,dstName,rType)
            srcClass=self.getPackageElement(srcName);

            dstClass=self.getPackageElement(dstName);
            rEnd=classdiagram.app.core.domain.RelationshipEnd(srcClass,dstClass,rType);
            rEnd=self.insertObjectIntoMap(rEnd);
        end

        function relationship=makeRelationship(self,srcEnd,dstEnd,rType)
            relationship=classdiagram.app.core.domain.Relationship(srcEnd,dstEnd,rType,self.GlobalSettingsFcn);
            relationship=self.insertObjectIntoMap(relationship);
            self.addToRelationshipMap(relationship);
        end






        function[toCreate,toRemove,toUpdate]=getRelationships(self,classNames,showAssociations)


            [toCreate,toRemove,toUpdate]=self.getInheritance(classNames);
            if~showAssociations
                return;
            end
            for iname=numel(classNames)
                name=classNames(iname);
                class=self.getClass(name{:});
                rels=self.getAssociationRelationships(class);
                if isempty(rels)
                    continue;
                end
                emptyUuids=arrayfun(@(r)isempty(r.getDiagramElementUUID),rels);
                rels=rels(emptyUuids);
                toCreate=[toCreate,rels];%#ok<AGROW>
            end
        end

        function relationships=setExistingRelationshipsStale(self,toMatch)

            domainObjects=keys(self.idToObjectMap);
            matches=regexp(domainObjects,toMatch);
            relationships=domainObjects(~cellfun('isempty',matches));
            for iid=1:numel(relationships)
                id=relationships(iid);
                rel=self.idToObjectMap(id{:});
                rel.setIsStale(true);
            end
        end

        function superclasses=getSuperclassesForClassesSet(self,classesSet,toShowAll)
            k=1;
            superclasses=[];
            while(k<=length(classesSet))
                classID=classesSet(k);
                class=self.getObject(classID);
                singleClassSuperclasses=self.getSuperclasses(class);
                if(toShowAll)
                    addedElements=arrayfun(@(el)el.getObjectID(),singleClassSuperclasses);
                    if(isempty(addedElements))
                        k=k+1;
                        continue;
                    end
                    classesSet=cat(2,classesSet,addedElements);
                end
                superclasses=cat(2,superclasses,singleClassSuperclasses);
                k=k+1;
            end
            superclasses=unique(superclasses);
        end

        function removeFromRelationshipMaps(self,relationship)
            self.removeFromMap(relationship.getSrcEnd(),relationship,self.relationshipMapBySrc);
            self.removeFromMap(relationship.getDstEnd(),relationship,self.relationshipMapByDst);
        end
    end

    methods(Access=protected)

        function staleReport=virtualGetOutOfDateElements(~)
            staleReport=struct("outOfDate",[],"upToDate",[],"changedType",[]);
        end

        function acc=convertAccessToString(self,access)
            if(iscell(access))
                acc=self.private;
            elseif(ischar(access))
                acc=string(access);
            else
                warning('Problem converting access data to string. Assigning a value of private.');
                acc=self.private;
            end
        end

        function metadata=setAccessMeta(self,obj,getAccessName,setAccessName)
            getAcc=self.convertAccessToString(obj.(getAccessName));
            setAcc=self.convertAccessToString(obj.(setAccessName));
            metadata=containers.Map;
            if setAcc==self.immutable||(getAcc==self.public&&setAcc==self.private)
                metadata(self.accessKey)=self.readonly;
            else

                metadata(self.accessKey)=getAcc;
            end
        end

        function setBooleanMeta(~,obj,metadata,key)
            if(obj.(key))
                metadata(key)=key;%#ok<NASGU>
            end
        end

        function setBooleanMetaVal(~,val,metadata,key)
            if(val)
                metadata(key)=key;%#ok<NASGU>
            end
        end

        function unsetBooleanMetaVal(~,val,metadata,key)
            if(~val)
                metadata(key)=key;%#ok<NASGU>
            end
        end

        function validRelationshipTypes=getValidRelationshipTypes(self)


            validRelationshipTypes=["INHERITANCE","COMPOSITION","AGGREGATION","ASSOCIATION","STEREOTYPE","INDIRECTINHERITANCE"];
        end

        function relationshipEnd=getRelationshipEnd(self,parentClass,...
            oppositeEndClass,relationshipType)


            relationshipEnd=classdiagram.app.core.domain.RelationshipEnd(parentClass,...
            oppositeEndClass,relationshipType);
            relationshipEnd=self.insertObjectIntoMap(relationshipEnd);
        end


        function relationship=getRelationship(self,srcEnd,dstEnd,relationshipType)




            validRelationshipTypes=self.getValidRelationshipTypes();
            if~any(validRelationshipTypes.contains(relationshipType))
                relationshipType=validRelationshipTypes(1);
            end

            relationship=[];
            srcEndClassID=srcEnd.getParentClass.getObjectID;
            if(self.relationshipMapBySrc.isKey(srcEndClassID))
                relationships=self.relationshipMapBySrc(srcEndClassID);
                for ir=1:numel(relationships)
                    r=relationships(ir);
                    if r.getRelationshipType()==relationshipType&&r.getDstEnd()==dstEnd
                        relationship=r;
                        break;
                    end
                end
            end
            if isempty(relationship)
                relationship=self.makeRelationship(srcEnd,dstEnd,relationshipType);
            end
        end

        function relationships=getRelationshipsBySrc(self,srcClass)
            relationships=[];
            if self.relationshipMapBySrc.isKey(srcClass.getObjectID())
                relationships=self.relationshipMapBySrc(srcClass.getObjectID());
            end
        end

        function relationships=getRelationshipsByDst(self,dstClass)
            relationships=[];
            if self.relationshipMapByDst.isKey(dstClass.getObjectID())
                relationships=self.relationshipMapByDst(dstClass.getObjectID());
            end
        end

        function newObject=insertObjectIntoMap(self,object,varargin)
            replace=false;
            if~isempty(varargin)
                replace=varargin{1};
            end
            newObject=object;
            objectID=classdiagram.app.core.utils.ObjectIDUtility.generateID(newObject);

            function insertWithID(newObject,objectID)
                newObject.setObjectID(objectID);
                self.idToObjectMap(objectID)=newObject;
            end

            if(self.idToObjectMap.isKey(objectID))
                if replace

                    newObject.setDiagramElementUUID(self.idToObjectMap(objectID).getDiagramElementUUID);
                    insertWithID(newObject,objectID);
                    return;
                end
                newObject=self.idToObjectMap(objectID);
                if object.getState~=newObject.getState
                    newObject.setState(object.getState);
                end
            else
                insertWithID(newObject,objectID);
            end
        end
    end

    methods(Access=private)

        function resetSuperclassesLoaded(self)
            objs=self.idToObjectMap.values;
            for obj=objs
                o=obj{:};
                if isa(o,'classdiagram.app.core.domain.Enum')||isa(o,'classdiagram.app.core.domain.Class')
                    o.Superclasses=-1;
                end
            end
        end

        function mapRelationshipToEnd(self,relationshipEnd,relationship,relationshipMap)
            relationshipEndClassID=relationshipEnd.getParentClass().getObjectID();
            if~relationshipMap.isKey(relationshipEndClassID)
                relationshipMap(relationshipEndClassID)=relationship;
            else
                relationshipMap(relationshipEndClassID)=[relationshipMap(relationshipEndClassID),relationship];
            end
        end

        function addToRelationshipMap(self,relationship)
            self.mapRelationshipToEnd(relationship.getSrcEnd(),relationship,self.relationshipMapBySrc);
            self.mapRelationshipToEnd(relationship.getDstEnd(),relationship,self.relationshipMapByDst);
        end

        function relationshipMap=removeFromMap(self,relationshipEnd,relationship,relationshipMap)
            classID=relationshipEnd.getParentClass().getObjectID();
            relationships=relationshipMap(classID);
            relationships(relationships==relationship)=[];
            relationshipMap(classID)=relationships;
        end

        function anyEmpty=anyNotInDiagram(~,objects)
            isHidden=arrayfun(@(o)o.isHidden,objects);
            objects(isHidden)=[];
            uuids=arrayfun(@(o){o.getDiagramElementUUID},objects);
            if isempty(uuids)
                anyEmpty=false;
                return;
            end
            anyEmpty=any(cellfun('isempty',uuids));
        end

        function updateParentInCanvas(self,object,incanvas)

            if self.child2parentMap.isKey(object.getObjectID)
                parentIDs=self.child2parentMap(object.getObjectID);
                for pid=parentIDs
                    pStateUpdateNeeded=false;
                    if self.idToObjectMap.isKey(pid)
                        parent=self.idToObjectMap(pid);
                        if~incanvas

                            parent.setInCanvas(false);
                            pStateUpdateNeeded=true;
                        else

                            if~parent.isInCanvas


                                pStateUpdateNeeded=true;
                                childIDs=self.parent2ChildMap(pid);
                                for cid=childIDs
                                    c=self.getObject(cid);


                                    if~c.isInCanvas
                                        if isa(c,'classdiagram.app.core.domain.PackageElement')||self.hasChild(c)
                                            pStateUpdateNeeded=false;
                                            break;
                                        end
                                    end
                                end

                                if pStateUpdateNeeded
                                    parent.setInCanvas(true);
                                end
                            end
                        end


                        if pStateUpdateNeeded
                            self.updateParentInCanvas(parent,parent.isInCanvas);
                        end
                    end
                end
            end
        end

        function haschild=hasChild(~,parentNode)
            import classdiagram.app.core.domain.*;

            haschild=false;
            if isa(parentNode,'Package')
                haschild=Package.hasPackageElements(parentNode);
            elseif isa(parentNode,'Folder')||...
                isa(parentNode,'Project')
                haschild=parentNode.hasChild;
            end

        end

    end

end
