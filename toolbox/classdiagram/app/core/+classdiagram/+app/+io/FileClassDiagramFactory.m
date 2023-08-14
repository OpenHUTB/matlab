classdef FileClassDiagramFactory<classdiagram.app.core.ClassDiagramFactory



    properties
        model mf.zero.Model;
        ioDiagram;
        domainFactory;
    end

    methods
        function obj=FileClassDiagramFactory(model,app)
            obj.model=model;
            obj.App=app;
            obj.domainFactory=app.getClassDiagramFactory;
            obj.GlobalSettingsFcn=@(key)obj.App.getGlobalSetting(key);
        end

        function schema=getPropertySchema(~,~)
            schema=[];
        end
    end

    methods
        function d=getTopLevelItemOfType(self,type)
            d=[];
            t=self.model.topLevelElements();
            for i=t
                mc=i.StaticMetaClass;
                if mc.name==type
                    d=i;
                    return;
                end
            end
        end

        function d=getIoDiagram(self)
            if~isempty(self.ioDiagram)
                d=self.ioDiagram;
                return;
            end

            d=self.getTopLevelItemOfType("Diagram");
            self.ioDiagram=d;
        end

        function[package,name]=splitFqn(~,fqn)
            package='';
            name=fqn;
            if~contains(fqn,".")
                return;
            end
            fqn=char(fqn);
            dots=strfind(fqn,".");
            lastDot=dots(end);
            name=fqn(lastDot+1:end);
            package=fqn(1:lastDot-1);
        end

        function str=getAccessMetaString(self,access)
            switch access
            case classdiagram.io.Access.PUBLIC
                str=self.public;
            case classdiagram.io.Access.PRIVATE
                str=self.private;
            case classdiagram.io.Access.PROTECTED
                str=self.protected;
            case classdiagram.io.Access.READONLY
                str=self.readonly;
            case classdiagram.io.Access.IMMUTABLE
                str=self.immutable;
            end
        end

        function metadata=createItemMetadata(self,item,expanded,nonLocalMetaName)
            metadata=containers.Map;
            metadata(self.accessKey)=self.getAccessMetaString(item.access);
            self.unsetBooleanMetaVal(expanded,metadata,"Collapsed");
            self.setBooleanMetaVal(item.hidden,metadata,"Hidden");
            self.setBooleanMetaVal(item.abstract,metadata,"Abstract");
            self.setBooleanMetaVal(item.static,metadata,nonLocalMetaName);
        end

        function section=getSectionByName(~,entity,name)
            sections=entity.sections.toArray';
            section=sections(strcmp({sections.name},string(name)));
        end

        function mths=getNonPropItems(self,class,sectionName,staticName)
            mths=[];
            d=self.getIoDiagram();
            mfClass=d.elements.getByKey(class.getName);
            if~isempty(mfClass)
                section=self.getSectionByName(mfClass,string(sectionName));
                if~isempty(section)
                    for item=section.items.toArray
                        metadata=createItemMetadata(self,item,section.expanded,string(staticName));
                        if sectionName=="Methods"
                            mths=[mths,self.getMethod(class,item.name,metadata)];%#ok<AGROW>
                        elseif sectionName=="Events"
                            mths=[mths,self.getEvent(class,item.name,metadata)];%#ok<AGROW>
                        end
                    end
                end
            end
        end

    end

    methods(Access=protected)
        function domainObject=virtualGetDomainObject(self,objName)
            if isempty(objName)
                return;
            end
            domainObject=self.getPackage(objName);
            if~isempty(domainObject)
                return;
            end
            domainObject=self.getClass(objName);
            if~isempty(domainObject)
                return;
            end
            domainObject=self.getEnum(objName);
        end

        function pkg=virtualGetPackage(self,packageName)
            pkg=[];
            if~isempty(packageName)
                pkg=classdiagram.app.core.domain.Package(packageName,self.GlobalSettingsFcn);
            end
        end

        function pos=virtualGetLoadedPositions(self,classes)
            fields={'x','y'};
            c=cell(length(fields),numel(classes));
            pos=cell2struct(c,fields);

            d=self.getIoDiagram();
            for i=1:numel(classes)
                clsName=classes{i};
                mfClass=d.elements.getByKey(clsName);
                pos(i)=struct('x',mfClass.bounds.left,'y',mfClass.bounds.top);
            end
        end

        function expandState=virtualGetLoadedExpandStates(self,classes)
            fields={'entity','expanded','sections'};
            c=cell(length(fields),numel(classes));
            expandState=cell2struct(c,fields);

            d=self.getIoDiagram();
            for i=1:numel(classes)
                clsName=classes{i};
                mfClass=d.elements.getByKey(clsName);
                sectionStates=struct;
                sections=mfClass.sections.toArray;
                for section=sections
                    sectionStates.(section.name)=section.expanded;
                end
                expandState(i)=struct('entity',mfClass.name,...
                'expanded',mfClass.expanded,...
                'sections',sectionStates);
            end
        end

        function settings=virtualGetLoadedSettings(self)
            settings=struct();
            di=self.getTopLevelItemOfType("DiagramInfo");
            if~isempty(di)
                settings.ShowPackageNames=di.showPackageNames;
                if di.showMixins
                    settings.ShowDetails=true;
                    settings.ShowHandle=true;
                    settings.ShowMixins=true;
                end
            end
        end

        function roots=virtualGetBrowserRoots(self)
            roots=struct(Package=string.empty,Class=string.empty,Enum=string.empty,Folder=string.empty,Project=string.empty);
            di=self.getTopLevelItemOfType("DiagramInfo");
            if~isempty(di)&&~isempty(di.browserState)
                for root=di.browserState.roots.toArray
                    switch root.type
                    case classdiagram.io.BrowserRootType.CLASS
                        roots.Class(end+1)=root.identifier;
                    case classdiagram.io.BrowserRootType.ENUM
                        roots.Enum(end+1)=root.identifier;
                    case classdiagram.io.BrowserRootType.PACKAGE
                        roots.Package(end+1)=root.identifier;
                    case classdiagram.io.BrowserRootType.FOLDER
                        roots.Folder(end+1)=root.identifier;
                    case classdiagram.io.BrowserRootType.PROJECT
                        roots.Project(end+1)=root.identifier;
                    end
                end
            end
        end

        function pkgs=virtualGetPackages(self)
            pkgs=[];
            d=self.getIoDiagram();
            for e=d.elements.toArray
                [pkgName,~]=self.splitFqn(e.name);
                pkgs=[pkgs,self.getPackage(pkgName)];%#ok<AGROW>
            end
            pkgs=unique(pkgs);
        end

        function pkgs=virtualGetSubPackages(self,package)
            pkgs=[];
            pkgPrefix=[package.getName(),'.'];
            for pkg=self.getPackages()
                subName=pkg.getName();
                if startsWith(subName,pkgPrefix)
                    remains=subName(length(pkgPrefix)+1:end);
                    if~contains(remains,".")
                        pkgs=[pkgs,pkg];%#ok<AGROW>
                    end
                end
            end
        end

        function pkg=virtualGetParentPackage(self,package)
            pkg=[];
            [pkgName,~]=self.splitFqn(package.getName());
            if~isempty(pkgName)
                pkg=self.getPackage(pkgName);
            end
        end

        function[package,metadata,superclassNames]=fillClass(self,className,el)
            metadata=containers.Map;
            self.setBooleanMetaVal(el.hidden,metadata,"Hidden");
            self.setBooleanMetaVal(el.abstract,metadata,"Abstract");
            self.unsetBooleanMetaVal(el.expanded,metadata,"Collapsed");
            [pkgName,~]=self.splitFqn(className);
            package=self.getPackage(pkgName);
            superclassNames=join(el.superclassNames.toArray,',');
        end

        function cls=virtualGetClass(self,className)
            cls=[];
            d=self.getIoDiagram();
            elements=d.elements.toArray;
            for el=elements
                if className==string(el.name)&&el.StaticMetaClass.name=="Class"
                    [package,metadata,superclassNames]=self.fillClass(className,el);
                    cls=classdiagram.app.core.domain.Class(className,package,metadata,superclassNames,self.GlobalSettingsFcn);
                end
            end
        end

        function cls=virtualGetPlaceholderClass(self,className)
            cls=self.virtualGetClass(className);
        end

        function method=virtualGetMethod(~,class,methodName,metadata)
            method=classdiagram.app.core.domain.Method(methodName,class,metadata);
        end

        function property=virtualGetProperty(~,class,propertyName,metadata,domainProperty)
            property=classdiagram.app.core.domain.Property(propertyName,class,metadata,domainProperty);
        end

        function event=virtualGetEvent(~,class,eventName,metadata)
            event=classdiagram.app.core.domain.Event(eventName,class,metadata);
        end

        function mths=virtualGetMethods(self,class)
            mths=self.getNonPropItems(class,"Methods","Static");
        end

        function props=virtualGetProperties(self,class)
            props=[];
            d=self.getIoDiagram();
            mfClass=d.elements.getByKey(class.getName);
            if~isempty(mfClass)
                section=self.getSectionByName(mfClass,"Properties");
                if~isempty(section)
                    for item=section.items.toArray
                        metadata=createItemMetadata(self,item,section.expanded,"Constant");
                        props=[props,self.getProperty(class,item.name,metadata,item.valueType)];%#ok<AGROW>
                    end
                end
            end
        end

        function events=virtualGetEvents(self,class)
            events=self.getNonPropItems(class,"Events","NONEXISTANT");
        end

        function enum=virtualGetEnum(self,enumName)
            enum=[];
            d=self.getIoDiagram();
            elements=d.elements.toArray;
            for el=elements
                if enumName==string(el.name)&&el.StaticMetaClass.name=="Enum"
                    [package,metadata,superclassNames]=self.fillClass(enumName,el);
                    enum=classdiagram.app.core.domain.Enum(enumName,package,metadata,superclassNames,self.GlobalSettingsFcn);
                end
            end
        end

        function enum=virtualGetPlaceholderEnum(self,enumName)
            enum=self.virtualGetEnum(enumName);
        end

        function enumLiteral=virtualGetEnumLiteral(~,enumLiteralName,enum)
            enumLiteral=classdiagram.app.core.domain.EnumLiteral(enumLiteralName,enum);
        end

        function enums=virtualGetEnums(self,package)
            enums=[];
            d=self.getIoDiagram();
            elements=d.elements.toArray;
            if isempty(package)
                packageName='';
            else
                packageName=string(package.getName());
            end
            for el=elements
                [pkg,~]=self.splitFqn(el.name);
                if strcmp(pkg,packageName)&&el.StaticMetaClass.name=="Enum"
                    enums=[enums,self.getEnum(el.name)];%#ok<AGROW>
                end
            end
        end

        function literals=virtualGetEnumLiterals(self,enum)
            literals=[];
            d=self.getIoDiagram();
            mfEnum=d.elements.getByKey(enum.getName);
            if~isempty(mfEnum)
                section=self.getSectionByName(mfEnum,"Values");
                if~isempty(section)
                    for item=section.items.toArray

                        literals=[literals,self.getEnumLiteral(item.name,enum)];%#ok<AGROW>
                    end
                end
            end
        end

        function classes=virtualGetClasses(self,package)
            classes=[];
            d=self.getIoDiagram();
            elements=d.elements.toArray;
            if isempty(package)
                packageName='';
            else
                packageName=string(package.getName());
            end
            for el=elements
                [pkg,~]=self.splitFqn(el.name);
                if strcmp(pkg,packageName)&&el.StaticMetaClass.name=="Class"
                    classes=[classes,self.getClass(el.name)];%#ok<AGROW>
                end
            end
        end

        function classes=virtualGetSuperclasses(self,class)
            classes=classdiagram.app.core.domain.PackageElement.empty;
            d=self.getIoDiagram();
            mfClass=d.elements.getByKey(class.getName);
            if~isempty(mfClass)
                supernames=mfClass.superclassNames.toArray;
                for supername=supernames
                    name=supername{:};
                    class=self.getClass(name);
                    if isempty(class)
                        class=self.domainFactory.virtualGetClass(name);
                    end
                    if~isempty(class)
                        classes(end+1)=class;%#ok<AGROW>
                    end
                end
            end
        end

        function subfolders=virtualGetSubFolders(self,folderOrProject)%#ok<INUSD>
            subfolders=[];
        end

        function project=virtualGetProject(self,projectName)%#ok<INUSD>
            project=[];
        end

        function folder=virtualGetFolder(self,folderPath)%#ok<INUSD>
            folder=[];
        end

    end

    methods(Access=protected)
        function rels=virtualGetAssociationRelationships(self,class)%#ok<INUSD>
            rels=[];
        end
    end

end

