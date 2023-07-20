classdef ElementBuilder<handle


























    properties

        Name string


        ClassName string


        SID string


        SlProxyObjectID string


Handle


SlProxyObject


        DisplayLabel string


        DisplayIcon string
    end

    properties(Access=private)


        IsBuilt=false;
    end

    methods
        function this=ElementBuilder()
        end

        function element=build(this)



            assert(~this.IsBuilt);

            element=slreportgen.webview.internal.Element;

            if~isempty(this.SlProxyObject)
                slobj=this.SlProxyObject;
                element.setSlProxyObject(slobj);
                element.setHandle(slobj.Handle);
                element.setSlProxyObjectID(slobj.getId());
            end

            if~isempty(this.Handle)
                element.setHandle(this.Handle);
            end

            if~isempty(this.SID)
                element.setSID(this.SID);
            end

            if~isempty(this.SlProxyObjectID)
                element.setSlProxyObjectID(this.SlProxyObjectID);
            end

            if isempty(element.SID)
                this.setSID(element);
            end

            if isempty(element.SlProxyObjectID)
                slpobjid=element.slproxyobject().getId();
                element.setSlProxyObjectID(slpobjid);
            end

            this.setName(element);
            this.setClassName(element);
            this.setDisplayIcon(element);
            this.setDisplayLabel(element);

            this.IsBuilt=true;
        end
    end

    methods(Access=private)
        function setSID(~,element)
            slpobj=element.slproxyobject();
            sid=slpobj.SID;
            if isempty(sid)
                sid=string.empty();
            end
            element.setSID(sid)
        end

        function setName(this,element)
            if~isempty(this.Name)
                name=this.Name;
            else
                try
                    hnd=element.handle();
                    if isnumeric(hnd)

                        name=get_param(hnd,'Name');
                    else

                        if~isa(hnd,"Stateflow.Transition")
                            name=hnd.Name;
                        else
                            name=string.empty();
                        end
                    end
                catch

                    name=string.empty();
                end
            end
            element.setName(name);
        end

        function setClassName(this,element)
            if~isempty(this.ClassName)
                className=this.ClassName;
            else
                className=element.slproxyobject().ClassName;
            end
            element.setClassName(className);
        end

        function setDisplayIcon(this,element)
            persistent PAT

            if isempty(PAT)
                PAT="^"+regexptranslate("escape",matlabroot());
            end

            if isempty(this.DisplayIcon)



                icon=slreportgen.utils.getDisplayIcon(element.slproxyobject().Handle);
            else
                icon=this.DisplayIcon;
            end
            icon=regexprep(icon,PAT,"$matlabroot");

            element.setDisplayIcon(icon);
        end

        function setDisplayLabel(this,element)
            if isempty(this.DisplayLabel)
                label=element.slproxyobject().getDisplayLabel();
            else
                label=this.DisplayLabel;
            end
            element.setDisplayLabel(label);
        end
    end
end

