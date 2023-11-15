function doseTable=getDoseTable(doseObjects,UnitsOn,units)

    doseTable=cell(size(doseObjects));

    for i=1:size(doseTable,1)
        for j=1:size(doseTable,2)
            obj=doseObjects(i,j);
            [time,amount,rate]=SimBiology.internal.dose2mat(obj);

            if isempty(rate)
                rate=zeros(size(time));
            end

            if UnitsOn
                time=sbiounitcalculator(obj.TimeUnits,units.TimeUnits,time);
                if SimBiology.internal.isMass(obj.AmountUnits)
                    amount=sbiounitcalculator(obj.AmountUnits,units.MassUnits,amount);
                else
                    amount=sbiounitcalculator(obj.AmountUnits,units.AmountUnits,amount);
                end

                if any(rate~=0)


                    if SimBiology.internal.isMass(obj.RateUnits)
                        rate=sbiounitcalculator(obj.RateUnits,[units.MassUnits,'/',units.TimeUnits],rate);
                    else
                        rate=sbiounitcalculator(obj.RateUnits,[units.AmountUnits,'/',units.TimeUnits],rate);
                    end
                end
            end

            doseTable{i,j}=[time(:),amount(:),rate(:)];
        end
    end
end