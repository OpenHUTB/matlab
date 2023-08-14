function setEventHandler(this)




    hSBD=get_param(this.modelName,'Object');
    L(1)=Simulink.listener(hSBD,'PostSaveEvent',@(hSrc,ev)NameChangeHandler(this,ev));
    L(end+1)=Simulink.listener(hSBD,'CloseEvent',@(hSrc,ev)CloseEventHandler(this,ev));

    if isempty(this.eventListener)
        this.eventListener=L;
    end

    function NameChangeHandler(this,ev)

        src=ev.Source;
        if~isa(src,'Simulink.BlockDiagram')
            return;
        end
        if~strcmpi(this.modelName,src.Name)&&...
            ~isempty(this.m_dlg)&&ishandle(this.m_dlg)
            delete(this.m_dlg);
        end



        function CloseEventHandler(this,ev)

            src=ev.Source;
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~strcmpi(this.modelName,src.Name)
                return;
            end
            if~isempty(this.m_dlg)&&ishandle(this.m_dlg)
                delete(this.m_dlg);
            end

