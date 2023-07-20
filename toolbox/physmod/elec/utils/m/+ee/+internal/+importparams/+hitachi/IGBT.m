classdef IGBT<ee.internal.importparams.hitachi.Format





    properties(Constant)
        ReferenceBlock=sprintf('ee_lib/Semiconductors &\nConverters/IGBT\n(Ideal,\nSwitching)');
    end
    properties
        ValidVariants={'ee.semiconductors.ideal.igbt_thermal'};

        MetadataMap=struct('dependent',...
        {{'Manufacturer','Package.vendorAttribute';...
        'PartNumber','Package.partnumberAttribute';...
        'ParameterizationNote','Package.Comment.Line';...
        }},...
        'fixed',...
        {{'PartSeries','';...
        'PartType','IGBT';...
        'WebLink','';...
        }});

        ParametersMap=struct('dependent',...
        {{...
        'Iout_data','Package.SemiconductorData.ConductionLoss.CurrentAxis';...
        'Tj','Package.SemiconductorData.ConductionLoss.TemperatureAxis';...
        'Von_data','Package.SemiconductorData.ConductionLoss.VoltageDrop';...
...
        'Iout_data_loss','Package.SemiconductorData.TurnOnLoss.CurrentAxis';...
        'Tj_loss','Package.SemiconductorData.TurnOnLoss.TemperatureAxis';...
        'Voff','Package.SemiconductorData.TurnOnLoss.VoltageAxis';...
        'Eon_data','Package.SemiconductorData.TurnOnLoss.Energy';...
        'Eoff_data','Package.SemiconductorData.TurnOffLoss.Energy';...
...
        'thermal_network_parameterization','Package.ThermalModel.Branch.typeAttribute';...
        'thermal_mass_parameterization','Package.ThermalModel.Branch.typeAttribute';...
        'Rth_Foster',{'Package.ThermalModel.Branch.typeAttribute',...
        'Package.ThermalModel.Branch.RTauElement'};...
        'thermal_time_constant_Foster',{'Package.ThermalModel.Branch.typeAttribute',...
        'Package.ThermalModel.Branch.RTauElement'};...
        'Rth_Cauer',{'Package.ThermalModel.Branch.typeAttribute',...
        'Package.ThermalModel.Branch.RCElement'};...
        'thermal_mass_Cauer',{'Package.ThermalModel.Branch.typeAttribute',...
        'Package.ThermalModel.Branch.RCElement'};...

        }},...
        'fixed',...
        {{...

        'thermal_loss_option','ee.enum.converters.thermalLossOption.tabulated2d';...
        'diode_param','ee.enum.converters.protectiondiode.none';...

        'Iout_data_unit','A';...
        'Tj_unit','degC';...
        'Von_data_unit','V';...
        'Iout_data_loss_unit','A';...
        'Tj_loss_unit','degC';...
        'Voff_unit','V';...
        'Eon_data_unit','J';...
        'Eoff_data_unit','J';...
        'Rth_Foster_unit','K/W';...
        'thermal_time_constant_Foster_unit','s';...
        'Rth_Cauer_unit','K/W';...
        'thermal_time_constant_Cauer_unit','s';...
        }});

    end


    methods

        function dependParamsValueCell=computeDependentParamsValue(obj)

            targetCell=obj.ParametersMap.dependent(:,1);
            sourceCell=obj.ParametersMap.dependent(:,2);
            dependParamsValueCell=cell(size(targetCell));

            for paramIdx=1:length(targetCell)

                thisTarget=targetCell{paramIdx};
                thisSource=sourceCell{paramIdx};


                try

                    switch thisTarget

                    case{'Eon_data','Eoff_data'}






                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        targetValue=obj.arrayFromStruct(structNode,thisSource);

                        validateValueFromXML(targetValue,thisSource,'double');

                        if all(targetValue(:,1,:)==0)


                            squeezedTargetValue=squeeze(targetValue(:,end,:));
                            if length(targetValue(:,1,1))==1


                                targetValue=squeezedTargetValue(:)';
                            else
                                targetValue=squeezedTargetValue;
                            end
                        else
                            pm_error('physmod:ee:importparams:igbt:InvalidSwitchingLoss')
                        end

                    case 'Voff'



                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        targetValue=obj.arrayFromStruct(structNode);
                        validateValueFromXML(targetValue,thisSource,'double');

                        if targetValue(1)==0
                            if length(targetValue)==2
                                targetValue=targetValue(2);
                            else


                                pm_warning('physmod:ee:importparams:igbt:InvalidValueSubstitution',thisTarget,mat2str(targetValue),mat2str(targetValue(end)))
                                targetValue=targetValue(end);
                            end
                        else


                            pm_error('physmod:ee:importparams:igbt:InvalidVoffNonzeroFirstVoltage');
                        end

                    case 'thermal_network_parameterization'



                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(structNode,'Foster')
                            targetValue='ee.enum.thermalNetworkTopology.foster';
                        elseif strcmp(structNode,'Cauer')
                            targetValue='ee.enum.thermalNetworkTopology.cauer';
                        else
                            pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkType',structNode)
                        end

                    case 'thermal_mass_parameterization'


                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(structNode,'Foster')
                            targetValue='ee.enum.thermalNetwork.timeconstant';
                        elseif strcmp(structNode,'Cauer')
                            targetValue='ee.enum.thermalNetwork.thermalmass';
                        else
                            pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkType',structNode)
                        end


                    case 'Rth_Foster'


                        tempSource=thisSource{1};
                        fieldCell=strsplit(tempSource,'.');
                        typeNetwork=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(typeNetwork,'Foster')


                            tempSource=thisSource{2};
                            fieldCell=strsplit(tempSource,'.');
                            try
                                structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                                targetValue=cat(2,structNode(:).RAttribute);
                                validateValueFromXML(targetValue,thisSource,'double');
                            catch
                                pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkParameter',structNode)
                            end
                        else

                            [paramNames,paramValues]=obj.getNamesValues();
                            targetValue=paramValues{strcmp(paramNames,thisTarget)};
                        end

                    case 'thermal_time_constant_Foster'


                        tempSource=thisSource{1};
                        fieldCell=strsplit(tempSource,'.');
                        typeNetwork=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(typeNetwork,'Foster')


                            tempSource=thisSource{2};
                            fieldCell=strsplit(tempSource,'.');
                            try
                                structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                                targetValue=cat(2,structNode(:).TauAttribute);
                                validateValueFromXML(targetValue,thisSource,'double');
                            catch
                                pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkParameter',structNode)
                            end
                        else

                            [paramNames,paramValues]=obj.getNamesValues();
                            targetValue=paramValues{strcmp(paramNames,thisTarget)};
                        end

                    case 'Rth_Cauer'


                        tempSource=thisSource{1};
                        fieldCell=strsplit(tempSource,'.');
                        typeNetwork=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(typeNetwork,'Cauer')


                            tempSource=thisSource{2};
                            fieldCell=strsplit(tempSource,'.');
                            try
                                structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                                targetValue=cat(2,structNode(:).RAttribute);
                                validateValueFromXML(targetValue,thisSource,'double');
                            catch
                                pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkParameter',structNode)
                            end
                        else

                            [paramNames,paramValues]=obj.getNamesValues();
                            targetValue=paramValues{strcmp(paramNames,thisTarget)};
                        end

                    case 'thermal_mass_Cauer'


                        tempSource=thisSource{1};
                        fieldCell=strsplit(tempSource,'.');
                        typeNetwork=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(typeNetwork,'Cauer')


                            tempSource=thisSource{2};
                            fieldCell=strsplit(tempSource,'.');
                            try
                                structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                                targetValue=cat(2,structNode(:).CAttribute);
                                validateValueFromXML(targetValue,thisSource,'double');
                            catch
                                pm_error('physmod:ee:importparams:igbt:InvalidThermalNetworkParameter',structNode)
                            end
                        else

                            [paramNames,paramValues]=obj.getNamesValues();
                            targetValue=paramValues{strcmp(paramNames,thisTarget)};
                        end



                    otherwise

                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        targetValue=obj.arrayFromStruct(structNode,thisSource);
                        validateValueFromXML(targetValue,thisSource,'double');

                    end
                catch ME





                    if any(strcmp(ME.identifier,{'MATLAB:nonExistentField','MATLAB:noSuchMethodOrField'}))&&...
                        contains(ME.message,fieldCell{end})


                        if iscell(thisSource)
                            pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',thisSource{1});
                        else
                            pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',thisSource);
                        end
                    else
                        rethrow(ME);
                    end

                end

                dependParamsValueCell{paramIdx}=targetValue;

            end





            idx_Iout_data=strcmp(targetCell,'Iout_data');
            Iout_data=dependParamsValueCell{idx_Iout_data};
            if Iout_data(1)==0
                idx_Von_data=strcmp(targetCell,'Von_data');
                Von_data=dependParamsValueCell{idx_Von_data};
                if any(Von_data(:,1)~=0)

                    pm_warning('physmod:ee:importparams:igbt:InvalidValueSubstitution',sourceCell{idx_Iout_data},num2str(Iout_data(1)),num2str(0.1*Iout_data(2)))
                    Iout_data(1)=0.1*Iout_data(2);
                    dependParamsValueCell{idx_Iout_data}=Iout_data;
                end

            end





            I_off_source='Package.SemiconductorData.TurnOffLoss.CurrentAxis';
            T_off_source='Package.SemiconductorData.TurnOffLoss.TemperatureAxis';


            fieldCell=strsplit(I_off_source,'.');
            structNode=getfield(obj.getSourceStruct(),fieldCell{:});
            Iout_data_loss_off=obj.arrayFromStruct(structNode);

            fieldCell=strsplit(T_off_source,'.');
            structNode=getfield(obj.getSourceStruct(),fieldCell{:});
            Tj_loss_off=obj.arrayFromStruct(structNode);


            I_out_data_loss_on=dependParamsValueCell{strcmp(targetCell,'Iout_data_loss')};
            Tj_loss_on=dependParamsValueCell{strcmp(targetCell,'Tj_loss')};

            if~isequal(Iout_data_loss_off,I_out_data_loss_on)||~isequal(Tj_loss_off,Tj_loss_on)
                pm_error('physmod:ee:importparams:igbt:IncompatibleSwitchingLossAxis')
            end

        end

    end

end

function validateValueFromXML(value,SourceField,expectedType)



    if isempty(value)
        pm_error('physmod:ee:importparams:igbt:EmptyFieldInXml',SourceField);
    elseif~isa(value,expectedType)
        pm_error('physmod:ee:importparams:igbt:InvalidFieldFormat',SourceField);
    end
end

