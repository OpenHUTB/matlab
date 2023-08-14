classdef(AllowedSubclasses={?coder.internal.mlfb.WebFptFacade})FptFacade<handle




    methods(Static,Sealed)
        function facade=getInstance()
            facade=coder.internal.mlfb.FptFacade.instance('get');
        end

        function varargout=invoke(methodName,varargin)
            instance=coder.internal.mlfb.FptFacade.getInstance();
            if nargout>0
                [varargout{1:nargout}]=feval(methodName,instance,varargin{:});
            else
                feval(methodName,instance,varargin{:});
            end
        end
    end

    methods(Static,Sealed,Hidden)
        function reset()

            coder.internal.mlfb.FptFacade.instance('clear');
        end
    end

    methods(Static,Sealed,Access=private)
        function varargout=instance(command)
            validatestring(command,{'get','clear'});
            mlock;
            persistent singleton;

            if strcmp(command,'get')
                if isempty(singleton)
                    singleton=coder.internal.mlfb.WebFptFacade;
                end
                varargout={singleton};
            else
                singleton=[];
                varargout={};
            end
        end
    end




    methods



        function cleanupObj=onSettingChanged(this,changeCallback,varargin)
            validateattributes(this.getCurrentModelName(),{'char'},{'nonempty'});
            validateattributes(changeCallback,{'function_handle'},{});
            cellfun(@(arg)validateattributes(arg,{'coder.internal.mlfb.FptSetting'},{}),varargin);

            autoscalerSettings=this.getAutoscalerSettings();
            cleanupObj=cell(size(varargin));

            for i=1:numel(varargin)
                setting=varargin{i};
                propObj=findprop(autoscalerSettings,setting.ModelProperty);
                cleanupObj{i}=event.proplistener(autoscalerSettings,propObj,'PostSet',...
                @(~,~)changeCallback(setting,autoscalerSettings.(setting.ModelProperty)));
            end
        end

        function wordLength=getAutoscalerWordLength(this)
            wordLength=this.getFptSettingValue(coder.internal.mlfb.FptSetting.WordLength);
        end

        function fractionLength=getAutoscalerFractionLength(this)
            fractionLength=this.getFptSettingValue(coder.internal.mlfb.FptSetting.FractionLength);
        end

        function safetyMargin=getAutoscalerSafetyMargin(this)
            safetyMargin=this.getFptSettingValue(coder.internal.mlfb.FptSetting.SafetyMargin);
        end

        function proposeSignedness=isProposeSignedness(this)
            proposeSignedness=this.getFptSettingValue(coder.internal.mlfb.FptSetting.ProposeSignedness);
        end

        function proposeWordLength=isProposeWordLength(this)
            proposeWordLength=this.getFptSettingValue(coder.internal.mlfb.FptSetting.ProposeWordLength);
        end

        function value=getSettingValue(this,setting)
            validateattributes(setting,{'coder.internal.mlfb.FptSetting'},{});
            value=this.getAutoscalerSettings().(setting.ModelProperty);
        end
    end

    methods(Access=protected)
        function autoscalerSettings=getAutoscalerSettings(this)
            appData=SimulinkFixedPoint.getApplicationData(this.getCurrentModelName());
            autoscalerSettings=appData.AutoscalerProposalSettings;
        end
    end




    methods(Abstract)

        propose(this,runName);


        apply(this,runName);




        blockObj=getSelectedTreeNode(this);


        resultObj=getSelectedResult(this);


        isSet=isSudSet(this);


        sudObj=getSud(this);





        setSystemForConversion(this,blockObject,temporary);



        goToTreeNode(this,qualifiedName);






        live=isLive(this);


        modelName=getCurrentModelName(this);


        setAutoscalerWordLength(this,wordLength);


        setAutoscalerFractionLength(this,fractionLength);


        setAutoscalerSafetyMargin(this,safetyMargin);


        setAutoscalerProposeSignedness(this,proposeSignedness);


        setAutoscalerProposeWordLength(this,proposeWordLength);




        cleanupObj=onSudChanged(this,sudChangeCallback);




        cleanupObj=onDisposed(this,disposeCallback);
    end
end


