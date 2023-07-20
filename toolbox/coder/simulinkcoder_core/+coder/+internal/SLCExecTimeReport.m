classdef SLCExecTimeReport<coder.profile.ExecTimeReport




    methods(Access=public,Static=true)

        function modelHighlight(varargin)

            entitiesToHighlight=varargin;

            modelsProcessed={};

            for i=1:length(entitiesToHighlight)
                entity=entitiesToHighlight{i};


                if any(strfind(entity,':'))
                    model=strtok(entity,':');
                    isBlockRef=true;
                elseif any(strfind(entity,'/'))
                    model=strtok(entity,'/');
                    isBlockRef=true;
                else
                    model=entity;
                    isBlockRef=false;
                end
                isStateflowObject=false;

                try

                    if~any(strcmp(modelsProcessed,model))
                        if~bdIsLoaded(model)
                            load_system(model);
                        else
                            set_param(model,'HiliteAncestors','off');
                        end
                        modelsProcessed{end+1}=model;%#ok
                    end
                    colonPositions=strfind(entity,':');
                    for ii2=2:length(colonPositions)
                        libBlock=entity(1:colonPositions(ii2)-1);
                        if~strcmp(libBlock(end),':')
                            referenceBlock=get_param(libBlock,'ReferenceBlock');
                            if~isempty(referenceBlock)


                                libName=strtok(referenceBlock,'/');
                                if~any(strcmp(modelsProcessed,libName))
                                    if~bdIsLoaded(libName)
                                        load_system(libName);
                                    else
                                        set_param(libName,'HiliteAncestors','off');
                                    end
                                    modelsProcessed{end+1}=libName;%#ok
                                end
                            end
                            if any(strcmpi(get_param(libBlock,'SFBlockType'),{'Chart','MATLAB Function'}))
                                isStateflowObject=true;
                                isBlockRef=false;
                                break;
                            end
                        end
                    end

                    if isStateflowObject
                        Simulink.ID.hilite(entity);
                    elseif isBlockRef
                        hilite_system(entity);
                    else
                        open_system(model)
                    end

                catch exc
                    if strcmp...
                        (exc.identifier,...
                        'Simulink:Commands:OpenSystemUnknownSystem')...
                        ||...
                        strcmp(exc.identifier,...
                        'Simulink:Engine:RTWNameUnableToLocateRootBlock')
                        DAStudio.error('CoderProfile:ExecutionTime:ProfilingBDRefNotValid');
                    else
                        rethrow(exc)
                    end
                end
            end
        end

        function url=codeHighlight(componentName,buildDir,varargin)
            try
                url=coder.internal.slcoderReport('hiliteCode',buildDir,varargin{:});
            catch e
                if strcmp(e.identifier,'RTW:report:ReportNotFound')
                    id='CoderProfile:ExecutionTime:ProfilingMissingHtmlReport';
                    msg=DAStudio.message(id,componentName);
                    eNew=MException(id,msg);
                    eNew=eNew.addCause(e);
                    throw(eNew)
                else
                    rethrow(e)
                end
            end
        end

        function[execProfBaseStr,execProfFullStr,execProfileObjFunction]=searchForExecProfObj(idParent,modelName)
            [execProfBaseStr,execProfFullStr,execProfileObjFunction]=...
            coder.internal.SLCExecTimeReport.searchForObj(...
            idParent,...
            modelName,...
            'CodeExecutionProfileVariable',...
            'coder.profile.ExecutionTime');
        end

        function[execProfBaseStr,execProfFullStr,execProfileObjFunction]=searchForStackProfObj(idParent,modelName)
            [execProfBaseStr,execProfFullStr,execProfileObjFunction]=...
            coder.internal.SLCExecTimeReport.searchForObj(...
            idParent,...
            modelName,...
            'CodeStackProfileVariable',...
            'coder.profile.ExecutionStack');
        end

        function[modelText,entitiesToHighlight]=getTaskTextandEntity(traceInfo,simComp)


            modelText=traceInfo.getName;
            if~isempty(simComp)
                entitiesToHighlight={simComp};
            else
                entitiesToHighlight={traceInfo.getOriginalModelRef};
            end
        end
    end

    methods(Access=private,Static=true)
        function[execProfBaseStr,execProfFullStr,execProfileObjFunction]=...
            searchForObj(idParent,modelName,varNamePrm,classType)

            execProfBaseStr=[];
            execProfFullStr=[];
            execProfileObjFunction=[];


            whosBase=evalin('base','whos');
            nWhos=length(whosBase);
            [names{1:nWhos}]=deal(whosBase.name);
            [classes{1:nWhos}]=deal(whosBase.class);

            if isvarname(modelName)&&bdIsLoaded(modelName)
                execProfVarName=get_param(modelName,varNamePrm);


                simOutIdx=strcmp(classes,'Simulink.SimulationOutput');
                namesSimOut=names(simOutIdx);
                for i=1:length(namesSimOut)
                    name=namesSimOut{i};
                    candidate=evalin('base',[name,'.get(''',execProfVarName,''');']);
                    if~isempty(candidate)&&isa(candidate,classType)
                        if candidate.getIdUint64==idParent
                            execProfBaseStr=name;
                            execProfFullStr=sprintf('%s.get(''%s'')',...
                            name,execProfVarName);
                            return
                        end
                    end
                end
            end
        end
    end
end
