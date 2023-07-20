
































classdef Variable
    properties(SetAccess=private,GetAccess=public)
Name
    end

    properties
Value
    end

    properties(SetAccess=private,GetAccess=public)
Workspace
    end

    properties(SetAccess=private,GetAccess=public)
        Context{mustBeTextScalar}='';
    end

    properties(Hidden,SetAccess=public,GetAccess=public)


        DataSource='global-workspace'
    end

    properties
        Description(1,1)string
    end

    methods
        function obj=Variable(name,value,varargin)
            if~isvarname(name)
                throw(MException(message('Simulink:Commands:InvalidVariableName',name)));
            end
            p=inputParser;
            isScalarText=@(x)validateattributes(x,{'char','string'},{'scalartext'});
            addRequired(p,'name',isScalarText);
            addRequired(p,'value');
            addParameter(p,'workspace','global-workspace',isScalarText);
            addParameter(p,'context','',isScalarText);

            parse(p,name,value,varargin{:});



            [~,~,ext]=fileparts(p.Results.workspace);
            if~isdeployed&&slfeature('SlEnableSLDDWspSupportInSimInputCommandLineAPI')==0&&strcmp(ext,'.sldd')
                throwAsCaller(MException(message('Simulink:Commands:SimInputInvalidWorkspace',p.Results.workspace)));
            end
            obj.Name=p.Results.name;
            obj.Value=p.Results.value;
            obj.Workspace=p.Results.workspace;
            obj.Context=p.Results.context;
        end

        function T=table(obj)
            T=table;
            for i=1:numel(obj)
                T=[T;{i,obj(i).Name,Simulink.Simulation.internal.varValue2str(obj(i).Value),...
                obj(i).Workspace,obj(i).Context}];%#ok<AGROW>
            end
            T.Properties.VariableNames=["Index","Name","Value","Workspace","Context"];


            T.Name=categorical(T.Name);
            T.Value=categorical(T.Value);
            T.Workspace=categorical(T.Workspace);
            T.Context=categorical(T.Context);
        end
    end
end


