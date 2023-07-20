function propMap=deriveProperties(ssid,supportExecutionOnlyBlocks)




    try
        if nargin<2
            supportExecutionOnlyBlocks=false;
        end
        propMap=[];

        [forCode,codeCovFiltInfo]=SlCov.FilterEditor.isForCode(ssid);

        if forCode
            fixNameFcn=@(x)regexprep(x,'\n',' ');
            codeCovInfo=codeCovFiltInfo.codeCovInfo;
            ssid=codeCovFiltInfo.ssid;
            if~isempty(ssid)
                modelObject=SlCov.FilterEditor.getObject(ssid);
            end
            if SlCov.FilterEditor.isCodeFilterFileInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{1};
                    propMap=addToPropMap(propMap,'P14',id,val);
                else
                    codeCovInfo=[codeCovInfo(1),{'','','','',ssid}];
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    propMap=addToPropMap(propMap,'P20',id,fixNameFcn(modelObject.Name));
                end
            elseif SlCov.FilterEditor.isCodeFilterFunInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{2};
                    propMap=addToPropMap(propMap,'P15',id,val);
                else
                    codeCovInfo=[codeCovInfo(1:2),{'','','',ssid}];
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    propMap=addToPropMap(propMap,'P21',id,fixNameFcn(modelObject.Name));
                end
            elseif SlCov.FilterEditor.isCodeFilterDecInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{3};
                    if numel(codeCovInfo{4})==1
                        propId='P16';
                        mode=0;
                    else
                        propId='P42';
                        mode=1;
                    end
                    propMap=addToPropMap(propMap,propId,id,val,mode);
                else
                    codeCovInfo{end+1}=ssid;
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    if numel(codeCovInfo{4})==1
                        propId='P22';
                        mode=0;
                    else
                        propId='P46';
                        mode=1;
                    end
                    propMap=addToPropMap(propMap,propId,id,fixNameFcn(modelObject.Name),mode);
                end
            elseif SlCov.FilterEditor.isCodeFilterCondInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{3};
                    if numel(codeCovInfo{4})==1
                        propId='P17';
                        mode=0;
                    else
                        mode=1;
                        propId='P43';
                    end
                    propMap=addToPropMap(propMap,propId,id,val,mode);
                else
                    codeCovInfo{end+1}=ssid;
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    if numel(codeCovInfo{4})==1
                        propId='P23';
                        mode=0;
                    else
                        mode=1;
                        propId='P47';
                    end
                    propMap=addToPropMap(propMap,propId,id,fixNameFcn(modelObject.Name),mode);
                end
            elseif SlCov.FilterEditor.isCodeFilterMCDCInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{3};
                    propMap=addToPropMap(propMap,'P44',id,val,1);
                else
                    codeCovInfo{end+1}=ssid;
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    propMap=addToPropMap(propMap,'P48',id,fixNameFcn(modelObject.Name),1);
                end
            elseif SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeCovInfo)
                if isempty(ssid)
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    val=codeCovInfo{3};
                    propId='P45';
                    propMap=addToPropMap(propMap,propId,id,val,1);
                else
                    codeCovInfo{end+1}=ssid;
                    id=SlCov.FilterEditor.encodeCodeFilterInfo(codeCovInfo{:});
                    propId='P49';
                    propMap=addToPropMap(propMap,propId,id,fixNameFcn(modelObject.Name),1);
                end
            end
            return
        end
        if contains(ssid,'.m')
            propMap=addToPropMap(propMap,'P9',ssid,ssid);
            return;
        end
        modelObject=SlCov.FilterEditor.getObject(ssid);
        if isempty(modelObject)
            return;
        end
        if contains(class(modelObject),'Stateflow.')

            if isa(modelObject,'Stateflow.Chart')
                valueDesc=modelObject.Name;
                propMap=addToPropMap(propMap,'P1',ssid,valueDesc);
            elseif isa(modelObject,'Stateflow.State')&&~isEmptyState(modelObject)
                valueDesc=modelObject.getFullName;
                events=findStateEvents(modelObject);
                if~isempty(modelObject.down)
                    propMap=addToPropMap(propMap,'P2',ssid,valueDesc);
                else
                    if~isempty(events)||saturateOnIntegerOverflow(modelObject)||...
                        hasSldvObjects(modelObject)||findAssigment(modelObject)
                        propMap=addToPropMap(propMap,'P3',ssid,valueDesc);
                    end
                end
                propMap=addEventsToPropMap(propMap,events);
            elseif isa(modelObject,'Stateflow.Transition')
                [hasCond,events]=findTransitionEvents(modelObject);
                if hasCond||saturateOnIntegerOverflow(modelObject)||...
                    hasSldvObjects(modelObject)||findAssigment(modelObject)
                    text=[modelObject.getDisplayLabel,' at ',modelObject.getFullName];
                    propMap=addToPropMap(propMap,'P4',ssid,text);
                    propMap=addEventsToPropMap(propMap,events);
                end

            elseif isa(modelObject,'Stateflow.AtomicSubchart')
                valueDesc=modelObject.Name;
                cssid=Simulink.ID.getSID(modelObject);
                propMap=addToPropMap(propMap,'P1',cssid,valueDesc);
                subchartMan=Stateflow.SLINSF.SubchartMan(modelObject.Id);
                linkStatStr=get_param(subchartMan.subchartH,'StaticLinkStatus');
                if~isempty(linkStatStr)&&strcmpi(linkStatStr,'resolved')
                    libName=modelObject.subChart.Path;
                    propMap=addToPropMap(propMap,'P7',libName,libName);
                end
            elseif isa(modelObject,'Stateflow.EMFunction')
                propMap=addToPropMap(propMap,'P8','MATLAB Function','MATLAB Function');
                propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);
            elseif isa(modelObject,'Stateflow.TruthTable')
                propMap=addToPropMap(propMap,'P8','Truth Table','Truth Table');
                propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);
            elseif isa(modelObject,'Stateflow.Function')
                propMap=addToPropMap(propMap,'P11',ssid,modelObject.Name);
            end
        elseif ishandle(modelObject)&&strcmpi(modelObject.Type,'block')
            if isDVBlock(modelObject)
                propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);
            elseif strcmpi(modelObject.BlockType,'subsystem')
                chartId=isChart(modelObject.Handle);
                if~isempty(chartId)
                    if sf('Private','is_eml_chart',chartId)
                        propMap=addToPropMap(propMap,'P8','MATLAB Function','MATLAB Function');
                        propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);
                    elseif sf('Private','is_truth_table_chart',chartId)
                        propMap=addToPropMap(propMap,'P8','Truth Table','Truth Table');
                        propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);
                    else
                        propMap=addToPropMap(propMap,'P1',ssid,modelObject.Name);
                        propMap=addToPropMap(propMap,'P8','Stateflow','Stateflow');
                    end
                    if~isempty(modelObject.ReferenceBlock)
                        propMap=addToPropMap(propMap,'P7',modelObject.ReferenceBlock,modelObject.ReferenceBlock);
                    end
                else
                    propMap=addToPropMap(propMap,'P6',ssid,modelObject.Name);
                    if~isempty(modelObject.ReferenceBlock)
                        propMap=addToPropMap(propMap,'P7',modelObject.ReferenceBlock,modelObject.ReferenceBlock);
                    end
                end
            else
                supported=true;
                if~supportExecutionOnlyBlocks
                    suppBlocks=cvi.TopModelCov.getSupportedBlockTypes;
                    supported=~isempty(intersect(modelObject.BlockType,suppBlocks));
                end
                if supported
                    propMap=addToPropMap(propMap,'P8',modelObject.BlockType,modelObject.BlockType);

                    propMap=addToPropMap(propMap,'P9',ssid,modelObject.Name);

                    if isa(modelObject,'Simulink.SFunction')
                        funName=SlCov.Utils.fixSFunctionName(modelObject.FunctionName);
                        propMap=addToPropMap(propMap,'P13',funName,funName);
                    end
                end
            end

            if~isempty(modelObject.MaskType)
                propMap=addToPropMap(propMap,'P10',modelObject.MaskType,modelObject.MaskType);
            end

        end
    catch MEx
        rethrow(MEx);
    end

    function propMap=addToPropMap(propMap,id,value,valueDesc,mode)
        if nargin<5
            mode=0;
        end
        allPropMap=SlCov.FilterEditor.getPropertyDB;
        newProp=allPropMap(id);
        assert(~isempty(newProp));
        newProp.value=value;
        newProp.valueDesc=valueDesc;
        newProp.Rationale='';
        newProp.mode=mode;
        if isempty(propMap)
            propMap=newProp;
        else
            propMap(end+1)=newProp;
        end

        function res=saturateOnIntegerOverflow(modelObject)


            if isa(modelObject,'Stateflow.Chart')
                ch=modelObject;
            else
                ch=modelObject.Chart;
            end
            res=ch.saturateOnIntegerOverflow;

            function res=isDVBlock(modelObject)

                res=false;
                maskType=modelObject.MaskType;
                if~isempty(maskType)
                    maskNames={'Design Verifier Test Objective',...
                    'Design Verifier Proof Objective',...
                    'Design Verifier Test Condition',...
'Design Verifier Assumption'...
                    };

                    res=strfind(maskNames,maskType);
                    res=any([res{:}]);
                end


                function chartId=isChart(blockH)

                    chartId=[];
                    if Stateflow.SLUtils.isStateflowBlock(blockH)
                        chartId=sfprivate('block2chart',blockH);
                    end



                    function res=isEmptyState(modelObject)
                        res=true;
                        try
                            cont=Stateflow.Ast.getContainer(modelObject);
                            res=isempty(modelObject.getChildren)&&isempty(cont.sections);
                        catch Mex %#ok<NASGU>


                        end

                        function propMap=addEventsToPropMap(propMap,events)
                            for idx=1:numel(events)
                                value=events(idx);
                                propMap=addToPropMap(propMap,'P5',value,value.name);
                            end

                            function events=getTransitionEvents(land,events)
                                if isa(land,'Stateflow.Ast.WakeupEvent')||...
                                    isa(land,'Stateflow.Ast.AbsoluteTimerEvent')||...
                                    isa(land,'Stateflow.Ast.ExplicitEvent')||...
                                    isa(land,'Stateflow.Ast.PreProcessedTrigger')
                                    value.type='Event';
                                    value.name=land.sourceSnippet;
                                    if isempty(events)
                                        events=value;
                                    else
                                        events(end+1)=value;
                                    end
                                else
                                    if~isa(land,'Stateflow.Ast.TemporalCondition')
                                        for idx=1:numel(land.children)
                                            events=getTransitionEvents(land.children{idx},events);
                                        end
                                    end
                                end



                                function hasAss=findAssigment(modelObject)
                                    hasAss=false;
                                    cont=Stateflow.Ast.getContainer(modelObject);
                                    if~isempty(cont.sections)
                                        for idx=1:numel(cont.sections)
                                            sec=cont.sections{idx};
                                            if isa(sec,'Stateflow.Ast.DuringSection')||...
                                                isa(sec,'Stateflow.Ast.EntrySection')||...
                                                isa(sec,'Stateflow.Ast.ExitSection')
                                                roots=sec.roots;
                                                for idxr=1:numel(roots)
                                                    if isa(roots{idxr},'Stateflow.Ast.EqualAssignment')
                                                        ss=roots{idxr}.sourceSnippet;
                                                        if contains(ss,'||')||contains(ss,'&&')
                                                            hasAss=true;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end



                                    function[hasCond,events]=findTransitionEvents(modelObject)

                                        events=[];
                                        hasCond=false;
                                        cont=Stateflow.Ast.getContainer(modelObject);
                                        if~isempty(cont.sections)
                                            for idx=1:numel(cont.sections)
                                                cond=cont.sections{idx};
                                                if isa(cond,'Stateflow.Ast.ConditionSection')
                                                    hasCond=true;
                                                    events=getTransitionEvents(cond.roots{1},events);
                                                end
                                            end
                                        end

                                        function events=findStateEvents(modelObject)
                                            eids=Stateflow.Ast.getResolvedSymbols(modelObject.Id);
                                            events=[];
                                            for idx=1:numel(eids)
                                                if sf('get',eids(idx),'.isa')==sf('get','default','event.isa')
                                                    value.type='Event';
                                                    value.name=sf('get',eids(idx),'.name');
                                                    if isempty(events)
                                                        events=value;
                                                    else
                                                        events(end+1)=value;%#ok<AGROW>
                                                    end
                                                end
                                            end

                                            function hasSldv=hasSldvObjects(modelObject)
                                                hasSldv=~isempty(strfind(modelObject.LabelString,'sldv.'));



