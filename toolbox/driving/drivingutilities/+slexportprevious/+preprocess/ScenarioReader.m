function ScenarioReader(obj)
    scenarioReaderRef='drivingscenarioandsensors/Scenario Reader';

    if isR2021aOrEarlier(obj.ver)
        rmParams={'OutputEgoVehicleState','BusName4Source','BusName4'};
        for rndx=1:numel(rmParams)
            obj.appendRule(getRuleRemovePair(scenarioReaderRef,rmParams{rndx},obj));
        end
    end

    if isR2020bOrEarlier(obj.ver)
        rmParams={'BusNumActorsSource','BusNumActors','BusNumLaneBoundariesSource','BusNumLaneBoundaries'};
        for rndx=1:numel(rmParams)
            obj.appendRule(getRuleRemovePair(scenarioReaderRef,rmParams{rndx},obj));
        end
    end

    if isR2019bOrEarlier(obj.ver)
        rmParams={'OrientVehiclesOnRoad','OutputEgoVehiclePose','ShowCoordinateLabels','BusName3Source','BusName3'};
        for rndx=1:numel(rmParams)
            obj.appendRule(getRuleRemovePair(scenarioReaderRef,rmParams{rndx},obj));
        end
    end

    if isR2019aOrEarlier(obj.ver)
        obj.appendRule(getRuleRenameValue(scenarioReaderRef,'EgoVehicleSource',...
        'Scenario','Scenario file',obj));

        rmParams={'ScenarioVariableName','ScenarioSource','EgoVehicleActorID'};
        for rndx=1:numel(rmParams)
            obj.appendRule(getRuleRemovePair(scenarioReaderRef,rmParams{rndx},obj));
        end
    end

    if isR2018bOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'driving.scenario.internal.ScenarioReader');
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

function rule=getRuleRemovePair(scenarioReaderRef,pairName,obj)
    rule=slexportprevious.rulefactory.removeInstanceParameter(['<SourceBlock|"',scenarioReaderRef,'">'],pairName,obj.ver);
end

function pairValue=addQuotesIfRequired(pairValue)
    pairValue=slexportprevious.utils.escapeRuleCharacters(pairValue);
    if any(pairValue==' ')||any(pairValue==newline)||any(pairValue==char(9))
        pairValue=['"',pairValue,'"'];
    end
end
