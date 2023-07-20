function[status,errorid]=applyproperties(this,dlghandle)







    status=true;
    errorid='';
    ok=true;

    me=TflDesigner.getexplorer;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ApplyingChangesStatusMsg'));
    me.getRoot.iseditorbusy=true;
    wasDirty=this.parentnode.isDirty;
    needupdate=true;

    try
        if needupdate
            this.isValid=false;
            this.parentnode.isDirty=true;
            this.isDirty=true;

            if strcmpi(this.getkeyentries{dlghandle.getWidgetValue('Tfldesigner_Key')+1},'Custom')
                this.object.Key=dlghandle.getWidgetValue('Tfldesigner_CustomFunc');
                this.Name=this.object.Key;
            end

            if dlghandle.isEnabled('Tfldesigner_AlgorithmInfo')
                this.setPropValue('AlgorithmInfo',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_AlgorithmInfo')));
            end

            if dlghandle.isEnabled('Tfldesigner_AddMinusAlgorithm')
                this.setPropValue('AddMinusAlgorithm',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_AddMinusAlgorithm')));
            end

            if dlghandle.isEnabled('Tfldesigner_TIMER_CountDirection')
                this.setPropValue('CountDirection',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_TIMER_CountDirection')));
            end

            if dlghandle.isEnabled('Tfldesigner_TIMER_Ticks')
                this.setPropValue('TicksPerSecond',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_TIMER_Ticks')));
            end

            if dlghandle.isEnabled('Tfldesigner_FIR2D_OutputMode')
                this.setPropValue('FIR2D_OutputMode',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_OutputMode')));
                this.setPropValue('FIR2D_NumInRows',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumInRows')));
                this.setPropValue('FIR2D_NumInCols',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumInCols')));
                this.setPropValue('FIR2D_NumOutRows',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumOutRows')));
                this.setPropValue('FIR2D_NumOutCols',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumOutCols')));
                this.setPropValue('FIR2D_NumMaskRows',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumMaskRows')));
                this.setPropValue('FIR2D_NumMaskCols',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FIR2D_NumMaskCols')));
            end

            tagList={'Tfldesigner_IntrpMethod_AlgoParam',...
            'Tfldesigner_ExtrpMethod_AlgoParam',...
            'Tfldesigner_IndexSearchMethod',...
            'Tfldesigner_RemoveProtection',...
            'Tfldesigner_RemoveProtectionIndex',...
            'Tfldesigner_SupportTunableTable',...
            'Tfldesigner_InputSelectObjectTable',...
            'Tfldesigner_TableDimension',...
            'Tfldesigner_UseLastTableValue',...
            'Tfldesigner_ValidIndexReachLast',...
            'Tfldesigner_UseLastBreakpoint',...
            'Tfldesigner_BeginIndexSearchUsingPreviousIndexResult',...
            'Tfldesigner_SatMethod',...
            'Tfldesigner_RoundMethod',...
            'Tfldesigner_UseRowMajorAlgorithm',...
            'Tfldesigner_AngleUnit_AlgoParam'};
            for i=1:length(tagList)
                if~dlghandle.isEnabled(tagList{i})
                    continue;
                end
                widgetValue=dlghandle.getWidgetValue(tagList{i});
                this.setPropValue(this.getBlockPropertyFromTag(tagList{i}),widgetValue);
            end
            if~isempty(this.apSet)&&isa(this.object,'RTW.TflCFunctionEntry')
                this.object.setAlgorithmParameters(this.apSet);
            end

            if isa(this.object,'RTW.TflCSemaphoreEntry')
                this.setPropValue('EntryTag',...
                dlghandle.getWidgetValue('Tfldesigner_DWorkEntryTag'));
            end

            if dlghandle.isEnabled('Tfldesigner_CONVCORR1D_NumIn1Rows')
                this.setPropValue('CONVCORR1D_NumIn1Rows',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_CONVCORR1D_NumIn1Rows')));
                this.setPropValue('CONVCORR1D_NumIn2Rows',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_CONVCORR1D_NumIn2Rows')));
            end

            if dlghandle.isEnabled('Tfldesigner_LOOKUP_SearchMethod')
                this.setPropValue('LOOKUP_SearchMethod',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_LOOKUP_SearchMethod')));
                this.setPropValue('LOOKUP_IntrpMethod',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_LOOKUP_IntrpMethod')));
                this.setPropValue('LOOKUP_ExtrpMethod',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_LOOKUP_ExtrpMethod')));
            end

            if dlghandle.isEnabled('Tfldesigner_FLmustbesame')
                this.setPropValue('SlopesMustBeTheSame',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FLmustbesame')));
                this.setPropValue('MustHaveZeroNetBias',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_FLmustbesame')));
            end

            if dlghandle.isEnabled('Tfldesigner_Netslopeadjustfac')
                this.setPropValue('NetSlopeAdjustmentFactor',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_Netslopeadjustfac')));
                this.setPropValue('NetFixedExponent',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_Netfixedexponent')));
            end

            if dlghandle.isEnabled('Tfldesigner_SameSlopeFunction')
                this.setPropValue('SlopesMustBeTheSame',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_SameSlopeFunction')));
                this.setPropValue('BiasMustBeTheSame',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_SameBiasFunction')));
            end

            if dlghandle.isEnabled('Tfldesigner_ArrayLayout')
                this.setPropValue('ArrayLayout',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_ArrayLayout')));
            end

            if dlghandle.isEnabled('Tfldesigner_AllowShapeAgnosticMatch')
                this.setPropValue('AllowShapeAgnosticMatch',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_AllowShapeAgnosticMatch')));
            end
            if strcmp(this.EntryType,'RTW.TflCustomization')
                this.setPropValue('InlineFcn',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_InlineFcn')));
                this.setPropValue('Precise',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_Precise')));
                this.setPropValue('SupportNonFinite',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_SupportNonFinite')));
                this.setPropValue('ImplementationCallback',...
                dlghandle.getWidgetValue('Tfldesigner_EMLCallback'));
            else
                this.setPropValue('SaturationMode',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_SaturationMode')));
                this.setPropValue('RoundingMode',...
                num2str(dlghandle.getWidgetValue('Tfldesigner_RoundingMode')));
            end

            [~,~,ext]=fileparts(this.parentnode.Name);

            if~strcmpi(this.parentnode.Name,'HitCache')&&...
                ~strcmpi(this.parentnode.Name,'MissCache')&&...
                ~strcmpi(this.parentnode.Name,'TLCCallList')&&...
                ~strcmpi(ext,'.mat')&&~strcmpi(ext,'.p')


                if~isempty(this.object.ConceptualArgs)
                    [status,errorid]=this.applyconceptargchanges(dlghandle);
                    ok=status;
                end

                if~strcmp(this.EntryType,'RTW.TflCustomization')
                    if ok
                        this.setPropValue('ImplementationName',...
                        dlghandle.getWidgetValue('Tfldesigner_Implementationname'));
                        this.setPropValue('AcceptExprInput',num2str(dlghandle.getWidgetValue('Tfldesigner_ExprInput')));

                        isReturnArgEmpty=isempty(this.object.Implementation.Return);
                        hasSideEffects=dlghandle.getWidgetValue('Tfldesigner_SideEffects');
                        this.setPropValue('SideEffects',num2str(hasSideEffects));


                        if~isempty(this.object.Implementation.Arguments)||~isReturnArgEmpty
                            [status,errorid]=this.applyimplargchanges(dlghandle);
                            ok=status;
                            copysettings=dlghandle.getWidgetValue('Tfldesigner_CopyConcepArgSettings');
                            if copysettings
                                this.copyConceptualArgsSettings;
                                this.copyconcepargsettings=3;
                            else
                                this.copyconcepargsettings=0;
                            end
                        end
                    end


                    if ok
                        [status,errorid]=this.applybuildinfochanges(dlghandle);
                        ok=status;
                    end
                end
            else
                if~isempty(this.object.ConceptualArgs)
                    this.activeconceptarg=dlghandle.getWidgetValue('Tfldesigner_ActiveConceptArg')+1;
                    classtype=class(this.object.ConceptualArgs(this.activeconceptarg));

                    if strcmpi(classtype,'RTW.TflArgPointer')
                        this.argtype=2;
                    elseif strcmpi(classtype,'RTW.TflArgMatrix')
                        this.argtype=1;
                    else
                        this.argtype=0;
                    end
                end
                if~strcmp(this.EntryType,'RTW.TflCustomization')
                    if~isempty(this.object.Implementation.Arguments)||...
                        ~isempty(this.object.Implementation.Return)
                        this.activeimplarg=dlghandle.getWidgetValue('Tfldesigner_ImplfuncArglist');
                    end
                end
            end
            if ok
                dlghandle.refresh;
            end
        end
    catch ME
        status=false;
        errorid=ME.message;
        this.applyerrorlog=errorid;
        me.getRoot.iseditorbusy=false;
    end

    me.getRoot.iseditorbusy=false;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    this.firepropertychanged;

    if~wasDirty&&needupdate
        this.parentnode.firehierarchychanged;
    end

    dlghandle.refresh;





