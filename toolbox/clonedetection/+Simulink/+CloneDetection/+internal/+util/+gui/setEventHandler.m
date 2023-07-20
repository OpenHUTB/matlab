function setEventHandler(this)




    hSBD=get_param(this.model,'Object');
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
        if~strcmpi(get_param(this.model,'name'),src.Name)&&...
            ~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
            delete(this.fDialogHandle);
        end



        function CloseEventHandler(this,ev)

            src=ev.Source;
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~strcmpi(get_param(this.model,'name'),src.Name)
                return;
            end
            if~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
                delete(this.fDialogHandle);
            end

