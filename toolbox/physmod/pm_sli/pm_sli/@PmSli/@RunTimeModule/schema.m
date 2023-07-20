function schema







    mlock;

    doTrace(false);
    if doDebug(false)
        visibleParam='on';
    else
        visibleParam='off';
    end




    load_simulink;

    pkg=findpackage('PmSli');
    c=schema.class(pkg,'RunTimeModule');






    if isempty(findtype('PmSli_RTM_DialogParameterType'))
        schema.EnumType('PmSli_RTM_DialogParameterType',...
        doGetDialogParameterTypeValues);
    end


    if isempty(findtype('PmSli_RTM_EditingModeType'))
        schema.EnumType('PmSli_RTM_EditingModeType',...
        doGetEditingModeTypeValues);
    end


    if isempty(findtype('PmSli_RTM_PreferredLoadModeType'))
        schema.EnumType('PmSli_RTM_PreferredLoadModeType',...
        doGetPreferredLoadModeTypeValues);
    end


    if isempty(findtype('PmSli_CallbackType'))
        schema.EnumType('PmSli_CallbackType',...
        {...
        'BLK_POSTLOAD',...
        'BLK_POSTCOPY',...
        'BLK_PRECOPY',...
        'BLK_POSTDELETE',...
        'BLK_PREDELETE',...
        'BLK_PRESAVE',...
        'BLK_POSTSAVE',...
        'BLK_PRECOMPILE',...
        'BLK_OPENDLG',...
        'MODEL_CLOSE',...
...
        'DOM_INIT',...
...
        'CCC_ACTIVATE',...
        'CCC_DEACTIVATE',...
...
'SLM_SELECTMODE'...
        });
    end






    m=schema.method(c,'canPerformOperation');
    s=m.Signature;
    s.Varargin='on';
    s.InputTypes={'handle',...
    'mxArray',...
    'PmSli_CallbackType',...
'mxArray'...
    };
    s.OutputTypes={'bool'...
    };



    m=schema.method(c,'isParameterEnabled');
    s=m.Signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
    'mxArray',...
'PmSli_RTM_DialogParameterType'...
    };
    s.OutputTypes={'bool'...
    };





    m=schema.method(c,'getModelEditingMode','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'mxArray',...
    };
    s.OutputTypes={'PmSli_RTM_EditingModeType',...
'bool'
    };


    m=schema.method(c,'setModelEditingMode');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
    'mxArray',...
'PmSli_RTM_EditingModeType'...
    };
    s.OutputTypes={'bool'...
    };




    m=schema.method(c,'update','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'string',...
'mxArray'...
    };
    s.OutputTypes={'bool'...
    };







    m=schema.method(c,'denyProductLicense','static');
    s=m.signature;
    s.Varargin='on';
    s.InputTypes={'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };



    m=schema.method(c,'getParamTypeEnum','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'string'...
    };
    s.OutputTypes={'PmSli_RTM_DialogParameterType'...
    };



    m=schema.method(c,'setPreferredLoadMode','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'PmSli_RTM_PreferredLoadModeType'...
    };
    s.OutputTypes={...
    };



    m=schema.method(c,'getPreferredLoadMode','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'PmSli_RTM_PreferredLoadModeType'...
    };


    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'MATLAB array'...
    };


    fgPkg=findpackage('DAStudio');
    m=schema.method(c,'getSlMenuCustomization','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'DAStudio.CallbackInfo'...
    };
    s.OutputTypes={'DAStudio.ToolSchema'...
    };


    m=schema.method(c,'blockGetParameterModes','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(c,'getInstance','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'handle'...
    };


    m=schema.method(c,'determineModelProducts','static');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray'...
    ,'bool'...
    };
    s.OutputTypes={'mxArray'...
    ,'mxArray'...
    ,'mxArray'...
    };



    m=schema.method(c,'determineBlockProduct','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(c,'getBlockDiagram','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };









    p=schema.prop(c,'classDate','string');
    p.Visible=visibleParam;
    p.FactoryValue=datestr(now);

    p=schema.prop(c,'objectDate','string');
    p.Visible=visibleParam;



    db=PmSli.RtmModelRegistry;
    p=schema.prop(c,'modelRegistry',class(db));
    p.Visible=visibleParam;
    p.FactoryValue=db;


    m=schema.method(c,'propertySetFcn_editingMode','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'string'...
    };
    s.OutputTypes={...
    };

    if doTrace||doDebug
        p=schema.prop(c,'debugMode','bool');
        p.FactoryValue=true;
        p.AccessFlags.PublicSet='off';
    end




