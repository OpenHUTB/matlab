classdef EventChainRefDataSource<handle






    properties(Constant)
        EventChainNameCol=getString(message('SoftwareArchitecture:ArchEditor:EventChainNameColumn'));
        EventChainDurationCol=getString(message('SoftwareArchitecture:ArchEditor:EventChainDurationColumn'));
    end

    properties(Access=private)
pReadOnly
pParentEC
pParentTab
pReferencedChain
pChildrenRef
    end

    methods
        function this=EventChainRefDataSource(parentTab,parentEC,refChain,readonly)
            if nargin<4
                readonly=false;
            end
            if nargin<3
                refChain=[];
            end

            this.pParentTab=parentTab;
            this.pParentEC=parentEC;
            this.pReferencedChain=refChain;
            this.pReadOnly=readonly;
        end

        function ref=makeReference(this,parentEC)
            ref=swarch.internal.spreadsheet.EventChainRefDataSource(...
            this.pParentTab,parentEC,this.pReferencedChain,true);
        end


        function tObj=get(this)
            tObj=[];
            if~isempty(this.pReferencedChain)
                tObj=this.pReferencedChain.get();
            end
        end


        function allowed=getPropAllowedValues(this,~)
            timingTrait=this.pParentEC.parent;
            chains=arrayfun(@getName,timingTrait.eventChains.toArray,...
            'UniformOutput',false);

            if~isempty(this.pReferencedChain)
                name=this.get().getName();
            else
                name=getString(message('SoftwareArchitecture:ArchEditor:SelectEventChain'));
            end

            allowed=unique([{name},chains]);
        end

        function dt=getPropDataType(this,propName)
            if strcmp(propName,swarch.internal.spreadsheet.EventChainInfoDataSource.EventChainNameCol)
                dt='enum';
            elseif~isempty(this.pReferencedChain)
                this.pReferencedChain.getPropDataType(propName);
            else
                dt='string';
            end
        end

        function propValue=getPropValue(this,propName)
            if~isempty(this.pReferencedChain)
                propValue=this.pReferencedChain.getPropValue(propName);
            else
                propValue=getString(message('SoftwareArchitecture:ArchEditor:SelectEventChain'));
            end
        end


        function removeFromParent(this)
            ec=this.get();
            if~isempty(ec)
                this.pParentEC.subChains.remove(ec);
            end
        end



        function setPropValue(this,propName,propValue)
            assert(strcmpi(propName,this.EventChainNameCol))
            txn=mf.zero.getModel(this.pParentEC).beginTransaction();
            this.removeFromParent();

            trait=this.pParentEC.parent;
            ec=trait.eventChains.getByKey(propValue);
            tab=this.pParentTab;


            dataSources=tab.getChildren();
            childSource=dataSources(arrayfun(@get,dataSources)==ec);
            this.pReferencedChain=childSource;
            this.pChildrenRef=[];


            this.pParentEC.subChains.add(ec);
            txn.commit();
        end

        function isValid=isValidProperty(~,~)
            isValid=true;
        end

        function isEditable=isEditableProperty(this,propName)
            isEditable=~this.pReadOnly&&(isempty(this.pReferencedChain)||...
            this.pReferencedChain.isEditableProperty(propName));
        end

        function isHyperlink=propertyHyperlink(~,~,~)
            isHyperlink=false;
        end

        function tf=isHierarchical(~)
            tf=true;
        end

        function children=getHierarchicalChildren(this)
            if isempty(this.pChildrenRef)&&~isempty(this.pReferencedChain)


                childrenOrig=this.pReferencedChain.getHierarchicalChildren();
                this.pChildrenRef=arrayfun(@(child)child.makeReference(this.get()),childrenOrig);
            end

            children=this.pChildrenRef;
        end

        function isAllowed=isDragAllowed(~)
            isAllowed=false;
        end

        function isAllowed=isDropAllowed(~)
            isAllowed=false;
        end

        function schema=getPropertySchema(this)
            schema=[];
            if~isempty(this.pReferencedChain)
                schema=this.pReferencedChain.getPropertySchema();
            end
        end

        function allowed=performDrag(~,~)
            allowed=false;

        end

        function allowed=performDrop(~,~)
            allowed=false;
        end



        function tf=isEventChainReference(~)
            tf=true;
        end

        function tf=isReadOnly(this)
            tf=this.pReadOnly;
        end
    end
end


