classdef channel<serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=channel(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end

        function value=get.ChannelModel(obj)
            value=obj.ChannelModel;
        end
        function set.ChannelModel(obj,value)
            validateattributes(value,{'char'},{'nonempty'},'',obj.ChannelModel_NameInGUI);
            obj.ChannelModel=value;
        end

        function value=get.ImpulseResponse(obj)
            value=obj.ImpulseResponse;
        end
        function set.ImpulseResponse(obj,value)
            if~obj.isWorkspaceVariable(value)
                if~obj.isParameterWorkspaceValuesRestored&&ischar(value)

                    actualValue=obj.ImpulseResponse;
                else
                    actualValue=value;
                end
            else
                actualValue=evalin('base',value);
            end
            validateattributes(actualValue,{'numeric'},{'nonempty','finite','nonnan','2d'},'',obj.ImpulseResponse_NameInGUI);
            impulseSize=size(actualValue);
            coder.internal.errorIf(impulseSize(2)>impulseSize(1),'serdes:serdessystem:ImpulseWaveShouldBeColumnMatrix2');
            obj.ImpulseResponse=value;
            obj.setWorkspaceVariableValue('ImpulseResponse',value);
        end
        function isValid=isValidImpulseResponseWorkspaceVariable(obj,workspaceParamName)
            if~isempty(workspaceParamName)&&~isnumeric(workspaceParamName)
                w=evalin('base','whos');
                isValid=ismember(workspaceParamName,{w(:).name})&&...
                ~isempty(evalin('base',workspaceParamName));
                if isValid
                    actualValue=evalin('base',workspaceParamName);
                    try
                        validateattributes(actualValue,{'numeric'},{'nonempty','finite','nonnan','2d'},'',obj.ImpulseResponse_NameInGUI)
                        impulseSize=size(actualValue);
                        if impulseSize(2)>impulseSize(1)
                            isValid=false;
                        end
                    catch
                        isValid=false;
                    end
                end
            else
                isValid=false;
            end
        end

        function value=get.ImpulseSampleInterval(obj)
            value=obj.ImpulseSampleInterval;
        end
        function set.ImpulseSampleInterval(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','positive'},'',obj.ImpulseSampleInterval_NameInGUI);
            obj.ImpulseSampleInterval=value;
        end

        function value=get.ChannelLoss_dB(obj)
            value=obj.ChannelLoss_dB;
        end
        function set.ChannelLoss_dB(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative'},'',obj.ChannelLoss_dB_NameInGUI);

            minLoss=1;
            coder.internal.errorIf(~(value==0||value>=minLoss),...
            'serdes:serdessystem:LossValueRange',...
            sprintf('%g',minLoss));
            obj.ChannelLoss_dB=value;
        end

        function value=get.DifferentialImpedance(obj)
            value=obj.DifferentialImpedance;
        end
        function set.DifferentialImpedance(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero'},'',obj.DifferentialImpedance_NameInGUI);
            obj.DifferentialImpedance=value;
        end

        function value=get.Impedance(obj)
            value=obj.Impedance;
        end
        function set.Impedance(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero'},'',obj.Impedance_NameInGUI);
            obj.Impedance=value;
        end

        function value=get.TargetFrequency(obj)
            value=obj.TargetFrequency;
        end
        function set.TargetFrequency(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero'},'',obj.TargetFrequency_NameInGUI);
            obj.TargetFrequency=value;
        end


        function value=get.XTalkEnabled(obj)
            obj.initializeCrossTalkIfNeeded();
            value=obj.XTalkEnabled;
        end
        function set.XTalkEnabled(obj,value)
            obj.validate_XTalkEnabled(value);
            obj.XTalkEnabled=value;
        end
        function validate_XTalkEnabled(obj,value)
            obj.ChannelLoss.EnableCrosstalk=value;
        end


        function value=get.XTalkSpecification(obj)
            obj.initializeCrossTalkIfNeeded();
            value=obj.XTalkSpecification;
        end
        function set.XTalkSpecification(obj,value)
            obj.validate_XTalkSpecification(value);
            obj.XTalkSpecification=value;
        end
        function validate_XTalkSpecification(obj,value)
            obj.ChannelLoss.CrosstalkSpecification=value;
        end


        function value=get.FE_XTalkICN(obj)
            obj.initializeCrossTalkIfNeeded();
            value=obj.FE_XTalkICN;
        end
        function set.FE_XTalkICN(obj,value)
            obj.validate_FE_XTalkICN(value);
            obj.FE_XTalkICN=value;
        end
        function validate_FE_XTalkICN(obj,value)
            obj.ChannelLoss.FEXTICN=value;
        end


        function value=get.NE_XTalkICN(obj)
            obj.initializeCrossTalkIfNeeded();
            value=obj.NE_XTalkICN;
        end
        function set.NE_XTalkICN(obj,value)
            obj.validate_NE_XTalkICN(value);
            obj.NE_XTalkICN=value;
        end
        function validate_NE_XTalkICN(obj,value)
            obj.ChannelLoss.NEXTICN=value;
        end


        function initializeCrossTalkIfNeeded(obj)
            if isempty(obj.ChannelLoss)

                obj.ChannelLoss=serdes.ChannelLoss;
                obj.XTalkEnabled=obj.ChannelLoss.EnableCrosstalk;
                obj.XTalkSpecification=obj.ChannelLoss.CrosstalkSpecification;
                obj.ChannelLoss.CrosstalkSpecification='Custom';
                obj.FE_XTalkICN=obj.ChannelLoss.FEXTICN;
                obj.NE_XTalkICN=obj.ChannelLoss.NEXTICN;
                obj.ChannelLoss.CrosstalkSpecification=obj.XTalkSpecification;
            end
        end

        function tooltips=getToolTips(obj)
            tooltips=obj.ToolTips;
        end

        function togglePairs=getTogglePairs_SeDiff(obj)
            togglePairs=obj.TogglePairs_SeDiff;
        end
    end

    properties
        ChannelModel='Loss model';
        ImpulseResponse=[0;0;1/6.25e-12;zeros(276,1)];
        ImpulseSampleInterval=6.25e-12;
        ChannelLoss_dB=8;
        DifferentialImpedance=100;
        Impedance=50;
        TargetFrequency=5e9;


        XTalkEnabled=[];
        XTalkSpecification=[];
        FE_XTalkICN=[];
        NE_XTalkICN=[];


        SparameterButton='@sParameterFitter';
    end


    properties(Access=private)
        ChannelLoss=[];
    end

    properties(Constant,Hidden)
        ChannelModelSet=[{'Loss model'};{'Impulse response'}];
        XTalkSpecificationSet=[{'CEI-28G-SR'};{'CEI-25G-LR'};{'CEI-28G-VSR'};{'100GBASE-CR4'};{'Custom'}];

        ChannelModel_NameInGUI=getString(message('serdes:serdesdesigner:ChannelModel_NameInGUI'));
        ImpulseResponse_NameInGUI=getString(message('serdes:serdesdesigner:ImpulseResponse_NameInGUI'));
        ImpulseSampleInterval_NameInGUI=getString(message('serdes:serdesdesigner:ImpulseSampleInterval_NameInGUI'));

        ChannelLoss_dB_NameInGUI=getString(message('serdes:serdesdesigner:ChannelLoss_dB_NameInGUI'));
        DifferentialImpedance_NameInGUI=getString(message('serdes:serdesdesigner:DifferentialImpedance_NameInGUI'));
        Impedance_NameInGUI=getString(message('serdes:serdesdesigner:Impedance_NameInGUI'));
        TargetFrequency_NameInGUI=getString(message('serdes:serdesdesigner:TargetFrequency_NameInGUI'));
        XTalkEnabled_NameInGUI=getString(message('serdes:serdesdesigner:XTalkEnabled_NameInGUI'));
        XTalkSpecification_NameInGUI=getString(message('serdes:serdesdesigner:XTalkSpecification_NameInGUI'));
        FE_XTalkICN_NameInGUI=getString(message('serdes:serdesdesigner:FE_XTalkICN_NameInGUI'));
        NE_XTalkICN_NameInGUI=getString(message('serdes:serdesdesigner:NE_XTalkICN_NameInGUI'));
        SparameterButton_NameInGUI='Import S-Parameter';

        ChannelLoss_dB_ToolTip=getString(message('serdes:serdesdesigner:ChannelLoss'));
        DifferentialImpedance_ToolTip=getString(message('serdes:serdesdesigner:ChannelDifferentialImpedance'));
        Impedance_ToolTip=getString(message('serdes:serdesdesigner:ChannelImpedance'));
        TargetFrequency_ToolTip=getString(message('serdes:serdesdesigner:ChannelTargetFrequency'));
        XTalkEnabled_ToolTip=getString(message('serdes:serdesdesigner:ChannelXTalkEnabled'));
        XTalkSpecification_ToolTip=getString(message('serdes:serdesdesigner:ChannelXTalkSpecification'));
        FE_XTalkICN_ToolTip=getString(message('serdes:serdesdesigner:FE_XTalkICN'));
        NE_XTalkICN_ToolTip=getString(message('serdes:serdesdesigner:NE_XTalkICN'));
        SparameterButton_ToolTip='Import S-Parameter Touchstone File with sParameterFitter App';

        ToggleParamPairs_SE_Diff=[{'Impedance'},{'DifferentialImpedance'}];
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:ChannelHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='Channel';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.channel;
            copyProperties(in,out);
        end
    end
end

