classdef ServiceInterface<systemcomposer.base.StereotypableElement&systemcomposer.base.BaseElement

    properties(SetAccess=private)
Dictionary
Name
Description
Elements
    end

    properties(Dependent=true,SetAccess=private)
Model
    end


    methods(Hidden)
        function this=ServiceInterface(impl)
            narginchk(1,1);
            if~isa(impl,'systemcomposer.architecture.model.swarch.ServiceInterface')
                error('systemcomposer:API:ServiceInterfaceInvalidInput',message('SystemArchitecture:API:ServiceInterfaceInvalidInput').getString);
            end
            this@systemcomposer.base.BaseElement(impl);
            impl.cachedWrapper=this;
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
    end


    methods

        function m=get.Model(this)
            m=systemcomposer.arch.Model.empty;
            catalog=this.getImpl().getCatalog();
            catalogOwnerName=catalog.getStorageSource;
            if(catalog.getStorageContext==systemcomposer.architecture.model.interface.Context.MODEL)...
                &&bdIsLoaded(catalogOwnerName)
                m=systemcomposer.loadModel(catalogOwnerName);
            end
        end


        function dictionary=get.Dictionary(this)
            dictionary=systemcomposer.internal.getWrapperForImpl(this.getImpl().getCatalog(),'systemcomposer.interface.Dictionary');
        end


        function name=get.Name(this)
            name=this.getImpl().getName;
        end


        function setName(this,name)
            systemcomposer.interface.ServiceInterface.incheck(name);
            isModelContext=isempty(this.Dictionary.ddConn);
            sourceName=this.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.RenameInterface(sourceName,isModelContext,this.Name,name);
        end


        function desc=get.Description(this)
            desc=this.getImpl().getDescription;
        end


        function setDescription(this,desc)
            systemcomposer.interface.ServiceInterface.incheck(desc);
            isModelContext=isempty(this.Dictionary.ddConn);
            sourceName=this.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.SetInterfaceDescription(sourceName,isModelContext,this.Name,desc);
        end


        function elements=get.Elements(this)
            interfaceImpl=this.getImpl();
            interfaceImplElements=interfaceImpl.getElementsInIndexOrder();
            elements=systemcomposer.interface.FunctionElement.empty(numel(interfaceImplElements),0);
            for i=1:numel(interfaceImplElements)
                elements(i)=systemcomposer.internal.getWrapperForImpl(interfaceImplElements(i),'systemcomposer.interface.FunctionElement');
            end
        end


        function element=addElement(this,elementName,varargin)
            p=inputParser;
            addRequired(p,'elementName',@(x)ischar(x)||isstring(x));
            addParameter(p,'FunctionPrototype','y = f0(u)',@(x)ischar(x)&&~isempty(x)||isstring(x)&&~isequal(x,""));
            parse(p,elementName,varargin{:});
            results=p.Results;
            isModelContext=isempty(this.Dictionary.ddConn);
            sourceName=this.Dictionary.getSourceName;

            if nargin>2
                systemcomposer.BusObjectManager.AddFunctionElement(sourceName,isModelContext,this.Name,elementName,results);
            else
                systemcomposer.BusObjectManager.AddFunctionElement(sourceName,isModelContext,this.Name,elementName);
            end
            elementImpl=this.getImpl.getElement(elementName);
            element=systemcomposer.internal.getWrapperForImpl(elementImpl,'systemcomposer.interface.FunctionElement');
        end


        function removeElement(this,elementName)
            isModelContext=isempty(this.Dictionary.ddConn);
            sourceName=this.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.DeleteInterfaceElement(sourceName,isModelContext,this.Name,elementName);
        end


        function element=getElement(this,elementName)
            elementImpl=this.getImpl().getElement(elementName);
            if(isempty(elementImpl))
                element=systemcomposer.interface.FunctionElement.empty();
            else
                element=systemcomposer.internal.getWrapperForImpl(elementImpl,'systemcomposer.interface.FunctionElement');
            end
        end


        function destroy(this)

        end

    end
end

