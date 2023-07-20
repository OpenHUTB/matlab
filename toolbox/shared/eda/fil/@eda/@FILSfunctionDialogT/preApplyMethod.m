function[status,errMsg]=preApplyMethod(this,dialog)




    status=1;
    errMsg='';


    genericExprDropDown=eda.internal.filhost.DTypeSpecT.expVarOrFunc_;

    this.dialogState.bitstreamFile=dialog.getWidgetValue('bitFileEdit');
    if dialog.isWidgetValid('ipAddressEdit')
        this.dialogState.IPAddress=dialog.getWidgetValue('ipAddressEdit');
        this.dialogState.Username=dialog.getWidgetValue('usernameEdit');
        this.dialogState.Password=dialog.getWidgetValue('passwordEdit');
    end
...
...
...
...
...
    this.params.overclocking=l_comboToParam(dialog,'ocCombo',genericExprDropDown);
    this.params.inputFrameSize=l_comboToParam(dialog,'inFSCombo',genericExprDropDown);
    this.params.outputFrameSize=l_comboToParam(dialog,'outFSCombo',genericExprDropDown);

    this.dialogState.loadStatus=dialog.getWidgetValue('loadStatus');

    try
        for row=2:(this.params.getNumInputPorts()+this.params.getNumOutputPorts()+1)
            [currPort,portDir,portNum]=l_getCurrPort(this,row);
            rowtag=['r',num2str(row)];

            stWidgetVal=dialog.getWidgetValue(['stime_',rowtag,'c4']);
            dtWidgetVal=dialog.getWidgetValue(['dtype_',rowtag,'c5']);

            if(any(strcmp(genericExprDropDown,{stWidgetVal,dtWidgetVal})))
                genstr=regexprep(genericExprDropDown,'[<>]','');
                throw(MException('fil:sfuncddg:MustDefinePortPExpression',...
                ['Specify a valid ',genstr,' for ',portDir,' ',num2str(portNum),' (''',currPort.name,''').']));
            end

            currPort.sampleTime=eda.internal.filhost.STimeSpecT(stWidgetVal);
            currPort.dtypeSpec=eda.internal.filhost.DTypeSpecT(dtWidgetVal);

            switch(portDir)
            case 'InputPort'
                this.params.inputPorts(portNum)=currPort;
            case 'OutputPort'
                this.params.outputPorts(portNum)=currPort;
            end
        end
    catch ME
        status=0;
        errMsg=ME.message;
        return;
    end



    this.params.dialogState=this.dialogState;


    this.block.UserData=this.params;

end

function objVal=l_comboToParam(dialog,tag,genericExpr)
    wval=dialog.getWidgetValue(tag);
    if(strcmp(genericExpr,wval))
        genstr=regexprep(genericExpr,'[<>]','');
        throw(MException('fil:sfuncddg:MustDefineBlockPExpression',...
        ['Specify a valid ',genstr,' for the parameter.']));
    end
    objVal=eda.internal.filhost.InhUint32T(wval);
end

function[currPort,portDir,portNum]=l_getCurrPort(this,row)
    portRow=row-1;
    numIns=this.params.getNumInputPorts;

    if(portRow<=numIns)
        portNum=portRow;
        portDir='InputPort';
        currPort=this.params.inputPorts(portNum);
    else
        portNum=portRow-numIns;
        portDir='OutputPort';
        currPort=this.params.outputPorts(portNum);
    end
end
