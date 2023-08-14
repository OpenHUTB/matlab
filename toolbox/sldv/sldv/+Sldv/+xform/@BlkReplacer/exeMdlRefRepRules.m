function exeMdlRefRepRules(obj)




    modelRefBlkTree=obj.MdlInfo.ModelRefBlkTree;

    treeIteratorBFS=modelRefBlkTree.MdlTreeBFSIterator;

    treeIteratorBFS.firstElement(modelRefBlkTree);

    busList=Sldv.xform.BlkReplacer.genBusNamesInBaseWorkSpace;

    sharedLocalDSMToNewNameMap=containers.Map('KeyType','char','ValueType','char');
    dsmNamesToUpdate=containers.Map('KeyType','double','ValueType','char');

    while true
        currentNode=treeIteratorBFS.currentElement;

        if~isempty(currentNode.Up)
            currentNode.ReplacementInfo.Rule.InlineOnlyMode=obj.MdlInlinerOnlyMode;
            currentNode.ReplacementInfo.Rule.PathTranslationInfo=obj.PathTranslationInfo;
            parentReplaced=currentNode.Up.ReplacementInfo.Replaced;

            if~parentReplaced&&~isempty(obj.PathTranslationInfo)
                if ismember(currentNode.BlockH,obj.PathTranslationInfo.replacableModelBlockH)
                    subPath=obj.PathTranslationInfo.origSubPath;
                    if~isempty(subPath)

                        cnt=numel(subPath);

                        [~,relativePath]=strtok(getfullname(currentNode.BlockH),'/');
                        matches=strncmp(subPath,relativePath,cnt);
                        currentNode.ReplacementInfo.IsReplaceable=matches;
                    else


                        currentNode.ReplacementInfo.IsReplaceable=...
                        ~ismember(currentNode.Up,[obj.MdlRefBlksRejectedForReplacement{:}]);
                    end
                else
                    currentNode.ReplacementInfo.IsReplaceable=false;
                end
            end






            currentNode.ReplacementInfo.MakeSampleTimeInherit=...
            currentNode.isExportFcnMdl||...
            currentNode.Up.ReplacementInfo.MakeSampleTimeInherit;

            obj.fixModelWorkspace(currentNode);
            currentNode.replaceBlock();

            if currentNode.ReplacementInfo.Replaced


                if~isempty(obj.NotifyMdlInlineFcn)

                    replacementBlkH=currentNode.ReplacementInfo.AfterReplacementH;
                    replacementPath=currentNode.ReplacementInfo.BlockToReplaceOriginalPath;

                    try
                        refMdlIsInlinedWithNewSubsys=...
                        currentNode.ReplacementInfo.Rule.InlinedWithNewSubsys;
                        feval(obj.NotifyMdlInlineFcn,obj.NotifyData,...
                        replacementPath,...
                        replacementBlkH,...
                        currentNode.RefMdlName,...
                        refMdlIsInlinedWithNewSubsys);
                    catch MEx
                    end
                end

                obj.fixPreprocessorConditionals(currentNode);

                Sldv.xform.BlkReplacer.fixInOutPorts(currentNode,true,busList,obj.MdlInlinerOnlyMode);





                Sldv.xform.BlkReplacer.addSigConvInOutPorts(currentNode);

                obj.fixDSRWblocks(currentNode,sharedLocalDSMToNewNameMap,dsmNamesToUpdate);
                obj.fixGotoFromblocks(currentNode);
                obj.fixMimizationOfAlgebraicLoops(currentNode);


                if(1==slfeature('ObserverSLDV'))
                    obj.reconfigObserverMapping(currentNode);
                end
                obj.ReplacedMdlRefBlks{end+1}=currentNode;
            else
                obj.MdlRefBlksRejectedForReplacement{end+1}=currentNode;
            end
        else
            currentNode.ReplacementInfo.AfterReplacementH=...
            get_param(obj.MdlInfo.ModelH,'Handle');
            obj.fixModelWorkspace(currentNode);
        end


        if treeIteratorBFS.hasMoreElements
            treeIteratorBFS.nextElement;
        else
            break;
        end
    end

    keyList=keys(dsmNamesToUpdate);
    for idx=1:length(keyList)
        set_param(keyList{idx},'DataStoreName',dsmNamesToUpdate(keyList{idx}));
    end

end
