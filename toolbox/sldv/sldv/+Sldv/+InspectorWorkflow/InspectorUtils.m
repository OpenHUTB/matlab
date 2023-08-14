classdef InspectorUtils




    methods(Static)



        function summary=getInformerSummary(sldvData,fileNames,isModelHighlighted,justifiedObjs)
            if isempty(fileNames)
                fileNames=Sldv.Utils.initDVResultStruct();
            end
            summary=Sldv.ReportUtils.getHTMLsummary(sldvData,...
            fileNames,...
            sldvData.ModelInformation.Name,...
            isModelHighlighted,true,...
            justifiedObjs);
        end


        function completeSummary=getBlockSummary(objectives)
            completeSummary=[];

            completeSummary=[completeSummary,getblockSummaryForTab('Structural')];
            completeSummary=[completeSummary,getblockSummaryForTab('Extension')];
            completeSummary=[completeSummary,getblockSummaryForTab('Custom')];

            function summary=getblockSummaryForTab(selectedTab)
                summary=[];
                relevantObjectives=objectives(strcmp({objectives.displayTab},selectedTab));
                allTypes={relevantObjectives.type};


                [uniqueTypes,~,uniqueTypeIndices]=unique(allTypes);

                for index=1:length(uniqueTypes)
                    summary(index).type=uniqueTypes{index};%#ok<AGROW>
                    summary(index).count=sum(uniqueTypeIndices==index);%#ok<AGROW>
                end
            end
        end

        function highlightSid=getHighlightSid(sid)

            highlightSid=sid;
            if~isempty(sid)
                try

                    [handle,~,contextH]=Simulink.ID.getHandle(sid);
                catch
                    return;
                end
                if~isfloat(handle)&&handle.isa('Stateflow.Object')
                    sfId=handle.Id;
                    if(sf('get',sfId,'.isa')==sf('get','default','chart.isa')&&...
                        sf('get',sfId,'.type')==2)



                        highlightSid=Simulink.ID.getSID(contextH);
                    elseif sf('get',sfId,'.isa')==8||...
                        sfprivate('is_truth_table_fcn',sfId)||...
                        sfprivate('is_eml_truth_table_fcn',sfId)
                        chartId=sfprivate('getChartOf',sfId);
                        instanceId=sf('get',chartId,'.instance');
                        slBlockH=sf('get',instanceId,'.sfunctionBlock');
                        slsid=Simulink.ID.getSID(slBlockH);
                        sidBlk=regexp(slsid,'::','split');
                        highlightSid=sidBlk{1};
                    end
                end
            end
        end

        function updatedMap=concatenateBlockDataMap(oldMap,newMap)
            updatedMap=oldMap;
            newKeys=newMap.keys;
            for index=1:length(newKeys)
                key=newKeys{index};
                if~isKey(updatedMap,key)
                    updatedMap(key)=newMap(key);
                else
                    existingData=updatedMap(key);
                    newData=newMap(key);





                    if(isa(newData,'Sldv.InspectorWorkflow.ReducedBlock'))
                        updatedData=existingData;
                    elseif isa(existingData,'Sldv.InspectorWorkflow.ReducedBlock')
                        updatedData=newData;
                    else
                        updatedData=existingData;
                        updatedData.setObjectives([...
                        updatedData.getObjectives,newData.getObjectives]);

                        updatedData.updateRangeObjectives(newData.getRanges);
                    end
                    updatedMap(key)=updatedData;
                end
            end
        end







        function[rangeObjective,blockToDataMap]=updateRanges(rangeObjective,label,blkSid)
            blockToDataMap=containers.Map...
            ('KeyType','char','ValueType','any');
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            sldvObjective=rangeObjective.sldvObjective;
            if~isempty(sldvObjective.range)


                r=sldvprivate('util_values2range',sldvObjective.range);
                rangeObjective.rangeData=sldvprivate('util_mxarray_print',r,'..');


                busElemIdx=0;
                busElemPath='';
                if isfield(sldvObjective,'busElementIdx')&&sldvObjective.busElementIdx>0
                    busElemIdx=sldvObjective.busElementIdx;
                    busObj=strsplit(sldvObjective.descr,'on ');
                    busElemPath=[' - ',getString(message('Sldv:Informer:BusElement')),' ',busObj{2}];
                end

                if(sldvObjective.outcomeValue>0)
                    blkH=Simulink.ID.getHandle(blkSid);
                    rangeObjective.isInternalRange=false;
                    lineInfo=get_param(blkH,'LineHandles');

                    if(sldvObjective.outcomeValue>numel(lineInfo.Outport))&&...
                        ~strcmp(get_param(blkH,'BlockType'),'Outport')

                        rangeObjective.rangeHeader=[getString(message('Sldv:Informer:StatePort'))...
                        ,busElemPath];

                        rangeObjective.portIdx=-1;
                    else
                        rangeObjective.rangeHeader=[getString(message('Sldv:Informer:Outport'))...
                        ,' ',num2str(sldvObjective.outcomeValue)...
                        ,busElemPath];

                        rangeObjective.portIdx=sldvObjective.outcomeValue;
                    end


                    blockToDataMap=utils.extendRangeInfo(blkH,sldvObjective.outcomeValue,...
                    rangeObjective,busElemIdx,busElemPath);
                else


                    rangeObjective.rangeHeader=[utils.safeHTML(label),busElemPath];
                    rangeObjective.isInternalRange=true;
                    rangeObjective.portIdx=-1;
                end
            end
        end
















        function blockToDataMap=extendRangeInfo(blkH,idx,rangeObjective,busElemIdx,busElemPath,visitedMap)

            utils=Sldv.InspectorWorkflow.InspectorUtils;
            blockToDataMap=containers.Map...
            ('KeyType','char','ValueType','any');
            if~strcmp(get_param(blkH,'Type'),'block')
                return;
            end

            sid=Simulink.ID.getSID(blkH);

            if nargin<6
                visitedMap=containers.Map('KeyType','char','ValueType','logical');
                visitedMap(sid)=true;
            else
                if isKey(visitedMap,sid)


                    return;
                end

                visitedMap(sid)=true;
            end

            if nargin<5
                busElemPath='';
            end

            if nargin<4
                busElemIdx=0;
            end



            ls=get_param(blkH,'LineHandles');
            if isempty(ls.Outport)







                return;
            end




            outputHs=[ls.Outport,ls.State];
            line=outputHs(idx);
            if line==-1

                return;
            end
            destPorts=get_param(line,'DstPortHandle');
            destinationBlocks=get_param(line,'DstBlockHandle');

            for i=1:length(destPorts)
                destPort=destPorts(i);

                if destPort==-1
                    continue;
                end

                dstPortIdx=get_param(destPort,'PortNumber');
                destinationBlock=destinationBlocks(i);

                switch get_param(destinationBlock,'BlockType')
                case 'SubSystem'






                    if~isempty(get_param(destinationBlock,'TemplateBlock'))
                        continue;
                    end


                    inportBlks=Sldv.utils.getSubSystemPortBlks(destinationBlock);


                    if isempty(inportBlks)
                        continue;
                    end

                    if any(strcmp(get_param(inportBlks,'IsComposite'),'on'))

                        inportBlks=inportBlks(str2double(get_param(inportBlks,'Port'))==dstPortIdx);
                        inportBlks=inportBlks(strcmp(get_param(inportBlks,'IsComposite'),'off'));

                        for idx=1:length(inportBlks)
                            inBlkH=inportBlks(idx);

                            inportBlockToMap=utils.addRangeInfoToMap(inBlkH,dstPortIdx,rangeObjective,busElemIdx,busElemPath);
                            blockToDataMap=utils.concatenateBlockDataMap(blockToDataMap,inportBlockToMap);

                            mapFromExtendRangeInfo=utils.extendRangeInfo(inBlkH,1,rangeObjective,busElemIdx,busElemPath,visitedMap);
                            blockToDataMap=utils.concatenateBlockDataMap(blockToDataMap,mapFromExtendRangeInfo);
                        end
                    else


                        if dstPortIdx<=length(inportBlks)
                            inBlkH=inportBlks(dstPortIdx);

                            inportBlockToMap=utils.addRangeInfoToMap(inBlkH,dstPortIdx,rangeObjective,busElemIdx,busElemPath);
                            blockToDataMap=utils.concatenateBlockDataMap(blockToDataMap,inportBlockToMap);

                            mapFromExtendRangeInfo=utils.extendRangeInfo(inBlkH,1,rangeObjective,busElemIdx,busElemPath,visitedMap);
                            blockToDataMap=utils.concatenateBlockDataMap(blockToDataMap,mapFromExtendRangeInfo);
                        end
                    end
                case 'Outport'



                    if strcmp(get_param(destinationBlock,'IsComposite'),'on')
                        continue;
                    end



                    parent=get_param(destinationBlock,'Parent');
                    if~isempty(parent)&&strcmp(get_param(parent,'Type'),'block')
                        parentH=get_param(parent,'Handle');
                        parentSID=Simulink.ID.getSID(parentH);
                        portIdx=str2double(get_param(destinationBlock,'Port'));

                        outportDataMap=utils.addRangeInfoToMap(destinationBlock,1,rangeObjective,busElemIdx,busElemPath);
                        blockToDataMap=utils.concatenateBlockDataMap(blockToDataMap,outportDataMap);

                        if isKey(visitedMap,parentSID)



                            continue;
                        end

                        tempDataMap=utils.addRangeInfoToMap(parentH,portIdx,rangeObjective,busElemIdx,busElemPath);
                        mapFromExtendRangeInfo=utils.extendRangeInfo(parentH,portIdx,rangeObjective,...
                        busElemIdx,busElemPath,visitedMap);

                        tempDataMap=utils.concatenateBlockDataMap(tempDataMap,mapFromExtendRangeInfo);

                        blockToDataMap=...
                        utils.concatenateBlockDataMap(blockToDataMap,tempDataMap);
                    end

                end
            end
        end

        function blockToDataMap=addRangeInfoToMap(blkH,idx,rangeObjectiveH,busElemIdx,busElemPath)
            rangeObjective=copy(rangeObjectiveH);

            rangeObjective.portIdx=idx;

            if nargin<5
                busElemPath='';
            end

            if nargin<4
                busElemIdx=0;
            end

            if busElemIdx~=0
                rangeObjective.rangeHeader=[getString(message('Sldv:Informer:Outport'))...
                ,' ',num2str(idx),busElemPath];
            else
                rangeObjective.rangeHeader=[getString(message('Sldv:Informer:Outport'))...
                ,' ',num2str(idx)];
            end


            sid=Simulink.ID.getSID(blkH);
            blkData=Sldv.InspectorWorkflow.Block;
            blkData.setName(getfullname(blkH));
            blkData.setSID(sid);
            blkData.setRanges(rangeObjective);

            blockToDataMap=containers.Map...
            ('KeyType','char','ValueType','any');
            blockToDataMap(sid)=blkData;
        end



        function enumType=getInspectorObjectiveType(objectiveType)
            switch objectiveType
            case{'Condition',...
                'S-Function Condition'}
                enumType=Sldv.InspectorWorkflow.Objective_Enum.Condition;
            case{'Decision',...
'S-Function Decision'...
                ,'S-Function Entry',...
                'S-Function Exit',...
                }
                enumType=Sldv.InspectorWorkflow.Objective_Enum.Decision;
            case{'MCDC',...
                'S-Function MCDC'}
                enumType=Sldv.InspectorWorkflow.Objective_Enum.MCDC;
            case{'RelationalBoundary',...
                'S-Function RelationalBoundary'}
                enumType=Sldv.InspectorWorkflow.Objective_Enum.RelationalBoundary;
            case 'Test Objective'
                enumType=Sldv.InspectorWorkflow.Objective_Enum.TestObjective;
            case 'Range'
                enumType=Sldv.InspectorWorkflow.Objective_Enum.Range;
            otherwise
                enumType=Sldv.InspectorWorkflow.Objective_Enum.MISCELLANEOUS;
            end
        end

        function out=getFilterLinkType(objective,mode)
            color=Sldv.InspectorWorkflow.InspectorUtils.computeColor(objective.status,mode);
            switch color
            case 'green'
                out=0;
            case{'orange','red'}
                out=1;
            case 'steelblue'
                out=2;
            otherwise
                out=-1;
            end
        end

        function newObjective=createObjectiveOnType(sldvObjective,mode,modelName,...
            pathObjectives,isJustified,isXIL,blockSID)
            if strcmpi(sldvObjective.type,'Requirements Table Objective')
                newObjective=Sldv.InspectorWorkflow.RequirementsTableObjective(blockSID);
            else
                newObjective=Sldv.InspectorWorkflow.StructuralCoverageObjective;
            end
            newObjective.populateObjective(sldvObjective,mode,modelName,...
            pathObjectives,isJustified,isXIL);
        end


        function status=getInspectorStatus(sldvObjectiveStatus,~)



            status=sldvprivate('util_translate_status',sldvObjectiveStatus);
        end

        function isAl=isActiveLogic(sldvObjective)


            isAl=strcmp(sldvObjective.status,'Active Logic');
        end

        function action=getInspectorAction(sldvObjective,model,analysisMode,...
            isJustified,isXIL,isQuickDL)
            action='';
            utils=Sldv.InspectorWorkflow.InspectorUtils;

            if nargin<4
                isJustified=false;
            end



            if~isJustified&&isfield(sldvObjective,'testCaseIdx')&&...
                ~isempty(sldvObjective.testCaseIdx)&&...
                ~utils.isActiveLogic(sldvObjective)

                if isfield(sldvObjective,'type')&&...
                    (strcmp(sldvObjective.type,'Proof objective')||...
                    strcmp(sldvObjective.type,'Assert')||...
                    Sldv.utils.isErrorDetectionObjective(sldvObjective))
                    action=utils.viewCounterExampleLink(model,sldvObjective.testCaseIdx(1));
                else
                    action=utils.viewTestCaseLink(model,...
                    sldvObjective.testCaseIdx(1));
                end
            end


            debugActionHtml=utils.getSlicerActionLink(sldvObjective,model,analysisMode);
            if~isempty(debugActionHtml)
                action=[action,debugActionHtml];
            end

            if nargin<3||...
                (isXIL&&~strcmp(analysisMode,'TestGeneration'))||...
                strcmp(analysisMode,'PropertyProving')||...
                Sldv.utils.isSldvAnalysisRunning(model)||...
                (isXIL&&(~isfield(sldvObjective,'moduleName')||isempty(sldvObjective.moduleName)))||...
                (isXIL&&(~isfield(sldvObjective,'codeLnk')||isempty(sldvObjective.codeLnk)))
                return;
            end



            if isXIL&&sldv.code.internal.CodeInfoUtils.isOldCodeLinkFormat(sldvObjective.codeLnk)
                return
            end

            if Sldv.utils.isTestGenObjectiveForFiltering(sldvObjective)||...
                Sldv.utils.isErrorDetectionObjective(sldvObjective)
                if isJustified
                    linkType=2;
                else
                    linkType=utils.getFilterLinkType(sldvObjective,analysisMode);
                    if linkType==-1||linkType==0
                        return;
                    end


                    if isXIL&&linkType==1&&strcmpi(sldvObjective.status,'Satisfied - needs simulation')
                        return
                    end
                end
            elseif any(strcmp(sldvObjective.type,{'RelationalBoundary','MCDC','Test objective'}))&&...
                (isJustified||any(strcmp(sldvObjective.status,{'Excluded','Justified'})))

                linkType=2;
            else
                return;
            end


            try
                if nargin<6
                    isQuickDL=false;
                end
                if isQuickDL
                    objDescr=['  ',utils.safeHTML(sldvObjective.descr)];
                else
                    objDescr='';
                end
                filterActionHtml=utils.getFilterActionLink(model,sldvObjective.ObjectiveIdx,objDescr,linkType);
            catch
                filterActionHtml=[];
            end

            if~isempty(filterActionHtml)
                action=[action,filterActionHtml];
            end
        end

        function link=getFilterActionLink(model,objectiveIdx,objDescr,linkType)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            filterAction=utils.filterObjectiveLink(model,objectiveIdx,objDescr,linkType);
            link=utils.addCellWithData(filterAction);
        end

        function link=getSlicerActionLink(sldvObjective,model,analysisMode)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            link=[];

            if utils.isObjectiveDebuggable(sldvObjective)

                action='Debug';
            elseif utils.isObjectiveInspectable(sldvObjective,analysisMode)

                action='Inspect';
            else
                return;
            end
            debugAction=utils.debugUsingSlicerLink(model,...
            sldvObjective.ObjectiveIdx,action);
            link=utils.addCellWithData(debugAction);
        end

        function status=isObjectiveDebuggable(sldvObjective)
            status=false;


            if(isfield(sldvObjective,'testCaseIdx')&&~isempty(sldvObjective.testCaseIdx))...
                ||strcmp(sldvObjective.status,'Falsified - No Counterexample')


                if isfield(sldvObjective,'type')...
                    &&(strcmp(sldvObjective.type,'Proof objective')...
                    ||strcmp(sldvObjective.type,'Assert')...
                    ||strcmp(sldvObjective.type,'Overflow')...
                    ||strcmp(sldvObjective.type,'Inf value')...
                    ||strcmp(sldvObjective.type,'Read-before-write')...
                    ||strcmp(sldvObjective.type,'NaN value')...
                    ||strcmp(sldvObjective.type,'Subnormal value')...
                    ||strcmp(sldvObjective.type,'Write-after-read')...
                    ||strcmp(sldvObjective.type,'Write-after-write')...
                    ||strcmp(sldvObjective.type,'Division by zero')...
                    ||strcmp(sldvObjective.type,'Block input range violation')...
                    ||strcmp(sldvObjective.type,'Design Range'))

                    allowedStatuses={'Falsified','Falsified - needs simulation',...
                    'Undecided with counterexample','Falsified - No Counterexample'};
                    objectiveStatus=sldvObjective.status;
                    if any(strcmpi(objectiveStatus,allowedStatuses))
                        status=true;
                    end
                end
            end
        end

        function status=isObjectiveInspectable(sldvObjective,analysisMode)


            status=false;

            if(isfield(sldvObjective,'testCaseIdx')&&~isempty(sldvObjective.testCaseIdx))
                utils=Sldv.InspectorWorkflow.InspectorUtils;

                status=strcmpi(analysisMode,'TestGeneration')&&isfield(sldvObjective,'type')...
                &&utils.istestgenobj(sldvObjective.type);
            end
        end

        function objective=updateObservabilityInformation(...
            sldvDataObjective,pathObjectives)
            objective=sldvDataObjective;
            pathObjStatuses={pathObjectives.status};

            updatedDetectability=false;

            if(strcmp(objective.status,'Satisfied'))||...
                (strcmp(objective.status,'Satisfied - needs simulation'))
                if isfield(pathObjectives,'testCaseIdx')&&...
                    isfield(objective,'testCaseIdx')
                    pathObjTestCases=[pathObjectives.testCaseIdx];
                    objTCIdx=objective.testCaseIdx;
                    [status,location]=ismember(objTCIdx,pathObjTestCases);
                    if status
                        objective.detectability='Detectable';
                        pathObjIdx=location;
                        objective.satPathObjective=pathObjIdx;
                        objective.detectionSites=pathObjectives(pathObjIdx).detectionSites;
                        updatedDetectability=true;
                    end
                end
            end
            if~updatedDetectability
                if(all(strcmp('Unsatisfiable',pathObjStatuses)))
                    objective.detectability='Not Detectable';
                else
                    objective.detectability='Undecided';
                end
            end
        end



        function out=istestgenobj(sldvObjectiveType)

            out=false;
            switch(sldvObjectiveType)
            case{'Condition',...
                'Decision',...
                'MCDC',...
                'Test objective',...
                'RelationalBoundary',...
                'Extension',...
                'Objective Composition',...
                'S-Function Decision',...
                'S-Function Condition',...
                'S-Function MCDC',...
                'S-Function Entry',...
                'S-Function Exit',...
                'S-Function RelationalBoundary'}
                out=true;
            end

        end



        function link=createPathLink(model,destSID,dispText)
            link=[' - <a style="text-decoration: none"'...
            ,'href="matlab:sldvprivate(''highlightPathLink'', '''...
            ,model,''', ''',destSID,''');">','&#8702;',dispText,'</a>'];

        end

        function boldedStr=bold(aStr)
            boldedStr=['<b>',aStr,'</b>'];
        end

        function bulletedStr=bullet(aStr)
            bulletedStr=['&#9899; ',aStr];
        end

        function str=getMenuString()
            backToSum=getString(message('Sldv:Informer:BackSummary'));
            back_link=['<a href="buffer:1">',backToSum,'</a>'];
            str=['<div style="background:#d6d6d6">',back_link,'</div>'];
        end

        function link=viewTestCaseLink(model,idx)
            if Simulink.harness.isHarnessBD(model)
                link=[];
                return;
            end
            viewtc=getString(message('Sldv:Informer:ViewTestCase'));
            link=[' - <a href="matlab:sldvprivate(''urlcall'', ''harness'', [], '''...
            ,model,''', ',num2str(idx),');">',viewtc,'</a>'];
        end

        function link=viewCounterExampleLink(model,idx)
            viewcex=getString(message('Sldv:Informer:ViewCounterexample'));
            link=[' - <a href="matlab:sldvprivate(''urlcall'', ''harness'', [], '''...
            ,model,''', ',num2str(idx),');">',viewcex,'</a>'];
        end

        function link=debugUsingSlicerLink(model,objectiveIdx,action)

            viewcex=getString(message(['Sldv:Informer:',action,'UsingSlicer']));
            link=[' <a href="matlab:sldvprivate(''urlcall'', ''debugUsingSlicerInformer'', [], '''...
            ,model,''', ','[]',', ',num2str(objectiveIdx)...
            ,');">',viewcex,'</a>'];
        end

        function link=deadLogicSuggestionLink(aDeadLogicSuggestionKind)
            doclink=getString(message('Sldv:DeadLogicExplanations:Documentation'));
            link=[' <a href="matlab:sldvprivate(''urlcall'', ''',aDeadLogicSuggestionKind,''');">',doclink,'</a>'];
        end

        function link=filterObjectiveLink(model,objIdx,objDescr,linkType)
            switch linkType
            case 0
                filterStr=getString(message('Sldv:Informer:ExcludeStatus'));
            case 1
                filterStr=getString(message('Sldv:Informer:JustifyStatus'));
            case 2
                filterStr=getString(message('Sldv:Informer:ViewStatus'));
            end
            filterStr=[filterStr,objDescr];

            link=[' <a href="matlab:sldvprivate(''urlcall'', ''filter'', [], ''',model,''', '...
            ,'[], [], ',num2str(objIdx),', ',num2str(linkType),');">',filterStr,'</a>'];
        end

        function str=emphCellHTML(in)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            if ischar(in)
                str=utils.safeHTML(in);
            elseif iscell(in)
                str='';
                for k=1:(numel(in)/2)
                    if(in{2*k-1})
                        str=[str,'<b>',utils.safeHTML(in{2*k}),'</b>'];%#ok<AGROW>
                    else
                        str=[str,utils.safeHTML(in{2*k})];%#ok<AGROW>
                    end
                end
            end
        end

        function str=safeHTML(str)
            str=strrep(str,'<','&lt;');
            str=strrep(str,'>','&gt;');
        end

        function htmlString=buildDisplayData(blockDataSet)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            menuData=utils.getMenuString();
            dataBegin='<p>';
            dataEnd='</p>';
            tableBegin='<table>';
            tableEnd='</table>';


            name=blockDataSet(1).getName;
            headerData=['<b>',utils.safeHTML(name),'</b>'];
            header=utils.addRowWithData(headerData);
            body='';
            for blockData=blockDataSet
                body=[body,blockData.printToHTML];%#ok<AGROW>
            end
            if isempty(body)
                htmlString='';
            else
                htmlString=[menuData,dataBegin,tableBegin,header,body,tableEnd,dataEnd];
            end
        end

        function htmlString=buildDisplayDataWithView(blockData)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            menuData=utils.getMenuString();


            name=blockData(1).getName;
            headerData=['<b>',utils.safeHTML(name),'</b>'];
            header=utils.addData(headerData);
            tabbedPanel='';
            body=blockData.printToHTML;
            if isempty(body)
                htmlString=[menuData,header,tabbedPanel,getString(message('dastudio:studio:NoDataToDisplay'))];
            else
                htmlString=[menuData,header,tabbedPanel,body];
            end
        end

        function htmlString=buildMultilinkChartData(blockDataSet)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            menuData=utils.getMenuString();


            name=blockDataSet{1}.getName;
            headerData=['<b>',utils.safeHTML(name),'</b>'];
            header=utils.addData(headerData);
            tabbedPanel='';
            body='';
            for blk=blockDataSet
                blkData=blk{:};
                path=blkData.getPath;
                pathInfo=['<b>',utils.safeHTML(path),'</b>'];
                pathName=utils.addData(pathInfo);
                blkInfo=blkData.printToHTML;
                body=[body,pathName,blkInfo];
            end
            if isempty(body)
                htmlString=[menuData,header,tabbedPanel,getString(message('dastudio:studio:NoDataToDisplay'))];
            else
                htmlString=[menuData,header,tabbedPanel,body];
            end
        end

        function msgSuffix=getMsgSuffix(status)
            persistent status2msg;

            if isempty(status2msg)
                mapping={...
                'Satisfied','Satisfied';...
                'SatisfiedNeedSim','Satisfied - needs simulation';...
                'SatisfiedByExistingData','Satisfied by coverage data';...
                'SatisfiedByExistingData','Satisfied by existing testcase';...
                'UndecidedWTest','Undecided with testcase';...
                'Valid','Proven valid';...
                'Valid','Valid';...
                'ValidUnderApprox','Valid under approximation';...
                'ValidWithinBound','Valid within bound';...
                'Unsatisfiable','Proven unsatisfiable';...
                'Unsatisfiable','Unsatisfiable';...
                'UnsatisfiableUnderApprox','Unsatisfiable under approximation';...
                'Falsified','Falsified';...
                'FalsifiedNeedSim','Falsified - needs simulation';...
                'UndecidedWithCx','Undecided with counterexample';...
                'UndecidedRTError','Undecided due to runtime error';...
                'UndecidedStub','Undecided due to stubbing';...
                'UndecidedNonlin','Undecided due to nonlinearities';...
                'UndecidedDiv0','Undecided due to division by zero';...
                'UndecidedArrBnd','Undecided due to array out of bounds';...
                'Undecided','Undecided';...
                'SatisfiedNoTest','Satisfied - No Test Case';...
                'FalsifiedNoCx','Falsified - No Counterexample';...
                'na','n/a';...
                'ProducedError','Produced error';...
                'DeadLogic','Dead Logic';...
                'DeadLogicUnderApprox','Dead Logic under approximation';...
                'ActiveLogic','Active Logic';...
                'ActiveLogicNeedSim','Active Logic - needs simulation';...
                'UndecidedDueApprox','Undecided due to approximations';...
                'Excluded','Excluded';...
                'Justified','Justified';...
                'InProgress','In progress';...
                };

                keys=mapping(:,2);
                values=mapping(:,1);
                status2msg=containers.Map(keys,values);
            end

            if status2msg.isKey(status)
                msgSuffix=status2msg(status);
            else
                msgSuffix='';
            end
        end


        function htmlSummary=getHTMLSummary(summary,msgString,modelName)


            htmlSummary='';
            if~isempty(summary)
                totalCount=sum([summary.count]);
                DesiredOrder={...
                'Satisfied',...
                'Satisfied - needs simulation',...
                'Undecided with testcase',...
                'Valid',...
                'Valid under approximation',...
                'Valid within bound',...
                'Unsatisfiable',...
                'Unsatisfiable under approximation',...
                'Falsified',...
                'Falsified - needs simulation',...
                'Undecided with counterexample',...
                'Undecided due to runtime error',...
                'Undecided due to stubbing',...
                'Undecided due to nonlinearities',...
                'Undecided due to division by zero',...
                'Undecided',...
                'Satisfied - No Test Case',...
                'Falsified - No Counterexample',...
                'n/a',...
                'Produced error',...
                'Dead Logic',...
                'Dead Logic under approximation',...
                'Active Logic',...
                'Active Logic - needs simulation',...
                'Undecided due to approximations',...
                'Excluded',...
'Justified'...
                };

                [~,indices]=ismember(DesiredOrder,{summary.status});

                indices(indices==0)=[];
                orderedSummary=summary(indices);

                utils=Sldv.InspectorWorkflow.InspectorUtils;

                for objSummaryIndex=1:length(orderedSummary)
                    status=orderedSummary(objSummaryIndex).status;
                    count=orderedSummary(objSummaryIndex).count;





                    if strcmp(status,'Undecided')&&...
                        Sldv.utils.isSldvAnalysisRunning(modelName)
                        msgSuffix='InProgress';
                    else
                        msgSuffix=Sldv.InspectorWorkflow.InspectorUtils.getMsgSuffix(status);
                    end

                    if count==1
                        msgId=[msgString,'OneObj',msgSuffix];
                    else
                        msgId=[msgString,'MultObj',msgSuffix];
                    end


                    objectiveStatusString=getString(message(msgId,count,totalCount));
                    htmlSummary=[htmlSummary...
                    ,utils.addRowWithData(...
                    utils.addCellWithData(objectiveStatusString))];%#ok<AGROW>

                end
            end

        end

        function htmlStr=getHTMLBlockSummary(summary)
            htmlStr='';
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            totalObjectives=sum([summary.count]);
            totalCount=num2str(totalObjectives);
            totalString=getString(message('Sldv:Informer:Total'));
            totalData=[totalString,' - ',totalCount];
            htmlStr=[htmlStr,utils.addData(totalData)];
            for summaryIndex=1:length(summary)
                summaryComponent=summary(summaryIndex);
                htmlType=sldvprivate('util_translate_ObjectiveType',...
                summaryComponent.type);
                htmlCount=num2str(summaryComponent.count);
                htmlData=[htmlType,' - ',htmlCount];
                htmlStr=[htmlStr,utils.addData(htmlData)];%#ok<AGROW>
            end
        end

        function htmlString=addTableWithData(data,style)
            htmlString='';
            if nargin==1
                style='';
            end
            if~isempty(data)
                tableBegin=['<table',style,'>'];
                tableEnd='</table>';
                htmlString=[tableBegin,data,tableEnd];
            end
        end

        function htmlString=addRowWithData(data)
            htmlString='';
            if~isempty(data)
                rowBegin='<tr>';
                rowEnd='</tr>';
                htmlString=[rowBegin,data,rowEnd];
            end
        end
        function htmlString=addCellWithData(data,forceAdd)
            htmlString='';
            if nargin<2
                forceAdd=false;
            end
            if~isempty(data)||forceAdd






                cellBegin='<td style="padding:1px 8px">';
                cellEnd='</td>';
                htmlString=[cellBegin,data,cellEnd];
            end
        end


        function htmlString=newline
            htmlString='<p>';
        end

        function htmlString=addData(data)
            htmlString='';
            if~isempty(data)
                dataBegin='<p>';
                dataEnd='</p>';
                htmlString=[dataBegin,data,dataEnd];
            end
        end

        function htmlStatusStr=getHTMLStatusStr(objStatus,mode)



            status=sldvprivate('util_translate_status',objStatus);

            if strcmp(objStatus,'Falsified - needs simulation')
                status=getString(message('Sldv:KeyWords:ErrorNeedsSimulation'));
            end
            if strcmp(objStatus,'Falsified')||...
                strcmp(objStatus,'Falsified - No Counterexample')
                status=getString(message('Sldv:KeyWords:ERROR'));
            end

            color=Sldv.InspectorWorkflow.InspectorUtils.computeColor(objStatus,mode);
            switch color
            case 'green'
                htmlStatusStr=['<b><font color="green">',status,'</font></b>'];
            case 'orange'
                htmlStatusStr=['<b><font color="orange">',status,'</font></b>'];
            case 'red'
                htmlStatusStr=['<b><font color="red">',status,'</font></b>'];
            case 'steelblue'
                htmlStatusStr=['<b><font color="steelblue">',status,'</font></b>'];
            otherwise
                htmlStatusStr=['<b><font color="blue">',upper(status),'</font></b>'];
            end
        end
        function htmlStr=getObservabilityStr(objective,~)
            htmlStr='';
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            if isfield(objective,'detectability')&&...
                ~isempty(objective.detectability)
                htmlStr=utils.getObsStatusStr(objective.detectability);
            end

        end
        function obsStatus=getObsStatusStr(status)
            switch status
            case 'Detectable'
                obsStatus=getString(message('Sldv:Informer:Detectable'));
            case 'Not Detectable'
                obsStatus=getString(message('Sldv:Informer:NotDetectable'));
            case 'Undecided'
                obsStatus=getString(message('Sldv:Informer:Undecided'));
            end
        end

        function color=computeColor(modelObjectiveStatus,mode)
            color='';
            switch(modelObjectiveStatus)
            case{'Valid',...
                'Valid within bound',...
                'Satisfied',...
                'Active Logic',...
                'Satisfied - No Test Case',...
                'Satisfied by coverage data',...
                'Satisfied by existing testcase'}
                color='green';
            case{'Undecided',...
                'Undecided due to stubbing',...
                'Undecided due to nonlinearities',...
                'Undecided due to division by zero',...
                'Valid under approximation',...
                'Unsatisfiable under approximation',...
                'Undecided due to approximations',...
                'Satisfied - needs simulation',...
                'Undecided with testcase',...
                'Undecided with counterexample',...
                'Undecided due to runtime error',...
                'Undecided due to array out of bounds',...
                'Produced error'}
                color='orange';
            case 'Active Logic - needs simulation'
                if slfeature('SldvValidateActiveLogic')
                    color='orange';
                else
                    color='green';
                end
            case 'Falsified - needs simulation'
                if~strcmp(mode,'DesignErrorDetection')
                    color='orange';
                else
                    color='red';
                end
            case{'Falsified',...
                'Falsified - No Counterexample',...
                'Unsatisfiable',...
                'Dead Logic',...
                'Dead Logic under approximation'}
                color='red';
            case{'Excluded',...
                'Justified'}
                color='steelblue';
            end
        end
    end

end


