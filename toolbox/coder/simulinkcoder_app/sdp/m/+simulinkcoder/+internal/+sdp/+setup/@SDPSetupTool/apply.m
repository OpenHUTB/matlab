function[success,errmsg]=apply(obj)


    success=true;
    errmsg='';

    refresher=coder.internal.toolstrip.util.Refresher(obj.studio);








    result=obj.preview;
    m=size(result);

    for i=1:m
        mdl=result{i,1};
        role=result{i,2};
        cgb=result{i,3};
        ecd=result{i,4};
        pf=result{i,5};
        dp=result{i,6};

        set_param(mdl,'CodeGenBehavior',cgb);

        if slfeature('FCPlatform')
            loc_setParam(mdl,'EmbeddedCoderDictionary',ecd);
        end

        if role>0
            coder.mapping.utils.create(mdl);
            mapping=Simulink.CodeMapping.getCurrentMapping(mdl);
            if dp==1
                type=simulinkcoder.internal.sdp.util.getCodeInterfaceType(ecd);
                if type==1
                    mapping.DeploymentType='Automatic';
                elseif type==2
                    mapping.DeploymentType='Component';
                end
            elseif dp==2
                mapping.DeploymentType='Subcomponent';
            end
        end

    end

    function loc_setParam(mdl,param,value)
        current=get_param(mdl,param);
        if~strcmp(current,value)
            cs=getActiveConfigSet(mdl);
            isRef=isa(cs,'Simulink.ConfigSetRef');
            if isRef
                warning(message('ToolstripCoderApp:sdpsetuptool:SDPSetupWarning_CSRef',mdl,param).getString);
            else
                set_param(mdl,param,value);
            end
        end

