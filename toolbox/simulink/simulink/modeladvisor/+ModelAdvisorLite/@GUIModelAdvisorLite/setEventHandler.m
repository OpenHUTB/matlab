function setEventHandler(this)




    hSBD=get_param(bdroot(this.mdl),'Object');
    L(1)=Simulink.listener(hSBD,'PostSaveEvent',@(hSrc,ev)NameChangeHandler(this,hSrc,ev));
    L(end+1)=Simulink.listener(hSBD,'CloseEvent',@(hSrc,ev)CloseEventHandler(this,hSrc,ev));

    if isempty(this.eventListener)
        this.eventListener=L;
    end

    function NameChangeHandler(this,src,~)

        if~isa(src,'Simulink.BlockDiagram')
            return;
        end
        if~isempty(this.dlg)&&ishandle(this.dlg)
            delete(this.dlg);
        end



        function CloseEventHandler(this,src,~)

            if~isa(src,'Simulink.BlockDiagram')
                return;
            end
            if~isempty(this.dlg)&&ishandle(this.dlg)
                delete(this.dlg);
            end

