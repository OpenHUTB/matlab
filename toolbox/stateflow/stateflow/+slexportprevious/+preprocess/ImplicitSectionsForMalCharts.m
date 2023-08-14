function ImplicitSectionsForMalCharts(obj)





    if sf('feature','Allow implicit sections in C and MATLAB charts to mean en, du:')

        if~isReleaseOrEarlier(obj.ver,'R2017b')
            return;
        end

        if isR2008aOrEarlier(obj.ver)


        else

            machine=getStateflowMachine(obj);
            if isempty(machine)
                return;
            end

            sf('ConvertImplicitSectionsToExplicitForCChartsInMachine',machine.id,'en, du: ');
            sf('ConvertImplicitSectionsToExplicitForMALChartsInMachine',machine.id,'en, du: ');

        end

    end
end




