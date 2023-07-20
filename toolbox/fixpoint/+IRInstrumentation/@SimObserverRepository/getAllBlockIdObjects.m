function allBlockIdObj=getAllBlockIdObjects(this)




    cnt=this.ModelBlockIdObjMap.getCount;
    if cnt>0
        for i=1:cnt
            allBlockIdObj(i)=this.ModelBlockIdObjMap.getDataByIndex(i);%#ok<AGROW>
        end
    else
        allBlockIdObj=[];
    end
end
