function res=getSLCCGlobalIOData(self)





    res=struct("UndefinedFunctions",string([]),...
    "UndefinedVariables",string([]),...
    "EntryPoints",struct("Name",{}),...
    "GlobalVariables",struct("Name",{},"Type",{},"VariableStatus",{}),...
    "GlobalDictionary",struct("Function",{},"Name",{},"AccessMode",{}),...
    "CallTree",struct("CallerFunction",{},"CalleeFunction",{}),...
    "Errors",[]);

    self.checkObject();
    res.EntryPoints=arrayfun(@(x)struct("Name",x),self.getFunctions('EntryPoints',true));
    vInfoList=self.CodeInsightInfo.Variables.toArray;
    if~isempty(vInfoList)
        isUndef=~[vInfoList.IsDefined];
        allVars=[vInfoList.Variable];
        undefVars=allVars(isUndef);
        res.UndefinedVariables=string({undefVars.Name});
        res.GlobalVariables=arrayfun(@(x)struct("Name",string(x.Name),"Type",string(x.Type.Name),"VariableStatus",""),allVars);
    end

    fInfoList=self.CodeInsightInfo.Functions.toArray;
    for fInfo=fInfoList
        caller=fInfo.Function;

        for callee=fInfo.CalledFuns.toArray
            res.CallTree(end+1)=struct("CallerFunction",string(caller.Name),"CalleeFunction",string(callee.Name));
        end

        globalRead=fInfo.TransitiveReadVars.toArray;
        globalReadDict=arrayfun(@(x)(struct("Function",string(caller.Name),"Name",x.Name,"AccessMode","Read")),globalRead);
        globalWrite=fInfo.TransitiveWrittenVars.toArray;
        globalWriteDict=arrayfun(@(x)(struct("Function",string(caller.Name),"Name",x.Name,"AccessMode","Write")),globalWrite);
        res.GlobalDictionary=[res.GlobalDictionary,globalReadDict,globalWriteDict];
    end

end
