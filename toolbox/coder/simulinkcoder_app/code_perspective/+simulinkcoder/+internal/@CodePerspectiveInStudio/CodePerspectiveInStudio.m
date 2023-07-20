classdef CodePerspectiveInStudio<handle






    properties
studio
app
appLang
    end

    properties(Hidden)
data
preModel
registerCallbackId
closeListener
bdListeners
cv
        active=true
    end

    methods
        function obj=CodePerspectiveInStudio(st)

            obj.studio=st;


            obj.init();


        end

        function delete(obj)
            ls=obj.bdListeners;
            for i=1:length(ls)
                l=ls{i};
                delete(l);
            end

        end

    end

    methods
        init(obj)
        destroy(obj,varargin)
        handleEditorChanged(obj,cbinfo)
        refresh(obj)
        reset(obj)
    end

    methods(Static)
        out=getFromStudio(studio)
    end
end

