function schema




    doTrace(false);
    if doDebug(false)
        PROP_PRIVATE_ISPUBLIC='off';
    else
        PROP_PRIVATE_ISPUBLIC='on';
    end

    pkg=findpackage('SSC');

    parentpkg=findpackage('Simulink');
    parentcls=findclass(parentpkg,'CustomCC');
    cls=schema.class(pkg,'SimscapeCC',parentcls);








    propList=getClientPropertyList;
    for prop=propList
        p=schema.prop(cls,prop.Name,prop.DataType);
        p.SetFunction=prop.SetFcn;
        if prop.IsPrototype
            p.AccessFlags.Serialize='off';
        end
    end

    p=schema.prop(cls,'SelectedTab','string');
    p=schema.prop(cls,'Version','string');







    p=schema.prop(cls,'ComponentsAttached','bool');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicGet=PROP_PRIVATE_ISPUBLIC;
    p.AccessFlags.PublicSet=PROP_PRIVATE_ISPUBLIC;


    p=schema.prop(cls,'Listener','handle.listener vector');
    p.AccessFlags.Serialize='off';





    p.AccessFlags.PublicSet=PROP_PRIVATE_ISPUBLIC;
    p.Visible='off';


    p=schema.prop(cls,'someListenersNotInstalled','bool');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicGet=PROP_PRIVATE_ISPUBLIC;
    p.AccessFlags.PublicSet=PROP_PRIVATE_ISPUBLIC;
    p.FactoryValue=true;





    p=schema.prop(cls,'instanceId','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    if doDebug
        p.GetFunction=@queryInstanceId;
    end
    p.Visible='off';


    if doDebug
        p=schema.prop(cls,'instanceIdImpl','mxArray');
        p.AccessFlags.PublicSet='off';
        p.AccessFlags.PublicGet='off';
        p.AccessFlags.Serialize='off';
        p.AccessFlags.Copy='off';
    end

    if doTrace||doDebug
        p=schema.prop(cls,'debugMode','bool');
        p.FactoryValue=true;
        p.AccessFlags.PublicSet='off';
    end






    m=schema.method(cls,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'initialize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'getSlMenuCustomization','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'DAStudio.CallbackInfo'...
    };
    s.OutputTypes={'DAStudio.ToolSchema'...
    };


    m=schema.method(cls,'getClientClasses','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(cls,'getClientProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'bool'...
    };
    s.OutputTypes={'mxArray'...
    };

    m=schema.method(cls,'getComponentName','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'string'...
    };

    m=schema.method(cls,'getConfigSetCC');




    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle',...
    'mxArray',...
'int32'...
    };
    s.OutputTypes={'handle',...
'handle vector'...
    };

    m=schema.method(cls,'clearCachedConfigSet','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={...
'mxArray'...
    };
    s.OutputTypes={...
'handle'...
    };


    m=schema.method(cls,'getSubComponent');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'string'...
    };
    s.OutputTypes={'handle'...
    };


    m=schema.method(cls,'tabChangeCallback','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
    'string',...
'mxArray'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'preSave_pruneProducts','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray',...
'mxArray'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'postSave_restoreProducts','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'...
    };
    s.OutputTypes={...
    };




    m=schema.method(cls,'getActiveTab');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(cls,'setActiveTab');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'attachAllSubComponents');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={...
    };

    m=schema.method(cls,'detachAllSubComponents');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={...
    };




    m=schema.method(cls,'getSubComponentList');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(cls,'attachToConfigSet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'Simulink.ConfigSet'...
    };
    s.OutputTypes={...
    };



    m=schema.method(cls,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'string'...
    };
    s.OutputTypes={...
    };






    m=schema.method(cls,'setListeners');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'propertyChanged');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={...
    };


    m=schema.method(cls,'makeCopy');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={'handle'...
    };


    m=schema.method(cls,'makeCleanCopy');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={'handle'...
    };


    m=schema.method(cls,'getBlockDiagram');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={'mxArray'...
    };



    m=schema.method(cls,'skipModelReferenceComparison');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'...
    };
    s.OutputTypes={'bool'...
    };



