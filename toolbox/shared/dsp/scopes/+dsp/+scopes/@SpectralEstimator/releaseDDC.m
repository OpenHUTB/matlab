function releaseDDC(obj)




    if~isempty(obj.sDDCStage1)
        release(obj.sDDCStage1);
        release(obj.sDDCStage2);
        if~obj.sDDCStage3Bypassed
            release(obj.sDDCStage3);
        end
        if~obj.sDDCOscillatorBypassed
            release(obj.sDDCOscillator);
        end
    end
end
