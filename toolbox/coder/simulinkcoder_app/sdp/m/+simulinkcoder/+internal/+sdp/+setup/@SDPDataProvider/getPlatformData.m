function[data,meta]=getPlatformData(obj,id,role)




    nativeP='Embedded Code';

    data=mdom.Data;
    if role>0
        platform=obj.dataModel.getPlatform(id);
        if strcmp(platform,'-')
            platform=nativeP;
            icon=connector.getBaseUrl('toolbox/coder/simulinkcoder_app/toolstrip/icons/ert_CodeC_16.png');
        else
            icon=connector.getBaseUrl('toolbox/shared/toolstrip_coder_app/plugin/icons/sdp/FunctionPlatform_24.png');
        end
        data.setProp('label',platform);
        data.setProp('iconUri',icon)
    end

    meta=mdom.MetaData;
    if role==1
        meta.setProp('editor','ComboboxEditor');

        items=[];
        item=mdom.MetaData;
        item.registerDataType('value',mdom.MetaDataType.STRING);


        item.setProp('value','-');
        item.setProp('label',nativeP);
        items=[items,item];



        if slfeature('FCPlatform')
            node=obj.dataModel.getNode(id);
            ecd=node.CoderDictionary;
            if~isempty(ecd)
                hlp=coder.internal.CoderDataStaticAPI.getHelper();
                try
                    list=hlp.getSoftwarePlatforms(ecd);
                    for i=1:length(list)
                        pf=list(i);
                        if strcmp(pf.PlatformType,'ServiceInterfaceConfiguration')
                            pfName=pf.Name;
                            item.clear();
                            item.setProp('value',pfName);
                            item.setProp('label',pfName);
                            items=[items,item];%#ok<AGROW>
                            break;
                        end
                    end
                catch
                end
            end
        end

        meta.setProp('items',items);
    end



