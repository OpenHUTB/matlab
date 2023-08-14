function aCellOfStr=verifyCellOfStrings(aPropName,aCellOfStr)



    if~(iscellstr(aCellOfStr)||isstring(aCellOfStr))
        me=MException('Simulink:tools:CGFEPropertyValueNotCellStr',...
        message('Simulink:tools:CGFEPropertyValueNotCellStr',...
        aPropName));
        me.throw();
    end

    aCellOfStr=cellstr(aCellOfStr);

    if~isempty(aCellOfStr)

        aCellOfStr=aCellOfStr(:)';


        aCellOfStr(cellfun(@isempty,aCellOfStr))=[];


        aCellOfStr=unique(aCellOfStr,'stable');
    end

end


