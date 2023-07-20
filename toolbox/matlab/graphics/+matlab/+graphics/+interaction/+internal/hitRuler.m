function ruler=hitRuler(evd)



    ruler=[];
    hitprim=evd.HitPrimitive;

    if~isempty(hitprim)
        ruler=ancestor(hitprim,'matlab.graphics.axis.decorator.Ruler');
    end