classdef BandstopIIRModel<signal.task.internal.designfilt.responsemodels.BaseBpBsModel





    methods
        function this=BandstopIIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('bandstopiir');
        end
    end

    methods(Access=protected)

        function updateMagnitudeValues(this,whatChanged,evtData)






            fdesObj=this.pFilterDesignerObj;
            if strcmp(fdesObj.MagnitudeConstraints,'Passband ripple')
                fdesObj.Apass1=ensureString(this,evtData.Value);
            elseif strcmp(fdesObj.MagnitudeConstraints,'Passband ripples and stopband attenuation')&&strcmp(whatChanged,'Mag1')
                fdesObj.Apass1=ensureString(this,evtData.Value);
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
                fValuesSettings.F1=ensureNumeric(this,specValues.Fpass1);
                fValuesSettings.F1Name='Fpass1';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fstop1);
                fValuesSettings.F2Name='Fstop1';
                fValuesSettings.F3=ensureNumeric(this,specValues.Fstop2);
                fValuesSettings.F3Name='Fstop2';
                fValuesSettings.F4=ensureNumeric(this,specValues.Fpass2);
                fValuesSettings.F4Name='Fpass2';
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
            case 'Passband ripples and stopband attenuation'
                if strcmp(fdesObj.OrderMode,'Minimum')
                    magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass1);
                    magValuesSettings.Mag1Name='Apass1';
                    magValuesSettings.Mag2=ensureNumeric(this,specValues.Astop);
                    magValuesSettings.Mag2Name='Astop';
                    magValuesSettings.Mag3=ensureNumeric(this,specValues.Apass2);
                    magValuesSettings.Mag3Name='Apass2';
                else
                    magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass);
                    magValuesSettings.Mag1Name='Apass';
                    magValuesSettings.Mag2=ensureNumeric(this,specValues.Astop);
                    magValuesSettings.Mag2Name='Astop';
                end
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

