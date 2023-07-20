function varargout=feature(varargin)




    if nargin==0
        if nargout>0
            error(message('fusion:internal:feature:TooManyOutputs'));
        end
        return
    end
    [varargin{:}]=convertStringsToChars(varargin{:});

    featureName=varargin{1};
    validateattributes(featureName,{'char','string'},{},'fusion.internal.feature','featureName',1);
    switch featureName
    case 'ResetToFactory'
        if nargout>0
            error(message('fusion:internal:feature:TooManyOutputs'));
        end
        fusion.internal.feature('EnableTrackingScenarioDesigner',false);

    case 'EnableTrackingScenarioDesigner'
        [varargout{1:nargout}]=handlePluginGenFeature('etsd',varargin{:});
    otherwise
        error(message('fusion:internal:feature:BadOption',featureName));
    end
end

function varargout=handlePluginGenFeature(xmlName,varargin)
    s=settings;
    group=s.fusion.fusiontrackingscenariodesigner;
    [varargout{1:nargout}]=handleStealthLogicalSetting(group,xmlName,varargin{:});
end

function varargout=handleStealthLogicalSetting(group,xmlName,varargin)
    oldValue=hasSetting(group,xmlName);
    switch numel(varargin)
    case 1



        varargout{1}=oldValue;
    case 2



        value=varargin{2};
        validateattributes(value,{'logical'},{},'fusion.internal.feature','value',2);
        if oldValue~=value
            if value
                addSetting(group,xmlName,'PersonalValue',true,'Hidden',true);
                fprintf('%s',string(message('fusion:internal:feature:NotForSale')));
            else
                removeSetting(group,xmlName);
            end
        end
        if nargout>0
            varargout{1}=oldValue;
        end
    otherwise
        error(message('fusion:internal:feature:TooManyArgs'));
    end
end
