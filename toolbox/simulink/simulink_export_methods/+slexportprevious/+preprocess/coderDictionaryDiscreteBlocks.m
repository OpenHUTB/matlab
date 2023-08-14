function coderDictionaryDiscreteBlocks(obj)




    newRules={};

    if isR2017bOrEarlier(obj.ver)

        newRules{end+1}='<Block<BlockType|DiscreteFir><StateName:remove>>';
        newRules{end+1}='<Block<BlockType|DiscreteFir><StateMustResolveToSignalObject:remove>>';
        newRules{end+1}='<Block<BlockType|DiscreteFir><StateSignalObject:remove>>';
        newRules{end+1}='<Block<BlockType|DiscreteFir><StateStorageClass:remove>>';
        newRules{end+1}='<Block<BlockType|DiscreteFir><RTWStateStorageTypeQualifier:remove>>';
        newRules{end+1}='<Block<BlockType|DiscreteFir><RTWStateStorageClass:remove>>';
    end



    if isR2017bOrEarlier(obj.ver)
        newRules{end+1}=slexportprevious.rulefactory.renameInstanceParameter(...
        '<SourceBlock|"simulink/Additional Math\n&& Discrete/Additional\nDiscrete/Fixed-Point\nState-Space">',...
        'InitialCondition','X0',obj.ver);
    end




    if isR2017bOrEarlier(obj.ver)


        blks=find_system(obj.origModelName,'RegExp','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'AttributesFormatString','.*%<InitialCondition>.*');
        for idx=1:numel(blks)
            blk=blks{idx};
            currentValue=get_param(blk,'AttributesFormatString');
            if isempty(regexp(currentValue,'%<InitialCondition>','match'))
                continue
            end
            splitCurrentVal=regexp(currentValue,'%<InitialCondition>','split');
            newValue='';
            for i=1:numel(splitCurrentVal)-1
                newValue=[splitCurrentVal{i},'%<X0>'];
            end
            newValue=[newValue,splitCurrentVal{end}];
            newRules{end+1}=['<AttributesFormatString|"',currentValue,'":repval "',newValue,'">'];
        end
    end




    if isR2017aOrEarlier(obj.ver)
        newRules{end+1}='<Block<BlockType|DiscreteFilter><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|DiscreteIntegrator><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|DiscreteStateSpace><InitialCondition:rename X0>>';
        newRules{end+1}='<Block<BlockType|DiscreteStateSpace><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|DiscreteTransferFcn><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|DiscreteZeroPole><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|Memory><InitialCondition:rename X0>>';
        newRules{end+1}='<Block<BlockType|Memory><StateName:rename StateIdentifier>>';
        newRules{end+1}='<Block<BlockType|RateTransition><InitialCondition:rename X0>>';
    end


    if isR2011aOrEarlier(obj.ver)
        import slexportprevious.rulefactory.*
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Discrete/Difference');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Discrete/Discrete Derivative');
        newRules{end+1}=removeInSourceBlock('InputProcessing','simulink/Discrete/Transfer Fcn\nReal Zero');
        newRules{end+1}='<Block<SourceBlock|"simulink/Discrete/Difference"><LibraryVersion:repval 0.000>>';
        newRules{end+1}='<Block<SourceBlock|"simulink/Discrete/Discrete Derivative"><LibraryVersion:repval 0.000>>';
        newRules{end+1}='<Block<SourceBlock|"simulink/Discrete/Transfer Fcn\nReal Zero"><LibraryVersion:repval 0.000>>';
    end

    obj.appendRules(newRules)
