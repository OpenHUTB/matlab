classdef BandpassIIRModel<signal.task.internal.designfilt.responsemodels.BaseBpBsModel





    methods
        function this=BandpassIIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('bandpassiir');
        end
    end

    methods(Access=protected)

        function updateMagnitudeValues(this,whatChanged,evtData)%#ok<INUSL>



            fdesObj=this.pFilterDesignerObj;
            if strcmp(fdesObj.MagnitudeConstraints,'Stopband attenuation')
                fdesObj.Astop1=ensureString(this,evtData.Value);
            else
                fdesObj.(evtData.Source.UserData)=ensureString(this,evtData.Value);
            end
        end

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"||...
                strcmp(fdesObj.FrequencyConstraints,'Passband and stopband edges')
                fValuesSettings.F1=ensureNumeric(this,specValues.Fstop1);
                fValuesSettings.F1Name='Fstop1';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fpass1);
                fValuesSettings.F2Name='Fpass1';
                fValuesSettings.F3=ensureNumeric(this,specValues.Fpass2);
                fValuesSettings.F3Name='Fpass2';
                fValuesSettings.F4=ensureNumeric(this,specValues.Fstop2);
                fValuesSettings.F4Name='Fstop2';
            else






                switch fdesObj.FrequencyConstraints
                case 'Passband edges'
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fpass1);
                    fValuesSettings.F1Name='Fpass1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.Fpass2);
                    fValuesSettings.F2Name='Fpass2';
                case 'Stopband edges'
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fstop1);
                    fValuesSettings.F1Name='Fstop1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.Fstop2);
                    fValuesSettings.F2Name='Fstop2';
                case '3dB points'
                    fValuesSettings.F1=ensureNumeric(this,specValues.F3dB1);
                    fValuesSettings.F1Name='F3dB1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.F3dB2);
                    fValuesSettings.F2Name='F3dB2';
                end
            end
        end

        function magValuesSettings=getMagnitudeValuesSettings(this)

            magValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);




            switch fdesObj.MagnitudeConstraints
            case 'Passband ripple and stopband attenuations'
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop1);
                magValuesSettings.Mag1Name='Astop1';
                magValuesSettings.Mag2=ensureNumeric(this,specValues.Apass);
                magValuesSettings.Mag2Name='Apass';
                magValuesSettings.Mag3=ensureNumeric(this,specValues.Astop2);
                magValuesSettings.Mag3Name='Astop2';
            case 'Passband ripple'
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass);
                magValuesSettings.Mag1Name='Apass';
            case 'Stopband attenuation'
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop);
                magValuesSettings.Mag1Name='Astop';
            end
        end

        function restriction=getOrderRestriction(~)

            restriction='even';
        end
    end
end

