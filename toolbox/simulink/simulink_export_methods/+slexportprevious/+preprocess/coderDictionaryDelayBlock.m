function coderDictionaryDelayBlock(obj)




    blkType='Delay';

    if isR2016aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|Delay><RemoveDelayLengthCheckInGeneratedCode:rename RemoveProtectionDelayLength>>');
        obj.appendRule('<Block<BlockType|Delay><DiagnosticForDelayLength:rename DiagnosticForOutOfRangeDelayLength>>');
    end
    if isR2014bOrEarlier(obj.ver)
        delayBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(isempty(delayBlks))
            return;
        end

        for i=1:length(delayBlks)
            blk=delayBlks{i};

            if strcmp(get_param(blk,'ShowEnablePort'),'off')
                continue;
            end


            obj.replaceWithEmptySubsystem(blk);
        end


        obj.appendRule('<Block<BlockType|Delay><ShowEnablePort:remove>>');
    end

    if isR2011aOrEarlier(obj.ver)


        delayBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);

        if(isempty(delayBlks))
            return;
        end

        useLink=false(size(delayBlks));
        newDelayLen=cell(size(delayBlks));

        for i=1:length(delayBlks)
            blk=delayBlks{i};
            if(i_canBeReplacedByIntegerDelayBlock(blk))
                useLink(i)=true;
                if isDelayLengthCompatibleWithIntegerDelayBlock(blk)
                    newDelayLen{i}=get_param(blk,'DelayLength');
                else
                    obj.helper.reportWarning('Simulink:ExportPrevious:ReplacedDelayBlock',getfullname(blk));
                    newDelayLen{i}='1';
                end
            end
        end

        obj.replaceWithEmptySubsystem(delayBlks(~useLink));

        delayBlks=delayBlks(useLink);
        obj.replaceWithLibraryLink(delayBlks,'simulink/Discrete/Integer Delay',...
        {'samptime','SampleTime';...
        'vinit','InitialCondition';...
        'NumDelays','DelayLength';...
        'InputProcessing','InputProcessing'});

        if~isR2010aOrEarlier(obj.ver)
            for i=1:length(delayBlks)
                blk=delayBlks{i};
                aVal=struct('hasInheritedOption',1);
                set_param(blk,'UserData',aVal,'UserDataPersistent','on');
            end
        end
    end

    if isR2010aOrEarlier(obj.ver)
        obj.appendRule(slexportprevious.rulefactory.removeInSourceBlock('InputProcessing','simulink/Discrete/Integer Delay'));
    end
end



function result=i_canBeReplacedByIntegerDelayBlock(blk)


    prmVal=get_param(blk,'DelayLengthSource');
    if~strcmp(prmVal,'Dialog')
        result=false;
        return;
    end


    prmVal=get_param(blk,'InitialConditionSource');
    if~strcmp(prmVal,'Dialog')
        result=false;
        return;
    end


    prmVal=get_param(blk,'StateName');
    if~isempty(prmVal)
        result=false;
        return;
    end


    prmVal=get_param(blk,'ExternalReset');
    if~strcmp(prmVal,'None')
        result=false;
        return;
    end



    result=true;
    return;

end

function result=isDelayLengthCompatibleWithIntegerDelayBlock(blk)

    prmStr=get_param(blk,'DelayLength');
    prmVal=slResolve(prmStr,blk);
    if~isa(prmVal,'double')
        result=false;
        return;
    end


    if prmVal<=0
        result=false;
        return;
    end

    result=true;
    return;
end
