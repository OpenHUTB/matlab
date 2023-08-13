function VisionDetectionGenerator(obj)
    visionDetGenRef='drivingscenarioandsensors/Vision Detection Generator';

    if isR2020aOrEarlier(obj.ver)
        obj.appendRule(getRuleRenameValue(visionDetGenRef,'ActorProfilesSource',...
        'From Scenario Reader block','Parameters',obj));
    end


    if isR2018bOrEarlier(obj.ver)

        newRef='drivingscenarioandsensors/Vision Detection Generator';
        oldRef='drivinglib/Vision Detection Generator';
        obj.appendRule(['<ExternalFileReference<Reference|"',newRef,'":repval "',oldRef,'">>']);
        obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);
    end


    if isR2017aOrEarlier(obj.ver)



        blks=findBlocksWithMaskType(obj,'visionDetectionGenerator');
        obj.replaceWithEmptySubsystem(blks);
    end

end

function rule=getRuleRenameValue(scenarioReaderRef,param,newVal,oldVal,obj)
    if obj.ver.isMDL
        rule=['<Block<SourceBlock|"',scenarioReaderRef,'"><',param...
        ,'|',addQuotesIfRequired(newVal),':repval ',addQuotesIfRequired(oldVal),'>>'];
    else
        rule=['<Block<SourceBlock|"',scenarioReaderRef,'"><InstanceData<',param...
        ,'|',addQuotesIfRequired(newVal),':repval ',addQuotesIfRequired(oldVal),'>>>'];
    end
end





function pairValue=addQuotesIfRequired(pairValue)
    pairValue=slexportprevious.utils.escapeRuleCharacters(pairValue);
    if any(pairValue==' ')||any(pairValue==newline)||any(pairValue==char(9))
        pairValue=['"',pairValue,'"'];
    end
end
