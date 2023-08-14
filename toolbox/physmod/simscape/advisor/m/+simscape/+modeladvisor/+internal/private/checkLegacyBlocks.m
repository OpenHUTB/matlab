function obj=checkLegacyBlocks(objType)


    checkId='checkLegacySimscapeBlocks';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,@actionCallback,...
    context='None',...
    checkedByDefault=false,...
    style='DetailStyle');
end



function ResultDescription=checkCallback(system,CheckObj)
    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    legacyBlks=getLegacyBlks(system);
    legacyMap=getLegacyMap();

    results=ModelAdvisor.ResultDetail.empty;
    for i=1:height(legacyBlks)
        blk=legacyBlks{i,1};
        sf=legacyBlks{i,2};
        results=[results,advise(getInstance(legacyMap(sf)),blk)];
    end

    if isempty(results)

        results=ModelAdvisor.ResultDetail;
        results.IsInformer=true;
        results.Status=lGetMsg('NoBlocksFound');
        mdladvObj.setCheckResultStatus('pass');
        mdladvObj.setActionEnable(false);
    else
        mdladvObj.setActionEnable(true);
    end

    CheckObj.setResultDetails(results);
end

function result=actionCallback(taskobj)
    mdladvObj=taskobj.MAObj;
    legacyBlks=getLegacyBlks(mdladvObj.System);
    legacyMap=getLegacyMap();

    ft1=ModelAdvisor.FormatTemplate('TableTemplate');
    ft1.setColTitles({lGetMsg('Block'),lGetMsg('ActionResult')});

    for i=1:height(legacyBlks)
        blk=legacyBlks{i,1};
        sf=legacyBlks{i,2};
        result=upgrade(getInstance(legacyMap(sf)),blk);
        if islogical(result)&&result
            result=lGetMsg('Updated');
        end
        ft1.addRow({blk,result});
    end

    result=ft1;
end


function out=getLegacyMap()
    out=simscape.internal.upgradeadvisor.LegacyPackageRepository();
end

function out=getInstance(clsname)
    out=feval(clsname);
end

function out=getLegacyBlks(system)
    out={};
    sscBlks=find_system(system,MatchFilter=@Simulink.match.allVariants,BlockType='SimscapeBlock');
    legacyMap=getLegacyMap();
    for i=1:numel(sscBlks)
        blk=sscBlks{i};
        sf=get_param(blk,'SourceFile');
        if legacyMap.isKey(sf)
            out(end+1,:)={blk,sf};
        end
    end
end

function msg=lGetMsg(id)
    messageCatalog='physmod:simscape:advisor:modeladvisor:checkLegacySimscapeBlocks';
    msg=DAStudio.message([messageCatalog,':',id]);
end