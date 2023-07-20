function update(hSrc,event)





    configset.ert.update(hSrc,event);


    switch event
    case 'attach'

        registerPropList(hSrc,'NoDuplicate','All',[]);
    case{'switch_target','activate'}
        cs=hSrc.getConfigSet;
        if~isempty(cs)
            customizeConfigSetParameters(cs)

            if strcmp(event,'switch_target')

                setDefaultValues(cs);
            end
        end
    otherwise

    end
end

function customizeConfigSetParameters(cs)






    loc_setValueAndEnableParam(cs,'AutosarCompliant',true,0)


    loc_setValueAndEnableParam(cs,'EmbeddedCoderDictionary','',0);


    loc_setValueAndEnableParam(cs,'TargetLang','C++',0);

    loc_setValueAndEnableParam(cs,'SimTargetLang','C++',0);


    loc_setValueAndEnableParam(cs,'TargetLangStandard','C++11',1);


    loc_setValueAndEnableParam(cs,'CodeInterfacePackaging','C++ class',0);
    loc_setValueAndEnableParam(cs,'CPPClassGenCompliant','on',0);



    loc_enableParam(cs,'SupportComplex',1);



    loc_enableParam(cs,'SupportAbsoluteTime',1);


    loc_setValueAndEnableParam(cs,'SupportContinuousTime','off',0);
    loc_setValueAndEnableParam(cs,'ZeroExternalMemoryAtStartup','off',0);
    loc_setValueAndEnableParam(cs,'CombineOutputUpdateFcns','on',0);
    loc_setValueAndEnableParam(cs,'GenerateSampleERTMain','off',0);
    loc_setValueAndEnableParam(cs,'TargetOS','BareBoardExample',0);
    loc_setValueAndEnableParam(cs,'MatFileLogging','off',0);
    loc_setValueAndEnableParam(cs,'GRTInterface','off',0);
    loc_setValueAndEnableParam(cs,'SupportNonInlinedSFcns','off',0);
    loc_setValueAndEnableParam(cs,'SuppressErrorStatus','on',0);
    loc_setValueAndEnableParam(cs,'ModelStepFunctionPrototypeControlCompliant','off',0);
    loc_setValueAndEnableParam(cs,'CompOptLevelCompliant','on',0);
    loc_setValueAndEnableParam(cs,'ParMdlRefBuildCompliant','on',0);
    loc_setValueAndEnableParam(cs,'ERTFirstTimeCompliant','on',0);
    loc_setValueAndEnableParam(cs,'GenCodeOnly','on',0);


    loc_enableParam(cs,'ModelReferenceCompliant',1);
    loc_enableParam(cs,'CreateSILPILBlock',1);
    loc_enableParam(cs,'IncludeERTFirstTime',1);
    loc_enableParam(cs,'SupportVariableSizeSignals',1);


    loc_setValueAndEnableParam(cs,'RootIOFormat','Structure Reference',0);


    loc_enableParam(cs,'ZeroInternalMemoryAtStartup',1);


    loc_enableParam(cs,'InitFltsAndDblsToZero',1);


    loc_setValueAndEnableParam(cs,'GenerateAllocFcn','off',0);


    loc_setValueAndEnableParam(cs,'MultiInstanceErrorCode','Error',0);


    loc_setValueAndEnableParam(cs,'IncludeMdlTerminateFcn','on',1);


    loc_enableParam(cs,'MultiInstanceERTCode',1);


    loc_setValueAndEnableParam(cs,'ConcurrentExecutionCompliant','on',0);


    loc_enableParam(cs,'Toolchain',1);



    loc_setValueAndEnableParam(cs,'UseToolchainInfoCompliant','on',1);




    cs.setProp('LookupTableObjectStructAxisOrder','2,1,3,4,...');




    loc_setValueAndEnableParam(cs,'LUTObjectStructOrderExplicitValues','Size,Breakpoints,Table',0);




    loc_setValueAndEnableParam(cs,'LUTObjectStructOrderEvenSpacing','Size,Table,Breakpoints',0);



    loc_setValueAndEnableParam(cs,'GenerateExternalIOAccessMethods','None',0);
    loc_setValueAndEnableParam(cs,'ExternalIOMemberVisibility','public',0);
end

function setDefaultValues(cs)




    loc_setValueAndEnableParam(cs,'Toolchain','AUTOSAR Adaptive | CMake',1);


    loc_setValueAndEnableParam(cs,'SupportAbsoluteTime','on',1);



    loc_setValueAndEnableParam(cs,'SimGenImportedTypeDefs','on',1);



    loc_setValueAndEnableParam(cs,'MaxIdLength',63,1);


    loc_setValueAndEnableParam(cs,'ModelReferenceCompliant','on',1);
    loc_setValueAndEnableParam(cs,'CreateSILPILBlock','None',1);
    loc_setValueAndEnableParam(cs,'IncludeERTFirstTime','off',1);
    loc_setValueAndEnableParam(cs,'SupportNonFinite','off',1);


    loc_setValueAndEnableParam(cs,'ArrayContainerType','std::array',1);
end


function loc_setValueAndEnableParam(cs,paramName,value,enable)

    cs.setPropEnabled(paramName,true);
    cs.setProp(paramName,value);
    loc_enableParam(cs,paramName,enable);
end

function loc_enableParam(cs,paramName,enable)

    cs.setPropEnabled(paramName,enable);
end


