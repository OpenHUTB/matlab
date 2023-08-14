function getExtensionUpdate(hObj,event)









































    cs=hObj.getConfigSet();
    if isempty(cs),return;end
    model=cs.getModel();

    switch(event)
    case{'pre-activate','deactivate','attach','update_host_model'}

    case 'deselect_target'
        dirtyBit=get_param(model,'Dirty');
        set_param(model,'PostCodeGenCommand','');
        setValAndEnForce(cs,'ProdLongLongMode',get_param(cs,'ProdLongLongMode'),true);
        setValAndEnForce(cs,'ProdHWDeviceType',get_param(cs,'ProdHWDeviceType'),true);
        set_param(model,'Dirty',dirtyBit);

    case{'switch_target','activate'}







        dirtyBit=get_param(model,'Dirty');




        setValAndEn(cs,'GenerateCodeInfo','on',false);

        set_param(model,'PostCodeGenCommand',...
        'tlmgenerator_hookpoints(''post_code_gen'', modelName, '''', '''', '''', '''', buildInfo)');


        setValAndEn(cs,'SolverMode','SingleTasking',false);






        setValAndEn(cs,'InlineParams','on',false);


        setValAndEn(cs,'UnconnectedInputMsg','error',false);
        setValAndEn(cs,'UnconnectedOutputMsg','error',false);
        setValAndEn(cs,'UnconnectedLineMsg','error',false);








        try
            CCList=get_param(model,'tlmgCompilerSelectDetected');
            CCSelect=get_param(model,'tlmgCompilerSelect');
            if~any(strcmp(CCSelect,CCList))
                set_param(model,'tlmgCompilerSelect',CCList{1});
            end
        catch
        end

        try
            targetOSSelect=get_param(model,'tlmgTargetOSSelect');
        catch
            targetOSSelect='';
        end

        if(strcmp(targetOSSelect,'Linux 64'))
            setParamAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Linux 64)',false);

        elseif(strcmp(targetOSSelect,'Windows 64'))
            setParamAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Windows64)',false);
        else
            l_host=computer;
            if(strcmp(l_host,'GLNXA64'))
                setParamAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Linux 64)',false);
            elseif(strcmp(l_host,'PCWIN64'))
                setParamAndEnForce(cs,'ProdHWDeviceType','Intel->x86-64 (Windows64)',false);
            end
        end

        setParamAndEnForce(cs,'ProdLongLongMode','on',false);


        setValAndEnForce(cs,'TargetUnknown','off',false);
        setValAndEnForce(cs,'ProdEqTarget','on',false);




        setValAndEn(cs,'TargetLang','C++',false);
        setValAndEn(cs,'TargetLangStandard','C89/C90 (ANSI)',false);
        setValAndEn(cs,'CodeInterfacePackaging','Nonreusable function',false);
        setValAndEn(cs,'TLCOptions','',false);
        setValAndEn(cs,'GenerateMakefile','off',false);
        setValAndEn(cs,'GenCodeOnly','on',false);

















        setValAndEn(cs,'CodeReplacementLibrary','None',false);
        setValAndEn(cs,'UtilityFuncGeneration','Auto',false);
        setValAndEn(cs,'IncludeMdlTerminateFcn','on',false);

        setValAndEn(cs,'CodeInterfacePackaging','Reusable function',false);
        setValAndEnForce(cs,'MultiInstanceERTCode','on',false);
        setValAndEnForce(cs,'MultiInstanceErrorCode','Error',true);
        setValAndEn(cs,'CombineOutputUpdateFcns','on',false);
        setValAndEn(cs,'GRTInterface','off',false);
        setValAndEn(cs,'IncludeERTFirstTime','off',false);
        setValAndEn(cs,'GenerateSampleERTMain','off',false);


        setValAndEnForce(cs,'ZeroExternalMemoryAtStartup','on',false);
        setValAndEnForce(cs,'ZeroInternalMemoryAtStartup','on',false);



        setValAndEnForce(cs,'SignalLoggingSaveFormat','Dataset',false);


        set_param(model,'Dirty',dirtyBit);
    end
end





function setValAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        cs.setProp(prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end

function setValAndEnForce(cs,prop,val,en)
    cs.setPropEnabled(prop,true);
    setValAndEn(cs,prop,val,en);
end

function setParamAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        set_param(cs,prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end

function setParamAndEnForce(cs,prop,val,en)
    cs.setPropEnabled(prop,true);
    setParamAndEn(cs,prop,val,en);
end






















































