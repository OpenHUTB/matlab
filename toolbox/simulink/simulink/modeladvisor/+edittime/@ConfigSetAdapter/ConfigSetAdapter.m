classdef ConfigSetAdapter<handle
    properties
        system;
    end
    properties(Hidden)
        fPropListener={}
    end

    methods
        function obj=ConfigSetAdapter(cs,system)
            obj.system=system;
            obj.setupListener(cs);
        end
    end

    methods(Access=public)
        update(obj,src,name)
    end

    methods(Access=public)
        function callback(obj,m,~)
            if strcmp(m.Name,'UniqueDataStoreMsg')
                editEngine=edittimecheck.EditTimeEngine.getInstance();
                editEngine.rerunCheck(obj.system,'DuplicateDataStoreMemoryBlocksOnDifferentGraph')
            end
        end
        function setupListener(obj,cs)
            fcn=@obj.callback;
            if isa(cs,'Simulink.ConfigSetRef')
                try
                    cs=cs.getRefConfigSet;
                catch E
                    if(strcmp(E.identifier,'Simulink:ConfigSet:ConfigSetRef_SourceNameNotInBaseWorkspace'))
                        return;
                    end
                end
            end
            owner=cs.getComponent('Diagnostics');
            m=findprop(owner,'UniqueDataStoreMsg');
            obj.fPropListener=handle.listener(owner,m,'PropertyPostSet',fcn);
        end
    end
end

