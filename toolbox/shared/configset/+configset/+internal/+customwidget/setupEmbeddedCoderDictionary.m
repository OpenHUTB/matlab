function updateDeps=setupEmbeddedCoderDictionary(cs,~)




    updateDeps=false;
    name='EmbeddedCoderDictionary';
    value=get_param(cs,name);

    function callback(filename)
        if~strcmp(filename,value)
            configset.internal.util.setWidgetValue(cs.getDialogHandle,...
            name,filename);
            if slfeature('ConfigsetDDUX')==1
                dH=cs.getDialogHandle;
                if(isa(dH,'DAStudio.Dialog'))
                    htmlView=dH.getDialogSource;
                    data=struct;
                    data.paramName=[name,'New'];
                    data.paramValue=filename;
                    data.widgetType='browse';
                    htmlView.publish('sendToDDUX',data);
                end
            end
        end
    end



    simulinkcoder.internal.app.ViewSDP('','ModelToLink',...
    @callback);
end


