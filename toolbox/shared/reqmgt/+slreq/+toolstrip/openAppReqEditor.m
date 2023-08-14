


function openAppReqEditor(userdata,cbinfo)

    rootmodelH=slreq.toolstrip.getModelHandle(cbinfo);

    if slreq.toolstrip.shouldAppBeDisabled(rootmodelH)



        if isempty(get_param(rootmodelH,'FileName'))
            rmisl.notify(rootmodelH,message('Slvnv:slreq:WarningUnsavedModel'));
        end
        return;
    end


    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);

    if isempty(app)
        return;
    end

    st=cbinfo.studio;
    sa=st.App;
    acm=sa.getAppContextManager;

    if show
        cc=acm.getCustomContext(userdata);
        if~isempty(cc)

            ts=st.getToolStrip;
            ts.ActiveTab=cc.DefaultTabName;


            return;
        end
    end








    isOn=slreq.utils.isInPerspective(rootmodelH,false);

    if show~=isOn
        appmgr=slreq.app.MainManager.getInstance();
        appmgr.perspectiveManager.togglePerspective(cbinfo.studio);




    end
end
