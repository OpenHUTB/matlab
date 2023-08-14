classdef LBCustomizer<handle

    properties(SetAccess=private,GetAccess=public)
        Orderings;
        Filters;
        HideBlocks;
        Dirty;
        IsCustom;
        NodePreferences;
    end

    properties(Constant)
        Instance=LBCustomizer();
    end

    methods

        function obj=LBCustomizer()
            mlock;
            obj.Orderings={};
            obj.Filters={};
            obj.HideBlocks=false;

            obj.Dirty=true;
            obj.IsCustom=false;
            obj.NodePreferences={};
        end

        function applyOrder(obj,order)
            if(~iscell(order)||~eq(mod(length(order),2),0))
                warning(message('Simulink:LibraryBrowser:applyOrderExpectsTuples'));
                return;
            end

            i=1;
            while i<length(order)
                if(~obj.isCharOrStringScalar(order{i})||~isnumeric(order{i+1}))
                    warning(message('Simulink:LibraryBrowser:applyOrderExpectsTuples'));
                    return;
                end

                if isempty(obj.Orderings)
                    obj.Orderings={{order{i},order{i+1}}};
                else
                    obj.Orderings=[obj.Orderings,{{order{i},order{i+1}}}];
                end
                obj.Dirty=true;

                i=i+2;
            end
        end

        function applyFilter(obj,filters)
            if(~iscell(filters)||~eq(mod(length(filters),2),0))
                warning(message('Simulink:LibraryBrowser:applyFilterExpectsTuples'));
                return;
            end

            i=1;
            while i<length(filters)
                if~obj.isCharOrStringScalar(filters{i})&&~obj.isChar(filters{i+1})
                    warning(message('Simulink:LibraryBrowser:applyFilterExpectsStrings'));
                    return;
                end

                filterType=filters{i+1};
                if(~strcmp(filterType,'Enabled')&&...
                    ~strcmp(filterType,'Disabled')&&...
                    ~strcmp(filterType,'Hidden'))
                    warning(message('Simulink:LibraryBrowser:unknownFilterType',filterType,filters{i}));
                    i=i+2;
                    continue;
                end

                if isempty(obj.Filters)
                    obj.Filters={{filters{i},filters{i+1}}};
                else
                    obj.Filters=[obj.Filters,{{filters{i},filters{i+1}}}];
                end
                obj.Dirty=true;

                i=i+2;
            end
        end

        function applyNodePreference(obj,isExpanded)
            if(~iscell(isExpanded)||~eq(mod(length(isExpanded),2),0))
                warning(message('Simulink:LibraryBrowser:applyNodePreferenceExpectsTuples'));
                return;
            end

            i=1;
            while i<length(isExpanded)
                if~obj.isCharOrStringScalar(isExpanded{i})||~(islogical(isExpanded{i+1})||isnumeric(isExpanded{i+1}))
                    warning(message('Simulink:LibraryBrowser:applyNodePreferenceExpectsStringLogicalPairs'));
                    return;
                end

                if isempty(obj.NodePreferences)
                    obj.NodePreferences={{isExpanded{i},isExpanded{i+1}}};
                else
                    obj.NodePreferences=[obj.NodePreferences,{{isExpanded{i},isExpanded{i+1}}}];
                end
                obj.Dirty=true;

                i=i+2;
            end
        end

        function setIsCustom(obj,value)
            obj.IsCustom=value;
            obj.Dirty=true;
        end

        function hideAllBlocks(obj)
            obj.HideBlocks=true;
            obj.Dirty=true;
        end

        function clear(obj)
            obj.Orderings={};
            obj.Filters={};
            obj.HideBlocks=false;
            obj.Dirty=true;
            obj.NodePreferences={};
        end

        function isAChar=isCharOrStringScalar(obj,c)
            isAChar=ischar(c)||(isstring(c)&&isscalar(c));
        end

    end

    methods(Static=true)
        function obj=getInstance()
            obj=LBCustomizer.Instance;
        end

        function orderings=getOrderings()
            orderings=LBCustomizer.Instance.Orderings;
        end

        function filters=getFilters()
            filters=LBCustomizer.Instance.Filters;
        end

        function dirty=getDirtyFlag()
            dirty=LBCustomizer.Instance.Dirty;
        end

        function isCustom=getIsCustom()
            isCustom=LBCustomizer.Instance.IsCustom;
        end

        function nodePreferences=getNodePreferences()
            nodePreferences=LBCustomizer.Instance.NodePreferences;
        end

        function hideBlocks=getHideBlocks()
            hideBlocks=LBCustomizer.Instance.HideBlocks;
        end

        function clearDirtyFlag()
            LBCustomizer.Instance.Dirty=false;
        end

        function applyOrderImpl(in)
            LBCustomizer.Instance.applyOrder(in);
        end
        function applyFilterImpl(in)
            LBCustomizer.Instance.applyFilter(in);
        end
        function applyNodePreferenceImpl(in)
            LBCustomizer.Instance.applyNodePreference(in);
        end
        function setIsCustomImpl(in)
            LBCustomizer.Instance.setIsCustom(in);
        end

    end
end
