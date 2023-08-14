function replaceData=setData(dataToSet,~,item)






    if iscell(dataToSet)
        replaceData=dataToSet';
        for id=1:length(replaceData)
            replaceData{id}=replaceData{id}(1,1:end-1);
            if any(strcmp(item.DataType,{'logical','boolean'}))

                for col=2:length(replaceData{id})

                    if~ischar(replaceData{id}{1,col})
                        if replaceData{id}{1,col}==0
                            replaceData{id}{1,col}='false';
                        else
                            replaceData{id}{1,col}='true';
                        end
                    end
                end
            end
        end
    else
        replaceData=dataToSet(1:end,1:end-1);
    end
end
