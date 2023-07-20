function prop=set_Parameters(this,prop,varargin)




    if nargin==3&&~isempty(varargin)

        parameterSync=varargin{1};
    else
        parameterSync=true;
    end


    useParameterTable='off';
    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'Parameters')
            this.PrivateData.Parameters=prop;
        end
        if isfield(this.PrivateData,'ParametersUseConfig')

            useParameterTable=this.PrivateData.ParametersUseConfig;
        end
    else
        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'Parameters'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'Parameters'],prop);
        end
        useParameterTable=get_param(this.activeCS,[this.extproductTag,'ParametersUseConfig']);
    end

    if parameterSync

        if strcmp(prop,'on')&&strcmp(useParameterTable,'on')
            this.set_ParameterConfiguration('UseParameterTable');
        elseif strcmp(prop,'on')&&strcmp(useParameterTable,'off')
            this.set_ParameterConfiguration('UseParameterConfigFile');
        elseif strcmp(prop,'off')
            this.set_ParameterConfiguration('None');
        end
    end
end
