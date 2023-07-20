classdef DifferentiatorFIRView<signal.task.internal.designfilt.responseviews.BaseConstrainedResponseView




    methods
        function this=DifferentiatorFIRView(parentAccordion)

            this.ParentAccordion=parentAccordion;
        end

        function flag=isGroupsRendered(this)
            flag=~isempty(this.SpecificationsPanel)&&...
            ~isempty(this.FrequencyConstraintsPanel)&&...
            ~isempty(this.AlgorithmPanel);
        end
    end

    methods(Access=protected)
        function out=addMagnitudeConstraintsGroup(~)

            out=[];
        end

        function addMagnitudeConstraintsControls(~)

        end

        function updateSpecificationSettings(this,settings)

            setDenominatorOrderCheckBoxVisible(this,false);
            setDenominatorOrderVisible(this,false);
            setOrderModeVisible(this,false);
            setOrderVisible(this,true);
            setControlValue(this,'Order',settings.Order);
            updateOrderSpinnerBasedOnOrderRestriction(this,settings.OrderRestriction);
        end

        function updateFrequencyConstraintsSettings(this,settings)



            if isfield(settings,'PopupItems')
                setPopupItems(this,'FrequencyConstraints',settings.PopupItems,...
                settings.PopupItemsData,settings.PopupValue);
            end
            setFrequencyConstraintsVisible(this,true);

            if strcmp(settings.CurrentFrequencyConstraints,'Unconstrained')

                updateFrequencySpecsControls(this);
            elseif strcmp(settings.CurrentFrequencyConstraints,'Passband edge and stopband edge')

                isNormalized=settings.FrequencyUnitsValue=="normalized";
                if isNormalized
                    fNyquist=1;
                else
                    fNyquist=settings.SampleRateNumericValue/2;
                end
                updateFrequencySpecsControls(this,settings,fNyquist);
            end


            if settings.FrequencyUnitsValue=="Hz"
                setSampleRateValue(this,settings.SampleRate,settings.SampleRateSource);
                setSampleRateVisible(this,true);
            else
                setSampleRateVisible(this,false);
            end
            setControlValue(this,'FrequencyUnits',settings.FrequencyUnitsValue);
        end

        function updateMagnitudeConstraintsSettings(~,~)

        end

    end
end
