function this=FixptDialog(controller,baseDTs,otherDTs,extraOp)



















    this=dspfixptddg.FixptDialog;
    if nargin<3
        otherDTs={};
    end
    if nargin<4
        extraOp=[];
    end
    this.initFixptDialog(controller,baseDTs,otherDTs,extraOp);


