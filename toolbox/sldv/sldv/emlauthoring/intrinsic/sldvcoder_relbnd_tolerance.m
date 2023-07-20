%#codegen
function tol=sldvcoder_relbnd_tolerance(inLarge,inSmall)




    coder.allowpcode('plain');
    coder.extrinsic('sldvprivate');
    absTol=coder.const(sldvprivate('tolabs_gcs'));
    relTol=coder.const(sldvprivate('tolrel_gcs'));

    if(relTol==0.0)
        if(absTol>0.0)
            tol=absTol;
        else
            assert(false,'Bad tolerance setting');
        end
    else
        if(absTol>0.0)
            tol=max(absTol,relTol*max(abs(inLarge),abs(inSmall)));
        else
            tol=relTol*max(abs(inLarge),abs(inSmall));
        end
    end

end