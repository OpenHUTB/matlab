function resetDDC(obj)




    if~isempty(obj.sDDCStage1)
        reset(obj.sDDCStage1);
        reset(obj.sDDCStage2);
        if~obj.sDDCStage3Bypassed
            reset(obj.sDDCStage3);
        end
        if~obj.sDDCOscillatorBypassed
            reset(obj.sDDCOscillator);
        end
    end
end
