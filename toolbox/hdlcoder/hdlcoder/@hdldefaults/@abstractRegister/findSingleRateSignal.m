function hS=findSingleRateSignal(hC)












    [hS1,rate1]=findSignalAndRate(hC.getInputSignals('data'));
    [hS2,rate2]=findSignalAndRate(hC.getOutputSignals('data'));

    if rationalRate(rate1)
        hS=hS1;

        if rationalRate(rate2)
            assertRatesMatch(rate1,rate2)
        end

    else
        hS=hS2;
    end
end

function[hS,rate]=findSignalAndRate(signals)
    rate=0;
    hS=[];
    for i=1:length(signals)
        currentRate=signals(i).SimulinkRate;
        if rationalRate(currentRate)
            if rate==0
                rate=currentRate;
                hS=signals(i);
            else
                assertRatesMatch(rate,currentRate);
            end
        end
    end
end

function isRational=rationalRate(rate)
    if~isinf(rate)&&rate>0
        isRational=true;
    else
        isRational=false;
    end
end

function assertRatesMatch(rate1,rate2)
    if rate1~=rate2
        error(message('hdlcoder:validate:FoundMultipleRates',hC.Name));
    end
end

