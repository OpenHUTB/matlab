function result=checkRates(~,sigs)



    result=[];
    ratesMatch=checkSignalRates(sigs);

    if~ratesMatch
        result=hdlvalidatestruct(1,message('hdlcoder:validate:mismatchedRates'));
    end




    function allMatch=checkSignalRates(signals)
        allMatch=true;
        singleRate=[];
        if~isempty(signals)
            for i=1:length(signals)
                currentRate=signals(i).SimulinkRate;
                if~isinf(currentRate)&&currentRate~=-1
                    if isempty(singleRate)
                        singleRate=currentRate;
                    else
                        if currentRate~=singleRate
                            allMatch=false;
                            break;
                        end
                    end
                end
            end
        end
