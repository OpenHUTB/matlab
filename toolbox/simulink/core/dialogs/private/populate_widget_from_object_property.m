function wid=populate_widget_from_object_property(h,prop,toplevelH,immediateMode)



















    try
        modifyObjectStack('push',h,prop.Name);
        wid.Name=prop.Name;
        wid.Visible=1;
        if(~ddg_is_property_visible(h,prop))
            wid.Visible=0;
            wid.Enabled=0;
        elseif(~ddg_is_property_enabled(h,prop))
            wid.Enabled=0;
        end


        wid.Type=get_widget_type_from_property(h,prop);
        if(strcmp(wid.Type,'combobox')==1)
            switch Simulink.data.getScalarObjectLevel(h)
            case 1
                wid.Entries=set(h,prop.Name)';
            case 2
                try
                    wid.Entries=getPropAllowedValues(h,prop.Name);
                catch
                    wid.Entries=DAStudio.Protocol.getPropAllowedValues(h,prop.Name);
                end
            otherwise
                assert(false);
            end
            wid.Source=h;
            wid.ObjectProperty=prop.Name;
            wid.Tag=prop.Name;
            if(~isequal(toplevelH,h))
                wid.MatlabMethod='dataddg_cb';
                wid.MatlabArgs={'%dialog','refresh_me_cb',toplevelH};
            end


            wid.Mode=immediateMode;
            wid.DialogRefresh=immediateMode;

        elseif(strcmp(wid.Type,'group')==1)
            newHandle=h.(prop.Name);
            wid.Source=newHandle;

            if hasGetDialogSchemaMth(newHandle)
                wid=getDialogSchema(newHandle,'');
                fieldsToRemove=intersect(fieldnames(wid),...
                {'DialogTitle','HelpMethod','HelpArgs','SmartApply'...
                ,'PreApplyCallback','PreApplyArgs','MinimalApply'...
                ,'PostApplyCallback','PostApplyArgs'});
                wid=rmfield(wid,fieldsToRemove);
                wid.Source=newHandle;
                wid.Name=prop.Name;
                wid.Type='group';
                if(~ddg_is_property_visible(h,prop))
                    wid.Visible=0;
                elseif(~ddg_is_property_enabled(h,prop))
                    wid.Enabled=0;
                end
            else
                props=Simulink.data.getPropList(newHandle,'GetAccess','public',...
                'Hidden',false);

                assert(~isempty(props));
                numItems=1;
                for i=1:length(props)
                    type=get_widget_type_from_property(newHandle,props(i));

                    if(strcmp(type,'unknown')==1)
                        continue;
                    end
                    wid2=populate_widget_from_object_property(newHandle,props(i),toplevelH,immediateMode);
                    if strcmp(props(i).Name,'PreserveDimensions')
                        wid2.Name=DAStudio.message(['Simulink:dialog:Data',props(i).Name,'Prompt']);
                    end

                    wid2.RowSpan=[numItems,numItems];
                    wid2.ColSpan=[1,2];

                    if(strcmp(wid2.Type,'edit')==1)
                        if(ishandle(h))
                            hClass=classhandle(h);
                            hClassName=hClass.Name;


                            wid2.ActionProperty=[hClassName,'.',wid.Name,'.',wid2.Name];
                        end
                    end

                    wid.Items{numItems}=wid2;
                    numItems=numItems+1;
                end
            end
        else
            wid.Source=h;
            wid.ObjectProperty=prop.Name;
            wid.Tag=prop.Name;
            if(~isequal(toplevelH,h))
                wid.MatlabMethod='dataddg_cb';
                wid.MatlabArgs={'%dialog','refresh_me_cb',toplevelH};
            end


            wid.Mode=immediateMode;
            wid.DialogRefresh=immediateMode;
        end
        modifyObjectStack('pop',h);
    catch e %#ok
        clear wid;
        wid.Type='text';
        wid.Name=DAStudio.message('Simulink:dialog:UnableToDisplayProperty',prop.Name);
        wid.WordWrap=true;
        modifyObjectStack('pop',h);
    end


    function modifyObjectStack(action,hObj,propName)

        persistent objStack






        if~isMCOSValueObj(hObj)
            switch action
            case 'push'
                objFound=false;
                for idx=1:length(objStack)
                    if(objStack{idx}==hObj)
                        objFound=true;
                    end
                end


                objStack=[objStack;{hObj}];

                if objFound
                    DAStudio.error('Simulink:dialog:UnableToDisplayProperty',propName);
                end
            case 'pop'

                assert(hObj==objStack{end});
                objStack(end)=[];
            end
        end


        function retVal=isMCOSValueObj(obj)

            retVal=false;

            if isobject(obj)
                classHandle=metaclass(obj);
                if~classHandle.HandleCompatible
                    retVal=true;
                end
            end

            function retVal=hasGetDialogSchemaMth(obj)


                retVal=false;



                if isa(obj,'DAStudio.Object')||isa(obj,'Simulink.DABaseObject')
                    retVal=true;
                else
                    switch Simulink.data.getScalarObjectLevel(obj)
                    case 1
                        methodList=methods(obj);
                        retVal=ismember('getDialogSchema',methodList);
                    case 2
                        hClass=metaclass(obj);
                        methodList={hClass.MethodList.Name}';
                        retVal=ismember('getDialogSchema',methodList);
                    otherwise
                        assert(false);
                    end
                end


