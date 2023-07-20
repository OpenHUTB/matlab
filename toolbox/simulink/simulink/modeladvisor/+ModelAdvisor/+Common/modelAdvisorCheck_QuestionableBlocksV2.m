













function[bResultStatus,ResultDescription,ResultHandles]=...
    modelAdvisorCheck_QuestionableBlocksV2(system,confCommand,xlateTagPrefix)

    ResultDescription={};
    ResultHandles={};


    NoMAMode=false;
    if strncmp(system,'NoMAMode:',9)
        system=system(10:end);
        NoMAMode=true;
    end

    if NoMAMode
        theID='_SYS_BP_EC_mathworks.codegen.PCGSupport';
    else
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        theID=defineJumpId(mdladvObj);
    end

    allBlocks=getAllBlocks(system);

    allBlocks=Advisor.Utils.Simulink.standardFilter(system,allBlocks);




    filterStruct=readConfiguration(confCommand);

    filteredBlocks=generalFilter(allBlocks);
    if~NoMAMode
        filteredBlocks=...
        mdladvObj.filterResultWithExclusion(filteredBlocks);
    end

    questionableBlocks=cell(0,1);
    allFootnotesCodegen=cell(0,1);
    allFootnotesProduction=cell(0,1);

    for idx=1:length(filteredBlocks)

        block=filteredBlocks{idx};
        blockDetails=getBlockDetails(block);
        result=analyzeBlockDetails(blockDetails,filterStruct);

        if result.questionable

            questionableBlocks{end+1}=block;%#ok<AGROW>

            allFootnotesCodegen=unique(...
            [allFootnotesCodegen,result.footnotesCodegen],'stable');
            allFootnotesProduction=unique(...
            [allFootnotesProduction,result.footnotesProduction],'stable');

        end

    end

    allFootnotes=unique([allFootnotesCodegen,allFootnotesProduction],'stable');
    hasFootnotes=~isempty(allFootnotes);
    ignoreProduction=filterStruct.ignoreProduction;
    bResultStatus=isempty(questionableBlocks);

    ftTable=ModelAdvisor.FormatTemplate('TableTemplate');
    ftTable.SubBar=0;

    defineInformation(ftTable,ignoreProduction,xlateTagPrefix);
    if bResultStatus
        ftTable.setSubResultStatus('Pass');
        defineSubResultStatusTextPass(ftTable,ignoreProduction,xlateTagPrefix);
    else
        ftTable.setSubResultStatus('Warn');
        defineSubResultStatusTextFail(ftTable,ignoreProduction,xlateTagPrefix);
        defineRecAction(ftTable,ignoreProduction,hasFootnotes,xlateTagPrefix);
        defineResultsTable(ftTable,ignoreProduction,questionableBlocks,...
        allFootnotes,filterStruct,xlateTagPrefix,theID);
    end
    ResultDescription{end+1}=ftTable;
    ResultHandles{end+1}=[];


    if~bResultStatus&&hasFootnotes


        ftFootHead=ModelAdvisor.Paragraph;

        ftFootHead.addItem(...
        ['<a id="',theID,'">',...
        DAStudio.message([xlateTagPrefix,'QB_SupportNotes']),...
        '</a>']);
        ResultDescription{end+1}=ftFootHead;
        ResultHandles{end+1}=[];


        ftFootList=ModelAdvisor.List;
        ftFootList.setType('Numbered');
        for idx=1:length(allFootnotes)
            descriptionString=getFootnoteText(allFootnotes{idx});
            ftFootList.addItem(descriptionString);
        end
        ResultDescription{end+1}=ftFootList;
        ResultHandles{end+1}=[];

    end

end

function id=defineJumpId(mdladvObj)
    fullId=mdladvObj.LatestRunID;
    if isempty(fullId)

        fullId=mdladvObj.getActiveCheck;
    end
    id=fullId;

    id=strrep(id,'SYSTEM','SYS');
    id=strrep(id,'By Product','BP');
    id=strrep(id,'By Task','BT');
    id=strrep(id,'Embedded Coder','EC');
    id=strrep(id,'Simulink Check','SLCK');
end











function defineInformation(ftTable,ignoreProduction,xlateTagPrefix)
    if ignoreProduction
        ftTable.setInformation(...
        DAStudio.message([xlateTagPrefix,'QB_CG_TitleTips']));
    else
        ftTable.setInformation(...
        DAStudio.message([xlateTagPrefix,'QB_PR_TitleTips']));
    end
end

function defineSubResultStatusTextPass(ftTable,ignoreProduction,xlateTagPrefix)
    if ignoreProduction
        ftTable.setSubResultStatusText(...
        DAStudio.message([xlateTagPrefix,'QB_CG_ResultPass']));
    else
        ftTable.setSubResultStatusText(...
        DAStudio.message([xlateTagPrefix,'QB_PR_ResultPass']));
    end
end

function defineSubResultStatusTextFail(ftTable,ignoreProduction,xlateTagPrefix)
    if ignoreProduction
        ftTable.setSubResultStatusText(...
        DAStudio.message([xlateTagPrefix,'QB_CG_ResultFail']));
    else
        ftTable.setSubResultStatusText(...
        DAStudio.message([xlateTagPrefix,'QB_PR_ResultFail']));
    end
end

function defineRecAction(ftTable,ignoreProduction,hasFootnotes,xlateTagPrefix)
    if ignoreProduction
        recAction=DAStudio.message([xlateTagPrefix,'QB_CG_Action']);
        if hasFootnotes
            recAction=[recAction,' ',...
            DAStudio.message([xlateTagPrefix,'QB_CG_ActionFootnote'])];
        end
    else
        recAction=DAStudio.message([xlateTagPrefix,'QB_PR_Action']);
        if hasFootnotes
            recAction=[recAction,' ',...
            DAStudio.message([xlateTagPrefix,'QB_PR_ActionFootnote'])];
        end
    end
    ftTable.setRecAction(recAction);
end

function defineColTitles(ftTable,ignoreProduction,xlateTagPrefix)
    if ignoreProduction
        colTitles={...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleBlock']),...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleType']),...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleCodegen'])};
    else
        colTitles={...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleBlock']),...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleType']),...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleCodegen']),...
        DAStudio.message([xlateTagPrefix,'QB_TabTitleProduction'])};
    end
    ftTable.setColTitles(colTitles);
end

function defineResultsTable(ftTable,ignoreProduction,questionableBlocks,...
    allFootnotes,filterStruct,xlateTagPrefix,theID)

    defineColTitles(ftTable,ignoreProduction,xlateTagPrefix);

    for idx=1:length(questionableBlocks)

        block=questionableBlocks{idx};
        capabilitySet=getCapabilitySet(block);
        codegen=capabilitySet.supports('codegen');
        production=capabilitySet.supports('production');
        blockDetails=getBlockDetails(block);
        result=analyzeBlockDetails(blockDetails,filterStruct);
        type=getBlockType(block);

        footnotesCodegen=getFootnotesReference(...
        result.footnotesCodegen,allFootnotes,theID);
        footnotesProduction=getFootnotesReference(...
        result.footnotesProduction,allFootnotes,theID);

        if ignoreProduction
            codegen=[codegen,footnotesCodegen];%#ok<AGROW>
            ftTable.addRow({block,type,codegen});
        else
            codegen=[codegen,footnotesCodegen];%#ok<AGROW>
            production=[production,footnotesProduction];%#ok<AGROW>
            ftTable.addRow({block,type,codegen,production});
        end

    end

end

function type=getBlockType(block)
    type=get_param(block,'BlockType');
    if strcmp(type,'SubSystem')
        MaskType=get_param(block,'MaskType');
        if~isempty(MaskType)
            type=MaskType;
        end
    end
end

function filterStruct=readConfiguration(confCommand)

    list=eval(confCommand);

    if isempty(list)
        listCodegen={};
        listProduction={};
    else
        listCodegen=list(strcmp('codegen',list(:,1)),2);
        listProduction=list(strcmp('production',list(:,1)),2);
    end

    emptyProduction=strcmp('',listProduction);

    filterStruct.filterCodegen=listCodegen;
    filterStruct.filterProduction=listProduction(~emptyProduction);

    if any(emptyProduction)
        filterStruct.ignoreProduction=true;
    else
        filterStruct.ignoreProduction=false;
    end
end












































function details=getBlockDetails(block)

    capabilitySet=getCapabilitySet(block);

    supportsCodegen=capabilitySet.supports('codegen');
    supportsProduction=capabilitySet.supports('production');
    footnotesCodegen=capabilitySet.footnotes('codegen');
    footnotesProduction=capabilitySet.footnotes('production');

    if isempty(footnotesCodegen)
        footnotesCodegen={};
    else
        footnotesCodegen=regexp(footnotesCodegen,',','split');
    end

    if isempty(footnotesProduction)
        footnotesProduction={};
    else
        footnotesProduction=regexp(footnotesProduction,',','split');
    end

    details.supportsCodegen=supportsCodegen;
    details.supportsProduction=supportsProduction;
    details.footnotesCodegen=footnotesCodegen;
    details.footnotesProduction=footnotesProduction;

end

function outputBlocks=generalFilter(inputBlocks)

    counter=0;
    outputBlocks=cell(size(inputBlocks));

    for idx=1:length(inputBlocks)

        block=inputBlocks{idx};
        capabilitySet=getCapabilitySet(block);

        if~isempty(capabilitySet)

            supportsCodegen=capabilitySet.supports('codegen');
            supportsProduction=capabilitySet.supports('production');
            footnotesCodegen=capabilitySet.footnotes('codegen');
            footnotesProduction=capabilitySet.footnotes('production');

            condition1=strcmp(supportsCodegen,'No');
            condition2=strcmp(supportsProduction,'No');
            condition3=~isempty(footnotesCodegen);
            condition4=~isempty(footnotesProduction);

            if condition1||condition2||condition3||condition4

                counter=counter+1;
                outputBlocks{counter}=inputBlocks{idx};

            end

        end

    end

    if counter<length(inputBlocks)
        outputBlocks(counter+1:end)=[];
    end

end

function result=analyzeBlockDetails(blockDetails,filterStruct)

    supportsCodegen=strcmp(blockDetails.supportsCodegen,'Yes');
    supportsProduction=strcmp(blockDetails.supportsProduction,'Yes');
    footnotesCodegen=blockDetails.footnotesCodegen;
    footnotesProduction=blockDetails.footnotesProduction;
    ignoreProduction=filterStruct.ignoreProduction;
    filterCodegen=filterStruct.filterCodegen;
    filterProduction=filterStruct.filterProduction;

    if ignoreProduction

        if isempty(footnotesCodegen)

            if supportsCodegen
                questionable=false;
            else
                questionable=true;
            end

        else

            footnotesCodegen(ismember(footnotesCodegen,filterCodegen))=[];
            if isempty(footnotesCodegen)
                questionable=false;
            else
                questionable=true;
            end

        end

    else

        if isempty(footnotesCodegen)&&isempty(footnotesProduction)

            if supportsCodegen&&supportsProduction
                questionable=false;
            else
                questionable=true;
            end

        else

            footnotesCodegen(ismember(footnotesCodegen,filterCodegen))=[];
            footnotesProduction(ismember(footnotesProduction,filterProduction))=[];
            if isempty(footnotesCodegen)&&isempty(footnotesProduction)
                questionable=false;
            else
                questionable=true;
            end

        end

    end

    result.questionable=questionable;
    result.footnotesCodegen=footnotesCodegen;
    result.footnotesProduction=footnotesProduction;

end

function text=getFootnoteText(footnote)

    temp=regexp(footnote,'(\S*)_(\S*)','tokens');
    if isempty(temp)
        messageString=sprintf('Simulink:bcst:%s',footnote);
    else
        tokens=temp{1};
        messageString=sprintf('%s:bcst:%s',tokens{1},tokens{2});
    end
    try
        text=DAStudio.message(messageString);
    catch
        text=footnote;
    end
end

function string=getFootnotesReference(footnotes,allFootnotes,theID)

    string='';

    for idx=1:length(footnotes)

        ref=find(strcmp(footnotes{idx},allFootnotes));
        footnoteTitle=getFootnoteText(footnotes{idx});

        footnoteTitle=regexprep(footnoteTitle,'<[^<]*>','');










        onClick=sprintf('var ele = document.getElementById(''%s''); ele.scrollIntoView(true); return false;',theID);

        if idx==1
            string=sprintf('<a href="#" onclick="%s" title="%s">%d</a>',...
            onClick,footnoteTitle,ref);
        else
            string=sprintf('%s, <a href="#" onclick="%s" title="%s">%d</a>',...
            string,onClick,footnoteTitle,ref);
        end


    end

    string=sprintf('<sup>%s</sup>',string);

end

function blocks=getAllBlocks(system)


    blocks=find_system(system,...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'Type','Block');

end

function capabilitySet=getCapabilitySet(block)

    blockObject=get_param(block,'Object');

    try

        if isprop(blockObject,'Capabilities')
            capabilities=blockObject.Capabilities;
        else
            capabilities=[];
        end

        if isempty(capabilities)
            capabilitySet=[];
        else
            capabilitySet=capabilities.getSet(capabilities.CurrentMode);
        end

    catch

        capabilitySet=[];

    end

end

