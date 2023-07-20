classdef EntryPoint<handle

















    properties(Dependent,GetAccess=public,SetAccess=private)

        File;
    end

    properties(GetAccess=public,SetAccess=private,Hidden)

Type
FileLocation
    end

    properties(GetAccess=protected,SetAccess=protected)
        FileReturnTransform=@(x)x;
    end

    properties(Access=private,Hidden)

JavaEntryPointManager
    end
    methods
        function file=get.File(obj)
            file=obj.FileReturnTransform(obj.FileLocation);
        end
    end
    methods(Access=public,Hidden=true)
        function obj=EntryPoint(javaEntryPointManager,file)
            p=inputParser();
            p.addRequired('javaEntryPointManager',...
            @(x)validateattributes(x,{...
            'com.mathworks.toolbox.slproject.project.matlab.api.entrypoint.MatlabAPIEntryPointManagerFacade',...
'com.mathworks.toolbox.slproject.project.matlab.api.entrypoint.ReferencedProjectEntryPointManagerFacadeDecorator'...
            },{'nonempty'}));
            p.addRequired('file',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            p.parse(javaEntryPointManager,file);

            obj.JavaEntryPointManager=p.Results.javaEntryPointManager;
            file=p.Results.file;
            if isa(file,'string')
                file=char(file);
            end
            obj.FileLocation=file;
        end
    end

    methods
        function type=get.Type(obj)
            getType=@(x)x.getType();
            javaType=obj.getEntryPointProperty(getType);
            import matlab.internal.project.util.EntryPointType;
            type=EntryPointType.convertFromJava(javaType);
        end
    end

    methods(Access=protected,Hidden)
        function property=getEntryPointProperty(obj,getProperty)
            getEntryPoint=@()obj.JavaEntryPointManager.getEntryPoint(obj.FileLocation);
            property=getJavaProperty(getEntryPoint,getProperty);
        end

        function setEntryPointManagerProperty(obj,setProperty)
            getEntryPointManger=@()obj.JavaEntryPointManager;
            setJavaProperty(getEntryPointManger,setProperty);
        end

        function entryPoint=getEntryPoint(obj)
            entryPoint=obj.JavaEntryPointManager.getEntryPoint(obj.FileLocation);
        end
    end

end

function property=getJavaProperty(getObject,getProperty)
    import matlab.internal.project.util.processJavaCall;
    property=processJavaCall(...
    @()getProperty(getObject())...
    );
end

function setJavaProperty(getObject,setProperty)
    import matlab.internal.project.util.processJavaCall;
    processJavaCall(...
    @()setProperty(getObject())...
    );
end
