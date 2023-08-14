








function addNode(varargin)
    argc=length(varargin);
    selectedObj=varargin{1};
    newNodeNames=varargin{2};
    index=-1;

    if argc==3
        index=varargin{3};
    elseif argc==4
        option=varargin{3};
        interfacePkgPath=varargin{4};
    end

    metaClass=metaclass(selectedObj);

    if~isempty(selectedObj)&&strcmp(metaClass.Name,...
        'autosar.ui.metamodel.M3INode')
        isInterface=false;
        isRunnable=false;
        isNamespace=false;
        if any(strcmp(selectedObj.Name,...
            autosar.ui.metamodel.PackageString.InterfaceTypes))
            isInterface=true;
        elseif strcmp(selectedObj.Name,...
            autosar.ui.metamodel.PackageString.runnableNode)
            isRunnable=true;
        elseif strcmp(selectedObj.Name,...
            autosar.ui.metamodel.PackageString.namespacesNodeName)
            isNamespace=true;
        end

        if isInterface
            validChildIndex=-1;
            for i=1:length(selectedObj.Children)
                if isvalid(selectedObj.Children(i))
                    validChildIndex=i;
                    break;
                end
            end

            if validChildIndex~=-1
                nodeM3I=selectedObj.Children(validChildIndex).getM3iObject();
                parentM3I=nodeM3I.containerM3I;
                if strcmp(autosar.api.Utils.getQualifiedName(parentM3I),interfacePkgPath)
                    classStr=class(nodeM3I);
                else
                    validChildIndex=-1;
                end
            end

            if validChildIndex==-1

                parentM3I=autosar.mm.Model.getArPackage(selectedObj.ParentM3I.M3iObject,interfacePkgPath);
                if isempty(parentM3I)
                    modelM3I=selectedObj.ParentM3I.getM3iObject();
                    modelM3I.beginTransaction();
                    parentM3I=...
                    autosar.mm.Model.getOrAddARPackage(modelM3I,interfacePkgPath);
                    modelM3I.commitTransaction();
                end
                switch selectedObj.Name
                case autosar.ui.metamodel.PackageString.InterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{1};
                case autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{3};
                case autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{2};
                case autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{5};
                case autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{6};
                case autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{4};
                case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{7};
                case autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName
                    classStr=autosar.ui.metamodel.PackageString.InterfacesCell{8};
                otherwise
                    assert(false,'Unknown selected object');
                end
            end

            seqObj=parentM3I;
        else
            if isa(selectedObj.ParentM3I,...
                autosar.ui.metamodel.PackageString.M3IObjectName)
                parentM3I=selectedObj.ParentM3I;
            else
                parentM3I=selectedObj.ParentM3I.getM3iObject;
            end
            seqObj=parentM3I.get(selectedObj.Name);
            classStr=parentM3I.getMetaClass.getProperty(...
            selectedObj.Name).type.qualifiedName;
        end
        modelM3I=parentM3I.modelM3I;

        t=M3I.Transaction(modelM3I);
        for i=1:length(newNodeNames)
            newObj=feval(classStr,modelM3I);
            newObj.Name=newNodeNames{i};
            if isInterface
                if~isa(newObj,autosar.ui.metamodel.PackageString.InterfacesCell{7})&&...
                    ~isa(newObj,autosar.ui.metamodel.PackageString.InterfacesCell{8})


                    newObj.IsService=option{i}{1};
                end
                autosar.ui.utils.populateInterface(newObj,option{i}(2:end));
                seqObj.packagedElement.append(newObj);
            else
                if argc==4
                    newObj.Interface=option(i);
                end
                if isRunnable
                    newObj.symbol=newObj.Name;
                elseif isNamespace
                    newObj.Symbol=newObj.Name;
                end
                if index>0&&index<=seqObj.size()
                    seqObj.insert(index,newObj);
                else
                    seqObj.append(newObj);
                end
            end

        end
        t.commit;


        explorer=autosar.ui.utils.findExplorer(modelM3I);
        assert(~isempty(explorer));
        imme=DAStudio.imExplorer(explorer);
        if strcmp(selectedObj.Name,autosar.ui.metamodel.PackageString.argumentsNode)||...
            strcmp(selectedObj.Name,autosar.ui.metamodel.PackageString.namespacesNodeName)
            imme.enableListSorting(false,'Name',false);
        end
    end
end

