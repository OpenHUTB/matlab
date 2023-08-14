classdef ModelHierarchyItem<handle




































    properties(Dependent)
        Name;
        DisplayLabel;
        Path;
        CheckState;
        ModelHierarchy;
    end

    properties(SetAccess=private)
        ID;
    end

    properties(Constant,Hidden)
        CHECKED=slreportgen.webview.enum.CheckState.Checked;
        UNCHECKED=slreportgen.webview.enum.CheckState.Unchecked;
        PARTIAL=slreportgen.webview.enum.CheckState.PartiallyChecked;
    end

    properties(Access=private)
        m_name;
        m_displayLabel;
        m_displayIcon;
        m_path;
        m_modelHierarchy;

        m_checkable=true;
        m_checkState=slreportgen.webview.enum.CheckState.Unchecked;

        m_root=slreportgen.webview.ModelHierarchyItem.empty();
        m_parent=slreportgen.webview.ModelHierarchyItem.empty();
        m_children=slreportgen.webview.ModelHierarchyItem.empty();

        m_isMdlRef;
        m_isConfigSys;

        m_diagH;
        m_elemH;
        m_dhid;
        m_ehid;
    end

    methods
        function name=get.Name(h)
            name=getName(h);
        end

        function name=getName(h)
            if isempty(h.m_name)
                hs=slreportgen.utils.HierarchyService;
                h.m_name=string(hs.getName(getDiagramHierarchyId(h)));
            end
            name=h.m_name;
        end

        function displayLabel=get.DisplayLabel(h)
            displayLabel=getDisplayLabel(h);
        end

        function label=getDisplayLabel(h)
            if isempty(h.m_displayLabel)
                displayLabel=getName(h);
                h.m_displayLabel=regexprep(displayLabel,'\s',' ');
            end
            label=h.m_displayLabel;
        end

        function path=get.Path(h)
            path=getPath(h);
        end

        function path=getPath(h)
            if isempty(h.m_path)
                updatePath(h);
            end
            path=h.m_path;
        end

        function icon=getDisplayIcon(h)
            if isempty(h.m_displayIcon)
                if isModelReference(h)
                    backingH=getElementBackingHandle(h);
                else
                    backingH=getDiagramBackingHandle(h);
                end
                h.m_displayIcon=slreportgen.utils.getDisplayIcon(backingH);
            end
            icon=h.m_displayIcon;
        end

        function modelHierarchy=get.ModelHierarchy(h)
            modelHierarchy=h.m_modelHierarchy;
        end

        function checkable=isCheckable(obj)
            checkable=obj.m_checkable;
        end

        function checkState=get.CheckState(h)
            checkState=h.m_checkState;
        end


        function checkState=getCheckState(h)
            checkState=h.CheckState.DDGValue;
        end

        function check(h)
            checked=h.CHECKED;
            partial=h.PARTIAL;

            if~isChecked(h)
                setCheckState(h,checked);

                pItem=getParent(h);
                while~isempty(pItem)
                    if isUnchecked(pItem)
                        setCheckState(pItem,partial);
                        pItem=getParent(pItem);
                    else
                        pItem=[];
                    end
                end
            end
        end

        function uncheck(h)
            unchecked=h.UNCHECKED;
            partial=h.PARTIAL;

            if~isUnchecked(h)
                setCheckState(h,unchecked);

                children=getChildren(h);
                if~isempty(children)&&~all([children.CheckState]==unchecked)
                    setCheckState(h,partial);
                end

                pItem=getParent(h);
                if(~isempty(pItem)&&isPartiallyChecked(pItem))
                    siblingsAndSelf=getChildren(pItem);
                    if all([siblingsAndSelf.CheckState]==unchecked)
                        uncheck(pItem);
                    end
                end
            end
        end


        function tf=isChecked(h)
            tf=(h.CheckState==h.CHECKED);
        end

        function tf=isPartiallyChecked(h)
            tf=(h.CheckState==h.PARTIAL);
        end

        function tf=isUnchecked(h)
            tf=(h.CheckState==h.UNCHECKED);
        end

        function dhid=getDiagramHierarchyId(h)
            validateBacking(h);
            dhid=h.m_dhid;
        end

        function ehid=getElementHierarchyId(h)
            validateBacking(h);
            ehid=h.m_ehid;
        end

        function diagH=getDiagramBackingHandle(h)
            validateBacking(h);
            diagH=h.m_diagH;
        end

        function elemH=getElementBackingHandle(h)
            validateBacking(h);
            elemH=h.m_elemH;
        end

        function tf=isRoot(h)
            tf=isempty(h.m_parent);
        end

        function root=getRoot(h)
            if isempty(h.m_root)
                if isRoot(h)
                    root=h;
                else
                    p=getParent(h);
                    root=getRoot(p);
                end
                h.m_root=root;
            end
            root=h.m_root;
        end

        function parent=getParent(h)
            parent=h.m_parent;
        end

        function id=getParentID(obj)
            id=getID(getParent(obj));
        end

        function ancestors=getAncestors(h)
            parent=getParent(h);
            ancestors=[];
            while~isempty(parent)
                ancestors=[parent,ancestors];%#ok
                parent=getParent(parent);
            end
        end

        function children=getChildren(h)
            children=h.m_children;
        end

        function tf=hasChildren(h)
            tf=~isempty(h.m_children);
        end


        function children=getHierarchicalChildren(h)
            children=num2cell(h.m_children);
        end

        function descendants=getDescendants(h,filter)
            if(nargin<2)
                filter=[];
            end

            descendants=[];
            children=getChildren(h);
            nChildren=numel(children);

            if~isempty(filter)
                for i=1:nChildren
                    child=children(i);

                    ehid=getElementHierarchyId(child);
                    if(isempty(ehid)||~isempty(filter.filter(ehid)))
                        descendants=[descendants,child,getDescendants(child,filter)];%#ok
                    end
                end
            else
                for i=1:nChildren
                    child=children(i);
                    descendants=[descendants,child,getDescendants(child,filter)];%#ok
                end
            end
        end

        function tf=isModelReference(h)
            if isempty(h.m_isMdlRef)
                elemH=getElementBackingHandle(h);
                h.m_isMdlRef=slreportgen.utils.isModelReferenceBlock(elemH);
            end
            tf=h.m_isMdlRef;
        end

        function tf=isConfigurableSubSystem(h)
            if isempty(h.m_isConfigSys)
                elemH=getElementBackingHandle(h);
                h.m_isConfigSys=slreportgen.utils.isConfigurableSubsystemBlock(elemH);
            end
            tf=h.m_isConfigSys;
        end
    end

    methods(Access={?slreportgen.webview.ModelHierarchy})
        function h=ModelHierarchyItem(dhid,ehid,id)
            resetBacking(h,dhid,ehid);
            h.ID=id;
        end

        function setParent(h,parentItem)
            h.m_parent=parentItem;
            updatePath(h);
        end

        function setChildren(h,children)
            h.m_children=children;
        end

        function setModelHierarchy(h,modelHierarchy)
            h.m_modelHierarchy=modelHierarchy;
        end

        function setCheckState(h,val)
            h.m_checkState=val;
        end
    end

    methods(Access=private)
        function updatePath(h)
            if isRoot(h)
                h.m_path=getName(h);
            else
                p=getParent(h);
                h.m_path=slreportgen.utils.pathJoin(getPath(p),getName(h));
            end
        end

        function resetBacking(h,dhid,ehid)
            h.m_dhid=dhid;
            h.m_ehid=ehid;
            h.m_diagH=slreportgen.utils.getSlSfHandle(h.m_dhid);
            if~isempty(h.m_ehid)
                h.m_elemH=slreportgen.utils.getSlSfHandle(h.m_ehid);
            else
                h.m_elemH=[];
            end
        end

        function validateBacking(h)
            if~ishandle(h.m_diagH)||~(isempty(h.m_elemH)||ishandle(h.m_elemH))

                hs=slreportgen.utils.HierarchyService;
                dhid=hs.getDiagramHID(getPath(h));
                ehid=hs.getParent(dhid);
                resetBacking(h,dhid,ehid);
            end
        end
    end
end
