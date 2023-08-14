function[isId,isNaturalText,isColumnEmpty]=classifyContents(textFromCells)



    isId=true(1,size(textFromCells,2));
    dupliCheck=containers.Map('KeyType','char','ValueType','logical');
    isNaturalText=false(1,size(textFromCells,2));
    isColumnEmpty=true(1,size(textFromCells,2));
    for row=1:size(textFromCells,1)
        for col=1:size(textFromCells,2)
            text=textFromCells{row,col};
            if isempty(text)
                isId(col)=false;
            else
                isColumnEmpty(col)=false;
                if any(text==' ')
                    isId(col)=false;
                    if~isNaturalText(col)&&sum(text==' ')>1
                        isNaturalText(col)=true;
                    end
                elseif isId(col)
                    key=sprintf('%s_%d',text,col);
                    if isKey(dupliCheck,key)
                        isId(col)=false;
                    else
                        dupliCheck(key)=true;
                    end
                end
            end
        end
    end
end