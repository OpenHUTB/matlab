function[time,voltage,current]=loadDataFromMatFile(FileName,varargin)












































    p=inputParser;
    p.StructExpand=true;
    p.KeepUnmatched=true;


    p.addParameter('VoltageVariable','',@ischar);
    p.addParameter('CurrentVariable','',@ischar);
    p.addParameter('TimeVariable','',@ischar);
    p.parse(varargin{:});


    VoltageVariable=p.Results.VoltageVariable;
    CurrentVariable=p.Results.CurrentVariable;
    TimeVariable=p.Results.TimeVariable;






    VarInfo=whos('-file',FileName);


    IsTable=strcmp({VarInfo.class},'table');
    if any(IsTable)


        idxTable=find(IsTable,1);
        TableVar=VarInfo(idxTable).name;


        S=load(FileName,TableVar);


        VarNames=S.(TableVar).Properties.VariableNames;
        [VoltageVariable,CurrentVariable,TimeVariable]=i_FindVars(VarNames,VoltageVariable,CurrentVariable,TimeVariable,FileName);


        voltage=S.(TableVar).(VoltageVariable)(:);
        current=S.(TableVar).(CurrentVariable)(:);
        time=S.(TableVar).(TimeVariable)(:);

    else


        VarNames={VarInfo.name};
        [VoltageVariable,CurrentVariable,TimeVariable]=i_FindVars(VarNames,VoltageVariable,CurrentVariable,TimeVariable,FileName);


        S=load(FileName,VoltageVariable,CurrentVariable,TimeVariable);


        voltage=S.(VoltageVariable)(:);
        current=S.(CurrentVariable)(:);
        time=S.(TimeVariable)(:);

    end






    function[VoltageVariable,CurrentVariable,TimeVariable]=i_FindVars(VarNames,VoltageVariable,CurrentVariable,TimeVariable,FileName)






        if isempty(VoltageVariable)
            varIdx=~cellfun(@isempty,regexpi(VarNames,'volt'));
        else
            varIdx=strcmp(VarNames,VoltageVariable);
        end


        if sum(varIdx)==1
            VoltageVariable=VarNames{varIdx};
        else
            error(getString(message('autoblks:autoblkErrorMsg:errVolt',FileName)));
        end


        if isempty(CurrentVariable)
            varIdx=~cellfun(@isempty,regexpi(VarNames,'current|amps'));
        else
            varIdx=strcmp(VarNames,CurrentVariable);
        end


        if sum(varIdx)==1
            CurrentVariable=VarNames{varIdx};
        else
            error(getString(message('autoblks:autoblkErrorMsg:errCurr',FileName)));
        end


        if isempty(TimeVariable)
            varIdx=~cellfun(@isempty,regexpi(VarNames,'time'));
        else
            varIdx=strcmp(VarNames,TimeVariable);
        end


        if sum(varIdx)==1
            TimeVariable=VarNames{varIdx};
        else
            error(getString(message('autoblks:autoblkErrorMsg:errTime',FileName)));
        end