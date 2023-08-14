classdef HighpassIIRModel<signal.task.internal.designfilt.responsemodels.BaseLpHpModel





    methods
        function this=HighpassIIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('highpassiir');
        end
    end

    methods(Access=protected)

        function specificationSettings=getSpecificationsSettings(this)

            fdesObj=this.pFilterDesignerObj;
            specificationSettings.OrderMode=fdesObj.OrderMode;
            specificationSettings.OrderRestriction='none';
            if lower(string(specificationSettings.OrderMode))=="specify"
                specificationSettings.Order=ensureNumeric(this,fdesObj.Order);
                specificationSettings.SpecifyDenominator=fdesObj.SpecifyDenominator;
                if specificationSettings.SpecifyDenominator
                    specificationSettings.DenominatorOrder=...
                    ensureNumeric(this,fdesObj.DenominatorOrder);
                else
                    specificationSettings.OrderRestriction=getOrderRestriction(this);
                end
            end
        end

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"
                fValuesSettings.F1=ensureNumeric(this,specValues.Fstop);
                fValuesSettings.F1Name='Fstop';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fpass);
                fValuesSettings.F2Name='Fpass';
            else

                s=getActiveFrequencyConstraints(this);







                if s.hasFstop
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fstop);
                    fValuesSettings.F1Name='Fstop';
                    if s.hasFpass
                        fValuesSettings.F2=ensureNumeric(this,specValues.Fpass);
                        fValuesSettings.F2Name='Fpass';
                    end
                elseif s.hasFpass
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fpass);
                    fValuesSettings.F1Name='Fpass';
                elseif s.hasF3db
                    fValuesSettings.F1=ensureNumeric(this,specValues.F3dB);
                    fValuesSettings.F1Name='F3dB';
                end
            end
        end

        function magValuesSettings=getMagnitudeValuesSettings(this)

            magValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);



            hasApass=contains(lower(fdesObj.MagnitudeConstraints),'passband ripple');
            hasAstop=contains(lower(fdesObj.MagnitudeConstraints),'stopband attenuation');




            if hasAstop
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop);
                magValuesSettings.Mag1Name='Astop';
                if hasApass
                    magValuesSettings.Mag2=ensureNumeric(this,specValues.Apass);
                    magValuesSettings.Mag2Name='Apass';
                end
            elseif hasApass
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass);
                magValuesSettings.Mag1Name='Apass';
            end
        end
    end
end

