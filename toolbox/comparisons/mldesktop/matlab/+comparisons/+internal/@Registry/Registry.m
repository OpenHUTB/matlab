classdef(Sealed,SupportExtensionMethods=true)Registry<handle




    properties(Constant)
        Instance=comparisons.internal.Registry;
    end


    properties(GetAccess=public,SetAccess=private)
        DiffGUIProviders=comparisons.internal.DiffGUIProvider.empty;
        DiffNoGUIProviders=comparisons.internal.DiffNoGUIProvider.empty;
        Merge3GUIProviders=comparisons.internal.Merge3GUIProvider.empty;
    end


    methods(Access=protected)

        function result=register(this,type)
            class=metaclass(this);
            names={class.MethodList.Name};
            applicable=~cellfun('isempty',regexp(names,['^register.*',type,'$']));

            result=this.findprop(type).DefaultValue;
            for n=find(applicable)
                registered=this.(names{n});
                result=[result;registered(:)];%#ok<AGROW>
            end
        end

    end


    methods

        function providers=get.DiffGUIProviders(this)
            if isempty(this.DiffGUIProviders)
                this.DiffGUIProviders=this.register('DiffGUIProviders');
            end
            providers=this.DiffGUIProviders;
        end

        function providers=get.DiffNoGUIProviders(this)
            if isempty(this.DiffNoGUIProviders)
                this.DiffNoGUIProviders=this.register('DiffNoGUIProviders');
            end
            providers=this.DiffNoGUIProviders;
        end

        function providers=get.Merge3GUIProviders(this)
            if isempty(this.Merge3GUIProviders)
                this.Merge3GUIProviders=this.register('Merge3GUIProviders');
            end
            providers=this.Merge3GUIProviders;
        end

    end

end
