function levelStep=getLevelStepImpl(hObj)


    if strcmp(hObj.LevelStepMode,'auto')
        [bUseZRange,zmin,zmax]=useZRange(hObj);
        if bUseZRange
            zrange=zmax-zmin;
            zrange10=10^(floor(log10(zrange)));
            nsteps=zrange/zrange10;
            if nsteps<1.2
                zrange10=zrange10/10;
            elseif nsteps<2.4
                zrange10=zrange10/5;
            elseif nsteps<6
                zrange10=zrange10/2;
            end
            levelStep=zrange10;
        else
            levelStep=0;
        end
    else
        levelStep=hObj.LevelStep_I;
    end
end
