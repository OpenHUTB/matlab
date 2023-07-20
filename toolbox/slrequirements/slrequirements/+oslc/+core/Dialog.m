


























classdef Dialog<oslc.internal.BaseService



    properties(Dependent)
        dialog;
        hintWidth;
        hintHeight;
    end

    methods
        function this=Dialog(dom)
            this.dom=dom;
        end

        function out=get.dialog(this)
            node=this.dom.getElementsByTagName('oslc:dialog');
            out=node.node(1).getAttribute('rdf:resource');
        end

        function out=get.hintWidth(this)
            node=this.dom.getElementsByTagName('oslc:hintWidth');
            out=node.node(1).TextContent;
        end

        function out=get.hintHeight(this)
            node=this.dom.getElementsByTagName('oslc:hintHeight');
            out=node.node(1).TextContent;
        end

        function view(this)
            web(this.dialog);
        end
    end
end


