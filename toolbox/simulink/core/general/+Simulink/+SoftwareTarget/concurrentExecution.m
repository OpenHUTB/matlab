function varargout=concurrentExecution(varargin)





























    narginchk(2,3);
    nargoutchk(0,1);

    obj=varargin{1};
    arg=varargin{2};

    [objType,obj]=loc_get_clean_obj(obj);

    if strcmp(objType,'Invalid')
        DAStudio.error('Simulink:mds:InvalidArg1_concurrentExecution');
    end

    if~ischar(arg)
        DAStudio.error('Simulink:mds:InvalidArg2_concurrentExecution');
    end

    switch objType

    case 'Configuration'
        if nargin>2
            DAStudio.error('Simulink:mds:TooManyArgs_concurrentExecution');
        end
        if~strcmp(arg,'ConvertForConcurrentExecution')
            DAStudio.error('Simulink:mds:InvalidArg2_concurrentExecution');
        end
        configSet=loc_convert_configuration(obj);

    case 'Model'

        switch arg
        case 'ConvertForConcurrentExecution'
            if nargin==3&&~ischar(varargin{3})
                DAStudio.error('Simulink:mds:InvalidArg3_concurrentExecution');
            end
            configName=getArgsFromIdx(varargin,3,{''});
            configSet=loc_convert_existing_configuration(obj,configName);

        case 'AddConfigurationForConcurrentExecution'
            configSet=loc_add_configuration(obj);
        case 'OpenDialog'
            if nargin==3&&~ischar(varargin{3})
                DAStudio.error('Simulink:mds:InvalidArg3_concurrentExecution');
            end
            configName=getArgsFromIdx(varargin,3,{''});
            configSet=loc_open_configuration(obj,configName);
        otherwise
            DAStudio.error('Simulink:mds:InvalidArg2_concurrentExecution');
        end
    end

    if nargout==1
        varargout(1)={configSet};
    end

    function varargout=getArgsFromIdx(args,idx,defaults)

        varargout=defaults;
        for i=idx:length(args)
            varargout{i-idx+1}=args{idx};
        end

        function obj=loc_convert_configuration(obj)

            Simulink.SoftwareTarget.taskConfigUtils('ExtendConfigSet',obj);

            function configSet=loc_get_existing_configuration(obj,configName)

                if isempty(configName)
                    configSet=getActiveConfigSet(obj);
                else
                    configSet=getConfigSet(obj,configName);
                end

                if isempty(configSet)
                    DAStudio.error('Simulink:mds:CannotLocateConfigSet',...
                    configName,get_param(obj,'Name'));
                end

                function configSet=loc_convert_existing_configuration(obj,configName)

                    configSet=loc_convert_configuration(...
                    loc_get_existing_configuration(obj,configName));

                    function configSet=loc_add_configuration(obj)

                        configSet=loc_get_existing_configuration(obj,'');
                        configSet=configSet.copy;
                        Simulink.SoftwareTarget.checkSetDeploymentConfigSet(configSet,'set','model');
                        attachConfigSet(obj,configSet,1);
                        configSet=loc_convert_configuration(configSet);

                        function configSet=loc_open_configuration(obj,configName)

                            configSet=loc_get_existing_configuration(obj,configName);

                            if strcmp(get_param(configSet,'EnableConcurrentExecution'),'off')
                                DAStudio.error('Simulink:mds:NotConfiguredForConcurrentExecution',...
                                get_param(obj,'Name'),...
                                configSet.Name);
                            else
                                DeploymentDiagram.explorer(get_param(obj,'Name'));
                            end

                            function[objType,obj_out]=loc_get_clean_obj(obj_in)

                                objType='Invalid';
                                obj_out=[];

                                if isa(obj_in,'Simulink.ConfigSet')
                                    objType='Configuration';
                                    obj_out=obj_in;
                                    return;
                                end

                                try %#ok
                                    modelH=get_param(obj_in,'Handle');
                                    if strcmp(get_param(modelH,'type'),'block_diagram')
                                        objType='Model';
                                        obj_out=modelH;
                                    end
                                end
