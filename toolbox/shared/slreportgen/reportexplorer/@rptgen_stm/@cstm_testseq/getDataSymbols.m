function getDataSymbols(this,d,sect,testSeq)





    dataSymbol=testSeq.find(...
    '-isa','Stateflow.Data',...
    '-or','-isa','Stateflow.Message',...
    '-or','-isa','Stateflow.FunctionCall',...
    '-or','-isa','Stateflow.Trigger');
    nDataSymbol=numel(dataSymbol);

    if(nDataSymbol<1)

        return
    end


    adSL=rptgen_sl.appdata_sl;
    currentModel=adSL.CurrentModel;
    compiledModelList=adSL.CompiledModelList;
    compileStatus=true;
    if~(compiledModelList.search(currentModel)==1)
        compileStatus=false;
        rptgen.displayMessage(getString(message('RptgenSL:rstm_cstm_testseq:notCompiledWarning')),2);
    end


    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:dataSymbols')));
    setAttribute(elem,'role','bold');
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    inputDataSym={};
    outputDataSym={};
    localDataSym={};
    constDataSym={};
    paramDataSym={};
    dsmDataSym={};

    for i=1:nDataSymbol
        currDataSymbol=dataSymbol(i);
        if isa(currDataSymbol,'Stateflow.FunctionCall')...
            ||isa(currDataSymbol,'Stateflow.Trigger')

            s=struct('Name',currDataSymbol.Name,...
            'DataType','',...
            'Size','');
        elseif compileStatus

            s=struct('Name',currDataSymbol.Name,...
            'DataType',currDataSymbol.CompiledType,...
            'Size',currDataSymbol.CompiledSize);
        else

            s=struct('Name',currDataSymbol.Name,...
            'DataType',currDataSymbol.DataType,...
            'Size',currDataSymbol.Props.Array.Size);
        end


        switch currDataSymbol.Scope
        case 'Input'
            s.Class=strrep(class(currDataSymbol),'Stateflow.','');
            s.Port=currDataSymbol.Port;
            inputDataSym{end+1}=s;%#ok<AGROW>
        case 'Output'
            s.Class=strrep(class(currDataSymbol),'Stateflow.','');
            s.Port=currDataSymbol.Port;
            outputDataSym{end+1}=s;%#ok<AGROW>
        case 'Local'
            localDataSym{end+1}=s;%#ok<AGROW>
        case 'Constant'
            s.Value=currDataSymbol.Props.InitialValue;
            constDataSym{end+1}=s;%#ok<AGROW>
        case 'Parameter'
            paramDataSym{end+1}=s;%#ok<AGROW>
        case 'Data Store Memory'
            dsmDataSym{end+1}=s;%#ok<AGROW>
        end
    end

    if~isempty(inputDataSym)

        makeInputDataSymTable(this,d,sect,inputDataSym,compileStatus);
    end

    if~isempty(outputDataSym)

        makeOutputDataSymTable(this,d,sect,outputDataSym,compileStatus);
    end

    if~isempty(localDataSym)

        makeLocalDataSymTable(this,d,sect,localDataSym,compileStatus);
    end

    if~isempty(constDataSym)

        makeConstDataSymTable(this,d,sect,constDataSym,compileStatus);
    end

    if~isempty(paramDataSym)

        makeParamDataSymTable(this,d,sect,paramDataSym,compileStatus);
    end

    if~isempty(dsmDataSym)

        makeDSMDataSymTable(this,d,sect,dsmDataSym,compileStatus);
    end


    if~compileStatus
        noteElem=createElement(d,'emphasis',...
        getString(message('RptgenSL:rstm_cstm_testseq:note')));
        setAttribute(noteElem,'role','bold');
        warningElem=createElement(d,'emphasis',...
        getString(message('RptgenSL:rstm_cstm_testseq:notCompiledWarning')));
        para=createElement(d,'para');
        appendChild(para,noteElem);
        appendChild(para,warningElem);
        appendChild(sect,para);
    end
end
