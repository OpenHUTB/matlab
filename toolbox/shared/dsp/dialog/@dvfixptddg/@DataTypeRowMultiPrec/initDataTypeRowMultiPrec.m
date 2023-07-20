function this=initDataTypeRowMultiPrec(this,row,controller,customStruct)








    this.Row=row;
    this.Controller=controller;
    this.Block=controller.Block;
    this.Name=customStruct.Name;
    this.Entries=customStruct.Entries;
    this.Prefix=customStruct.Prefix;
    this.ParamBlock=customStruct.ParamBlock;
    this.ParamFuncName=customStruct.ParamFuncName;
    this.NumPrecs=customStruct.NumPrecs;



    maskNames=this.ParamBlock.(this.ParamFuncName)('MASK_NAMES');
    this.MaskPropNames{1}=maskNames{1};
    this.PropNames{1}='FracLength';
    this.SlopeTags{1}='Slope1';
    for ind=2:this.NumPrecs
        this.MaskPropNames{ind}=maskNames{ind};
        this.PropNames{ind}=['FracLength',num2str(ind)];
        this.SlopeTags{ind}=['Slope',num2str(ind)];
        schema.prop(this,this.PropNames{ind},'string');
    end

    this.loadFromBlock;


