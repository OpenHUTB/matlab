function detectBlocks(obj)






    if isR2011aOrEarlier(obj.ver)


        import slexportprevious.rulefactory.*
        newRules={};
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect\nIncrease');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect\nDecrease');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect\nChange');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect Rise\nPositive');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect Rise\nNonnegative');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect Fall\nNegative');
        newRules{end+1}=removeInSourceBlock('OutDataTypeStr','simulink/Logic and Bit\nOperations/Detect Fall\nNonpositive');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect\nIncrease');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect\nDecrease');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect\nChange');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect Rise\nPositive');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect Rise\nNonnegative');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect Fall\nNegative');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Logic and Bit\nOperations/Detect Fall\nNonpositive');

        if isR2011a(obj.ver)||isR2010b(obj.ver)||isR2010a(obj.ver)||isR2009b(obj.ver)

            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect\nIncrease"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect\nDecrease"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect\nChange"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect Rise\nPositive"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect Rise\nNonnegative"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect Fall\nNegative"><LibraryVersion:repval 0.000>>';
            newRules{end+1}='<Block<SourceBlock|"simulink/Logic and Bit\nOperations/Detect Fall\nNonpositive"><LibraryVersion:repval 0.000>>';
        end
        obj.appendRules(newRules);
    end

