function parsedResults=parseCGIRResults(obj,key,removeOutOfScope,analysisRoot)




    if nargin==2
        removeOutOfScope=false;
        analysisRoot=[];
    end

    parsedResults=parseCGIRResults@Advisor.BaseRegisterCGIRInspectorResults(obj,key);
    if isempty(parsedResults)||~isfield(parsedResults,'tag')
        return;
    end
    parsedResults=removeDuplicateEntries(parsedResults);
    parsedResults=removeStateflowSFunctionRefs(parsedResults);
    parsedResults=removeDuplicateEntries(parsedResults);
    parsedResults=removeEmptyEntries(parsedResults);

    if removeOutOfScope
        parsedResults=removeOutOfScopeEntries(parsedResults,analysisRoot);
    end

    if~modeladvisorprivate('modeladvisorutil2','FeatureControl','test')
        parsedResults=applyModelAdvisorExclusions(parsedResults);
    end

    for i=1:length(parsedResults.tag)
        lines=splitUp(parsedResults.tag{i}.sid);
        MAElementArray=[];
        for k=1:length(lines)
            MAElementArray=[MAElementArray,ModelAdvisor.Text(lines{k})];%#ok<AGROW>
            if k~=length(lines)
                MAElementArray=[MAElementArray,ModelAdvisor.Text('<br/>')];%#ok<AGROW>
            end
        end
        parsedResults.tag{i}.sid=MAElementArray;
    end
    if isempty(parsedResults.tag)
        parsedResults=[];
    end






    function parsedResults=removeOutOfScopeEntries(parsedResults,analysisRoot)
        filter=false(size(parsedResults.tag));
        for i=1:numel(parsedResults.tag)
            thisTag=parsedResults.tag{i};
            lines=splitUp(thisTag.sid);
            sid=lines{1};
            if Simulink.ID.isValid(sid)
                fullPath=Simulink.ID.getFullName(sid);
                if strncmp(analysisRoot,fullPath,numel(analysisRoot))
                    filter(i)=true;
                end
            end
        end
        parsedResults.tag=parsedResults.tag(filter);


        function parsedResults=removeStateflowSFunctionRefs(parsedResults)
            for i=1:length(parsedResults.tag)
                lines=splitUp(parsedResults.tag{i}.sid);
                dupIdx=[];
                for j=1:length(lines)
                    try
                        h=Simulink.ID.getHandle(lines{j});
                        if~isempty(h)&&(strcmp(get_param(h,'BlockType'),'S-Function')&&...
                            strcmp(get_param(h,'FunctionName'),'sf_sfun'))
                            dupIdx=[dupIdx,j];%#ok<AGROW>
                        end
                    catch E %#ok<NASGU>
                    end
                end
                lines(dupIdx)=[];
                parsedResults.tag{i}.sid=strjoin(lines,'\n');
            end


            function parsedResults=applyModelAdvisorExclusions(parsedResults)
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                if isempty(mdladvObj)
                    return;
                end
                dupIdx=[];
                for i=1:length(parsedResults.tag)
                    lines=splitUp(parsedResults.tag{i}.sid);
                    for j=1:length(lines)
                        if isempty(mdladvObj.filterResultWithExclusion(lines{j}))
                            dupIdx=[dupIdx,i];%#ok<AGROW>
                            break;
                        end
                    end
                end
                parsedResults.tag(dupIdx)=[];


                function parsedResults=removeDuplicateEntries(parsedResults)
                    parsedResults=removeDuplicateEntries@Advisor.BaseRegisterCGIRInspectorResults(parsedResults);



                    for i=1:length(parsedResults.tag)
                        lines=splitUp(parsedResults.tag{i}.sid);
                        dupIdx=[];
                        for j=1:length(lines)
                            if~isempty(Simulink.ID.checkSyntax(lines{j}))||...
                                ~isempty(strfind(lines{j},'.m'))
                                dupIdx=[dupIdx,j];%#ok<AGROW>
                            end
                        end
                        lines(dupIdx)=[];
                        parsedResults.tag{i}.sid=strjoin(lines,'\n');
                    end



                    dupIdx=[];
                    for i=1:length(parsedResults.tag)
                        lines=splitUp(parsedResults.tag{i}.sid);
                        for j=1:length(lines)
                            if isInAcceleratedMdlRef(lines{j})
                                dupIdx=[dupIdx,i];%#ok<AGROW>
                                break;
                            end
                        end
                    end
                    parsedResults.tag(dupIdx)=[];


                    function flag=isInAcceleratedMdlRef(sid)
                        flag=false;
                        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

                        if~isempty(Simulink.ID.checkSyntax(sid))||isempty(mdladvObj)
                            return;
                        end
                        idx=strfind(sid,':');
                        if~isempty(idx)
                            mdlName=sid(1:idx(1)-1);
                            accelMdlrefs=Advisor.RegisterCGIRInspectorResults.modelReferenceInfo(bdroot(mdladvObj.System));
                            if any(strcmp(mdlName,accelMdlrefs))
                                flag=true;
                                return;
                            end
                        end


                        function parsedResults=removeEmptyEntries(parsedResults)
                            parsedResults=removeEmptyEntries@Advisor.BaseRegisterCGIRInspectorResults(parsedResults);


                            function lines=splitUp(inCell)
                                lines=Advisor.BaseRegisterCGIRInspectorResults.splitUp(inCell);
