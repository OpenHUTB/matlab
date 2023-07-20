function this=DigitalFilter(block,varargin)







    [TAPSUM,MULTIPLICAND,STAGEIO,COEFFS,PROD,ACCUM,STATE,OUTPUT]=deal(1,2,3,4,5,6,7,8);

    this=dspdialog.DigitalFilter(block);

    this.init(block);


    otherDTs=cell(8,1);


    otherDTs{TAPSUM}.Name='Tap sum';
    otherDTs{TAPSUM}.Prefix='tapSum';
    otherDTs{TAPSUM}.Entries={'Same as input',...
    'Binary point scaling',...
    'Slope and bias scaling'};


    otherDTs{MULTIPLICAND}.Name='Multiplicand';
    otherDTs{MULTIPLICAND}.Prefix='multiplicand';
    otherDTs{MULTIPLICAND}.Entries={'Same as output',...
    'Binary point scaling',...
    'Slope and bias scaling'};


    otherDTs{STAGEIO}.ParamBlock=this;
    otherDTs{STAGEIO}.Name='Section I/O';
    otherDTs{STAGEIO}.Type='DataTypeRowMultiPrec';
    otherDTs{STAGEIO}.Prefix='stageIO';
    otherDTs{STAGEIO}.Entries={'Same as input',...
    'Binary point scaling',...
    'Slope and bias scaling'};
    otherDTs{STAGEIO}.ParamFuncName='getStageIOInfo';
    otherDTs{STAGEIO}.NumPrecs=2;



    otherDTs{COEFFS}.ParamBlock=this;
    otherDTs{COEFFS}.Name='Coefficients';
    otherDTs{COEFFS}.Type='DataTypeRowMultiPrec';
    otherDTs{COEFFS}.Prefix='firstCoeff';
    otherDTs{COEFFS}.Entries={'Same word length as input',...
    'Specify word length',...
    'Binary point scaling',...
    'Slope and bias scaling'};
    otherDTs{COEFFS}.ParamFuncName='getCoeffPrecInfo';
    otherDTs{COEFFS}.NumPrecs=3;



    otherDTs{PROD}.Name='Product output';
    otherDTs{PROD}.Prefix='prodOutput';
    otherDTs{PROD}.Entries={'Same as input',...
    'Binary point scaling',...
    'Slope and bias scaling'};



    otherDTs{ACCUM}.Name='Accumulator';
    otherDTs{ACCUM}.Prefix='accum';
    otherDTs{ACCUM}.Entries={'Same as input',...
    'Same as product output',...
    'Binary point scaling',...
    'Slope and bias scaling'};



    otherDTs{STATE}.Name='State';
    otherDTs{STATE}.Prefix='memory';
    otherDTs{STATE}.Entries={'Same as input',...
    'Same as accumulator',...
    'Binary point scaling',...
    'Slope and bias scaling'};



    otherDTs{OUTPUT}.Name='Output';
    otherDTs{OUTPUT}.Prefix='output';
    otherDTs{OUTPUT}.Entries={'Same as input',...
    'Same as accumulator',...
    'Binary point scaling',...
    'Slope and bias scaling'};


    this.MaskFixptDialog=dspfixptddg.FixptDialog(this,{},otherDTs);

    this.loadFromBlock;
