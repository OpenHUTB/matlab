function ret=isVariableChecked(this,varParser)

    keyStr=getUniqueKeyStr(varParser);
    ret=~this.UncheckedParsers.isKey(keyStr);
end
