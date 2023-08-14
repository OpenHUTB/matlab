function RTWCPPFcnClass(obj)









    saveAsVersionObj=obj.ver;
    modelNameNoPath=obj.modelName;

    if isR2007bOrEarlier(saveAsVersionObj)
        try
            c=get_param(modelNameNoPath,'RTWCPPFcnClass');
            if~isempty(c)
                set_param(modelNameNoPath,'RTWCPPFcnClass',[]);
            end
        catch %#ok<CTCH>
            return;
        end
    end

    if isR2010a(saveAsVersionObj)||isR2009b(saveAsVersionObj)
        sets=getConfigSets(modelNameNoPath);

        for i=1:length(sets)
            CS=getConfigSet(modelNameNoPath,sets{i});
            if strcmp(get_param(CS,'CodeInterfacePackaging'),...
                'C++ class')

                cppComp=CS.getComponent('Code Generation').getComponent('Target').getComponent('CPPClassGenComp');

                if~isempty(cppComp)
                    mapping=Simulink.CodeMapping.get(obj.modelName,'CppModelMapping');
                    if~isempty(mapping)
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                        ,'GenerateExternalIOAccessMethods "',getGenerateIOAccessMethods10B(cppComp),'">']);
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair ExternalIOMemberVisibility "'...
                        ,mapping.DefaultsMapping.ExternalInportsMemberVisibility,'">']);
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair ParameterMemberVisibility "'...
                        ,mapping.DefaultsMapping.ParameterMemberVisibility,'">']);
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair GenerateParameterAccessMethods "'...
                        ,mapping.DefaultsMapping.GenerateParameterAccessMethods,'">']);
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair InternalMemberVisibility "'...
                        ,mapping.DefaultsMapping.InternalMemberVisibility,'">']);
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair GenerateInternalMemberAccessMethods "'...
                        ,mapping.DefaultsMapping.GenerateInternalMemberAccessMethods,'">']);
                    else
                        obj.appendRule(['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                        ,'GenerateExternalIOAccessMethods "',getGenerateIOAccessMethods10B(cppComp),'">']);
                    end
                end
            end
        end

    end

    if isR2009a(saveAsVersionObj)||isR2008b(saveAsVersionObj)||...
        isR2008a(saveAsVersionObj)
        sets=getConfigSets(modelNameNoPath);

        for i=1:length(sets)
            CS=getConfigSet(modelNameNoPath,sets{i});
            if strcmp(get_param(CS,'CodeInterfacePackaging'),...
                'C++ class')

                cppComp=CS.getComponent('Code Generation').getComponent('Target').getComponent('CPPClassGenComp');

                if~isempty(cppComp)
                    ioAccess=['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                    ,'GenerateIOAccessMethods "',getGenerateIOAccessMethods(cppComp),'">'];

                    dataMem=['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                    ,'GeneratePrivateDataMembers "',getGeneratePrivateDataMembers(cppComp),'">'];

                    paramAccess=['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                    ,'GenerateAccessMethods "',getGenerateAccessMethods(cppComp),'">'];

                    inlineAccess=['<Object<ClassName|Simulink.ERTCPPComponent>:insertpair '...
                    ,'InlineAccessMethods "',getInlineAccessMethods(cppComp),'">'];

                    opNew='<Simulink.ERTCPPComponent<UseOperatorNewForModelRefRegistration:remove>>';

                    obj.appendRules({ioAccess,dataMem,paramAccess,inlineAccess,opNew});
                end
            end
        end
    end

    if isR2013aOrEarlier(saveAsVersionObj)
        obj.appendRule('<RTW.ModelCPPArgsClass<ClassNamespace:remove>>');
        obj.appendRule('<RTW.ModelCPPVoidClass<ClassNamespace:remove>>');
    end

    if isR2015bOrEarlier(saveAsVersionObj)

        obj.appendRule('<RTW.ModelCPPDefaultClass:rename RTW.ModelCPPVoidClass>');
        obj.appendRule('<RTW.ModelCPPVoidClass<Array<RTW.CPPFcnArgSpec:rename RTW.CPPFcnVoidArgSpec>>>');
    end


    function val=getGeneratePrivateDataMembers(hCPPComp)
        val='off';
        if~strcmp(hCPPComp.ParameterMemberVisibility,'public')||...
            ~strcmp(hCPPComp.InternalMemberVisibility,'public')
            val='on';
        end


        function val=getGenerateAccessMethods(hCPPComp)
            val='off';
            if~strcmp(hCPPComp.GenerateParameterAccessMethods,'None')||...
                ~strcmp(hCPPComp.GenerateInternalMemberAccessMethods,'None')
                val='on';
            end


            function val=getInlineAccessMethods(hCPPComp)
                val='off';
                if strcmp(hCPPComp.GenerateParameterAccessMethods,'InlinedMethod')&&...
                    strcmp(hCPPComp.GenerateInternalMemberAccessMethods,'InlinedMethod')&&...
                    strcmp(hCPPComp.GenerateExternalIOAccessMethods,'InlinedMethod')
                    val='on';
                end


                function val=getGenerateIOAccessMethods(hCPPComp)
                    val='off';
                    if~strcmp(hCPPComp.GenerateExternalIOAccessMethods,'None')
                        val='on';
                    end



                    function val=getGenerateIOAccessMethods10B(hCPPComp)
                        val=hCPPComp.GenerateExternalIOAccessMethods;
                        if strcmp(hCPPComp.GenerateExternalIOAccessMethods,'Structure-based method')
                            val='Method';
                        elseif strcmp(hCPPComp.GenerateExternalIOAccessMethods,'Inlined structure-based method')
                            val='Inlined method';
                        end



