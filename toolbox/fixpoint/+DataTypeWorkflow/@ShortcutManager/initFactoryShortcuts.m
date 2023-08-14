function initFactoryShortcuts(this)




    this.FactoryShortcuts=Simulink.sdi.Map(char('a'),?handle);
    mlfbConversionEnabled=fxptui.isMATLABFunctionBlockConversionEnabled;



    fltptfactorySettingsBlkMap=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsMap=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsValueMap=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsValueMap.insert('DataTypeOverride','Double');
    fltptfactorySettingsValueMap.insert('DataTypeOverrideAppliesTo','AllNumericTypes');
    fltptfactorySettingsValueMap.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
    if mlfbConversionEnabled
        fltptfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal);
    end
    fltptfactorySettingsMap.insert(this.ModelName,fltptfactorySettingsValueMap);
    fltptfactorySettingsBlkMap.insert('SystemSettingMap',fltptfactorySettingsMap);

    fltptfactorySettingsGlobalMap=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsGlobalMap.insert('CaptureDTO',true);
    fltptfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
    fltptfactorySettingsGlobalMap.insert('ModifyDefaultRun',true);
    fltptfactorySettingsGlobalMap.insert('RunName',fxptui.message('lblDblOverrideRunNameWeb'));
    fltptfactorySettingsBlkMap.insert('GlobalModelSettings',fltptfactorySettingsGlobalMap);

    this.FactoryShortcuts.insert(fxptui.message('lblDblOverride'),fltptfactorySettingsBlkMap);



    fixptfactorySettingsBlkMap1=Simulink.sdi.Map(char('a'),?handle);
    fixptfactorySettingsMap=Simulink.sdi.Map(char('a'),?handle);
    fixptfactorySettingsValueMap1=Simulink.sdi.Map(char('a'),?handle);
    fixptfactorySettingsValueMap1.insert('DataTypeOverride','UseLocalSettings');
    fixptfactorySettingsValueMap1.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
    if mlfbConversionEnabled
        fixptfactorySettingsValueMap1.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint);
    end
    fixptfactorySettingsMap.insert(this.ModelName,fixptfactorySettingsValueMap1);
    fixptfactorySettingsBlkMap1.insert('SystemSettingMap',fixptfactorySettingsMap);

    fixptfactorySettingsGlobalMap1=Simulink.sdi.Map(char('a'),?handle);
    fixptfactorySettingsGlobalMap1.insert('CaptureDTO',true);
    fixptfactorySettingsGlobalMap1.insert('CaptureInstrumentation',true);
    fixptfactorySettingsGlobalMap1.insert('ModifyDefaultRun',true);
    fixptfactorySettingsGlobalMap1.insert('RunName',fxptui.message('lblFxptOverrideRunNameWeb'));
    fixptfactorySettingsBlkMap1.insert('GlobalModelSettings',fixptfactorySettingsGlobalMap1);

    this.FactoryShortcuts.insert(fxptui.message('lblFxptOverride'),fixptfactorySettingsBlkMap1);


    sglfltptfactorySettingsBlkMap=Simulink.sdi.Map(char('a'),?handle);
    sglfltptfactorySettingsMap=Simulink.sdi.Map(char('a'),?handle);
    sglfltptfactorySettingsValueMap=Simulink.sdi.Map(char('a'),?handle);
    sglfltptfactorySettingsValueMap.insert('DataTypeOverride','Single');
    sglfltptfactorySettingsValueMap.insert('DataTypeOverrideAppliesTo','AllNumericTypes');
    sglfltptfactorySettingsValueMap.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
    if mlfbConversionEnabled
        sglfltptfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal);
    end

    sglfltptfactorySettingsMap.insert(this.ModelName,sglfltptfactorySettingsValueMap);
    sglfltptfactorySettingsBlkMap.insert('SystemSettingMap',sglfltptfactorySettingsMap);


    sglfltptfactorySettingsGlobalMap=Simulink.sdi.Map(char('a'),?handle);
    sglfltptfactorySettingsGlobalMap.insert('CaptureDTO',true);
    sglfltptfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
    sglfltptfactorySettingsGlobalMap.insert('ModifyDefaultRun',true);
    sglfltptfactorySettingsGlobalMap.insert('RunName',fxptui.message('lblSglOverrideRunNameWeb'));
    sglfltptfactorySettingsBlkMap.insert('GlobalModelSettings',sglfltptfactorySettingsGlobalMap);

    this.FactoryShortcuts.insert(fxptui.message('lblSglOverride'),sglfltptfactorySettingsBlkMap);


    instrumentationfactorySettingsBlkMap=Simulink.sdi.Map(char('a'),?handle);
    instrumentationfactorySettingsMap=Simulink.sdi.Map(char('a'),?handle);
    instrumentationfactorySettingsValueMap=Simulink.sdi.Map(char('a'),?handle);
    instrumentationfactorySettingsValueMap.insert('MinMaxOverflowLogging','UseLocalSettings');
    instrumentationfactorySettingsMap.insert(this.ModelName,instrumentationfactorySettingsValueMap);
    instrumentationfactorySettingsBlkMap.insert('SystemSettingMap',instrumentationfactorySettingsMap);
    instrumentationfactorySettingsGlobalMap=Simulink.sdi.Map(char('a'),?handle);
    instrumentationfactorySettingsGlobalMap.insert('CaptureDTO',false);
    instrumentationfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
    instrumentationfactorySettingsGlobalMap.insert('ModifyDefaultRun',false);
    instrumentationfactorySettingsBlkMap.insert('GlobalModelSettings',instrumentationfactorySettingsGlobalMap);

    this.FactoryShortcuts.insert(fxptui.message('lblMMOOff'),instrumentationfactorySettingsBlkMap);

    dtoinstrumentationfactorySettingsBlkMap=Simulink.sdi.Map(char('a'),?handle);
    dtoinstrumentationfactorySettingsMap=Simulink.sdi.Map(char('a'),?handle);
    dtoinstrumentationfactorySettingsValueMap=Simulink.sdi.Map(char('a'),?handle);
    dtoinstrumentationfactorySettingsValueMap.insert('DataTypeOverride','UseLocalSettings');
    dtoinstrumentationfactorySettingsValueMap.insert('MinMaxOverflowLogging','UseLocalSettings');
    if mlfbConversionEnabled
        dtoinstrumentationfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint);
    end
    dtoinstrumentationfactorySettingsMap.insert(this.ModelName,dtoinstrumentationfactorySettingsValueMap);
    dtoinstrumentationfactorySettingsBlkMap.insert('SystemSettingMap',dtoinstrumentationfactorySettingsMap);

    dtoinstrumentationfactorySettingsGlobalMap=Simulink.sdi.Map(char('a'),?handle);
    dtoinstrumentationfactorySettingsGlobalMap.insert('CaptureDTO',true);
    dtoinstrumentationfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
    dtoinstrumentationfactorySettingsGlobalMap.insert('ModifyDefaultRun',false);
    dtoinstrumentationfactorySettingsBlkMap.insert('GlobalModelSettings',dtoinstrumentationfactorySettingsGlobalMap);

    this.FactoryShortcuts.insert(fxptui.message('lblDTOMMOOff'),dtoinstrumentationfactorySettingsBlkMap);

    fltptfactorySettingsBlkMap2=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsMap2=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsValueMap2=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsValueMap2.insert('DataTypeOverride','ScaledDouble');
    fltptfactorySettingsValueMap2.insert('DataTypeOverrideAppliesTo','AllNumericTypes');
    fltptfactorySettingsValueMap2.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
    fltptfactorySettingsMap2.insert(this.ModelName,fltptfactorySettingsValueMap2);
    fltptfactorySettingsBlkMap2.insert('SystemSettingMap',fltptfactorySettingsMap2);

    fltptfactorySettingsGlobalMap2=Simulink.sdi.Map(char('a'),?handle);
    fltptfactorySettingsGlobalMap2.insert('CaptureDTO',true);
    fltptfactorySettingsGlobalMap2.insert('CaptureInstrumentation',true);
    fltptfactorySettingsGlobalMap2.insert('ModifyDefaultRun',true);
    fltptfactorySettingsGlobalMap2.insert('RunName',fxptui.message('lblSclDblOverrideRunNameWeb'));
    fltptfactorySettingsBlkMap2.insert('GlobalModelSettings',fltptfactorySettingsGlobalMap2);

    this.FactoryShortcuts.insert(fxptui.message('lblSclDblOverride'),fltptfactorySettingsBlkMap2);

end


