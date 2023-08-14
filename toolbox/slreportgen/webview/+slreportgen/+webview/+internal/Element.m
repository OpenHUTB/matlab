classdef Element<handle&matlab.mixin.Copyable







































    properties(SetAccess=private)





Name



ClassName




SID



SlProxyObjectID





DisplayLabel




DisplayIcon
    end

    properties(NonCopyable,Transient)

        ExportData slreportgen.webview.internal.ElementExportData
    end

    properties
Tag
    end

    properties(Access=private)
RSID
    end

    properties(NonCopyable,Transient)
Handle
        SlProxyObject slreportgen.webview.SlProxyObject



ReferenceDiagram

        NormalizedNameCacheValue string
    end

    methods
        function out=handle(this)


            if isempty(this.Handle)
                this.Handle=this.slproxyobject().Handle;
            end
            out=this.Handle;
        end

        function out=slproxyobject(this)





            if isempty(this.SlProxyObject)

                if isempty(this.Handle)


                    this.ReferenceDiagram.loadElementHandles();
                else
                    this.SlProxyObject=slreportgen.webview.SlProxyObject(this.Handle);
                end
                assert(~isempty(this.SlProxyObject));
            end
            out=this.SlProxyObject;
        end

        function out=normalizedName(this)
            if isempty(this.NormalizedNameCacheValue)
                this.NormalizedNameCacheValue=regexprep(this.Name,"\s"," ");
            end
            out=this.NormalizedNameCacheValue;
        end

        function out=rsid(this)





            if isempty(this.RSID)
                out=this.SlProxyObjectID;
            else
                out=this.RSID;
            end
        end
    end

    methods(Access={?slreportgen.webview.internal.ElementBuilder,...
        ?slreportgen.webview.internal.ElementListRegistry})
        function this=Element()
        end

        function setName(this,value)
            this.Name=string(value);
            this.NormalizedNameCacheValue=string.empty();
        end

        function setClassName(this,className)
            this.ClassName=string(className);
        end

        function setSID(this,sid)
            this.SID=string(sid);
        end

        function setRSID(this,rsid)
            this.RSID=string(rsid);
        end

        function setSlProxyObjectID(this,slpobjid)
            this.SlProxyObjectID=string(slpobjid);
        end

        function setDisplayIcon(this,icon)
            this.DisplayIcon=string(icon);
        end

        function setDisplayLabel(this,label)
            this.DisplayLabel=string(label);
        end
    end

    methods(Access={...
        ?slreportgen.webview.internal.ElementBuilder,...
        ?slreportgen.webview.internal.ElementListRegistry})
        function setHandle(this,hnd)
            this.Handle=hnd;
        end

        function setSlProxyObject(this,slpobj)
            this.SlProxyObject=slpobj;
        end
    end

    methods(Access=?slreportgen.webview.internal.ElementListRegistry)
        function setReferenceDiagram(this,hnd)
            this.ReferenceDiagram=hnd;
        end

        function out=referenceDiagram(this)
            out=this.ReferenceDiagram;
        end
    end
end
