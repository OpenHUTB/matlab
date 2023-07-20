classdef HighpassIIRView<signal.task.internal.designfilt.responseviews.BaseConstrainedResponseView




    methods
        function this=HighpassIIRView(parentAccordion)

            this.ParentAccordion=parentAccordion;
        end
    end




    methods(Access=protected)

        function updateSpecificationSettings(this,settings)


            if isfield(settings,'OrderMode')
                specifyFlag=string(settings.OrderMode)=="Specify";
                if specifyFlag
                    setControlValue(this,'Order',settings.Order);
                    setControlValue(this,'OrderMode','specify');
                    setDenominatorOrderCheckBoxVisible(this,true);




                    if settings.SpecifyDenominator
                        setDenominatorOrderVisible(this,true);
                        setControlValue(this,'DenominatorOrder',settings.DenominatorOrder);
                    else
                        setDenominatorOrderVisible(this,false);
                        updateOrderSpinnerBasedOnOrderRestriction(this,settings.OrderRestriction);
                    end
                else
                    setControlValue(this,'OrderMode','minimum');
                    setDenominatorOrderCheckBoxVisible(this,false);
                    setDenominatorOrderVisible(this,false);
                end
                setOrderVisible(this,specifyFlag);
            end
        end
    end
end
