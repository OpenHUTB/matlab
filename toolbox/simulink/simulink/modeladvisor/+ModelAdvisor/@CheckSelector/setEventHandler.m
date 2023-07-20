function setEventHandler(this)




    hSBD=get_param(this.getMdlName,'Object');
    L(1)=Simulink.listener(hSBD,'PostSaveEvent',@(hSrc,ev)NameChangeHandler(this,hSrc,ev));
    L(end+1)=Simulink.listener(hSBD,'CloseEvent',@(hSrc,ev)CloseEventHandler(this,hSrc,ev));

    if isempty(this.eventListener)
        this.eventListener=L;
    end

    function NameChangeHandler(this,src,~)

        if~isa(src,'Simulink.BlockDiagram')
            return;
        end
        if~strcmpi(this.fModelName,src.Name)&&...
            ~isempty(this.getMdlName)&&ishandle(this.fDialogHandle)
            delete(this.fDialogHandle);
        end



        function CloseEventHandler(this,src,~)

            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~strcmpi(this.getMdlName,src.Name)
                return;
            end
            if~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
                delete(this.fDialogHandle);
            end

