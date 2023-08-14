function sfDataObject=hGetRelatedSFData(~,variableIdentifier)





    if variableIdentifier.isStruct
        idx=strfind(variableIdentifier.VariableName,'.');
        varName=variableIdentifier.VariableName(1:idx(1)-1);
    else
        varName=variableIdentifier.VariableName;
    end


    mlBlk=variableIdentifier.getMATLABFunctionBlock;

    sfDataObject=[];
    if variableIdentifier.IsArgin
        if~variableIdentifier.MATLABFunctionIdentifier.IsRootFunc
            return;
        end

        sfDataObject=find(mlBlk,...
        '-isa','Stateflow.Data',...
        'Name',varName,...
        'Scope','Input');%#ok<GTARG>
        if isempty(sfDataObject)
            sfDataObject=find(mlBlk,...
            '-isa','Stateflow.Data',...
            'Name',varName,...
            'Scope','Parameter');%#ok<GTARG>
        end
    elseif variableIdentifier.IsArgout
        if~variableIdentifier.MATLABFunctionIdentifier.IsRootFunc
            return;
        end

        sfDataObject=find(mlBlk,...
        '-isa','Stateflow.Data',...
        'Name',varName,...
        'Scope','Output');%#ok<GTARG>


    else

        sfDataObject=find(mlBlk,...
        '-isa','Stateflow.Data',...
        'Name',varName,...
        'Scope','Data Store Memory');%#ok<GTARG>

    end

