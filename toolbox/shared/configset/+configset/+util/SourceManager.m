


classdef SourceManager<handle
    properties(Hidden)
fMap
fDD
fListener
    end

    methods
        function obj=SourceManager(dd)
            obj.fDD=dd;
            obj.fMap=containers.Map('KeyType','int32','ValueType','any');
            obj.fListener=event.listener(dd,'DataDictionaryModified',@obj.update);
        end

        function cs=getConfigSet(obj,csname)

            fullName=['Configurations.',csname];
            id=obj.fDD.getEntryID(fullName);

            if obj.isDialogOpen(id)
                cs=obj.fMap(id);
            else
                cs=obj.fDD.getEntryCached(fullName);
                obj.fMap(id)=cs;
            end

            cs.getDialogController.DataDictionary=obj.fDD.filespec;
        end
    end

    methods(Access=public)
        function update(obj,~,~)

            map=obj.fMap;
            keys=map.keys;
            for i=1:length(keys)
                id=keys{i};
                if obj.isDialogOpen(id)
                    cs1=map(id);

                    try
                        cs2in=obj.fDD.getEntryInfo(id);
                        cs2name=cs2in.Name;
                        cs2=obj.fDD.getEntryCached(['Configurations.',cs2name]);
                    catch
                        map.remove(id);
                        continue;
                    end

                    if~isequal(cs1,cs2)

                        cs1.assignFrom(cs2,true,'CopyDisabledList');
                    end
                else

                    map.remove(id);
                end
            end
        end

        function ret=isDialogOpen(obj,id)

            map=obj.fMap;

            if~map.isKey(id)
                ret=false;
            else
                cs=map(id);
                dlg=cs.getDialogHandle;

                if isempty(dlg)
                    ret=false;
                elseif isa(dlg,'DAStudio.Dialog')

                    ret=true;
                elseif isa(dlg,'DAStudio.Explorer')&&dlg.isVisible

                    ret=true;
                else
                    ret=false;
                end
            end
        end

        function closeDialog(obj,dlg)
            map=obj.fMap;
            keys=map.keys;
            for i=1:length(keys)
                id=keys{i};
                cs=map(id);
                if cs.getDialogHandle==dlg
                    map.remove(id);
                end
            end
        end

        function out=isEmpty(obj)
            map=obj.fMap;
            vs=map.values;
            out=true;

            for i=1:length(vs)
                cs=vs{i};
                dlg=cs.getDialogHandle;
                if isa(dlg,'DAStudio.Dialog')
                    out=false;
                    return;
                end
            end
        end
    end
end
