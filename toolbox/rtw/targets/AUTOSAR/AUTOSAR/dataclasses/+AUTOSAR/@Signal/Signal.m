classdef Signal<Simulink.Signal



    properties(PropertyType='char',Hidden=true,...
        AllowedValues={'NotAccessible';...
        'ReadOnly';...
        'ReadWrite'})
        SwCalibrationAccess='ReadOnly';
    end
    properties(PropertyType='char',Hidden=true)
        DisplayFormat='';
    end
    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'AUTOSAR');
        end

        function h=Signal()

        end

    end

    methods(Sealed,Hidden)

        function isPIM=getIsAutosarPerInstanceMemory(hObj)

            if strcmp(hObj.CoderInfo.StorageClass,'Custom')
                hClass=metaclass(hObj);
                pkgName=hClass.ContainingPackage.Name;
                csc=hObj.CoderInfo.CustomStorageClass;
                cscDefn=processcsc('GetCSCDefn',pkgName,csc);
                isPIM=isAutosarPerInstanceMemory(cscDefn,hObj);
            else
                isPIM=false;
            end
        end

    end
    methods(Hidden)

        function dlgStruct=getDialogSchema(obj,name)
            helpPages.parameter_help='autosar_parameter';
            helpPages.signal_help='autosar_signal';
            helpPages.mapfile='/autosar/helptargets.map';
            dlgStruct=dataddg(obj,name,'signal',false,helpPages);
        end
    end
end


