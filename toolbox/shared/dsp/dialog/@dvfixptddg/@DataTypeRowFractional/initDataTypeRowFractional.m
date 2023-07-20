function this=initDataTypeRowFractional(this,row,controller,customStruct)







    this.Row=row;
    this.Controller=controller;
    this.Block=controller.block;
    this.Name=customStruct.Name;
    this.Entries=customStruct.Entries;
    this.Prefix=customStruct.Prefix;
    if isfield(customStruct,'NumIntegerBits')
        this.NumIntegerBits=customStruct.NumIntegerBits;
    else
        this.NumIntegerBits=1;
    end
    this.BestPrecString='best precision';

    this.isSigned=1;
    if isfield(customStruct,'isSigned')
        this.isSigned=customStruct.isSigned;
    end

    this.SignednessVisible='auto';
    if isfield(customStruct,'alwaysShowSignedness')&&(customStruct.alwaysShowSignedness==1)
        this.SignednessVisible='always';
    end

    if~any(strcmp(customStruct.Entries,getString(message('dspshared:FixptDialog:SpecifyWordLength'))))
        error(message('dspshared:dialog:dataTypeRowFractional'));
    end

    this.loadFromBlock;

