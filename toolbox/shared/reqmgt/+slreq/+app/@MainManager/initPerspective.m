function initPerspective(this)






    if isempty(this.perspectiveManager)&&dig.isProductInstalled('Simulink')
        this.perspectiveManager=slreq.app.PerspectiveManager();

        this.perspectiveManager.addlistener('ReqPerspectiveChange',@this.perspectiveChangeHandler);


        this.perspectiveManager.addlistener('ReqSpreadsheetToggled',@slreq.toolstrip.respondToPerspective);
    end
end
