


function ConsCheckFlag=checkConstraints(Constraints,input_Permutations)

    ConsCheckFlag=1;

    ComponentList=["Drivers","ActuatorInput","Engines","ElectricalSystem","FirstActuatorInput","Maneuvers","PCM","Transmissions","TransmissionControl","Vehicles"];

    for i=1:length(ComponentList)
        if isfield(input_Permutations,ComponentList(i))
            ConstraintsComponent=Constraints.(ComponentList(i));
            PermutationOption=input_Permutations.(ComponentList(i));
            FindOption=contains(ConstraintsComponent.OptionVariantName,PermutationOption);


            checkConstraints=ConstraintsComponent.Constraints{FindOption};
            for k=1:length(checkConstraints.RequiredComponents)
                if isfield(input_Permutations,checkConstraints.RequiredComponents(k))
                    a=input_Permutations.(checkConstraints.RequiredComponents(k));
                    n=checkConstraints.RequiredOptionIndex(k);
                    b=Constraints.(checkConstraints.RequiredComponents(k)).OptionVariantName(n);
                    if~strcmp(a,b)
                        ConsCheckFlag=0;
                        break
                    end
                end
            end

            for k=1:length(checkConstraints.ExclusiveComponents)
                if isfield(input_Permutations,checkConstraints.ExclusiveComponents(k))
                    a=input_Permutations.(checkConstraints.ExclusiveComponents(k));
                    n=checkConstraints.ExclusiveOptionIndex(k);
                    b=Constraints.(checkConstraints.ExclusiveComponents(k)).OptionVariantName(n);
                    if strcmp(a,b)
                        ConsCheckFlag=0;
                        break
                    end
                end
            end
        end

        if ConsCheckFlag==0
            break
        end
    end
end