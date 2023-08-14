classdef Diode<ee.internal.importparams.hitachi.Format





    properties(Constant)
        ReferenceBlock=sprintf('ee_lib/Semiconductors &\nConverters/Diode');
    end

    properties
        ValidVariants={'ee.semiconductors.diode_thermal'};

        MetadataMap=struct('dependent',...
        {{'Manufacturer','Package.vendorAttribute';...
        'PartNumber','Package.partnumberAttribute';...
        'ParameterizationNote','Package.Comment.Line';...
        }},...
        'fixed',...
        {{'PartSeries','';...
        'PartType','Diode';...
        'WebLink','';...
        }});

        ParametersMap=struct('dependent',...
        {{...
        'IfVec','Package.SemiconductorData.ConductionLoss.CurrentAxis';...
        'TjVec','Package.SemiconductorData.ConductionLoss.TemperatureAxis';...
        'VfMat','Package.SemiconductorData.ConductionLoss.VoltageDrop';...
...
        'IfrecVec','Package.SemiconductorData.TurnOffLoss.CurrentAxis';...
        'TjrecVec','Package.SemiconductorData.TurnOffLoss.TemperatureAxis';...
        'VrecVal','Package.SemiconductorData.TurnOffLoss.VoltageAxis';...
        'ErecMat','Package.SemiconductorData.TurnOffLoss.Energy';...
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

        'fidelity_level','ee.enum.diode.fidelity.idealSwitch';...
        'ModelType','ee.enum.diode.modelType.tabulated';...
        'TableType','ee.enum.diode.tableType.VfMat';...
        'rec_loss_model','ee.enum.diode.reverseRecoveryModel.tabulated2d';...

        'IfVec_unit','A';...
        'TjVec_unit','degC';...
        'VfMat_unit','V';...
        'IfrecVec_unit','A';...
        'TjrecVec_unit','degC';...
        'VrecVal_unit','V';...
        'ErecMat_unit','J';...
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

                    case 'ErecMat'






                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        targetValue=obj.arrayFromStruct(structNode,thisSource);

                        validateValueFromXML(targetValue,thisSource,'double');

                        if all(targetValue(:,end,:)==0)


                            squeezedTargetValue=squeeze(targetValue(:,1,:));
                            if length(targetValue(:,1,1))==1


                                targetValue=squeezedTargetValue(:)';
                            else
                                targetValue=squeezedTargetValue;
                            end
                        else
                            pm_error('physmod:ee:importparams:diode:InvalidReverseRecoveryLoss')
                        end

                    case 'VrecVal'





                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        targetValue=obj.arrayFromStruct(structNode);
                        validateValueFromXML(targetValue,thisSource,'double');

                        if targetValue(end)==0
                            if length(targetValue)>2


                                pm_warning('physmod:ee:importparams:diode:InvalidValueSubstitution',thisTarget,mat2str(targetValue),mat2str(-1*targetValue(1)))
                            end
                            targetValue=-targetValue(1);
                        else


                            pm_error('physmod:ee:importparams:diode:InvalidVrecValNonzeroLastVoltage');
                        end

                    case 'thermal_network_parameterization'



                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(structNode,'Foster')
                            targetValue='ee.enum.thermalNetworkTopology.foster';
                        elseif strcmp(structNode,'Cauer')
                            targetValue='ee.enum.thermalNetworkTopology.cauer';
                        else
                            pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkType',structNode)
                        end

                    case 'thermal_mass_parameterization'


                        fieldCell=strsplit(thisSource,'.');
                        structNode=getfield(obj.getSourceStruct(),fieldCell{:});
                        if strcmp(structNode,'Foster')
                            targetValue='ee.enum.thermalNetwork.timeconstant';
                        elseif strcmp(structNode,'Cauer')
                            targetValue='ee.enum.thermalNetwork.thermalmass';
                        else
                            pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkType',structNode)
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
                                pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkParameter',structNode)
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
                                pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkParameter',structNode)
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
                                pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkParameter',structNode)
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
                                pm_error('physmod:ee:importparams:diode:InvalidThermalNetworkParameter',structNode)
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





            idx_IfVec=strcmp(targetCell,'IfVec');
            IfVec=dependParamsValueCell{idx_IfVec};
            if IfVec(1)==0
                idx_VfMat=strcmp(targetCell,'VfMat');
                VfMat=dependParamsValueCell{idx_VfMat};
                if any(VfMat(:,1)~=0)

                    pm_warning('physmod:ee:importparams:diode:InvalidValueSubstitution',sourceCell{idx_IfVec},num2str(IfVec(1)),num2str(0.1*IfVec(2)))
                    IfVec(1)=0.1*IfVec(2);
                    dependParamsValueCell{idx_IfVec}=IfVec;
                end

            end

        end

    end

end

function validateValueFromXML(value,SourceField,expectedType)



    if isempty(value)
        pm_error('physmod:ee:importparams:diode:EmptyFieldInXml',SourceField);
    elseif~isa(value,expectedType)
        pm_error('physmod:ee:importparams:diode:InvalidFieldFormat',SourceField);
    end
end

