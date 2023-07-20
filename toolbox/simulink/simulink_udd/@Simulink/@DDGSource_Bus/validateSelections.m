function modArray=validateSelections(this,inArray,data)





    modArray=inArray;
    for i=1:length(inArray)
        delimArray=this.str2CellArr(inArray{i},'.');
        currData=data;
        preStr='';

        for k=1:length(delimArray)
            currName=delimArray{k};
            found=0;
            for j=1:length(currData)
                compareName=currData(j).name;

                if strcmp(currName,compareName)
                    found=1;
                    if~isempty(currData(j).signals)
                        currData=currData(j).signals;
                    end
                    break;
                end
            end
            if(found==0)
                preStr='??? ';
                break;
            end
        end
        modArray{i}=[preStr,inArray{i}];
    end
end
