function setEventHandler(this)




    hSBD=get_param(this.mdlName,'Object');
    L(1)=Simulink.listener(hSBD,'PostSaveEvent',@(hSrc,ev)NameChangeHandler(this,ev));
    L(end+1)=Simulink.listener(hSBD,'CloseEvent',@(hSrc,ev)CloseEventHandler(hSrc,this));

    if isempty(this.eventListener)
        this.eventListener=L;
    end

    function NameChangeHandler(this,ev)

        src=ev.Source;
        if~isa(src,'Simulink.BlockDiagram')
            return;
        end
        if~strcmpi(this.mdlName,src.Name)&&...
            ~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
            delete(this.fDialogHandle);
        end



        function CloseEventHandler(src,this)
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~strcmpi(this.mdlName,src.Name)
                return;
            end
            if~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
                delete(this.fDialogHandle);
            end

