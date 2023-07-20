


classdef(Abstract)StudioComponentWidget<handle

    properties(Access=public)
        m_comp=[];
    end

    methods(Access=public)




        function visible=isVisible(this)
            import simulink.sysdoc.internal.SysDocUtil;
            visible=SysDocUtil.isComponentVisible(this.m_comp,this.getStudio());
        end

        function show(this)
            import simulink.sysdoc.internal.SysDocUtil;
            studio=this.getStudio();

            getOrCreateComponentAndShow(studio,this);
            if isempty(this.m_comp)
                return;
            end
            this.m_comp.PersistState=true;
            this.m_comp.CreateCallback='simulink.SystemDocumentationApplication.showOnCurrentStudio';
        end

        function hide(this)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(this.m_comp)
                return;
            end

            studio=this.getStudio();
            if SysDocUtil.isVisible(this.m_comp,studio)

                studio.hideComponent(this.m_comp);
                this.m_comp.PersistState=false;
            end
        end




        function setComponent(this,comp)
            this.m_comp=comp;
        end

        function comp=getComponent(this)
            comp=this.m_comp;
        end

        function comp=getValidComponent(this,studio)
            this.initComponentAndShow(studio);
            comp=this.m_comp;
        end
    end

    methods(Abstract)
        initComponentAndShow(this,studio);
        getStudio(this);
        getNameTag(this);
        getCompType(this);
        getTitle(this);
        getDefaultDockside(this);
    end
end




function getOrCreateComponentAndShow(studio,view)
    import simulink.sysdoc.internal.SysDocUtil;
    if~SysDocUtil.isNotEmptyAndValid(studio)
        return;
    end

    comp=view.getComponent();
    exited=SysDocUtil.isNotEmptyAndValid(comp);
    nameTag=view.getNameTag();
    if~exited

        comp=SysDocUtil.getComponentFromStudio(studio,nameTag,view.getCompType());
        exited=SysDocUtil.isNotEmptyAndValid(comp);
        if exited
            view.setComponent(comp);
        end
    end
    if exited
        comp.PersistState=true;
        if~comp.isVisible

            studio.showComponent(comp);
        end
        if strcmp(studio.getComponentLocation(comp),'Invisible')

            studio.moveComponentToDock(comp,view.getTitle(),view.getDefaultDockside(),'stacked');
        end
        return;
    end
    view.initComponentAndShow(studio);
    comp=view.getComponent();
    if isempty(comp)
        return;
    end
    comp.PersistState=true;
    comp.CreateCallback='simulink.SystemDocumentationApplication.showOnCurrentStudio';
end
