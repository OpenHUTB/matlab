classdef DataInterface<systemcomposer.base.StereotypableElement&systemcomposer.base.BaseElement




    properties(Dependent=true,SetAccess=private)

        Owner{mustBeA(Owner,["systemcomposer.interface.Dictionary",...
        "systemcomposer.interface.DataElement",...
        "systemcomposer.arch.ArchitecturePort"])}

        Name(1,1){mustBeTextScalar}

        Description(1,1){mustBeTextScalar}

        Elements(0,:)systemcomposer.interface.DataElement
    end

    properties(Dependent=true,SetAccess=private)
Model
    end

    properties(Hidden,SetAccess=private)

Dictionary
    end

    methods(Hidden)
        function this=DataInterface(impl)
            narginchk(1,1);
            if~isa(impl,'systemcomposer.architecture.model.interface.CompositeDataInterface')
                error('systemcomposer:API:SignalInterfaceInvalidInput',message('SystemArchitecture:API:SignalInterfaceInvalidInput').getString);
            end
            this@systemcomposer.base.BaseElement(impl);
            impl.cachedWrapper=this;
        end

        function tf=isAnonymous(this)
            tf=this.getImpl.isAnonymous();
        end
    end

    methods(Static,Hidden)
        function incheck(inval)
            persistent p
            if isempty(p)
                p=inputParser;
                addRequired(p,'inval',@(x)ischar(x)||isstring(x)&&~isempty(x));
            end
            parse(p,inval);
        end

        function setPropVal(elemImpl,prop,val)
            switch prop
            case 'Type'
                elemImpl.setType(val);
            case 'Dimensions'
                elemImpl.setDimensions(val);
            case 'Units'
                elemImpl.setUnits(val);
            case 'Complexity'
                elemImpl.setComplexity(val);
            case 'Minimum'
                elemImpl.setMinimum(val);
            case 'Maximum'
                elemImpl.setMaximum(val);
            case 'Description'
                elemImpl.setDescription(val);
            end
        end
    end

    methods

        function m=get.Model(this)



            m=systemcomposer.arch.Model.empty;
            if(this.getImpl.isAnonymous)







                containerModel=mf.zero.getModel(this.getImpl);
                zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(containerModel);
                modelName=zcModel.getName;
                if bdIsLoaded(modelName)
                    m=systemcomposer.loadModel(modelName);
                end
            else
                catalog=this.getImpl().getCatalog();
                catalogOwnerName=catalog.getStorageSource;
                if(catalog.getStorageContext==systemcomposer.architecture.model.interface.Context.MODEL)...
                    &&bdIsLoaded(catalogOwnerName)
                    m=systemcomposer.loadModel(catalogOwnerName);
                end
            end
        end

        function dictionary=get.Dictionary(this)
            warning(message('SystemArchitecture:API:DeprecatedProperty','Dictionary','Owner'));
            dictionary=systemcomposer.internal.getWrapperForImpl(this.getImpl().getCatalog(),'systemcomposer.interface.Dictionary');
        end

        function owner=get.Owner(this)
            if this.isAnonymous
                if~isempty(this.getImpl.p_AnonymousUsage)
                    owner=systemcomposer.internal.getWrapperForImpl(this.getImpl.p_AnonymousUsage.p_Port);
                    return;
                elseif~isempty(this.getImpl.p_OwningDataElement)
                    owner=systemcomposer.internal.getWrapperForImpl(this.getImpl.p_OwningDataElement);
                    return;
                end
            end
            owner=systemcomposer.internal.getWrapperForImpl(this.getImpl.getCatalog);
        end

        function name=get.Name(this)
            name=this.getImpl().getName;
        end

        function setName(this,name)
            systemcomposer.interface.DataInterface.incheck(name);

            if(this.isAnonymous()&&~isempty(name))
                error('SystemArchitecture:API:InvalidRenameOpOnAnonymousInterface',message('SystemArchitecture:API:InvalidRenameOpOnAnonymousInterface').getString);
            end

            isModelContext=isempty(this.Owner.ddConn);
            sourceName=this.Owner.getSourceName;
            systemcomposer.BusObjectManager.RenameInterface(sourceName,isModelContext,this.Name,name);
        end

        function desc=get.Description(this)
            desc=this.getImpl().getDescription;
        end

        function setDescription(this,desc)
            systemcomposer.interface.DataInterface.incheck(desc);

            if this.isAnonymous()
                return;
            end

            isModelContext=isempty(this.Owner.ddConn);
            sourceName=this.Owner.getSourceName;
            systemcomposer.BusObjectManager.SetInterfaceDescription(sourceName,isModelContext,this.Name,desc);
        end

        function elements=get.Elements(this)
            interfaceImpl=this.getImpl();
            interfaceImplElements=interfaceImpl.getElementsInIndexOrder();
            elements=systemcomposer.interface.DataElement.empty(numel(interfaceImplElements),0);
            for i=1:numel(interfaceImplElements)
                elements(i)=systemcomposer.internal.getWrapperForImpl(interfaceImplElements(i),'systemcomposer.interface.DataElement');
            end
        end

        function element=addElement(this,elementName,varargin)









            p=inputParser;
            addRequired(p,'elementName',@(x)ischar(x)||isstring(x));
            addParameter(p,'DataType','double',@(x)ischar(x)&&~isempty(x)||isstring(x)&&~isequal(x,""));
            addParameter(p,'Type','double',@(x)ischar(x)&&~isempty(x)||isstring(x)&&~isequal(x,""));
            addParameter(p,'Dimensions','1',@(x)ischar(x)&&~isempty(x)||isstring(x)&&~isequal(x,""));
            addParameter(p,'Units','',@(x)ischar(x)||isstring(x));
            validComplexities={'real','complex'};
            addParameter(p,'Complexity','real',@(x)any(validatestring(x,validComplexities)));
            addParameter(p,'Minimum','[]',@(x)ischar(x)||isstring(x));
            addParameter(p,'Maximum','[]',@(x)ischar(x)||isstring(x));
            addParameter(p,'Description','',@(x)ischar(x)||isstring(x));
            parse(p,elementName,varargin{:});


            results=p.Results;
            if~strcmpi(results.Type,results.DataType)&&strcmpi(results.DataType,'double')
                results.Type=results.Type;
            else
                results.Type=results.DataType;
            end

            if(this.isAnonymous)

                port=this.getImpl.p_AnonymousUsage.p_Port;
                systemcomposer.AnonymousInterfaceManager.AddInlinedInterfaceElement(port,elementName,results);
            else
                isModelContext=isempty(this.Owner.ddConn);
                sourceName=this.Owner.getSourceName;

                systemcomposer.BusObjectManager.AddInterfaceElement(sourceName,isModelContext,this.Name,elementName,results);
            end

            elementImpl=this.getImpl.getElement(elementName);

            element=systemcomposer.internal.getWrapperForImpl(elementImpl);
        end

        function removeElement(this,elementName)




            if(this.isAnonymous)
                aPort=this.getImpl.p_AnonymousUsage.p_Port;
                systemcomposer.AnonymousInterfaceManager.DeleteInlinedInterfaceElement(aPort,elementName);
                return;
            end

            isModelContext=isempty(this.Owner.ddConn);
            sourceName=this.Owner.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterfaceElement(sourceName,isModelContext,this.Name,elementName);
        end

        function element=getElement(this,elementName)



            elementImpl=this.getImpl().getElement(elementName);
            if(isempty(elementImpl))
                element=systemcomposer.interface.DataElement.empty();
            else
                element=systemcomposer.internal.getWrapperForImpl(elementImpl,'systemcomposer.interface.DataElement');
            end
        end

        function destroy(this)
            if(this.isAnonymous)
                this.Owner.setInterface('');
                return;
            end

            isModelContext=isempty(this.Owner.ddConn);
            sourceName=this.Owner.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterface(sourceName,...
            isModelContext,this.Name);
        end

    end

end
