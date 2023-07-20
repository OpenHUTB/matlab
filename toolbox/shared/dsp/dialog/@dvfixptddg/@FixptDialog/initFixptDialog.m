function this=initFixptDialog(this,controller,baseDTs,otherDTs,extraOp)







    this.Controller=controller;
    this.Block=controller.block;
    this.ExtraOp=extraOp;


    this.hasLockScale=isfield(this.Block.DialogParameters,'LockScale');

    this.TotalOpRows=1;
    ExtraDTypeRows=[];
    for ind=1:length(extraOp)
        if isempty(extraOp(ind).UserData)
            extraOp(ind).UserData='FixptOP';
        end
        rowspan=extraOp(ind).DialogSchema.RowSpan;
        switch extraOp(ind).UserData
        case 'FixptOP'
            this.TotalOpRows=this.TotalOpRows+1;
        case 'FixptDType'
            ExtraDTypeRows=cat(2,ExtraDTypeRows,rowspan(1):rowspan(2));
        end
    end

    ExtraDTypeRows=unique(ExtraDTypeRows);

    this.TotalDataTypeRows=1+this.hasLockScale+length(ExtraDTypeRows);

    baseLength=length(baseDTs);
    otherLength=length(otherDTs);
    baseOffset=otherLength+1;
    otherOffset=1;


    dtRows=matlab.internal.defaultObjectArray(1,baseLength+otherLength);

    row=1+baseOffset;
    row=row+sum(ExtraDTypeRows<=row);
    for ind=1:baseLength
        while any(row==ExtraDTypeRows)
            row=row+1;
        end
        dtRows(ind)=dvfixptddg.DataTypeRow(baseDTs{ind},...
        row,...
        controller);
        row=row+1;
    end

    row=1+otherOffset;
    row=row+sum(ExtraDTypeRows<=row);
    for ind=1:otherLength
        while any(row==ExtraDTypeRows)
            row=row+1;
        end
        if isfield(otherDTs{ind},'Type')
            dtRows(ind+baseLength)=...
            dvfixptddg.(otherDTs{ind}.Type)(row,...
            controller,...
            otherDTs{ind});
        else
            customType.name='custom';
            dtRows(ind+baseLength)=dvfixptddg.DataTypeRow(customType,...
            row,...
            controller,...
            otherDTs{ind});
        end
        row=row+1;
    end

    this.DataTypeRows=dtRows;

    this.TotalDataTypeRows=this.TotalDataTypeRows+length(this.DataTypeRows);

    this.loadFromBlock;
