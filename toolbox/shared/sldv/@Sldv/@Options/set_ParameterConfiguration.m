function prop=set_ParameterConfiguration(this,prop,varargin)




    if nargin==3&&~isempty(varargin)

        parameterSync=varargin{1};
    else
        parameterSync=true;
    end
    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ParameterConfiguration')
            this.PrivateData.ParameterConfiguration=prop;
        end
    else
        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'ParameterConfiguration'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'ParameterConfiguration'],prop);
        end
    end


    if parameterSync
        switch prop
        case 'None'
            this.set_Parameters('off',false);
        case 'UseParameterTable'
            this.set_Parameters('on',false);
            this.set_ParametersUseConfig('on',false);
        case 'UseParameterConfigFile'
            this.set_Parameters('on',false);
            this.set_ParametersUseConfig('off',false);
        case 'Auto'
            this.set_Parameters('on',false);
        case 'DetermineFromGeneratedCode'
            this.set_Parameters('on',false);
        end
    end
end
