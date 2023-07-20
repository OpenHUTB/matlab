classdef Three_PhaseV_IMeasuremen_class<ConvClass&handle



    properties

        OldParam=struct(...
        'LabelV',[],...
        'LabelI',[],...
        'Pbase',[],...
        'Vbase',[],...
        'PSBequivalent',[]...
        )


        OldDropdown=struct(...
        'VoltageMeasurement',[],...
        'CurrentMeasurement',[],...
        'OutputType',[],...
        'SetLabelV',[],...
        'Vpu',[],...
        'VpuLL',[],...
        'SetLabelI',[],...
        'Ipu',[],...
        'PhasorSimulation',[]...
        )


        NewDirectParam=struct(...
        'SRated',[],...
        'VRated',[],...
        'GotoTagV',[],...
        'GotoTagI',[]...
        )


        NewDerivedParam=struct(...
        'VG',[],...
        'IG',[]...
        )


        NewDropdown=struct(...
        'vMeasurementType',[],...
        'outputUnit',[]...
        )


        BlockOption={...
        {'VoltageMeasurement','no';'CurrentMeasurement','no'},'VnoIno';...

        {'VoltageMeasurement','no';'CurrentMeasurement','yes';'SetLabelI','off'},'VnoIyes';...
        {'VoltageMeasurement','no';'CurrentMeasurement','yes';'SetLabelI','on'},'VnoIyesL';...

        {'VoltageMeasurement','phase-to-phase';'SetLabelV','off';'CurrentMeasurement','no'},'VyesIno';...
        {'VoltageMeasurement','phase-to-phase';'SetLabelV','on';'CurrentMeasurement','no'},'VyesLIno';...

        {'VoltageMeasurement','phase-to-ground';'SetLabelV','off';'CurrentMeasurement','no'},'VyesIno';...
        {'VoltageMeasurement','phase-to-ground';'SetLabelV','on';'CurrentMeasurement','no'},'VyesLIno';...

        {'VoltageMeasurement','phase-to-phase';'SetLabelV','off';'CurrentMeasurement','yes';'SetLabelI','off'},'VyesIyes';...
        {'VoltageMeasurement','phase-to-phase';'SetLabelV','off';'CurrentMeasurement','yes';'SetLabelI','on'},'VyesIyesL';...
        {'VoltageMeasurement','phase-to-phase';'SetLabelV','on';'CurrentMeasurement','yes';'SetLabelI','off'},'VyesLIyes';...
        {'VoltageMeasurement','phase-to-phase';'SetLabelV','on';'CurrentMeasurement','yes';'SetLabelI','on'},'VyesLIyesL';...

        {'VoltageMeasurement','phase-to-ground';'SetLabelV','off';'CurrentMeasurement','yes';'SetLabelI','off'},'VyesIyes';...
        {'VoltageMeasurement','phase-to-ground';'SetLabelV','off';'CurrentMeasurement','yes';'SetLabelI','on'},'VyesIyesL';...
        {'VoltageMeasurement','phase-to-ground';'SetLabelV','on';'CurrentMeasurement','yes';'SetLabelI','off'},'VyesLIyes';...
        {'VoltageMeasurement','phase-to-ground';'SetLabelV','on';'CurrentMeasurement','yes';'SetLabelI','on'},'VyesLIyesL';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Measurements/Three-Phase V-I Measurement'
        NewPath='elec_conv_Three_PhaseV_IMeasuremen/Three_PhaseV_IMeasuremen'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.SRated=obj.OldParam.Pbase;
            obj.NewDirectParam.VRated=obj.OldParam.Vbase;
            obj.NewDirectParam.GotoTagV=obj.OldParam.LabelV;
            obj.NewDirectParam.GotoTagI=obj.OldParam.LabelI;
        end


        function obj=Three_PhaseV_IMeasuremen_class(VoltageMeasurement,CurrentMeasurement,Vpu,VpuLL,Ipu,Pbase,Vbase)
            if nargin>0
                obj.OldDropdown.VoltageMeasurement=VoltageMeasurement;
                obj.OldDropdown.CurrentMeasurement=CurrentMeasurement;
                obj.OldDropdown.Vpu=Vpu;
                obj.OldDropdown.VpuLL=VpuLL;
                obj.OldDropdown.Ipu=Ipu;
                obj.OldParam.Pbase=Pbase;
                obj.OldParam.Vbase=Vbase;
            end
        end


        function obj=objParamMappingDerived(obj)


            obj.NewDerivedParam.VG=1;
            obj.NewDerivedParam.IG=1;

            if strcmp(obj.OldDropdown.VoltageMeasurement,'no')&&strcmp(obj.OldDropdown.CurrentMeasurement,'no')

            elseif(~strcmp(obj.OldDropdown.VoltageMeasurement,'no'))&&strcmp(obj.OldDropdown.CurrentMeasurement,'no')
                if strcmp(obj.OldDropdown.VoltageMeasurement,'phase-to-phase')
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')

                    elseif strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')

                        obj.NewDerivedParam.VG=sqrt(3);
                    else

                    end
                else
                    if strcmp(obj.OldDropdown.Vpu,'off')

                    else

                    end
                end
            elseif strcmp(obj.OldDropdown.VoltageMeasurement,'no')&&strcmp(obj.OldDropdown.CurrentMeasurement,'yes')
                if strcmp(obj.OldDropdown.Ipu,'off')

                else

                end
            else
                if strcmp(obj.OldDropdown.VoltageMeasurement,'phase-to-phase')
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'off')

                    else

                        if strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'off')
                            obj.NewDerivedParam.VG=sqrt(3);
                            obj.NewDerivedParam.IG=sqrt(2/3)*obj.OldParam.Pbase/obj.OldParam.Vbase;
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'on')&&strcmp(obj.OldDropdown.Ipu,'off')
                            obj.NewDerivedParam.IG=sqrt(2/3)*obj.OldParam.Pbase/obj.OldParam.Vbase;
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                            obj.NewDerivedParam.VG=obj.OldParam.Vbase*sqrt(2);
                        elseif strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                            obj.NewDerivedParam.VG=sqrt(3);
                        else
                        end
                    end
                else
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.Ipu,'off')

                    else

                        if strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.Ipu,'off')
                            obj.NewDerivedParam.IG=sqrt(2/3)*obj.OldParam.Pbase/obj.OldParam.Vbase;
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                            obj.NewDerivedParam.VG=obj.OldParam.Vbase*sqrt(2/3);
                        else
                        end
                    end
                end

            end
        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.VoltageMeasurement,'no')&&strcmp(obj.OldDropdown.CurrentMeasurement,'no')

            elseif(~strcmp(obj.OldDropdown.VoltageMeasurement,'no'))&&strcmp(obj.OldDropdown.CurrentMeasurement,'no')
                if strcmp(obj.OldDropdown.VoltageMeasurement,'phase-to-phase')
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')
                        obj.NewDropdown.outputUnit='2';
                    elseif strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')
                        obj.NewDropdown.outputUnit='1';

                    else
                        obj.NewDropdown.outputUnit='1';
                    end
                else
                    if strcmp(obj.OldDropdown.Vpu,'off')
                        obj.NewDropdown.outputUnit='2';
                    else
                        obj.NewDropdown.outputUnit='1';
                    end
                end
            elseif strcmp(obj.OldDropdown.VoltageMeasurement,'no')&&strcmp(obj.OldDropdown.CurrentMeasurement,'yes')
                if strcmp(obj.OldDropdown.Ipu,'off')
                    obj.NewDropdown.outputUnit='2';
                else
                    obj.NewDropdown.outputUnit='1';
                end
            else
                if strcmp(obj.OldDropdown.VoltageMeasurement,'phase-to-phase')
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'off')
                        obj.NewDropdown.outputUnit='2';
                    else
                        obj.NewDropdown.outputUnit='1';
                        if strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'off')
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'on')&&strcmp(obj.OldDropdown.Ipu,'off')
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                        elseif strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.VpuLL,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                        else
                        end
                    end
                else
                    if strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.Ipu,'off')
                        obj.NewDropdown.outputUnit='2';
                    else
                        obj.NewDropdown.outputUnit='1';
                        if strcmp(obj.OldDropdown.Vpu,'on')&&strcmp(obj.OldDropdown.Ipu,'off')
                        elseif strcmp(obj.OldDropdown.Vpu,'off')&&strcmp(obj.OldDropdown.Ipu,'on')
                        else
                        end
                    end
                end

            end

            switch obj.OldDropdown.VoltageMeasurement
            case 'phase-to-phase'
                obj.NewDropdown.vMeasurementType='1';
            case 'phase-to-ground'
                obj.NewDropdown.vMeasurementType='2';
            otherwise
                obj.NewDropdown.vMeasurementType='1';
            end


            if strcmp(obj.OldDropdown.PhasorSimulation,'on')
                switch obj.OldDropdown.OutputType
                case 'Complex'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Complex');
                case 'Real-Imag'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Real-Imag');
                case 'Magnitude-Angle'
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Magnitude-Angle');
                otherwise
                    logObj.addMessage(obj,'OptionNotSupported','Output signal','Magnitude');
                end
            end

        end
    end

end
