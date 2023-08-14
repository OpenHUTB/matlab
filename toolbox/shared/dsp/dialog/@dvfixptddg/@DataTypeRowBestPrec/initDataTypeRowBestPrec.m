function this=initDataTypeRowBestPrec(this,row,controller,customStruct)








    this.Row=row;
    this.Controller=controller;
    this.Block=controller.Block;
    this.Name=customStruct.Name;
    this.Entries=customStruct.Entries;
    this.Prefix=customStruct.Prefix;
    if isfield(customStruct,'ParamBlock')
        this.ParamBlock=customStruct.ParamBlock;
    else
        this.ParamBlock=[];
    end
    if isfield(customStruct,'ParamPropNames')
        this.ParamPropNames=customStruct.ParamPropNames;
    else
        this.ParamPropNames={};
    end
    if isfield(customStruct,'WordLengthOffset')
        this.WordLengthOffset=customStruct.WordLengthOffset;
    else
        this.WordLengthOffset=NaN;
    end
    this.BestPrecString='best precision';

    this.loadFromBlock;

