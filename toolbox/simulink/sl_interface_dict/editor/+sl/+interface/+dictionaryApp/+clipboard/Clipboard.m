classdef Clipboard<Simulink.typeeditor.app.Clipboard







    properties(GetAccess=public,SetAccess=private)
        HoldsChildElements(1,1)logical=false;
    end

    methods(Static,Access=public)
        function obj=getInstance()

            mlock;
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=sl.interface.dictionaryApp.clipboard.Clipboard;
            end
            instance.addlistener('ObjectBeingDestroyed',@(~,~)munlock);
            obj=instance;
        end
    end

    methods(Access=public)
        function fill(this,nodes)

            if isa(nodes{1},'sl.interface.dictionaryApp.node.ElementNode')


                type='element';
                this.HoldsChildElements=true;
            else
                type='object';
                this.HoldsChildElements=false;
            end
            name=cellfun(@(x)x.getCachedName,nodes,'UniformOutput',false);
            fill@Simulink.typeeditor.app.Clipboard(this,nodes,type,name);
        end

        function isEmpty=isEmpty(this)
            isEmpty=isempty(this.contents);
            if~isEmpty



                isValid=cellfun(@(node)node.isValid(),this.contents);
                if~all(isValid)


                    this.clear();
                    isEmpty=true;
                end
            end
        end
    end

    methods(Access=private)
        function this=Clipboard()

            this=this@Simulink.typeeditor.app.Clipboard;
        end
    end
end
