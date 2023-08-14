function sourceBlocks(obj)






    if isR2017bOrEarlier(obj.ver)
        obj.appendRule(slexportprevious.rulefactory.renameInstanceParameter(...
        '<SourceBlock|"simulink/Sources/Ramp">','InitialOutput','X0',obj.ver));
    end
