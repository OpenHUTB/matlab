function schema()




mlock


    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomCC');


    hThisClass=schema.class(hCreateInPackage,'CPPComponent',hDeriveFromClass);

    if isempty(findtype('MemberVisibilityType'))
        schema.EnumType('MemberVisibilityType',{'public','private','protected'});
    end

    if isempty(findtype('InstPMemberVisibilityType'))
        schema.EnumType('InstPMemberVisibilityType',{'private','None'});
    end

    if isempty(findtype('ImplementationType'))
        schema.EnumType('ImplementationType',{'Structure reference','Class member'});
    end

    if isempty(findtype('AccessMethodType'))

        schema.EnumType('AccessMethodType',{'None','Method','Inlined method'});
    end

    if isempty(findtype('ExtIOAccessMethodType'))
        schema.EnumType('ExtIOAccessMethodType',{'None','Method','Inlined method',...
        'Structure-based method',...
        'Inlined structure-based method'});
    end



    hThisProp=schema.prop(hThisClass,'GeneratePrivateDataMembers','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.Visible='off';
    hThisProp.GetFunction=@getFcn_GeneratePrivateDataMembers;
    hThisProp.SetFunction=@setFcn_GeneratePrivateDataMembers;

    hThisProp=schema.prop(hThisClass,'GenerateAccessMethods','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.GetFunction=@getFcn_GenerateAccessMethods;
    hThisProp.SetFunction=@setFcn_GenerateAccessMethods;

    hThisProp=schema.prop(hThisClass,'GenerateDestructor','slbool');
    hThisProp.FactoryValue='on';

    hThisProp=schema.prop(hThisClass,'GenerateIOAccessMethods','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.GetFunction=@getFcn_GenerateIOAccessMethods;
    hThisProp.SetFunction=@setFcn_GenerateIOAccessMethods;

    hThisProp=schema.prop(hThisClass,'InlineAccessMethods','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';
    hThisProp.GetFunction=@getFcn_InlineAccessMethods;
    hThisProp.SetFunction=@setFcn_InlineAccessMethods;

    hThisProp=schema.prop(hThisClass,'ExternalIOMemberVisibility','MemberVisibilityType');
    hThisProp.FactoryValue='private';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_ExternalIOMemberVisibility;
    hThisProp.GetFunction=@getFcn_ExternalIOMemberVisibility;

    hThisProp=schema.prop(hThisClass,'GenerateExternalIOAccessMethods','ExtIOAccessMethodType');
    hThisProp.FactoryValue='Inlined structure-based method';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_GenerateExternalIOAccessMethods;
    hThisProp.GetFunction=@getFcn_GenerateExternalIOAccessMethods;

    hThisProp=schema.prop(hThisClass,'ParameterMemberVisibility','MemberVisibilityType');
    hThisProp.FactoryValue='private';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_ParameterMemberVisibility;
    hThisProp.GetFunction=@getFcn_ParameterMemberVisibility;

    hThisProp=schema.prop(hThisClass,'InternalMemberVisibility','MemberVisibilityType');
    hThisProp.FactoryValue='private';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_InternalMemberVisibility;
    hThisProp.GetFunction=@getFcn_InternalMemberVisibility;

    hThisProp=schema.prop(hThisClass,'GenerateParameterAccessMethods','AccessMethodType');
    hThisProp.FactoryValue='None';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_GenerateParameterAccessMethods;
    hThisProp.GetFunction=@getFcn_GenerateParameterAccessMethods;


    hThisProp=schema.prop(hThisClass,'GenerateInternalMemberAccessMethods','AccessMethodType');
    hThisProp.FactoryValue='None';
    if(~slfeature('CSClassInterfaceOptions'))
        hThisProp.AccessFlags.Serialize='on';
        hThisProp.Visible='off';
    end
    hThisProp.SetFunction=@setFcn_GenerateInternalMemberAccessMethods;
    hThisProp.GetFunction=@getFcn_GenerateInternalMemberAccessMethods;

    hThisProp=schema.prop(hThisClass,'UseOperatorNewForModelRefRegistration',...
    'slbool');
    hThisProp.FactoryValue='off';
    hThisProp.SetFunction=@setFcn_UseOperatorNewForModelRefRegistration;

    hThisProp=schema.prop(hThisClass,'IncludeModelTypesInModelClass','slbool');
    hThisProp.FactoryValue='on';





    hThisProp=schema.prop(hThisClass,'hasCachedValues','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheCodeInterfacePackaging','string');
    hThisProp.FactoryValue='Nonreusable function';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheGRTInterface','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheGenerateAllocFcn','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheCombineOutputUpdateFcns','slbool');
    hThisProp.FactoryValue='on';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheIncludeMdlTerminateFcn','slbool');
    hThisProp.FactoryValue='on';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheRTWCAPISignals','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheRTWCAPIParams','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheExtMode','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheGenerateASAP2','slbool');
    hThisProp.FactoryValue='off';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheRTWCPPFcnClass','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';



    hThisProp=schema.prop(hThisClass,'cacheCustomFileTem','string');
    hThisProp.FactoryValue='example_file_process.tlc';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'cacheRootIOFormat','string');
    hThisProp.FactoryValue='Structure reference';
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.Visible='off';
    hThisProp.AccessFlags.Copy='off';

    hPreSetListener=handle.listener(hThisClass,hThisClass.Properties,'PropertyPreSet',...
    @preSetFcn_Prop);
    schema.prop(hThisProp,'PreSetListener','handle');
    hThisProp.PreSetListener=hPreSetListener;





    m=schema.method(hThisClass,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'attachCPPComponent','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'detachCPPComponent','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'restoreCodeInterfacePackaging','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'convertERTCPPComponent','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'attachTempRTWCPPFcnClass','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'clearTempRTWCPPFcnClass','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'skipModelReferenceComparison');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'upgrade');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};












    function preSetFcn_Prop(hProp,eventData)

        hObj=eventData.AffectedObject;
        if~isequal(get(hObj,hProp.Name),eventData.NewVal)
            target=hObj.getParent();
            if~isempty(target)
                assert(isa(target,'Simulink.ERTTargetCC')||isa(target,'Simulink.GRTTargetCC'));
                target.dirtyHostBD;
            end
        end

        function currVal=getFcn_GeneratePrivateDataMembers(h,currVal)
            if strcmpi(get_param(h,'InMdlLoading'),'on')
                if strcmp(currVal,'off')


                    h.ParameterMemberVisibility='public';
                    h.InternalMemberVisibility='public';
                end




            elseif strcmp(h.ParameterMemberVisibility,'private')&&...
                strcmp(h.InternalMemberVisibility,'private')
                currVal='on';
            else
                currVal='off';
            end

            function newVal=setFcn_GeneratePrivateDataMembers(h,val)

                if strcmpi(get_param(h,'InMdlLoading'),'off')
                    MSLDiagnostic('RTW:configSet:ERTDialogCPPParamRemovalWarnTwo',...
                    'GeneratePrivateDataMembers',...
                    'ParameterMemberVisibility',...
                    'InternalMemberVisibility').reportAsWarning;
                    if~strcmpi(val,'off')
                        h.ParameterMemberVisibility='private';
                        h.InternalMemberVisibility='private';
                    else
                        h.ParameterMemberVisibility='public';
                        h.InternalMemberVisibility='public';
                    end

                else
                    if~strcmpi(val,'off')
                        h.ParameterMemberVisibility='private';
                        h.InternalMemberVisibility='private';
                    else
                        h.ParameterMemberVisibility='public';
                        h.InternalMemberVisibility='public';
                    end

                end
                newVal=val;

                function currVal=getFcn_GenerateAccessMethods(h,currVal)

                    if strcmpi(get_param(h,'InMdlLoading'),'on')
                        if strcmp(currVal,'off')
                            h.GenerateParameterAccessMethods='None';
                            h.GenerateInternalMemberAccessMethods='None';
                        end
                    elseif~strcmp(h.GenerateParameterAccessMethods,'None')&&...
                        ~strcmp(h.GenerateInternalMemberAccessMethods,'None')
                        currVal='on';
                    else
                        currVal='off';
                    end

                    function newVal=setFcn_GenerateAccessMethods(h,val)
                        if strcmpi(get_param(h,'InMdlLoading'),'off')
                            MSLDiagnostic('RTW:configSet:ERTDialogCPPParamRemovalWarnThree',...
                            'GenerateAccessMethods',...
                            'GenerateParameterAccessMethods',...
                            'GenerateInternalMemberAccessMethods',...
                            'GenerateExternalIOAccessMethods').reportAsWarning;
                            if strcmpi(val,'on')
                                tmpVal='Method';



                                h.GenerateParameterAccessMethods=tmpVal;
                                h.GenerateInternalMemberAccessMethods=tmpVal;
                            else
                                h.GenerateParameterAccessMethods='None';
                                h.GenerateInternalMemberAccessMethods='None';
                            end


                        else
                            if strcmpi(val,'on')
                                tmpVal='Method';



                                h.GenerateParameterAccessMethods=tmpVal;
                                h.GenerateInternalMemberAccessMethods=tmpVal;
                            else
                                h.GenerateParameterAccessMethods='None';
                                h.GenerateInternalMemberAccessMethods='None';
                            end

                        end
                        newVal=val;

                        function currVal=getFcn_GenerateIOAccessMethods(h,currVal)
                            if strcmpi(get_param(h,'InMdlLoading'),'on')
                                if strcmp(currVal,'off')
                                    h.GenerateExternalIOAccessMethods='None';
                                end
                            elseif~strcmp(h.GenerateExternalIOAccessMethods,'None')
                                currVal='on';
                            else
                                currVal='off';
                            end


                            function newVal=setFcn_GenerateIOAccessMethods(h,val)
                                if strcmpi(get_param(h,'InMdlLoading'),'off')

                                    MSLDiagnostic('RTW:configSet:ERTDialogCPPParamRemovalWarnOne',...
                                    'GenerateIOAccessMethods',...
                                    'GenerateExternalIOAccessMethods').reportAsWarning;
                                    if strcmpi(val,'on')
                                        h.GenerateExternalIOAccessMethods='Method';
                                    else
                                        h.GenerateExternalIOAccessMethods='None';
                                    end

                                else
                                    if strcmpi(val,'on')
                                        h.GenerateExternalIOAccessMethods='Method';
                                    else
                                        h.GenerateExternalIOAccessMethods='None';
                                    end
                                end
                                newVal=val;


                                function currVal=getFcn_InlineAccessMethods(h,currVal)
                                    if strcmpi(get_param(h,'InMdlLoading'),'off')
                                        if strcmp(h.GenerateParameterAccessMethods,'Inlined method')&&...
                                            strcmp(h.GenerateInternalMemberAccessMethods,'Inlined method')&&...
                                            (strcmp(h.GenerateExternalIOAccessMethods,'Inlined method')||...
                                            strcmp(h.GenerateExternalIOAccessMethods,'Inlined structure-based method'))
                                            currVal='on';
                                        else
                                            currVal='off';
                                        end
                                    end


                                    function newVal=setFcn_InlineAccessMethods(h,val)
                                        if strcmpi(get_param(h,'InMdlLoading'),'off')
                                            MSLDiagnostic('RTW:configSet:ERTDialogCPPParamRemovalWarnThree',...
                                            'InlineAccessMethods',...
                                            'GenerateParameterAccessMethods',...
                                            'GenerateInternalMemberAccessMethods',...
                                            'GenerateExternalIOAccessMethods').reportAsWarning;
                                            if strcmpi(val,'on')
                                                tmpVal='Inlined method';
                                                if~strcmp(h.GenerateParameterAccessMethods,'None')
                                                    h.GenerateParameterAccessMethods=tmpVal;
                                                end
                                                if~strcmp(h.GenerateInternalMemberAccessMethods,'None')
                                                    h.GenerateInternalMemberAccessMethods=tmpVal;
                                                end
                                                if~strcmp(h.GenerateExternalIOAccessMethods,'None')
                                                    h.GenerateExternalIOAccessMethods=tmpVal;
                                                end
                                            end

                                        else
                                            if strcmpi(val,'on')
                                                tmpVal='Inlined method';
                                                if~strcmp(h.GenerateParameterAccessMethods,'None')
                                                    h.GenerateParameterAccessMethods=tmpVal;
                                                end
                                                if~strcmp(h.GenerateInternalMemberAccessMethods,'None')
                                                    h.GenerateInternalMemberAccessMethods=tmpVal;
                                                end
                                                if~strcmp(h.GenerateExternalIOAccessMethods,'None')
                                                    h.GenerateExternalIOAccessMethods=tmpVal;
                                                end
                                            end
                                        end
                                        newVal=val;

                                        function newVal=setFcn_UseOperatorNewForModelRefRegistration(h,val)

                                            if~slfeature('DisableZeroInitForCppEncap')
                                                cs=h.getConfigSet;
                                                if~isempty(cs)&&strcmpi(val,'on')
                                                    cs.set_param('ZeroInternalMemoryAtStartup','on');
                                                end
                                            end
                                            newVal=val;


                                            function newVal=setFcn_GenerateParameterAccessMethods(h,val)
                                                newVal=loc_setParam(h,val,'GenerateParameterAccessMethods');

                                                function curVal=getFcn_GenerateParameterAccessMethods(h,val)
                                                    mcosGetFunction=@(mapping)mapping.DefaultsMapping.GenerateParameterAccessMethods;
                                                    curVal=loc_getParam(h,val,mcosGetFunction);

                                                    function newVal=setFcn_ParameterMemberVisibility(h,val)
                                                        newVal=loc_setParam(h,val,'ParameterMemberVisibility');

                                                        function curVal=getFcn_ParameterMemberVisibility(h,val)
                                                            mcosGetFunction=@(mapping)mapping.DefaultsMapping.ParameterMemberVisibility;
                                                            curVal=loc_getParam(h,val,mcosGetFunction);

                                                            function newVal=setFcn_InternalMemberVisibility(h,val)
                                                                newVal=loc_setParam(h,val,'InternalMemberVisibility');

                                                                function curVal=getFcn_InternalMemberVisibility(h,val)
                                                                    mcosGetFunction=@(mapping)mapping.DefaultsMapping.InternalMemberVisibility;
                                                                    curVal=loc_getParam(h,val,mcosGetFunction);

                                                                    function newVal=setFcn_GenerateInternalMemberAccessMethods(h,val)
                                                                        newVal=loc_setParam(h,val,'GenerateInternalMemberAccessMethods');

                                                                        function curVal=getFcn_GenerateInternalMemberAccessMethods(h,val)
                                                                            mcosGetFunction=@(mapping)mapping.DefaultsMapping.GenerateInternalMemberAccessMethods;
                                                                            curVal=loc_getParam(h,val,mcosGetFunction);


                                                                            function newVal=setFcn_GenerateExternalIOAccessMethods(h,val)

                                                                                cs=h.getConfigSet;
                                                                                if~isempty(cs)&&strcmp(val,'None')
                                                                                    cs.set_param('ExternalIOMemberVisibility','public');
                                                                                end
                                                                                newVal=loc_setParam(h,val,'GenerateExternalIOAccessMethods');

                                                                                function curVal=getFcn_GenerateExternalIOAccessMethods(h,val)
                                                                                    mcosGetFunction=@(mapping)mapping.DefaultsMapping.GenerateExternalInportsAccessMethods;
                                                                                    curVal=loc_getParam(h,val,mcosGetFunction);

                                                                                    function newVal=setFcn_ExternalIOMemberVisibility(h,val)

                                                                                        cs=h.getConfigSet();
                                                                                        if~isempty(cs)&&...
                                                                                            ~strcmp(val,'public')&&...
                                                                                            strcmp(cs.get_param('GenerateExternalIOAccessMethods'),'None')
                                                                                            DAStudio.error('RTW:configSet:CannotChangeExternalIOMemberVisibility');
                                                                                        end
                                                                                        newVal=loc_setParam(h,val,'ExternalIOMemberVisibility');

                                                                                        function curVal=getFcn_ExternalIOMemberVisibility(h,val)
                                                                                            mcosGetFunction=@(mapping)mapping.DefaultsMapping.ExternalInportsMemberVisibility;
                                                                                            curVal=loc_getParam(h,val,mcosGetFunction);

                                                                                            function curVal=loc_getParam(h,val,mcosGetFcn)
                                                                                                modelHandle=h.getModel();
                                                                                                if~isempty(modelHandle)
                                                                                                    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelHandle);
                                                                                                    if strcmp(mappingType,'CppModelMapping')&&~isempty(mapping)
                                                                                                        curVal=mcosGetFcn(mapping);
                                                                                                    else
                                                                                                        curVal=val;
                                                                                                    end
                                                                                                else
                                                                                                    curVal=val;
                                                                                                end

                                                                                                function newVal=loc_setParam(h,val,csParamStr)
                                                                                                    modelHandle=h.getModel();
                                                                                                    if~isempty(modelHandle)
                                                                                                        [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelHandle);
                                                                                                        if strcmp(mappingType,'CppModelMapping')&&~isempty(mapping)
                                                                                                            activeConfigSet=getActiveConfigSet(modelHandle);
                                                                                                            if~isa(activeConfigSet,'ConfigSetRef')
                                                                                                                mapping.DefaultsMapping.setMappingByConfigsetKVP(csParamStr,val);
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                    newVal=val;




