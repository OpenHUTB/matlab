


classdef ConfigSetDialogSourceManager<handle
    properties
mgr
    end

    methods(Access=private,Hidden)
        function obj=ConfigSetDialogSourceManager
            obj.mgr=containers.Map;
        end
    end

    methods(Static,Hidden)
        function obj=getInstance()
            persistent inst;
            if isempty(inst)
                inst=configset.util.ConfigSetDialogSourceManager;
            end
            obj=inst;
        end
    end

    methods(Hidden)
        function cs=getSource(obj,ddname,csname)
            dd=Simulink.dd.open(ddname);
            fullName=dd.filespec;

            if obj.mgr.isKey(fullName)
                sm=obj.mgr(fullName);
                if~(sm.fDD==dd)
                    sm=configset.util.SourceManager(dd);
                    obj.mgr(fullName)=sm;
                end
            else
                sm=configset.util.SourceManager(dd);
                obj.mgr(fullName)=sm;
            end
            cs=sm.getConfigSet(csname);
        end

        function closeDialog(obj,dlg)
            ddnames=obj.mgr.keys;
            for i=1:length(ddnames)
                ddname=ddnames{i};
                sm=obj.mgr(ddname);
                sm.closeDialog(dlg);
                if sm.isEmpty
                    obj.mgr.remove(ddname);
                end
            end
        end

        function clean(obj)
            ddnames=obj.mgr.keys;
            for i=1:length(ddnames)
                ddname=ddnames{i};
                sm=obj.mgr(ddname);
                if sm.isEmpty
                    obj.mgr.remove(ddname);
                end
            end
        end

    end

    methods
        function listOpenDlgs(obj)
            ks=obj.mgr.keys;
            vs=obj.mgr.values;
            for i=1:length(vs)
                ddname=ks{i};
                v=vs{i};
                ids=v.fMap.keys;
                for j=1:length(ids)
                    id=ids{j};
                    if v.isDialogOpen(id)
                        disp([ddname,':',v.fDD.getEntryInfo(id).Name]);
                    end
                end
            end
        end
    end
end
