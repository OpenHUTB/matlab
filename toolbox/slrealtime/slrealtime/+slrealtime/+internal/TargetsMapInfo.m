classdef TargetsMapInfo<handle






    methods(Access=public)



        function this=TargetsMapInfo()
            this.target=[];
            this.renameListeners=event.listener.empty;
            this.settingsListeners=event.listener.empty;
        end

        function delete(this)
            this.deleteRenameListeners();
            this.deleteSettingsListeners();
        end
    end

    methods(Access=public)



        function enableRenameListeners(this)
            for i=1:length(this.renameListeners)
                this.renameListeners(i).Enabled=true;
            end
        end
        function disableRenameListeners(this)
            for i=1:length(this.renameListeners)
                this.renameListeners(i).Enabled=false;
            end
        end
    end

    methods(Access=private)



        function deleteRenameListeners(this)
            for i=1:length(this.renameListeners)
                delete(this.renameListeners(i));
            end
            this.renameListeners=[];
        end

        function deleteSettingsListeners(this)
            for i=1:length(this.settingsListeners)
                delete(this.settingsListeners(i));
            end
            this.settingsListeners=[];
        end
    end

    properties(Access=public)
        target;
        renameListeners;
        settingsListeners;
    end
end
