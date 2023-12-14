classdef DialogManager<handle


%#ok<*AGROW>


    properties(Hidden)
        Platform='Simulink';
        Renderer='DDG';
        ErrorFlag=false;
        MaxNumColsInGrid=10;
        SystemObjectParameterExpressions;
        SystemObjectParameterCacheForCancel;
    end

    properties(Dependent,Hidden)
        System;
        IsSystemObjectValid;
        SystemObjectClassFile;
        ShowSystemParameter;
        SystemMetaClass;
    end

    properties(Access=private)
        pSystemMetaClass;
    end

    methods(Abstract)
        getDialogStructFromSystemDisplayGroups(obj);
    end

    methods

        function obj=DialogManager(aplatform,arenderer,arg3)
            switch aplatform
            case 'MATLAB'
                obj.Platform=matlab.system.ui.MATLABDescriptor(arg3);
            case 'Simulink'
                obj.Platform=matlab.system.ui.SimulinkDescriptor(arg3);
            case 'SimulinkPreview'
                obj.Platform=matlab.system.ui.SimulinkPreviewDescriptor(arg3);
            otherwise
                error(message('MATLAB:system:wrongPlatform',aplatform));
            end

            switch arenderer
            case 'DDG'
                obj.Renderer=arenderer;
            otherwise
                error(message('MATLAB:system:wrongRenderer',arenderer));
            end
            obj.SystemObjectParameterExpressions=containers.Map;
        end
    end

    methods
        function val=get.IsSystemObjectValid(obj)
            name=obj.Platform.getSystemObjectName();
            val=~matlab.system.ui.DialogManager.isUnspecifiedSystemObject(name);
        end

        function val=get.System(obj)
            val=obj.Platform.getSystemObjectName();
        end

        function val=get.ShowSystemParameter(obj)
            val=obj.Platform.isCalledFromBlockParameters();
        end

        function launchSpecifySystemObjectDialog(~)

        end

        function fileLocation=get.SystemObjectClassFile(obj)
            fileLocation=which(obj.System);
            if~exist(fileLocation,'file')||~exist(obj.System,'class')
                fileLocation='';
            end
        end

        function val=get.SystemMetaClass(obj)



            if isempty(obj.pSystemMetaClass)
                obj.pSystemMetaClass=matlab.system.internal.MetaClass(obj.System);
            end
            val=obj.pSystemMetaClass(obj.System);
        end
    end

    methods(Static,Hidden)
        function adapter=getSystemObjectAdapter(systemName)
            adapter=matlab.system.ui.Adapter(systemName);
        end

        function flag=isUnspecifiedSystemObject(name)
            flag=strcmp(name,'<Enter System Class Name>')||isempty(name);
        end

        function err=removeHyperlinks(err)
            err=regexprep(err,'<a href.*?">(.*?)</a>','$1');
        end

        function helpstr=getPropertyHelp(systemName,propName)



            mc=meta.class.fromName(systemName);
            for mp=mc.PropertyList'
                if strcmp(propName,mp.Name)
                    helpstr=mp.Description;
                    return;
                end
            end
        end

        function prompt=getPropertyPrompt(systemName,propName)

            try
                prompt=matlab.system.ui.DialogManager.getPropertyHelp(systemName,propName);
                if isempty(prompt)
                    prompt=propName;
                end
            catch err %#ok<NASGU>

                prompt=propName;
            end
        end
    end

    methods
        function s=getDefaultDialogStruct(obj)

            systemName=obj.System;
            header=matlab.system.display.internal.Memoizer.getHeader(systemName);
            groups=obj.Platform.getPropertyGroups(systemName);
            s=getDialogStructFromSystemDisplayGroups(obj,header,groups);
        end
    end

    methods(Static)
        function allItemsInvisible=getAreAllItemsInvisible(s)

            allItemsInvisible=true;
            if isfield(s,'Items')
                for itemInd=1:numel(s.Items)
                    item=s.Items{itemInd};
                    if~isfield(item,'Visible')||item.Visible
                        allItemsInvisible=false;
                        break;
                    end
                end
            end
        end
    end
end

function[minClassPath,classFileName]=getClassPathInfo(className)

    [classPath,classFileName]=fileparts(which(className));



    minClassPath='';
    systemPathTokens=strsplit(classPath,filesep);
    numPackageTokens=numel(strsplit(className,'.'))-1;
    if numPackageTokens>0
        lastPathToken=systemPathTokens{end};
        isAtClass=strcmp('@',lastPathToken(1));
        if isAtClass
            numPathTokens=numPackageTokens+1;
        else
            numPathTokens=numPackageTokens;
        end
        minClassPath=strjoin(systemPathTokens(end-numPathTokens+1:end),filesep);
    end
end
