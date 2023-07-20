function varargout=feature(varargin)




    if nargin==0
        if nargout>0
            error(message('dsp:dsp:TooManyOutputs'));
        end
        return
    end
    [varargin{:}]=convertStringsToChars(varargin{:});

    featureName=varargin{1};
    validateattributes(featureName,{'char','string'},{},'audio.internal.feature','featureName',1);
    switch featureName
    case 'ResetToFactory'
        if nargout>0
            error(message('dsp:dsp:TooManyOutputs'));
        end

    case 'EnableTBBForCGSim'
        [varargout{1:nargout}]=handleLogicalFeatureSetting('enableTBB','enable',varargin{:});

    case 'dspunfoldOptimizedCG'
        [varargout{1:nargout}]=handleLogicalFeatureSetting('dspunfold',varargin{2},varargin{2:end});

    case 'EnhancedSim'
        switch varargin{2}
        case 'ChannelSynthesizer'
            [varargout{1:nargout}]=...
            handleLogicalFeatureSetting('channelSynthesizer','enable',varargin{2:end});
        case 'Channelizer'
            [varargout{1:nargout}]=...
            handleLogicalFeatureSetting('channelizer','enable',varargin{2:end});
        case 'FrequencyDomainFIRFilter'
            [varargout{1:nargout}]=...
            handleLogicalFeatureSetting('frequencyDomainFIRFilter','enable',varargin{2:end});
        otherwise
            enhancedSimulationsFeatureControl(varargin{:});
        end

    otherwise
        error(message('dsp:dsp:BadOption',featureName));
    end
end

function varargout=handleLogicalFeatureSetting(groupName,xmlName,varargin)
    s=settings;
    group=s.dsp.(groupName);
    switch numel(varargin)
    case 1
        varargout{1}=group.(xmlName).ActiveValue;
    case 2
        group.(xmlName).PersonalValue=logical(varargin{2});
    otherwise
        error(message('dsp:dsp:TooManyArgs'));
    end
end

function enhancedSimulationsFeatureControl(varargin)









    if(nargin<2)||(nargin>3)
        msg=sprintf(['wrong usage, try in below way',...
        '\n Set value using ',...
        '\n    dsp.internal.feature(''EnhancedSim'', <blk> ,value)',...
        '\n Get value using ',...
        '\n    dsp.internal.feature(''EnhancedSim'', <blk>)',...
        '\n         where blk   --> FIRFilter, FIRInterpolator',...
        '\n                         FIRRateConverter, FIRDecimator',...
        '\n                         Channelizer, ChannelSynthesizer',...
'\n                         Frequency Domain FIR Filter'...
        ,'\n               value --> 1 or 0 ']);
        error(msg);
    end
    if(strcmp(varargin{2},'FIRFilter')==0)&&...
        (strcmp(varargin{2},'FIRInterpolator')==0)&&...
        (strcmp(varargin{2},'FIRRateConverter')==0)&&...
        (strcmp(varargin{2},'FIRDecimator')==0)
        msg=sprintf("%s'. Use 'FIRFilter' or 'FIRInterpolator ..."+...
        "or 'FIRRateConverter' or FIRDecimator or Channelizer ..."+...
        "or ChannelSynthesizer"+"or Frequency Domain FIR Filter",...
        varargin{2});
        error(message('dsp:dsp:BadOption',msg));
    end

    if nargin==2

        getFeatureValue(true,varargin{2});
    elseif nargin==3

        if(varargin{3}==1)||(varargin{3}==0)||(varargin{3}==2)
            getFeatureValue(false,varargin{2});
            try
                if strcmp(varargin{2},'FIRFilter')
                    slf_feature('set','slDiscreteFIRHalideSimulations',varargin{3});
                    val=slf_feature('set','slDiscreteFIRHalideSimulations',...
                    varargin{3});
                elseif strcmp(varargin{2},'FIRInterpolator')
                    slf_feature('set','slFIRInterpolatorHalideSimulations',varargin{3});
                    val=slf_feature('set','slFIRInterpolatorHalideSimulations',...
                    varargin{3});
                elseif strcmp(varargin{2},'FIRRateConverter')
                    slf_feature('set','slFIRRateConverterHalideSimulations',varargin{3});
                    val=slf_feature('set','slFIRRateConverterHalideSimulations',...
                    varargin{3});
                elseif strcmp(varargin{2},'FIRDecimator')
                    slf_feature('set','slFIRDecimatorHalideSimulations',varargin{3});
                    val=slf_feature('set','slFIRDecimatorHalideSimulations',...
                    varargin{3});
                end
                fprintf("\nsuccessful in setting %d\n",val);
            catch
            end
        else
            msg=sprintf("%d'. Value has to be '0' or '1",varargin{3});
            error(message('dsp:dsp:BadOption',msg));
        end
    end
end

function getFeatureValue(toDisplay,block)
    try
        if strcmp(block,'FIRFilter')
            value=slf_feature('get','slDiscreteFIRHalideSimulations');
        elseif strcmp(block,'FIRInterpolator')
            value=slf_feature('get','slFIRInterpolatorHalideSimulations');
        elseif strcmp(block,'FIRRateConverter')
            value=slf_feature('get','slFIRRateConverterHalideSimulations');
        elseif strcmp(block,'FIRDecimator')
            value=slf_feature('get','slFIRDecimatorHalideSimulations');
        end
        if toDisplay
            disp(value);
        end
    catch
        A=dsp.FIRFilter;%#ok<NASGU>
        B=dsp.FIRInterpolator;%#ok<NASGU>
        C=dsp.FIRRateConverter;%#ok<NASGU>
        D=dsp.FIRDecimator;%#ok<NASGU>
        clear A B C D;
    end
end
