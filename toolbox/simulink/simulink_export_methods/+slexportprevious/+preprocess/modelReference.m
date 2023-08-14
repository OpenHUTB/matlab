function modelReference(obj)






%#ok<*AGROW>

    newRules={};
    verobj=obj.ver;

    modelName=obj.modelName;


    blocks=find_system(modelName,...
    'LookUnderMasks','all',...
    'LookUnderReadProtectedSubsystems','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','ModelReference');

    if isR2018bOrEarlier(verobj)
        newRules=loc_getR2018bOrEarlier(newRules,obj,blocks);
    end


    if isR2017aOrEarlier(verobj)
        newRules=loc_getR2017aOrEarlier(newRules,obj,blocks);
    end

    if isR2016aOrEarlier(verobj)
        newRules=loc_getR2016aOrEarlier(newRules,obj,blocks);
    end

    if isR2015bOrEarlier(verobj)
        newRules=loc_getR2015bOrEarlier(newRules,obj,blocks);
    end

    if isR2014aOrEarlier(verobj)
        newRules=loc_getR2014aOrEarlier(newRules,obj,blocks);
    end

    if isR2010bOrEarlier(verobj)
        newRules=loc_getR2010bOrEarlier(newRules,obj,blocks);
    end



    if isR2009aOrEarlier(verobj)
        newRules=loc_getR2009aOrEarlier(newRules,blocks);
    end

    obj.appendRules(newRules);

end




function newRules=loc_generateRuleForGroupParameters(newRules,blk)


    SID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
    blkHandle=get_param(blk,'Handle');
    argInfo=get_param(blkHandle,'ParameterArgumentInfo');
    if(isempty(argInfo))
        return;
    end

    nonBlkPrmArgs=true(1,length(argInfo));
    if isfield(argInfo,'ArgName')
        for i=1:length(argInfo)
            if~isletter(argInfo(i).ArgName(1))
                nonBlkPrmArgs(i)=false;
            end
        end
    end

    argVals=slInternal('getParsedParameterArgumentValues',blkHandle);

    numArgs=length(argInfo);
    numVals=length(argVals);
    numToFill=min(numArgs,numVals);
    names={argInfo.ArgName};

    values=cell(1,numArgs);
    values(1:numToFill)=argVals(1:numToFill);
    values((numToFill+1):numArgs)={'[]'};


    exportNames=slexportprevious.utils.escapeRuleCharacters(loc_concatString(names(nonBlkPrmArgs),','));
    exportValues=slexportprevious.utils.escapeRuleCharacters(loc_concatString(values(nonBlkPrmArgs),','));
    newRules{end+1}=sprintf('<Block<SID|%s><UsingDefaultArgumentValue:remove>>',SID);
    if(isempty(exportNames))
        newRules{end+1}=sprintf('<Block<SID|%s><ParameterArgumentNames:remove>>',SID);
    else
        newRules{end+1}=sprintf('<Block<SID|%s><ParameterArgumentNames:repval "%s">>',SID,exportNames);
    end
    if(isempty(exportValues))
        newRules{end+1}=sprintf('<Block<SID|%s><ParameterArgumentValues:remove>>',SID);
    else
        newRules{end+1}=sprintf('<Block<SID|%s><ParameterArgumentValues:repval "%s">>',SID,exportValues);
    end
end

function newRules=genRuleForInstanceParametersToR2018bOrEarlier(newRules,obj,blk)
    newRules=loc_generateRuleForGroupParameters(newRules,blk);
    dictBlock=get_param(blk,'DictionaryBlock');
    if(~isempty(dictBlock))
        params=dictBlock.Parameter.toArray;
        for prmIdx=1:length(params)
            param=params(prmIdx);
            param.Argument=false;
        end
    else
        assert(strcmp(get_param(blk,'Variant'),'on'),'Dictionary block is absent for non Variant Model block, this is unexpected.');
    end

    modelArgumentNames=get_param(obj.origModelName,'ParameterArgumentNames');
    if(~isempty(modelArgumentNames))
        newRules{end+1}=sprintf('<GraphicalInterface<ParameterArgumentNames:repval "%s">>',modelArgumentNames);
    end
end


function newRules=loc_getR2018bOrEarlier(newRules,obj,blocks)
    for blkIdx=1:length(blocks)
        blk=blocks{blkIdx};
        newRules=genRuleForInstanceParametersToR2018bOrEarlier(newRules,obj,blk);
    end
end

function reconnectSourcePortToTerminator(lineH,blk,pIdx)
    blkName=get_param(blk,'Name');
    parentSS=get_param(blk,'Parent');
    termBlkOffset=20;
    termBlkSize=20;

    if lineH~=-1
        srcBlkH=get_param(lineH,'SrcBlockHandle');
        if(srcBlkH~=-1)
            srcPortH=get_param(lineH,'SrcPortHandle');
            srcPortNum=get_param(srcPortH,'PortNumber');

            srcBlkName=get_param(srcBlkH,'Name');
            delete_line(parentSS,[srcBlkName,'/',num2str(srcPortNum)],...
            [blkName,'/',num2str(pIdx)]);

            srcPortPos=get_param(srcPortH,'Position');
            srcPortX=srcPortPos(1);
            srcPortY=srcPortPos(2);

            srcBlkOrient=get_param(srcBlkH,'Orientation');
            switch srcBlkOrient
            case 'up'
                termBlkLeft=srcPortX-termBlkSize/2;
                termBlkTop=srcPortY-termBlkOffset-termBlkSize;
            case 'down'
                termBlkLeft=srcPortX-termBlkSize/2;
                termBlkTop=srcPortY+termBlkOffset;
            case 'left'
                termBlkLeft=srcPortX-termBlkOffset-termBlkSize;
                termBlkTop=srcPortY-termBlkSize/2;
            otherwise

                termBlkLeft=srcPortX+termBlkOffset;
                termBlkTop=srcPortY-termBlkSize/2;
            end
            termBlkPos=[termBlkLeft...
            ,termBlkTop...
            ,termBlkLeft+termBlkSize...
            ,termBlkTop+termBlkSize];

            termBlk=add_block('built-in/Terminator',...
            [parentSS,'/Terminator'],'MakeNameUnique','on');
            termBlkName=get_param(termBlk,'Name');

            set_param(termBlk,'Position',termBlkPos,...
            'Orientation',srcBlkOrient,...
            'ShowName','off');

            add_line(parentSS,...
            [srcBlkName,'/',num2str(srcPortNum)],...
            [termBlkName,'/1']);
        end
    end
end

function[idxLow,idxHigh]=getPeriodicEventPortsIndexRange(mdlEventPortInfo,blk)
    lineHandles=get_param(blk,'LineHandles');
    inputLines=lineHandles.Inport;

    numInputPorts=length(inputLines);
    seperatorLoc=find(mdlEventPortInfo==',');

    numMdlEventPorts=length(seperatorLoc)+1;

    numPeriodicEventPorts=0;
    identifierLoc=1;
    for k=1:numMdlEventPorts
        if mdlEventPortInfo(identifierLoc)=='P'
            numPeriodicEventPorts=numPeriodicEventPorts+1;
        end
        if k<numMdlEventPorts
            identifierLoc=seperatorLoc(k)+1;
        end
    end

    periodicEventPortOffset=numInputPorts-numPeriodicEventPorts;
    idxLow=periodicEventPortOffset+1;
    idxHigh=numInputPorts;
end

function turnOffPeriodicEventPort(blk)
    set_param(blk,'ShowModelPeriodicEventPorts','off');
end

function newRules=loc_getR2017aOrEarlier(newRules,obj,blocks)%#ok<INUSL>
    for blkIdx=1:length(blocks)
        blk=blocks{blkIdx};

        newRules=loc_generateRuleForGroupParameters(newRules,blk);

        mdlEventPortInfo=get_param(blk,'ModelEventPortInfo');
        if isempty(mdlEventPortInfo)
            continue;
        end



        try %#ok
            [pIdxLow,pIdxHigh]=getPeriodicEventPortsIndexRange(mdlEventPortInfo,blk);
            for pIdx=pIdxLow:pIdxHigh
                lineH=inputLines(pIdx);
                reconnectSourcePortToTerminator(lineH,blk,pIdx);
            end
        end
        turnOffPeriodicEventPort(blk);
    end
end

function[idxLow,idxHigh]=getIRTEventPortIndexRange(mdlEventPortInfo,blk)
    lineHandles=get_param(blk,'LineHandles');
    inputLines=lineHandles.Inport;

    numInputPorts=length(inputLines);
    numMdlEventPorts=length(find(mdlEventPortInfo==','))+1;
    mdlEventPortOffset=numInputPorts-numMdlEventPorts;
    idxLow=mdlEventPortOffset+1;
    idxHigh=numInputPorts;
end

function turnOffIRTPortOnModelBlock(blk)
    set_param(blk,'ShowModelInitializePort','off');
    set_param(blk,'ShowModelResetPorts','off');
    set_param(blk,'ShowModelTerminatePort','off');
end

function newRules=loc_getR2016aOrEarlier(newRules,obj,blocks)%#ok<INUSL>
    for blkIdx=1:length(blocks)
        blk=blocks{blkIdx};

        newRules=loc_generateRuleForGroupParameters(newRules,blk);

        mdlEventPortInfo=get_param(blk,'ModelEventPortInfo');
        if isempty(mdlEventPortInfo)
            continue;
        end



        try %#ok
            [pIdxLow,pIdxHigh]=getIRTEventPortIndexRange(mdlEventPortInfo,blk);
            for pIdx=pIdxLow:pIdxHigh
                lineH=inputLines(pIdx);
                reconnectSourcePortToTerminator(lineH,blk,pIdx);
            end
        end

        turnOffIRTPortOnModelBlock(blk);
    end
end




function newRules=loc_getR2015bOrEarlier(newRules,obj,blocks)%#ok<INUSL>
    function loc_ReplaceParameterArgumentValues(block)
        aMaskObj=Simulink.Mask.get(block);
        if isempty(aMaskObj)
            return;
        end

        if(aMaskObj.isAutoGeneratedModelBlockMask())
            set_param(block,'ParameterArgumentValues',get_param(block,'MaskValueString'));
        end
    end

    function newRule=loc_CreateCopyOfParameters(block)
        modelName=get_param(block,'ModelNameDialog');
        newRule=slexportprevious.rulefactory.addParameterToBlock(...
        '<BlockType|ModelReference>',...
        'CopyOfModelName',['"',modelName,'"']);
    end

    for blkidx=1:length(blocks)
        block=blocks{blkidx};

        newRules{end+1}=loc_CreateCopyOfParameters(block);

        loc_ReplaceParameterArgumentValues(block);
    end
end




function newRules=loc_getR2014aOrEarlier(newRules,obj,blocks)%#ok<INUSL>
    function newRule=loc_removeRootConnectionPorts(block)
        function rv=loc_makePortsArrayStr(x)
            rv='[';
            n=length(x);

            while((n>0)&&(0==x(n)))
                n=n-1;
            end
            if n>0
                rv=cat(2,rv,num2str(x(1)));
                for tokidx=2:n
                    rv=cat(2,rv,', ');
                    rv=cat(2,rv,num2str(x(tokidx)));
                end
            end
            rv=cat(2,rv,']');
        end

        ports0=get_param(block,'Ports');
        ports1=ports0;
        ports1(6:7)=0;




        portsStr0=loc_makePortsArrayStr(ports0);
        portsStr1=loc_makePortsArrayStr(ports1);

        newRule=slexportprevious.rulefactory....
        replaceParameterValueInBlockType('Ports',...
        portsStr0,portsStr1,...
        'ModelReference');
    end



    function newRule=loc_replaceVSSModelChoiceWithSubsystemChoice(block)
        parent=get_param(block,'Parent');


        if~(strcmp(get_param(parent,'Type'),'block')&&...
            strcmp(get_param(parent,'BlockType'),'SubSystem')&&...
            slInternal('isVariantSubsystem',get_param(parent,'Handle')))
            newRule={};
            return;
        end










        blockName=get_param(block,'Name');


        subsysBlock=slInternal('CreateSubsystemWrapper',parent,block);

        wrappedModelBlock=find_system(subsysBlock,'MatchFilter',@Simulink.match.allVariants,'Name',blockName);


        slInternal('ConnectBlocksInsideSubsystemWrapper',subsysBlock,...
        wrappedModelBlock);



        pVariants=get_param(parent,'Variants');
        idx=[];
        for jj=1:length(pVariants)
            if strcmp(pVariants(jj).BlockName,block)
                idx=jj;
                break;
            end
        end

        vss=get_param(block,'parent');
        genPreprocessorConds=get_param(vss,'GeneratePreprocessorConditionals');


        delete_block(block);

        set_param(subsysBlock,'Name',blockName,...
        'VariantControl',pVariants(idx).Name,...
        'TreatAsAtomicUnit',genPreprocessorConds);


        newRule=['<Block<BlockType|ModelReference><Name|',blockName,'><VariantControl|',pVariants(idx).Name,':remove>>'];
    end


    for blkidx=1:length(blocks)
        block=blocks{blkidx};

        newRules{end+1}=loc_removeRootConnectionPorts(block);
        newRule=loc_replaceVSSModelChoiceWithSubsystemChoice(block);
        if~isempty(newRule)
            newRules{end+1}=newRule;
        end
    end
end







function newRules=loc_getR2010bOrEarlier(newRules,obj,blocks)







    function newRule=loc_getInsertPairIntoArraySigRule(priority,sid,name,value)
        name=slexportprevious.utils.escapeRuleCharacters(name);
        value=slexportprevious.utils.escapeRuleCharacters(value);

        newRule=[num2str(priority),...
        '<Block<SID|',...
        sid,...
        '><ArraySigs:insertattribpair ',name,' ',value,'>>'];
    end









    function sigRules=loc_createSimulinkSigPropRule(priority,sid,propPairs)
        sigRules={};


        sigRules{end+1}=[num2str(priority),...
        '<Block<SID|',...
        sid,...
        '><ArraySigs:insertcontainer newSigProp>>'];

        numPairs=length(propPairs)/2;
        for k=1:numPairs
            propName=propPairs{(2*k)-1};
            propVal=propPairs{(2*k)};


            if(islogical(propVal))
                if(propVal)
                    propVal='1';
                else
                    propVal='0';
                end
            end

            if(isnumeric(propVal))
                propVal=num2str(propVal);
            end

            propName=slexportprevious.utils.escapeRuleCharacters(propName);
            propVal=slexportprevious.utils.escapeRuleCharacters(propVal);




            sigRules{end+1}=[num2str(priority),...
            '<Block<SID|',sid,'><ArraySigs<newSigProp'...
            ,':insertpair ',propName,' ',propVal,'>>>'];
        end


        sigRules{end+1}=[num2str(priority),'<Block<SID|',sid,...
        '><ArraySigs<newSigProp:rename Simulink.SigProp>>>'];
    end

    modelName=obj.modelName;
    dlo=get_param(modelName,'DataLoggingOverride');
    if(~isempty(dlo))
        dlo=dlo.updateModelName(modelName);
        set_param(modelName,'DataLoggingOverride',dlo);
    end

    for i=1:length(blocks)
        block=blocks{i};

        try
            siglog=get_param(block,'AvailSigsInstanceProps');
        catch me %#ok<NASGU>


            continue;
        end


        SID=slexportprevious.utils.escapeSIDFormat(get_param(block,'SID'));
        signalCount=0;









        while~isempty(siglog)


            curChild=siglog;
            while~isempty(curChild)


                for idx=1:length(curChild.Signals)
                    sigObj=curChild.Signals(idx);

                    if sigObj.LogSignal
                        signalCount=signalCount+1;

                        SLSigPropPairs={};

                        SLSigPropPairs{end+1}='SigName';
                        SLSigPropPairs{end+1}=['"',sigObj.SigName,'"'];

                        SLSigPropPairs{end+1}='BlockPath';
                        SLSigPropPairs{end+1}=['"',sigObj.BlockPath,'"'];

                        if(sigObj.PortIndex~=1)
                            SLSigPropPairs{end+1}='PortIndex';
                            SLSigPropPairs{end+1}=['"',num2str(sigObj.PortIndex),'"'];
                        end

                        SLSigPropPairs{end+1}='LogSignal';
                        SLSigPropPairs{end+1}=sigObj.LogSignal;

                        if(sigObj.UseCustomName)
                            SLSigPropPairs{end+1}='UseCustomName';
                            SLSigPropPairs{end+1}=sigObj.UseCustomName;
                        end

                        if(~isempty(sigObj.LogName))
                            SLSigPropPairs{end+1}='LogName';
                            SLSigPropPairs{end+1}=['"',sigObj.LogName,'"'];
                        end

                        if(sigObj.LimitDataPoints)
                            SLSigPropPairs{end+1}='LimitDataPoints';
                            SLSigPropPairs{end+1}=sigObj.LimitDataPoints;
                            SLSigPropPairs{end+1}='MaxPoints';
                            SLSigPropPairs{end+1}=['"',num2str(sigObj.MaxPoints),'"'];
                        end

                        if(sigObj.Decimate)
                            SLSigPropPairs{end+1}='Decimate';
                            SLSigPropPairs{end+1}=sigObj.Decimate;
                            SLSigPropPairs{end+1}='Decimation';
                            SLSigPropPairs{end+1}=['"',num2str(sigObj.Decimation),'"'];
                        end

                        sigRules=loc_createSimulinkSigPropRule(5,SID,SLSigPropPairs);
                        newRules=cat(2,newRules,sigRules);

                    end
                end


                curChild=curChild.right;
            end


            siglog=siglog.down;
        end

        if(signalCount>0)




            newRules{end+1}=['3<Block<SID|',SID,'>:insertcontainer ArraySigs>'];



            newRules{end+1}=loc_getInsertPairIntoArraySigRule(4,SID,'Type','"Handle"');
            newRules{end+1}=loc_getInsertPairIntoArraySigRule(4,SID,'PropName','"AvailSigsLoadSave"');
            newRules{end+1}=loc_getInsertPairIntoArraySigRule(4,SID,'Dimension',num2str(signalCount));


            newRules{end+1}=['6<Block<SID|"',SID,'"><ArraySigs:rename Array>>'];
        end
    end
end







function newRules=loc_getR2009aOrEarlier(newRules,blocks)


    function stripped=loc_stripExtensionsIfNecessary(fileName)
        if(slInternal('hasSimulinkExtension',fileName))
            [~,stripped]=fileparts(fileName);
        else
            stripped=fileName;
        end
    end

    for i=1:length(blocks)
        block=blocks{i};

        fileName=get_param(block,'ModelNameDialog');
        strippedFileName=loc_stripExtensionsIfNecessary(fileName);

        copyOfModelName=get_param(block,'CopyOfModelName');
        strippedCopyOfModelName=loc_stripExtensionsIfNecessary(copyOfModelName);

        newRules{end+1}=...
        ['<Block<BlockType|ModelReference><ModelNameDialog|"',...
        slexportprevious.utils.escapeRuleCharacters(fileName),...
        '":repval "',...
        slexportprevious.utils.escapeRuleCharacters(strippedFileName),...
        '"><ModelNameDialog:rename ModelName>>'];

        newRules{end+1}=...
        ['<Block<BlockType|ModelReference><CopyOfModelName|"',...
        slexportprevious.utils.escapeRuleCharacters(copyOfModelName),...
        '":repval "',...
        slexportprevious.utils.escapeRuleCharacters(strippedCopyOfModelName),...
        '">>'];
    end
end



function catStr=loc_concatString(values,sep)
    catStr='';
    for i=1:length(values)
        if(i>1)
            catStr=[catStr,sep];
        end

        catStr=[catStr,values{i}];
    end
end


