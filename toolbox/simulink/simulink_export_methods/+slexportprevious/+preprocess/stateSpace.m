function stateSpace(obj)








    if isR2017aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|StateSpace><InitialCondition:rename X0>>');
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
            obj.appendRule(['<AttributesFormatString|"',currentValue,'":repval "',newValue,'">']);
        end
    end


end

