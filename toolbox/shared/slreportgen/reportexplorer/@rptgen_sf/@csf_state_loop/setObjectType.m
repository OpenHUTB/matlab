function this=setObjectType(this,objType)











    if islogical(objType)
        this.LockType=objType;
        return;
    end

    this.LockType=false;

    this.isBoxStates=(strcmp(objType,'isBoxStates')||strcmp(objType,'Box'));
    this.isFcnStates=(strcmp(objType,'isFcnStates')||strcmp(objType,'Function'));
    this.isTruthTables=(strcmp(objType,'isTruthTables')||strcmp(objType,'TruthTable'));
    this.isEMFunctions=(strcmp(objType,'isEMFunctions')||strcmp(objType,'EMFunction'));
    this.isSLFunctions=(strcmp(objType,'isSLFunctions')||strcmp(objType,'SLFunction'));
    this.isAndOrStates=(strcmp(objType,'isAndOrStates')||strcmp(objType,'State'));

    this.LockType=true;

