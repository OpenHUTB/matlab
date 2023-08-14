function this=Window(block,args)







    this=dspfixptddg.Window(block);

    this.init(block);

    baseDTs{1}.name='prodOutput';
    baseDTs{1}.internalRule=1;

    baseDTs{2}.name='output';
    baseDTs{2}.blockHasProdOut=1;

    otherDTs{1}.Name='Window';
    otherDTs{1}.Prefix='firstCoeff';
    otherDTs{1}.Entries={'Same word length as input',...
    'Specify word length',...
    'Binary point scaling',...
    'Slope and bias scaling'};
    otherDTs{1}.Type='DataTypeRowBestPrec';
    otherDTs{1}.ParamBlock=this;

    otherDTs{1}.ParamPropNames={'intentionally blank'};

    this.FixptDialog=dspfixptddg.FixptDialog(this,baseDTs,otherDTs);

    this.loadFromBlock;

