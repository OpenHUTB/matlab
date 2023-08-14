function levelList=getLevelListImpl(hObj)




    if strcmp(hObj.LevelListMode,'auto')
        [bUseZRange,zmin,zmax]=useZRange(hObj);
        if bUseZRange
            step=getLevelStepImpl(hObj);
            if step>0
                newValue=getContourList(hObj,zmin,zmax,step);
                if~strcmp(hObj.FaceColor,'none')&&(newValue(1)~=zmin)
                    newValue=[zmin,newValue];
                end
                levelList=newValue;
            else
                levelList=[];
            end
        else
            levelList=[];
        end
    else
        levelList=hObj.LevelList_I;
    end
end
