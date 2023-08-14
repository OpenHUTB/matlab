classdef styleElementsContainer<handle



    properties(SetAccess=private,GetAccess=public)
handles
resolvedObjects
BDs
    end



    methods(Access=public)
        function this=styleElementsContainer
            this.handles=containers.Map('KeyType','double','ValueType','any');
            this.resolvedObjects=containers.Map('KeyType','double','ValueType','any');
            this.BDs=[];
        end
    end



    methods(Access=public)
        function setElements(this,BD,elements)

            if(~ismember(BD,this.BDs))
                this.BDs=[this.BDs,BD];
            end
            this.handles(BD)=elements;
            this.createResolvedElements(BD,elements);
        end
    end



    methods(Access=public)
        function elements=getElements(this,BD)
            elements=[];
            if(isKey(this.resolvedObjects,BD))
                elements=this.handles(BD);
            end
        end
    end



    methods(Access=private)
        function createResolvedElements(this,BD,elements)
            thisbdElements=cell(1,length(elements));
            for n=1:length(elements)
                obj=diagram.resolver.resolve(elements(n));
                thisbdElements{n}=obj;
            end
            this.resolvedObjects(BD)=thisbdElements;
        end
    end



    methods(Access=public)
        function applyStyling(this,stylerObj,className,BD)
            if(isKey(this.resolvedObjects,BD))
                ResolvedElements=this.resolvedObjects(BD);
                if(~isempty(ResolvedElements))
                    stylerObj.applyClass(ResolvedElements,className);
                end
            end
        end
    end



    methods(Access=public)
        function removeStyling(this,stylerObj,className,BD)
            if(isKey(this.resolvedObjects,BD))
                ResolvedElements=this.resolvedObjects(BD);
                if(~isempty(ResolvedElements))
                    stylerObj.removeClass(ResolvedElements,className);
                end
            end
            this.resolvedObjects(BD)=[];
            this.handles(BD)=[];
        end
    end



    methods(Access=public)
        function removeStylingForAllBDs(this,stylerObj,className)
            keys=this.resolvedObjects.keys;

            if(isempty(keys))
                return;
            end

            for i=1:length(keys)
                bdObj=diagram.resolver.resolve(keys{i});
                stylerObj.clearChildrenClasses(className,bdObj);
            end
        end
    end
end

