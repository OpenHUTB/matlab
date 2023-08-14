function setVariableChecked(this,varParser,newCheckedState)

    keyStr=getUniqueKeyStr(varParser);
    isChecked=~this.UncheckedParsers.isKey(keyStr);
    if isChecked&&~newCheckedState
        this.UncheckedParsers.insert(keyStr,true);
    elseif~isChecked&&newCheckedState
        this.UncheckedParsers.deleteDataByKey(keyStr);
    end
end
