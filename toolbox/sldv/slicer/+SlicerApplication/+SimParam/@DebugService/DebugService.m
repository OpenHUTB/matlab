classdef DebugService<SlicerApplication.DebugService





    properties(Access=public,Hidden=true)
        currParamName=[];
        slicerObj=[];
        modelH=[];
        origShowFastRestartMessage=false;
        isSlicerSeedProvided=false;
        paramInfo slslicer.internal.ParameterDependenceInfo;
    end

    methods
        function obj=DebugService(seed,parametersToConsider)

            slicerSeedProvided=isa(seed,'SLSlicerAPI.SLSlicer');
            if slicerSeedProvided
                model=seed.Model;
            else
                model=seed;
            end
            if~bdIsLoaded(model)
                error('Sldv:DebugUsingSlicer:ModelNotLoaded',getString(message('Sldv:DebugUsingSlicer:ModelNotLoaded')));
            end

            obj@SlicerApplication.DebugService(model)
            obj.isSlicerSeedProvided=slicerSeedProvided;


            obj.criteriaTag='ForDebugging';
            obj.criteriaColor='Blue';
            obj.modelH=get_param(model,'handle');
            obj.originalfastRestartValue=get_param(model,'FastRestart');
            if~slicerSeedProvided
                set_param(model,'FastRestart','off');
                obj.slicerObj=slslicer(model);
            else
                if strcmp(obj.originalfastRestartValue,'on')
                    warning('DebugUsingSlicer:FastRestartOnInSlicerObjectSeedForSimParamWorkflow',...
                    getString(message('Sldv:DebugUsingSlicer:FastRestartOnInSlicerObjectSeedForSimParamWorkflow')));
                end
                obj.slicerObj=seed;
            end

            obj.slicerObj.addConfiguration();

            obj.origShowFastRestartMessage=obj.slicerObj.showFastRestartMessage;


            obj.slicerObj.showFastRestartMessage=false;

            obj.slicerObj.activate(false);

            if~exist('parametersToConsider',"var")


                parametersToConsider=[];
            end
            obj.paramInfo=slslicer.internal.ParameterDependenceInfo(model,parametersToConsider);
        end

        function setCurrentParamName(obj,paramName)

            obj.currParamName=paramName;
        end

        function setupSlicerCriteria(obj)



            slicerConfig=SlicerConfiguration.getConfiguration(obj.model);
            dlg=slicerConfig.modelSlicer.dlg;
            dlgSrc=dlg.getSource;


            criteriaIndex=obj.getCriteriaIndex(obj.currParamName);
            if~isempty(criteriaIndex)
                slicerConfig.selectCriteria(criteriaIndex);
            else

                currentObjectiveDescr=getString(message('Sldv:DebugUsingSlicer:CriteriaDescription'));
                sliceCriteria=obj.addSliceCriteriaForDebugWorkflows();
                sliceCriteria.name=obj.currParamName;
                sliceCriteria.description=currentObjectiveDescr;
                sliceCriteria.showCtrlDep=true;
                sliceCriteria.refresh;
            end


            obj.criteriaMap(obj.currParamName)=dlgSrc.Model.CurrentCriteria;
        end

        function dlgSrc=setupSlicerDialog(obj)


            msObj=modelslicerprivate('slicerMapper','get',obj.modelH);

            if isa(msObj,'ModelSlicer')&&~isempty(msObj.dlg)
                dlg=msObj.dlg;
            else
                dlg=obj.createSlicerDialog();
            end
            dlgSrc=dlg.getDialogSource;
        end

        function checkValidityOfSlicerObj(obj)

            if isa(obj.slicerObj,'handle')&&~isvalid(obj.slicerObj)
                error('Sldv:DebugUsingSlicer:SlicerObjectDeletedError',getString(message('Sldv:DebugUsingSlicer:SlicerObjectDeletedError')))
            end
        end


        function addParameterToClassScope(obj,parameters)
            obj.paramInfo.addParameterToClassScope(parameters);
        end


        setupSlicer(obj,simulinkParamStruct,includeIndirect);

        function blockList=getStartingPointsForParam(obj,varUsage,includeIndirect)
            blockList=obj.paramInfo.getStartingPointsForParam(varUsage,includeIndirect);
        end


        [parameters,slicerObj]=getParametersAffectingBlock(obj,block,includeIndirect);

        function disableCriteriaPanel(~,~)

        end

        function delete(obj)
            obj.currParamName=[];
            obj.modelH=[];

            if~isempty(obj.slicerObj)&&isvalid(obj.slicerObj)



                obj.slicerObj.showFastRestartMessage=obj.origShowFastRestartMessage;
            end
            if~obj.isSlicerSeedProvided

                delete(obj.slicerObj);
                if bdIsLoaded(obj.model)


                    set_param(obj.model,'FastRestart',obj.originalfastRestartValue);
                end
            end
            obj.origShowFastRestartMessage=false;
            obj.isSlicerSeedProvided=false;
            delete(obj.paramInfo);
        end
    end
end
