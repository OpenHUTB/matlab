function coderDictionarySubsystemBlock(obj)



    newRules={};

    if isR2019bOrEarlier(obj.ver)

        newRules{end+1}='<Block<BlockType|SubSystem><IsInjectorSS:remove>>';
    end

    if isR2018aOrEarlier(obj.ver)

        newRules{end+1}='<Block<BlockType|SubSystem><Latency:remove>>';

        newRules{end+1}='<Block<BlockType|SubSystem><IsObserver:remove>>';

        newRules{end+1}='<Block<BlockType|SubSystem><AutoFrameSizeCalculation:remove>>';
    end

    if isR2013aOrEarlier(obj.ver)




        params={'RTWSystemCode','MinAlgLoopOccurrences','PropExecContextOutsideSubsystem'};
        newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{1},':remove>>>'];
        newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{2},':remove>>>'];
        newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{3},':remove>>>'];

        if~isR2006aOrEarlier(obj.ver)

            params{end+1}='FunctionWithSeparateData';
            newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{end},':remove>>>'];
        end

        if~isR2007bOrEarlier(obj.ver)

            params{end+1}='Opaque';
            newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{end},':remove>>>'];
        end

        params{end+1}='MaskHideContents';
        newRules{end+1}=['<BlockParameterDefaults<Block<BlockType|SubSystem><',params{end},':remove>>>'];

        subsysBlocks=slexportprevious.utils.findBlockType(obj.modelName,'SubSystem');



        blkParamDefaults=get_param(obj.modelName,'BlockParameterDefaults');

        if(~isempty(subsysBlocks)&&~isempty(blkParamDefaults))

            subsysDefaultsIndex=find(strcmp({blkParamDefaults.BlockType},'SubSystem'),1);








            if(~isempty(subsysDefaultsIndex))
                defaultValues=cell(1,length(params));


                for paramIdx=1:length(params)
                    defaultValues{paramIdx}=eval(['blkParamDefaults(subsysDefaultsIndex).ParameterDefaults.',params{paramIdx}]);
                end

                for i=1:length(subsysBlocks)
                    blk=subsysBlocks{i};
                    if(strcmp(get_param(blk,'LinkStatus'),'resolved'))



                        continue;
                    end
                    for paramIdx=1:length(params)
                        blkParamValue=get_param(blk,params{paramIdx});







                        if strcmp(blkParamValue,defaultValues{paramIdx})
                            if(strcmp(params{paramIdx},'RTWSystemCode'))

                                ParamString=hWrapParameterValueInQuotes(defaultValues{paramIdx});
                            else
                                ParamString=defaultValues{paramIdx};
                            end
                            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blk);
                            newRules{end+1}=slexportprevious.rulefactory.addParameterToBlock(identifyBlock,...
                            params{paramIdx},...
                            ParamString);%#ok
                        end
                    end
                end
            end
        end
    end

    if slfeature('InlinedFunctions')>0&&isR2019aOrEarlier(obj.ver)
        newRules{end+1}='<BlockParameterDefaults<Block<BlockType|SubSystem><FunctionWithInlineKeyword:remove>>>';
    end






    if isR2020aOrEarlier(obj.ver)
        maskedBlocks=find_system(obj.origModelName,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on',...
        'Mask','on');

        for idx=1:numel(maskedBlocks)
            maskObject=get_param(maskedBlocks{idx},'MaskObject');
            maskPrms=maskObject.Parameters;
            VAT_prm=find(contains({maskPrms.Prompt},'VariantActivationTime'));
            for idx1=1:numel(VAT_prm)
                org_typeOpt=maskPrms(idx1).TypeOptions;
                rep_typeOpt=strrep(org_typeOpt,'VariantActivationTime','GeneratePreprocessorConditionals');

                if isR2017aOrEarlier(obj.ver)||~obj.ver.isSLX
                    newRules{end+1}=['<Object<$ClassName|"Simulink.MaskParameter"><Array<Cell|"',org_typeOpt{1},'":repval "',rep_typeOpt{1},'">>>'];
                else
                    newRules{end+1}=['<Mask<MaskParameter<TypeOptions<Option|"',org_typeOpt{1},'":repval "',rep_typeOpt{1},'">>>>'];
                end
            end

        end

    end

    obj.appendRules(newRules);

end


function quotedParamValue=hWrapParameterValueInQuotes(paramValue)

    quotedParamValue=['"',paramValue,'"'];

end
