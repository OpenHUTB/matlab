function dialogCallback(adp,msg)





    cs=adp.Source;
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.LocalConfigSet;
    end
    dlg=msg.dialog;
    name=msg.name;
    value=msg.value;
    data=msg.data;

    adp.inDialogUpdate=true;

    try



        if~isempty(data.CallbackFunction)&&...
            (~isa(data,'configset.internal.data.WidgetStaticData')||~strcmp(data.WidgetType,'table'))
            str=data.CallbackFunction;
            if contains(str,'(')&&contains(str,')')





                try
                    oldVal=cs.getProp(name);

                    if isnumeric(oldVal)&&~isnumeric(value)
                        value=str2double(value);
                    elseif~isnumeric(oldVal)&&isnumeric(value)
                        value=num2str(value);
                    end
                    cs.setProp(name,value);

                catch
                end

                [hObj,hSrc,hDlg,model]=configset.internal.util.populateTLCFunctionArguments(cs,dlg);%#ok<ASGLU>
                eval(str);



                adp.refresh;
                updateDependencies=false;
            else

                fn=str2func(str);
                updateDependencies=fn(cs,msg);
            end

            if~updateDependencies
                adp.inDialogUpdate=false;
                return;
            end

        end



        if isa(data,'configset.internal.data.WidgetStaticData')
            pdata=data.Parameter;
            param=pdata.Name;
            if~isempty(pdata.WidgetValuesFcn)

                wList=adp.getWidgetDataList(param);
                wValues=adp.getWidgetValueList(param);
                for i=1:length(wList)
                    if strcmp(wList{i}.Name,name)
                        wValues{i}=value;
                        break;
                    end
                end
                fn=str2func(pdata.WidgetValuesFcn);
                value=fn(cs,param,1,wValues);
            end

        elseif isa(data,'configset.internal.data.ParamStaticData')
            param=name;
            pdata=data;

            if pdata.isInvertValue
                value=configset.internal.util.invertValue(value);
            elseif~isempty(pdata.WidgetValuesFcn)
                fn=str2func(pdata.WidgetValuesFcn);
                if iscell(value)&&~isempty(pdata.WidgetList)





                    value=fn(cs,param,1,value);
                else
                    value=fn(cs,param,1,{value});
                end
            end
        end





        if strcmp(name,'HardwareBoard')
            if~isempty(cs.getConfigSet)
                avs=data.AvailableValues(cs);
                if strcmp(value,avs(1).str)
                    value=avs(1).disp;
                end
                codertarget.target.targetHardwareChanged(cs,value);
                adp.refresh;
                adp.inDialogUpdate=false;
                return;
            end
        end





        if strcmp(name,'HardwareBoardFeatureSet')
            if~isempty(cs.getConfigSet)
                adp.refresh;
            end
        end


        adp.lock();
        switch(data.Type)
        case 'boolean'
            if isnumeric(value)||islogical(value)
                v={'off','on'};
                value=v{double(value+1)};
            end
        case{'numeric','int','integer','double'}
            if ischar(value)
                value=str2double(value);
            end
        end

        value=adp.errorCheck(cs,data,value);

        adp.setParamValue(param,value);



        adp.params=union(adp.params,pdata.FullName);
        adp.flush(false);

    catch ME
        adp.flush(false);
        rethrow(ME);
    end

    adp.inDialogUpdate=false;
