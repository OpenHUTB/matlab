function setEventHandler(this)




    hSBD=get_param(this.fModelName,'Object');
    L(1)=Simulink.listener(hSBD,'PostSaveEvent',@(hSrc,ev)NameChangeHandler(this,hSrc));
    L(end+1)=Simulink.listener(hSBD,'CloseEvent',@(hSrc,ev)CloseEventHandler(this,hSrc));

    if isempty(this.eventListener)
        this.eventListener=L;
    end

    function NameChangeHandler(this,src)

        if~isa(src,'Simulink.BlockDiagram')
            return;
        end
        if~strcmpi(this.fModelName,src.Name)&&...
            ~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
            delete(this.fDialogHandle);
            if~isempty(this.browseDlg)
                delete(this.browseDlg)
            end
        end



        function CloseEventHandler(this,src)

            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~strcmpi(this.fModelName,src.Name)
                return;
            end
            if~isempty(this.fDialogHandle)&&ishandle(this.fDialogHandle)
                if~isempty(this.browseDlg)&&...
                    this.browseDlg.isvalid&&...
                    ~isempty(this.browseDlg.fDialogHandle)
                    try
                        delete(this.browseDlg.fDialogHandle)
                    catch E
                    end
                end
                delete(this.fDialogHandle);
            end

