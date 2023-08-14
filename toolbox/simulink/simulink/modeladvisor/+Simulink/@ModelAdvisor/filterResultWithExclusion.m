function[remainingObjs,filteredObjs]=filterResultWithExclusion(this,remainingObjs,varargin)






    if nargin>2
        activeCheck=this.getCheckObj(varargin{1});
    elseif~isempty(this.ActiveCheck)
        activeCheck=this.ActiveCheck;
    else
        return;
    end

    if strcmp(this.CustomTARootID,'_modeladvisor_')&&slfeature('ExclusionEditorWebUI')==1

        [remainingObjs,filteredObjs,detailedResult]=slcheck.filterResultWithExclusions(this.system,remainingObjs,activeCheck.ID);
        activeCheck.exclusionIndex=[activeCheck.exclusionIndex;detailedResult];

        return;
    end

    filteredObjs={};
    exclusions=ModelAdvisor.getExclusions(activeCheck.ID,this);


    if isempty(exclusions)||~(strcmp(this.CustomTARootID,'_modeladvisor_')||strcmp(this.CustomTARootID,'_SYSTEM_By Product_Simulink Code Inspector'))
        return;
    end


    isObjsNotcell=~iscell(remainingObjs);
    if isObjsNotcell
        if ischar(remainingObjs)
            remainingObjs={remainingObjs};
        else
            temp=remainingObjs;
            remainingObjs={};
            for i=1:length(temp)
                remainingObjs{end+1}=temp(i);
            end
        end
    end

    for i=1:length(exclusions)
        before=length(remainingObjs);
        try
            [remainingObjs,filteredByExclusion]=filterExclusionForArrays(this.system,remainingObjs,exclusions(i));
            after=length(remainingObjs);
            if length(activeCheck.exclusionIndex)>=i
                activeCheck.exclusionIndex{i}=activeCheck.exclusionIndex{i}+before-after;
            else
                activeCheck.exclusionIndex{i}=before-after;
            end
            filteredObjs=[filteredObjs,filteredByExclusion];%#ok<AGROW>
        catch E
            activeCheck.exclusionIndex{i}=0;
            disp(E.message);
        end
    end
    if isObjsNotcell
        temp=remainingObjs;
        if~isempty(temp)
            remainingObjs=temp{1};
        else
            remainingObjs=[];
        end
        for i=2:length(temp)
            remainingObjs(end+1)=temp{i};
        end
    end

    function[remainingObjs,filteredObjs]=filterExclusionForArrays(system,objs,ExclusionObj)
        remainingObjs={};
        filteredObjs={};
        masterObjs=objs;
        RuleObjList=ExclusionObj.Rules;
        updateObjs=false;
        for idx=1:length(RuleObjList)
            if~isempty(objs)
                rule=RuleObjList(idx);
                isRegexp=strcmpi(rule.RegExp,'on');
                switch rule.Type
                case 'Subsystem'
                    value=rule.Value;
                    for i=1:length(value)
                        if~isRegexp
                            try

                                if strcmpi(rule.SID,'on')
                                    SubsysHandle=Simulink.ID.getHandle(value{i});
                                else
                                    SubsysHandle=get_param(value{i},'handle');
                                end
                            catch E
                                continue;
                            end
                            try
                                for j=1:length(objs)
                                    [objHandle,isSFChart]=getObjHandle(objs{j},'Subsystem');
                                    if~isempty(objs{j})&&loc_InsideSubsys(objHandle,SubsysHandle,isSFChart)
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                end
                            catch E
                            end
                        else


                            allSubSys=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
                            matchedSubSys={};
                            for k=1:length(allSubSys)
                                if regexp(allSubSys{k},value{i})
                                    matchedSubSys{end+1}=allSubSys{k};
                                end
                            end
                            for k=1:length(matchedSubSys)
                                SubsysHandle=get_param(matchedSubSys{k},'handle');
                                for j=1:length(objs)
                                    if ishandle(objs{j})
                                        objHandle=objs{j};
                                    elseif isa(objs{j},'Stateflow.Chart')
                                        objHandle=get_param(objs{j}.path,'handle');
                                    else
                                        objHandle=get_param(objs{j},'handle');
                                    end
                                    if~isempty(objs{j})&&loc_InsideSubsys(objHandle,SubsysHandle)
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                end
                            end
                        end
                    end
                case 'MaskType'
                    value=rule.Value;
                    for i=1:length(value)
                        if~isRegexp
                            try
                                MaskType=value{i};
                            catch E
                                continue;
                            end
                            try
                                for j=1:length(objs)
                                    objHandle=getObjHandle(objs{j},'MaskType');
                                    if~isempty(objs{j})&&loc_InsideMaskType(objHandle,MaskType)
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                end
                            catch E
                            end
                        end
                    end
                case 'BlockType'
                    value=rule.Value;
                    for i=1:length(value)
                        try
                            BlockType=value{i};
                        catch E
                            continue;
                        end
                        try
                            for j=1:length(objs)
                                if~isempty(objs{j})
                                    objHandle=getObjHandle(objs{j},'BlockType');
                                    if~isRegexp
                                        if blockTypeCompare(objHandle,BlockType)

                                            filteredObjs{end+1}=objs{j};
                                            objs{j}='';
                                        end
                                    else
                                        if regexp(get_param(objHandle,'BlockType'),BlockType)
                                            filteredObjs{end+1}=objs{j};
                                            objs{j}='';
                                        end
                                    end
                                end
                            end
                        catch E
                        end
                    end
                case 'Block'
                    value=rule.Value;
                    for i=1:length(value)
                        if~isRegexp
                            try
                                if strcmpi(rule.SID,'on')
                                    blockHandle=Simulink.ID.getHandle(value{i});
                                else
                                    blockHandle=get_param(value{i},'handle');
                                end
                            catch E
                                continue;
                            end
                        end
                        for j=1:length(objs)
                            if~isempty(objs{j})
                                objHandle=getObjHandle(objs{j},'Block');
                                if~isRegexp
                                    if~isempty(objHandle)&&(blockHandle==objHandle)
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                else



                                    objName=strrep(getfullname(objHandle),sprintf('\n'),' ');
                                    ruleName=strrep(rule.Value{i},sprintf('\n'),' ');
                                    if~isempty(regexp(objName,ruleName))
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                end
                            end
                        end
                    end
                case 'BlockParameters'
                    value=rule.Value;
                    name=rule.Name;
                    for i=1:length(value)
                        for j=1:length(objs)
                            if~isempty(objs{j})
                                objHandle=getObjHandle(objs{j},'BlockParameters');
                                try
                                    paramValue=get_param(objHandle,name{i});
                                    if isnumeric(paramValue)
                                        paramValue=num2str(paramValue);
                                    end
                                    if strcmpi(paramValue,value{i})
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                catch E
                                end
                            end
                        end
                    end
                case 'Library'
                    value=rule.Value;
                    for i=1:length(value)
                        for j=1:length(objs)
                            if~isempty(objs{j})
                                try
                                    objHandle=getObjHandle(objs{j},'Library');
                                    bdName=get_param(bdroot(objHandle),'name');


                                    if bdroot(objHandle)==objHandle
                                        continue;
                                    else
                                        if isa(objs{j},'Stateflow.Object')
                                            referenceBlock=getfullname(objHandle);
                                        else





                                            BlkParent=get_param(objs{j},'Parent');
                                            referenceBlock=get_param(objs{j},'ReferenceBlock');
                                            originalreferenceBlock=referenceBlock;



                                            while~strcmpi(BlkParent,bdName)
                                                referenceBlock=get_param(BlkParent,'ReferenceBlock');
                                                if strncmpi(referenceBlock,value{i},length(value{i}))
                                                    break;
                                                end
                                                BlkParent=get_param(BlkParent,'Parent');
                                            end
                                        end
                                    end
                                    if iscell(referenceBlock)
                                        referenceBlock=referenceBlock{1};
                                    end

                                    if strncmpi(referenceBlock,value{i},length(value{i}))||strncmpi(originalreferenceBlock,value{i},length(value{i}))
                                        filteredObjs{end+1}=objs{j};
                                        objs{j}='';
                                    end
                                catch E
                                end
                            end
                        end
                    end
                case 'Stateflow'
                    value=rule.Value;
                end


                updateObjs=true;

                objs=filteredObjs;
                filteredObjs=[];
            end
        end
        if updateObjs
            if ischar(masterObjs{1})
                remainingObjs=setxor(objs,masterObjs,'legacy');
            else
                tempMasterObjs=masterObjs{1};
                tempObjs={};
                if~isempty(objs)
                    tempObjs=objs{1};
                end
                for i=2:length(masterObjs)
                    tempMasterObjs(end+1)=masterObjs{i};
                end
                for i=2:length(objs)
                    tempObjs(end+1)=objs{i};
                end
                tempremainingObjs=setxor(tempMasterObjs,tempObjs,'legacy');
                for i=1:length(tempremainingObjs)
                    remainingObjs{end+1}=tempremainingObjs(i);
                end
            end

        end

        function isInside=loc_InsideSubsys(block,subsys,isSFChart)
            if nargin<3
                isSFChart=false;
            end

            isInside=false;

            if subsys==block
                isInside=true;
                return
            end
            if isa(block,'Stateflow.EMFunction')
                parentSubsystem=block.Chart.Path;
            elseif isSFChart
                parentSubsystem=block;
            else
                parentSubsystem=get_param(block,'Parent');
            end
            while~isempty(parentSubsystem)
                parentSubsystem=get_param(parentSubsystem,'handle');
                if subsys==parentSubsystem
                    isInside=true;
                    break
                end
                parentSubsystem=get_param(parentSubsystem,'Parent');
            end

            function isInside=loc_InsideMaskType(block,maskType)
                isInside=false;
                try

                    if strcmpi(get_param(block,'MaskType'),maskType)
                        isInside=true;
                        return
                    end

                    parent=get_param(block,'Parent');
                    while~isempty(parent)
                        if strcmpi(get_param(parent,'MaskType'),maskType)
                            isInside=true;
                            break
                        end
                        parent=get_param(parent,'Parent');
                    end
                catch E
                    return;
                end

                function[objHandle,isSFChart]=getObjHandle(obj,scope)
                    try
                        objHandle=[];
                        isSFChart=false;


                        if isempty(Simulink.ID.checkSyntax(obj))
                            obj=Simulink.ID.getHandle(obj);
                        end
                        if isa(obj,'Stateflow.Chart')||isa(obj,'Stateflow.EMChart')
                            objHandle=get_param(obj.path,'handle');
                        elseif contains(class(obj),'Stateflow')&&strcmp(scope,'Subsystem')
                            chartId=sfprivate('getChartOf',obj.id);
                            out=sf('get',chartId,'chart.activeInstance');
                            if out==0.0
                                h=idToHandle(sfroot,chartId);
                                objHandle=get_param(h.Path,'Handle');
                                isSFChart=true;
                            end
                        elseif contains(class(obj),'Simulink')
                            objHandle=obj.Handle;
                        elseif ishandle(obj)
                            objHandle=obj;
                        else
                            objHandle=get_param(obj,'handle');
                        end
                    catch E
                    end

                    function flag=blockTypeCompare(objHandle,BlockType)
                        flag=false;


                        if strcmp(BlockType,'Stateflow')
                            if slprivate('is_stateflow_based_block',objHandle)
                                flag=true;
                                return;
                            end
                        end
                        if Stateflow.SLUtils.isStateflowBlock(objHandle)&&...
                            strcmpi(get_param(objHandle,'SFBlockType'),BlockType)
                            flag=true;
                            return;
                        end
                        if strcmpi(get_param(objHandle,'BlockType'),BlockType)
                            flag=true;
                            return;
                        else
                            if strcmpi(get_param(objHandle,'BlockType'),'SubSystem')
                                chartId=isChart(objHandle);
                                if~isempty(chartId)
                                    if sf('Private','is_eml_chart',chartId)
                                        if strcmp(BlockType,'MATLAB Function')
                                            flag=true;
                                        end
                                    end
                                end
                            end
                        end


                        function chartId=isChart(blockH)

                            chartId=[];

                            ud=get_param(blockH,'userdata');
                            if~isempty(ud)&&isscalar(ud)&&(isstruct(ud)||floor(ud)==ud)
                                chartId=sfprivate('block2chart',blockH);
                            end
