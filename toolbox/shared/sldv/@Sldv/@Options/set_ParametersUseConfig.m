function prop=set_ParametersUseConfig(this,prop,varargin)




    if nargin==3&&~isempty(varargin)

        parameterSync=varargin{1};
    else
        parameterSync=true;
    end


    enableParameters='off';
    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ParametersUseConfig')
            this.PrivateData.ParametersUseConfig=prop;
        end

        if isfield(this.PrivateData,'Parameters')
            enableParameters=this.PrivateData.Parameters;
        end
    else
        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'ParametersUseConfig'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'ParametersUseConfig'],prop);
        end

        enableParameters=get_param(this.activeCS,[this.extproductTag,'Parameters']);
    end

    if parameterSync
        if strcmp(enableParameters,'on')&&strcmp(prop,'on')
            this.set_ParameterConfiguration('UseParameterTable');
        elseif strcmp(enableParameters,'on')&&strcmp(prop,'off')
            this.set_ParameterConfiguration('UseParameterConfigFile');
        end
    end
end
