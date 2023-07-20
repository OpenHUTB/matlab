classdef Clipboard<handle




    properties(GetAccess=public,SetAccess=private,Hidden)
        contents;
        type;
        names cell;
    end

    methods(Hidden)
        function clear(this)
            if~isempty(this.contents)
                delete([this.contents{:}]);
            end
            this.contents={};
            this.type='';
            this.names={};
        end

        function fill(this,contents,type,names)
            this.contents=contents;
            this.type=type;
            this.names=names;
        end

        function delete(this)
            this.clear;
        end
    end

    methods(Hidden,Access={?Simulink.typeeditor.app.Editor,...
        ?sl.interface.dictionaryApp.clipboard.Clipboard})
        function obj=Clipboard
        end
    end
end
