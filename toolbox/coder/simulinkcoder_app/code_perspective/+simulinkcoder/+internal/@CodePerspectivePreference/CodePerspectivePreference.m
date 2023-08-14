classdef CodePerspectivePreference<handle




    properties(Dependent)
helpOn
    end

    properties(Access=private,Transient)
path
file
    end

    properties(Access=private)
        fHelpOn=false
    end

    methods
        function obj=CodePerspectivePreference
            obj.path=fullfile(prefdir,'code_perspective');
            obj.file=fullfile(obj.path,'CodePerspectivePref.mat');
        end

        function out=get.helpOn(obj)
            pref=obj.loadPref();
            out=pref.fHelpOn;
        end

        function set.helpOn(obj,val)
            pref=obj.loadPref();
            pref.fHelpOn=val;
            obj.savePref(pref);
        end
    end

    methods(Static)
        function resetPref()
            pref=simulinkcoder.internal.CodePerspectivePreference;
            pref.savePref(pref);
        end
    end

    methods(Access=private)
        function pref=loadPref(obj)
            if~isfolder(obj.path)
                mkdir(obj.path);
            end
            if isfile(obj.file)
                S=load(obj.file);
                pref=S.pref;
            else
                pref=obj;
            end
        end

        function savePref(obj,pref)%#ok<INUSD>
            if~isfolder(obj.path)
                mkdir(obj.path);
            end
            save(obj.file,'pref');
        end
    end
end

