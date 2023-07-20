function textList=getTextListImpl(hObj)


    if strcmp(hObj.TextListMode,'auto')
        if strcmp(hObj.LevelListMode,'auto')
            [bUseZRange,zmin,zmax]=useZRange(hObj);
            if bUseZRange
                step=getTextStepImpl(hObj);
                if step>0
                    textList=getContourList(hObj,zmin,zmax,step);
                else
                    textList=[];
                end
            else
                textList=[];
            end
        else
            textList=getLevelListImpl(hObj);
        end
    else
        textList=hObj.TextList_I;
    end
end
