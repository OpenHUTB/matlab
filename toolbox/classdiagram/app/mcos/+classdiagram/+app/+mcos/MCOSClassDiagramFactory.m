classdef MCOSClassDiagramFactory<classdiagram.app.core.ClassDiagramFactory



    properties(Access=private)
        ClassMetaList=["Abstract","Hidden"];
        PropertyMetaList=["GetAccess","SetAccess","Constant","Hidden","Abstract"];
        MethodMetaList=["Access","Static","Abstract","Hidden"];
        EventMetaList=["ListenAccess","NotifyAccess","Hidden"];
        DefaultMeta;
    end

    methods
        function obj=MCOSClassDiagramFactory(app)
            obj.App=app;
            obj.GlobalSettingsFcn=@(key)obj.App.getGlobalSetting(key);
            obj.DefaultMeta=containers.Map;
            obj.DefaultMeta('nosource')='nosource';
        end
    end

    methods
        function schema=getPropertySchema(self,objectID)
            function metaclass=getMetaClassIfAny(name)
                try
                    metaclass=meta.class.fromName(name);
                catch e %#ok<NASGU>
                    metaclass=[];
                end
            end

            schema=[];
            if isempty(objectID)

                schema=classdiagram.app.core.inspector.DiagramPropertySchema(self);
            else

                element=self.getObject(objectID);

                switch element.ConstantType
                case 'Relationship'
                    schema=classdiagram.app.core.inspector.InheritancePropertySchema(element);
                case 'EnumLiteral'
                    enum=element.getOwningEnum;
                    schema=self.getPropertySchema(enum.getObjectID);
                case 'Event'
                    metaClass=getMetaClassIfAny(element.getOwningClass().getName());
                    if isempty(metaClass)
                        return;
                    else
                        schema=classdiagram.app.mcos.inspector.EventPropertySchema(element);
                    end
                case 'Method'
                    metaClass=getMetaClassIfAny(element.getOwningClass().getName());
                    if isempty(metaClass)
                        return;
                    else
                        schema=classdiagram.app.mcos.inspector.MethodPropertySchema(element);
                    end
                case 'Property'
                    metaClass=getMetaClassIfAny(element.getOwningClass().getName());
                    if isempty(metaClass)
                        return
                    else
                        schema=classdiagram.app.mcos.inspector.PropPropertySchema(element);
                    end
                case 'Enum'
                    metaClass=getMetaClassIfAny(element.getName());
                    if isempty(metaClass)
                        return;
                    else
                        schema=classdiagram.app.mcos.inspector.EnumPropertySchema(element);
                    end
                case 'Class'
                    metaClass=getMetaClassIfAny(element.getName());
                    if isempty(metaClass)
                        return;
                    else
                        schema=classdiagram.app.mcos.inspector.ClassPropertySchema(element);
                    end
                otherwise
                    schema=[];
                end
            end
        end
    end

    methods(Access=protected)

        function folder=virtualGetFolder(self,folderPath)


            folder=classdiagram.app.core.domain.Folder.empty;
            if~isfolder(folderPath)
                return;
            end
            folder=classdiagram.app.core.domain.Folder(folderPath,self.GlobalSettingsFcn);
        end

        function project=virtualGetProject(self,projectName)

            project=classdiagram.app.core.domain.Project.empty;
            if~isfile(projectName)&&~isfolder(projectName)
                return;
            end

            try
                project=classdiagram.app.core.domain.Project(projectName,self.GlobalSettingsFcn);
            catch
            end
        end

        function subFolders=virtualGetSubFolders(~,folderOrProject)
            subFolders=folderOrProject.getSubFolders();
        end

        function class=virtualGetPlaceholderClass(self,className,state)



            class=classdiagram.app.core.domain.Class(className,[],self.DefaultMeta,{},self.GlobalSettingsFcn,state);



            id=classdiagram.app.core.utils.ObjectIDUtility.generateClassID(className);
            class.setObjectID(id);
        end

        function enum=virtualGetPlaceholderEnum(self,enumName,state)



            enum=classdiagram.app.core.domain.Enum(enumName,[],self.DefaultMeta,{},self.GlobalSettingsFcn,state);



            id=classdiagram.app.core.utils.ObjectIDUtility.generateEnumID(enumName);
            enum.setObjectID(id);
        end

        function domainObject=virtualGetDomainObject(self,objName)

            domainObject=[];
            if isempty(objName)
                return;
            end
            domainObject=self.getPackage(objName);
            if self.isMCOSObjectValid(domainObject)
                return;
            end
            domainObject=self.getClass(objName);
            if self.isMCOSObjectValid(domainObject)
                return;
            end
            domainObject=self.getEnum(objName);
        end

        function packages=virtualGetPackages(self)

            packages=[];
            metaPackages=meta.package.getAllPackages;
            for i=1:length(metaPackages)
                metaPackage=metaPackages{i};
                package=self.getPackage(metaPackage.Name);
                packages=[packages,package];
            end
        end

        function package=virtualGetPackage(self,packageName)


            package=[];
            metadata=meta.package.fromName(packageName);
            if~self.isMCOSObjectValid(metadata)
                return;
            end
            package=classdiagram.app.core.domain.Package(packageName,self.GlobalSettingsFcn);
        end

        function subPackages=virtualGetSubPackages(self,package)
            subPackages=[];
            if~(self.isMCOSObjectValid(package))
                return;
            end
            metadata=meta.package.fromName(package.getName());
            if isempty(metadata)
                return;
            end
            packageNames=string({metadata.PackageList.Name});
            subPackages=classdiagram.app.core.domain.Package.empty;
            for i=1:length(packageNames)
                subPackages(i)=self.virtualGetPackage(packageNames(i));
            end
        end

        function parentPackage=virtualGetParentPackage(self,package)
            parentPackage=[];
            if~self.isMCOSObjectValid(package)
                return;
            end
            metadata=meta.package.fromName(package.getName());
            if isempty(metadata)
                return;
            end
            if~isempty(metadata.ContainingPackage)
                parentPackage=self.getPackage(string(metadata.ContainingPackage.Name));
            end
        end

        function class=virtualGetClass(self,className)
            class=classdiagram.app.core.domain.Class.empty;
            try
                mcosMetadata=meta.class.fromName(className);
            catch ME
                class=self.virtualGetPlaceholderClass(className,...
                classdiagram.app.core.domain.ElementState.NotOnPath);
                return;
            end
            if~self.isMCOSObjectValid(mcosMetadata)||mcosMetadata.Enumeration
                return;
            end
            package=self.getPackageFromClassname(className);
            metadata=self.getMetadataForClass(className);
            superclassNames=self.getSuperclassNamesForClass(mcosMetadata);


            class=classdiagram.app.core.domain.Class(className,package,metadata,superclassNames,self.GlobalSettingsFcn);
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

        function methods=virtualGetMethods(self,class)
            methods=[];
            if~self.isMCOSObjectValid(class)
                return;
            end
            metaClass=meta.class.fromName(class.getName());
            if isempty(metaClass)||isempty(metaClass.MethodList)
                return;
            end
            className=class.getName;
            nonEmpty=metaClass.MethodList(~strcmp({metaClass.MethodList.Name},"empty"));
            if isempty(nonEmpty)
                return;
            end
            definingClass=[nonEmpty.DefiningClass];
            definingClassName=string({definingClass.Name});
            ownMethods=nonEmpty(strcmp(className,definingClassName));
            ownMethods(ismember({ownMethods.Name},...
            classdiagram.app.mcos.MCOSConstants.FilteredMethods))=[];

            [~,idx]=unique({ownMethods.Name},'stable');
            ownMethods=ownMethods(idx);

            methods=classdiagram.app.core.domain.Method.empty(0,numel(ownMethods));
            for ii=1:numel(ownMethods)
                method=ownMethods(ii);
                metadata=self.getMetadataForMethod(method);
                methods(ii)=self.getMethod(class,string(method.Name),metadata);
            end
        end

        function properties=virtualGetProperties(self,class)
            properties=classdiagram.app.core.domain.Property.empty;
            if~self.isMCOSObjectValid(class)
                return;
            end
            metaClass=meta.class.fromName(class.getName());
            if isempty(metaClass)||isempty(metaClass.PropertyList)
                return;
            end
            className=class.getName;
            definingClass=[metaClass.PropertyList.DefiningClass];
            definingClassName=string({definingClass.Name});

            ownProps=metaClass.PropertyList(strcmp(className,definingClassName));


            for metaProperty=ownProps'
                metadata=self.getMetadataForProperty(metaProperty);
                propertyName=string(metaProperty.Name);
                domainType='';
                if(~isempty(metaProperty.Validation)&&~isempty(metaProperty.Validation.Class)&&~isempty(metaProperty.Validation.Class.Name))
                    domainType=metaProperty.Validation.Class.Name;
                end

                showAssociations=self.App.getGlobalSetting('ShowAssociations');
                if~showAssociations||isempty(domainType)
                    prop=self.getProperty(class,propertyName,metadata,domainType);
                    properties(end+1)=prop;
                end
            end
        end

        function events=virtualGetEvents(self,class)
            events=classdiagram.app.core.domain.Event.empty;
            if~self.isMCOSObjectValid(class)
                return;
            end
            metaClass=meta.class.fromName(class.getName());
            if isempty(metaClass)||isempty(metaClass.EventList)
                return;
            end
            className=class.getName;
            nonEmpty=metaClass.EventList(~strcmp({metaClass.EventList.Name},"empty"));
            definingClass=[nonEmpty.DefiningClass];
            definingClassName=string({definingClass.Name});
            ownEvents=nonEmpty(strcmp(className,definingClassName));
            for event=ownEvents'



                metadata=self.getMetadataForEvent(event);
                eventName=string(event.Name);
                events(end+1)=self.getEvent(class,eventName,metadata);
            end
        end

        function classes=virtualGetClasses(self,package)
            classes=classdiagram.app.core.domain.Class.empty;
            if~self.isMCOSObjectValid(package)
                return;
            end
            metadata=meta.package.fromName(package.getName());
            if isempty(metadata)
                return;
            end

            classNames=string({metadata.ClassList.Name});
            classNames([metadata.ClassList.Enumeration])=[];
            classes=arrayfun(@(name)self.virtualGetClass(name),classNames);
        end

        function superclasses=virtualGetSuperclasses(self,class)
            superclasses=[];
            if~self.isMCOSObjectValid(class)
                return;
            end
            metadata=meta.class.fromName(class.getName());
            if isempty(metadata)
                return;
            end

            classNames=string({metadata.SuperclassList.Name});
            superclasses=arrayfun(@(name)self.getClass(name),classNames);
        end

        function enums=virtualGetEnums(self,package)
            enums=[];
            if~self.isMCOSObjectValid(package)
                return;
            end
            metadata=meta.package.fromName(package.getName());
            if isempty(metadata)
                return;
            end

            enumNames=string({metadata.ClassList.Name});
            enumNames(~[metadata.ClassList.Enumeration])=[];
            enums=arrayfun(@(name)self.virtualGetEnum(name),enumNames);
        end

        function enum=virtualGetEnum(self,enumName)


            enum=classdiagram.app.core.domain.Enum.empty;
            try
                mcosMetadata=meta.class.fromName(enumName);
            catch ME
                enum=self.virtualGetPlaceholderEnum(enumName,...
                classdiagram.app.core.domain.ElementState.NotOnPath);
                return;
            end
            if~self.isMCOSObjectValid(mcosMetadata)
                return;
            end

            package=self.getPackageFromClassname(enumName);
            metadata=self.getMetadataForClass(enumName);
            superclassNames=self.getSuperclassNamesForClass(mcosMetadata);
            enum=classdiagram.app.core.domain.Enum(enumName,package,metadata,superclassNames,self.GlobalSettingsFcn);
        end

        function enumLiteral=virtualGetEnumLiteral(~,enumLiteralName,enum)
            enumLiteral=classdiagram.app.core.domain.EnumLiteral(enumLiteralName,enum);
        end

        function enumLiterals=virtualGetEnumLiterals(self,enum)
            enumLiterals=[];
            if~self.isMCOSObjectValid(enum)
                return;
            end
            enumObject=meta.class.fromName(enum.getName());
            if isempty(enumObject)
                return;
            end
            metaEnums=enumObject.EnumerationMemberList;
            enumNames=string({metaEnums.Name});
            enumLiterals=arrayfun(@(name)self.getEnumLiteral(name,enum),enumNames);
        end
    end

    methods(Access=protected)



        function report=virtualGetOutOfDateElements(self)
            import classdiagram.app.core.domain.*;

            out=[];
            in=[];
            typeChanges=[];
            for ob=self.idToObjectMap.values
                el=ob{:};
                wasClass=isa(el,'Class');
                wasEnum=isa(el,'Enum');
                if wasClass||wasEnum
                    uuid=el.getDiagramElementUUID;
                    if~isempty(uuid)
                        mcosMetadata=meta.class.empty;
                        try
                            mcosMetadata=meta.class.fromName(el.getName());
                            if wasClass~=isempty(mcosMetadata.EnumerationMemberList)
                                if isempty(typeChanges)
                                    typeChanges=el;
                                else
                                    typeChanges(end+1)=el;%#ok<AGROW>
                                end
                            end
                        catch e %#ok<NASGU>
                        end
                        if self.isMCOSObjectValid(mcosMetadata)
                            if isempty(in)
                                in=el;
                            else
                                in(end+1)=el;%#ok<AGROW>
                            end
                            el.setState(ElementState.Normal);
                        else
                            if isempty(out)
                                out=el;
                            else
                                out(end+1)=el;%#ok<AGROW>
                            end
                            el.setState(ElementState.NotOnPath);
                        end
                    end
                end
            end

            report=struct("outOfDate",out,"upToDate",in,"changedType",typeChanges);
        end


        function associationRelationships=virtualGetAssociationRelationships(self,class)
            relType="ASSOCIATION";
            associationRelationships=classdiagram.app.core.domain.Relationship.empty;
            showAssociations=self.App.getGlobalSetting('ShowAssociations');
            if~showAssociations
                return;
            end
            if~self.isMCOSObjectValid(class)
                return;
            end
            metaClass=meta.class.fromName(class.getName());
            if isempty(metaClass)
                return;
            end
            definingClass=[metaClass.PropertyList.DefiningClass];
            definingClassName=string({definingClass.Name});

            ownProps=metaClass.PropertyList(strcmp(className,definingClassName));

            for property=ownProps'
                if isempty(property.Validation)||isempty(property.Validation.Class)||isempty(property.Validation.Class.Name)
                    continue;
                end







                dstClass=self.getClass(property.Validation.Class.Name);
                if~dstClass.isHidden
                    continue;
                end
                srcEnd=self.getRelationshipEnd(class,dstClass,relType);


                dstEnd=self.getRelationshipEnd(dstClass,class,relType);
                relationship=self.makeRelationship(srcEnd,dstEnd,relType);
                associationRelationships(end+1)=relationship;
            end
        end

        function package=getPackageFromClassname(self,className)
            package=[];
            metaClass=meta.class.fromName(className);
            if~isempty(metaClass)&&~isempty(metaClass.ContainingPackage)
                package=self.getPackage(metaClass.ContainingPackage.Name);
            end
        end

        function names=getSuperclassNamesForClass(self,mcosMetadata)
            names={mcosMetadata.SuperclassList.Name};
        end

        function metadata=getMetadataForClass(self,className)
            metadata=containers.Map;
            metaClass=meta.class.fromName(className);
            if isempty(metaClass)
                return;
            end
            for classMetaProp=self.ClassMetaList
                self.setBooleanMeta(metaClass,metadata,classMetaProp);
            end

            whichInfo=which(className);
            startIndex=regexpi(whichInfo,'built-in|\.p$','once');
            if(~isempty(startIndex))
                metadata('nosource')='nosource';
            end












        end

        function metadata=getMetadataForMethod(self,obj)
            metalist=self.MethodMetaList;
            metadataKey=obj.(metalist(1));
            metadata=containers.Map;
            metadata(self.accessKey)=self.convertAccessToString(metadataKey);
            for m=2:length(metalist)
                self.setBooleanMeta(obj,metadata,metalist(m));
            end
            if~self.canNavigateToMethod(obj)
                metadata('nosource')='nosource';
            end
        end

        function metadata=getMetadataForProperty(self,obj)
            metalist=self.PropertyMetaList;
            metadata=self.setAccessMeta(obj,metalist(1),metalist(2));
            for m=3:length(metalist)
                self.setBooleanMeta(obj,metadata,metalist(m));
            end
        end

        function metadata=getMetadataForEvent(self,obj)
            metalist=self.EventMetaList;
            metadata=self.setAccessMeta(obj,metalist(1),metalist(2));
            self.setBooleanMeta(obj,metadata,metalist(3));
        end


        function metadata=setBooleanMeta(self,obj,metadata,key)
            if(obj.(key))
                metadata(key)=key;
            end
        end

        function isValid=isMCOSObjectValid(~,obj)
            isValid=~isempty(obj);
        end

        function bool=canNavigateToMethod(~,obj)




            bool=false;
            methodName=obj.Name;
            className=obj.DefiningClass.Name;


            try
                if obj.Static

                    pathToMethod=which(className+"."+methodName,'in',className);
                else
                    pathToMethod=which(methodName,'in',className);
                end
            catch
                bool=false;
                return;
            end





            if isempty(pathToMethod)&&~isempty(regexp(className,"\."+methodName+"$",'once'))
                bool=true;
                return;
            end



            [~,~,ext]=fileparts(pathToMethod);


            builtinClassMessage=message('MATLAB:ClassText:whichBuiltinMethod',...
            className).getString(matlab.internal.i18n.locale('en_US'));
            builtinMethodMessage=message('MATLAB:ClassText:whichBuiltinMethod',...
            methodName).getString(matlab.internal.i18n.locale('en_US'));









            rPath=regexprep(pathToMethod,'\W','');
            if~isempty(pathToMethod)&&...
                ~strcmp(regexprep(builtinMethodMessage,'\W',''),rPath)&&...
                ~strcmp(regexprep(builtinClassMessage,'\W',''),rPath)&&...
                ext~=".p"
                bool=true;
            end
        end
    end
end
