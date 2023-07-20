function varargout=feature(varargin)




    if nargin==0
        if nargout>0
            error(message('audio:plugin:TooManyOutputs'));
        end
        return
    end
    [varargin{:}]=convertStringsToChars(varargin{:});

    featureName=varargin{1};
    validateattributes(featureName,{'char','string'},{},'audio.internal.feature','featureName',1);
    switch featureName
    case 'ResetToFactory'
        if nargout>0
            error(message('audio:plugin:TooManyOutputs'));
        end
        audio.internal.feature('EnableAUPluginGeneration',false);
        audio.internal.feature('EnableVst3PluginGeneration',false);
        audio.internal.feature('EnableAUv3PluginGeneration',false);
        audio.internal.feature('EnableVstPluginGeneration',false);
        audio.internal.feature('EnableWebBasedVisualization',false);
        audio.internal.feature('EnableAudioLabelerAutomation',false);
        audio.internal.feature('EnableAudioParameterTuner',false);
        audio.internal.feature('UseWebScopesInAudioTestBench',false);
        audio.internal.feature('UseScopesContainerInAudioTestBench',false);

    case 'EnableAUPluginGeneration'
        [varargout{1:nargout}]=handlePluginGenFeature('eapg',varargin{:});
    case 'EnableAUv3PluginGeneration'
        [varargout{1:nargout}]=handlePluginGenFeature('ea3pg',varargin{:});
    case 'EnableVst3PluginGeneration'
        [varargout{1:nargout}]=handlePluginGenFeature('e3vpg',varargin{:});
    case 'EnableVstPluginGeneration'
        [varargout{1:nargout}]=handlePluginGenFeature('evpg',varargin{:});
    case 'EnableWebBasedVisualization'

        deprecateLogicalFeature('audiowebbasedvisualization','ewbv',varargin{:});
    case 'EnableAudioLabelerAutomation'
        [varargout{1:nargout}]=handleLogicalFeature('audiolabeler','elabaut',varargin{:});
    case 'EnableAudioParameterTuner'

        deprecateLogicalFeature('audioparametertuner','eapt',varargin{:});
    case 'UseWebScopesInAudioTestBench'

        deprecateLogicalFeature('audiotestbench','uwsatb',varargin{:});
    case 'UseScopesContainerInAudioTestBench'
        [varargout{1:nargout}]=handleLogicalFeature('audiotestbench','uscatb',varargin{:});
    otherwise
        error(message('audio:plugin:BadOption',featureName));
    end
end

function deprecateLogicalFeature(groupName,xmlName,varargin)


    s=settings;
    astgroup=s.audio;
    if astgroup.hasGroup(groupName)&&hasSetting(astgroup.(groupName),xmlName)
        removeSetting(astgroup.(groupName),xmlName);
    end



    if(numel(varargin)<2)||varargin{2}
        error(message('audio:plugin:BadOption',varargin{1}));
    end
end

function varargout=handlePluginGenFeature(xmlName,varargin)
    s=settings;
    group=s.audio.audioplugingeneration;
    [varargout{1:nargout}]=handleStealthLogicalSetting(group,xmlName,varargin{:});
end

function varargout=handleLogicalFeature(groupName,xmlName,varargin)
    s=settings;
    astgroup=s.audio;
    if~astgroup.hasGroup(groupName)
        astgroup.addGroup(groupName,'hidden',true);
    end
    group=astgroup.(groupName);
    [varargout{1:nargout}]=handleStealthLogicalSetting(group,xmlName,varargin{:});
end

function varargout=handleStealthLogicalSetting(group,xmlName,varargin)
    oldValue=hasSetting(group,xmlName);
    switch numel(varargin)
    case 1



        varargout{1}=oldValue;
    case 2



        value=varargin{2};
        validateattributes(value,{'logical'},{},'audio.internal.feature','value',2);
        if oldValue~=value
            if value
                addSetting(group,xmlName,'PersonalValue',true,'Hidden',true);
                fprintf('%s',string(message('audio:plugin:NotForSale')));
            else
                removeSetting(group,xmlName);
            end
        end
        if nargout>0
            varargout{1}=oldValue;
        end
    otherwise
        error(message('audio:plugin:TooManyArgs'));
    end
end
