classdef mdlrefddg_LocalSolverTab<handle




    properties
        source=[];
        h=[];
        isSlimDialog=[];
        disableWholeDialog=[];


    end
    methods(Access=public)
        function this=mdlrefddg_LocalSolverTab(source,h,isSlimDialog,disableWholeDialog)
            this.source=source;
            this.h=h;
            this.isSlimDialog=isSlimDialog;
            this.disableWholeDialog=disableWholeDialog;

        end

        function mdlBlkLocalSolverTab=getLocalSolverTab(this)
            if slfeature('MultiSolverSimulationSupport')>1
                if slfeature('InstanceLevelLocalSolverSetting')>0
                    mdlBlkLocalSolverTab=this.i_GetLocalSolverTabWithInstanceSetting();
                else
                    mdlBlkLocalSolverTab=this.i_GetLocalSolverTab();
                end
            else
                mdlBlkLocalSolverTab=[];
            end
        end
    end

    methods(Access=private)
        function thisTab=i_GetLocalSolverTabWithInstanceSetting(this)
            thisTab.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverToggle');
            thisTab.Tag="TabOfLocalSolverSettings";
            rowIdx=1;
            if slfeature('MultiSolverSimulationSupport')>1
                rowIdx=rowIdx+1;
                mdlUseLocalSolverHeader.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefUseLocalSolverOptions');
                mdlUseLocalSolverHeader.Type='text';
                mdlUseLocalSolverHeader.RowSpan=[rowIdx,rowIdx];
                mdlUseLocalSolverHeader.ColSpan=[1,1];

                modelExist=strcmp(get_param(this.h.Handle,'MdlRefModelIsFound'),'on');



                rowIdx=rowIdx+1;
                pRefMdlNotFound.Type='text';
                pRefMdlNotFound.Name=DAStudio.message('Simulink:dialog:ModelRefSpecifyModelForLocalSolver');
                pRefMdlNotFound.RowSpan=[rowIdx,rowIdx];
                pRefMdlNotFound.Enabled=true;
                pRefMdlNotFound.Visible=~modelExist;





                encapsulateLocalSolver=false;
                isInvalidEncapsulatedLocalSolver=false;

                isValidEncapsulatedLocalSolver=false;

                isValidLocalSolver=false;


                if modelExist
                    referenceModelFile=get_param(this.h.Handle,'ModelFile');
                    cs=Simulink.slx.getActiveConfigSet(referenceModelFile);
                    refMdlSolverName=get_param(cs,'SolverName');
                    validLocalSolverList={'FixedStepAuto','ode8','ode5','ode4','ode3','ode2','ode1'};
                    isValidLocalSolver=any(strcmp(validLocalSolverList,refMdlSolverName));
                    encapsulateLocalSolver=strcmp(get_param(cs,'UseModelRefSolver'),'on');
                    isInvalidEncapsulatedLocalSolver=encapsulateLocalSolver&&~isValidLocalSolver;
                    isValidEncapsulatedLocalSolver=encapsulateLocalSolver&&isValidLocalSolver;
                end

                rowIdx=rowIdx+1;
                pShowMdlLocalSolverUsage=this.i_GetProperty('SolverUsage');
                pShowMdlLocalSolverUsage.RowSpan=[rowIdx,rowIdx];
                pShowMdlLocalSolverUsage.Visible=modelExist;
                pShowMdlLocalSolverUsage.Enabled=modelExist;
                pShowMdlLocalSolverUsage.DialogRefresh=true;


                if isInvalidEncapsulatedLocalSolver
                    set_param(this.h.Handle,'SolverUsage','Use solver specified by topmost model');
                    pShowMdlLocalSolverUsage.Enabled=false;
                end


                if isValidEncapsulatedLocalSolver
                    set_param(this.h.Handle,'SolverUsage','Use solver specified by referenced model');
                    pShowMdlLocalSolverUsage.Enabled=false;
                end



                isInvalidToInherit=false;
                if modelExist&&~encapsulateLocalSolver&&...
                    strcmp(get_param(this.h.Handle,'SolverUsage'),'Use solver specified by referenced model')
                    if~isValidLocalSolver
                        isInvalidToInherit=true;
                    end
                end

                invalidMsg='';
                if isInvalidEncapsulatedLocalSolver
                    invalidMsg=DAStudio.message(...
                    'Simulink:dialog:ModelRefLocalSolverTypeInvalidToEncapsulate',refMdlSolverName);
                end

                if isInvalidToInherit
                    invalidMsg=DAStudio.message(...
                    'Simulink:dialog:ModelRefLocalSolverTypeInvalidToInherit',refMdlSolverName);
                end

                rowIdx=rowIdx+1;
                pInvalidLocalSolverType.Type='text';
                pInvalidLocalSolverType.Name=invalidMsg;
                pInvalidLocalSolverType.RowSpan=[rowIdx,rowIdx];
                pInvalidLocalSolverType.ColSpan=[1,1];
                pInvalidLocalSolverType.Enabled=true;
                pInvalidLocalSolverType.Visible=isInvalidEncapsulatedLocalSolver||isInvalidToInherit;

                widgetVisible=~strcmp(get_param(this.h.Handle,'SolverUsage'),'Use solver specified by topmost model')...
                &&~pInvalidLocalSolverType.Visible;
                rowIdx=rowIdx+1;
                pShowLocalFixedStepSolverName=this.i_GetProperty('BlockSolverName');
                pShowLocalFixedStepSolverName.RowSpan=[rowIdx,rowIdx];
                pShowLocalFixedStepSolverName.Visible=widgetVisible;
                pShowLocalFixedStepSolverName.Enabled=widgetVisible&&...
                strcmp(get_param(this.h.Handle,'SolverUsage'),'Configure solver');

                rowIdx=rowIdx+1;
                pShowLocalSolverFixedStepSize=this.i_GetProperty('SolverFixedStepSize');
                pShowLocalSolverFixedStepSize.RowSpan=[rowIdx,rowIdx];
                pShowLocalSolverFixedStepSize.Visible=widgetVisible;
                pShowLocalSolverFixedStepSize.Enabled=widgetVisible&&...
                strcmp(get_param(this.h.Handle,'SolverUsage'),'Configure solver');

                if isValidEncapsulatedLocalSolver

                    if strcmp(refMdlSolverName,'FixedStepAuto')
                        set_param(this.h.Handle,'BlockSolverName','Auto');
                    else
                        set_param(this.h.Handle,'BlockSolverName',refMdlSolverName);
                    end

                    refMdlSolverStepSize=get_param(cs,'FixedStep');
                    set_param(this.h.Handle,'SolverFixedStepSize',refMdlSolverStepSize);
                end

                rowIdx=rowIdx+1;
                pShowInputCompensationMethod=this.i_GetProperty('InputSignalHandling');
                pShowInputCompensationMethod.RowSpan=[rowIdx,rowIdx];

                pShowInputCompensationMethod.Visible=widgetVisible;
                pShowInputCompensationMethod.Enabled=widgetVisible;

                rowIdx=rowIdx+1;
                pShowOutputApproximationMethod=this.i_GetProperty('OutputSignalHandling');
                pShowOutputApproximationMethod.RowSpan=[rowIdx,rowIdx];
                pShowOutputApproximationMethod.Visible=widgetVisible;
                pShowOutputApproximationMethod.Enabled=widgetVisible;
            end

            pLocalSolverPanel.Tag="ModelRefLocalSolverSettingPanel";
            pLocalSolverPanel.Type='panel';
            pLocalSolverPanel.LayoutGrid=[1,1];
            if slfeature('MultiSolverSimulationSupport')>1
                pLocalSolverPanel.Items={mdlUseLocalSolverHeader,pRefMdlNotFound,pShowMdlLocalSolverUsage,...
                pInvalidLocalSolverType,pShowLocalFixedStepSolverName,...
                pShowInputCompensationMethod,pShowOutputApproximationMethod};
            else
                pLocalSolverPanel.Items={};
            end
            pLocalSolverPanel.Visible=true;
            pLocalSolverPanel.Enabled=slfeature('MultiSolverSimulationSupport')>1;
            thisTab.Items={pLocalSolverPanel};
        end



        function thisTab=i_GetLocalSolverTab(this)
            thisTab.Tag="TabOfLocalSolverSettings";
            thisTab.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverToggle');

            pMdlRefSolverPanel.Tag="ModelRefLocalSolverSettingPanel";
            pMdlRefSolverPanel.Items={};
            pMdlRefSolverPanel.Type='panel';
            if slfeature('MultiSolverSimulationSupport')>1

                [useLocal,...
                useLocalCallBack,...
                useLocalToolTip,...
                solverName,...
                solverNameCallBack,...
                solverNameToolTip,...
                stepSize,...
                stepSizeCallBack,...
                stepSizeToolTip,...
                isProtected]=this.getMessagesAndCallbacks();
                useLocalSolverBool=strcmp(useLocal,'on');


                row=1;

                pUseLocalSolverBuddy.Tag='UseLocalSolver_buddy';
                pUseLocalSolverBuddy.Type='text';
                pUseLocalSolverBuddy.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefUseLocalSolver');
                pUseLocalSolverBuddy.Buddy='UseLocalSolver';
                pUseLocalSolverBuddy.RowSpan=[row,row];
                pUseLocalSolverBuddy.ColSpan=[1,1];
                pUseLocalSolverBuddy.Visible=true;
                pUseLocalSolverBuddy.Enabled=~this.disableWholeDialog&&~isProtected;

                pUseLocalSolver.Tag='UseLocalSolver';
                pUseLocalSolver.Type='hyperlink';
                pUseLocalSolver.Name=useLocal;
                pUseLocalSolver.ToolTip=useLocalToolTip;
                pUseLocalSolver.RowSpan=[row,row];
                pUseLocalSolver.ColSpan=[2,2];
                pUseLocalSolver.MatlabMethod='feval';
                pUseLocalSolver.MatlabArgs={useLocalCallBack};
                pUseLocalSolver.Visible=true;
                pUseLocalSolver.Enabled=~this.disableWholeDialog&&~isProtected;
                row=row+1;


                pSolverNameBuddy.Tag='SolverName_buddy';
                pSolverNameBuddy.Type='text';
                pSolverNameBuddy.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverName');
                pSolverNameBuddy.Buddy='SolverName';
                pSolverNameBuddy.RowSpan=[row,row];
                pSolverNameBuddy.ColSpan=[1,1];
                pSolverNameBuddy.Visible=true;
                pSolverNameBuddy.Enabled=~this.disableWholeDialog&&useLocalSolverBool;

                pSolverName.Tag='SolverName';
                pSolverName.Type='hyperlink';
                pSolverName.Name=solverName;
                pSolverName.ToolTip=solverNameToolTip;
                pSolverName.RowSpan=[row,row];
                pSolverName.ColSpan=[2,2];
                pSolverName.MatlabMethod='feval';
                pSolverName.MatlabArgs={solverNameCallBack};
                pSolverName.Visible=true;
                pSolverName.Enabled=~this.disableWholeDialog&&useLocalSolverBool&&~isProtected;
                row=row+1;

                pStepSizeBuddy.Tag='StepSize_buddy';
                pStepSizeBuddy.Type='text';
                pStepSizeBuddy.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverFixedStep');
                pStepSizeBuddy.Buddy='StepSize';
                pStepSizeBuddy.RowSpan=[row,row];
                pStepSizeBuddy.ColSpan=[1,1];
                pStepSizeBuddy.Visible=true;
                pStepSizeBuddy.Enabled=~this.disableWholeDialog&&useLocalSolverBool;

                pStepSize.Tag='StepSize';
                pStepSize.Type='hyperlink';
                pStepSize.Name=stepSize;
                pStepSize.ToolTip=stepSizeToolTip;
                pStepSize.RowSpan=[row,row];
                pStepSize.ColSpan=[2,2];
                pStepSize.MatlabMethod='feval';
                pStepSize.MatlabArgs={stepSizeCallBack};
                pStepSize.Visible=true;
                pStepSize.Enabled=~this.disableWholeDialog&&useLocalSolverBool&&~isProtected;
                row=row+1;




                pInputSignalHandling=this.i_GetProperty('InputSignalHandling');
                pInputSignalHandling.RowSpan=[row,row];
                pInputSignalHandling.ColSpan=[1,2];
                pInputSignalHandling.Visible=true;
                isOde14x=strcmp(solverName,'ode14x');
                isOde1be=strcmp(solverName,'ode1be');
                if useLocalSolverBool&&(isOde14x||isOde1be)
                    set_param(this.h.Handle,'InputSignalHandling','Zero-order hold');
                end
                pInputSignalHandling.Enabled=useLocalSolverBool&&~this.disableWholeDialog&&~isOde14x&&~isOde1be;



                [pInputSignalHandlingName,pInputSignalHandling]=convertWidgetToSlim(pInputSignalHandling);
                pInputSignalHandlingName.Tag='InputSignalHandlingPrompt';
                row=row+1;


                pOutputSignalHandling=this.i_GetProperty('OutputSignalHandling');
                pOutputSignalHandling.RowSpan=[row,row];
                pOutputSignalHandling.ColSpan=[1,2];
                pOutputSignalHandling.Visible=true;
                pOutputSignalHandling.Enabled=useLocalSolverBool&&~this.disableWholeDialog;



                [pOutputSignalHandlingName,pOutputSignalHandling]=convertWidgetToSlim(pOutputSignalHandling);
                pOutputSignalHandlingName.Tag='OutputSignalHandlingPrompt';
                row=row+1;


                pRowSpacer.Tag='localSolverPanelRowSpacer';
                pRowSpacer.Type='panel';
                pRowSpacer.RowSpan=[row,row];
                pRowSpacer.ColSpan=[1,2];
                pRowSpacer.Visible=true;
                pRowSpacer.Enabled=true;
                row=row+1;

                nRows=row-1;
                pMdlRefSolverPanel.Items=...
                {pUseLocalSolver,...
                pUseLocalSolverBuddy,...
                pSolverNameBuddy,...
                pSolverName,...
                pStepSizeBuddy,...
                pStepSize,...
                pInputSignalHandling,...
                pInputSignalHandlingName,...
                pOutputSignalHandling,...
                pOutputSignalHandlingName,...
                pRowSpacer};
            end
            pMdlRefSolverPanel.LayoutGrid=[nRows,2];


            pMdlRefSolverPanel.RowStretch=zeros(1,nRows);
            pMdlRefSolverPanel.RowStretch(end)=1;
            thisTab.Items={pMdlRefSolverPanel};
        end

        function[useLocal,useLocalCallBack,useLocalToolTip,...
            solverName,solverNameCallBack,solverNameToolTip,...
            stepSize,stepSizeCallBack,stepSizeToolTip,...
            isProtected]...
            =getMessagesAndCallbacks(this)
            useLocal='';%#ok<NASGU>
            useLocalToolTip='';
            useLocalCallBack=@()[];
            useLocalFatalError=false;
            solverName='';%#ok<NASGU>
            solverNameToolTip='';
            solverNameCallBack=@()[];
            solverNameFatalError=false;
            stepSize='';%#ok<NASGU>
            stepSizeToolTip='';
            stepSizeCallBack=@()[];
            stepSizeFatalError=false;
            isProtected=false;
            try
                modelExist=strcmp(get_param(this.h.Handle,'MdlRefModelIsFound'),'on');
                if~modelExist
                    useLocal=DAStudio.message('Simulink:dialog:ModelRefSpecifyModelForLocalSolver');
                    solverName=useLocal;
                    stepSize=useLocal;
                    return;
                end
                modelFile=get_param(this.h.Handle,'ModelFile');
                isProtected=slInternal('getReferencedModelFileInformation',this.h.ModelNameDialog);
                if isempty(modelFile)



                    modelName=get_param(this.h.Handle,'ModelName');

                else
                    [~,modelName,ext]=fileparts(modelFile);
                end
                loaded=bdIsLoaded(modelName);


                if loaded&&~isProtected
                    cs=getActiveConfigSet(modelName);
                else
                    if strcmpi(ext,'.mdl')
                        useLocal=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverLoadModel');
                        solverName=useLocal;
                        stepSize=useLocal;
                        useLocalCallBack=@()load_system(modelFile);
                        solverNameCallBack=useLocalCallBack;
                        stepSizeCallBack=useLocalCallBack;
                        return;
                    elseif strcmpi(ext,'.slx')
                        cs=Simulink.slx.getActiveConfigSet(modelFile);
                    elseif isProtected


                        info=Simulink.MDLInfo(modelFile);
                        solverName=info.Interface.SolverName;
                        if info.Interface.UseModelRefSolver
                            useLocal='on';
                        else
                            useLocal='off';
                        end
                        stepSize=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverProtected');
                        return;
                    else
                        useLocal=DAStudio.message(...
                        'Simulink:dialog:ModelFileFormatNotSupportedByLocalSolver');
                        solverName=useLocal;
                        stepSize=useLocal;
                        return
                    end
                end
                [useLocal,useLocalCallBack,useLocalFatalError,...
                solverName,solverNameCallBack,solverNameFatalError,...
                stepSize,stepSizeCallBack,stepSizeFatalError]=this.getSolverInfoFromConfigset(cs,modelName);


                if useLocalFatalError
                    useLocalToolTip=useLocal;
                    useLocal=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                end
                if solverNameFatalError
                    solverNameToolTip=solverName;
                    solverName=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                end
                if stepSizeFatalError
                    stepSizeToolTip=stepSize;
                    stepSize=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                end
            catch me


                useLocal=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                useLocalToolTip=me.message;
                solverName=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                solverNameToolTip=me.message;
                stepSize=DAStudio.message('Simulink:modelReference:LocalSolveErrorGettingDialogInfoShort');
                stepSizeToolTip=me.message;
            end
        end

        function[value,callback,fatalError]=getParamAndCallback(this,cs,paramName,modelName)
            try
                value=cs.get_param(paramName);
                callback=@()configset.internal.open(modelName,paramName);


                if~strcmpi(paramName,'UseModelRefSolver')&&strcmp(cs.get_param('SolverType'),'Variable-step')
                    value=DAStudio.message('Simulink:modelReference:LocalVariableStepSolverNotSupportedShort');
                end
                fatalError=false;
            catch me
                if strcmp(me.identifier,'Simulink:ConfigSet:ConfigSetRef_GetParamOnUnresolvedReference')&&...
                    ~bdIsLoaded(modelName)



                    value=DAStudio.message('Simulink:blkprm_prompts:ModelRefLocalSolverLoadModel');
                    modelFile=get_param(this.h.Handle,'ModelFile');
                    callback=@()load_system(modelFile);
                    fatalError=false;
                else




                    fatalError=true;
                    value=me.message;
                    callback=@()[];
                end
            end
        end

        function[useLocal,useLocalCallback,useLocalFatalError,...
            solverName,solverNameCallback,solverNameFatalError,...
            stepSize,stepSizeCallback,stepSizeFatalError]=...
            getSolverInfoFromConfigset(this,cs,modelName)

            [useLocal,useLocalCallback,useLocalFatalError]=this.getParamAndCallback(cs,'UseModelRefSolver',modelName);
            [solverName,solverNameCallback,solverNameFatalError]=this.getParamAndCallback(cs,'Solver',modelName);
            [stepSize,stepSizeCallback,stepSizeFatalError]=this.getParamAndCallback(cs,'FixedStep',modelName);
        end

        function property=i_GetProperty(this,propName)



            property.ObjectProperty=propName;
            property.Tag=propName;


            property.Name=this.h.IntrinsicDialogParameters.(propName).Prompt;


            switch lower(this.h.IntrinsicDialogParameters.(propName).Type)
            case 'enum'
                property.Type='combobox';
                property.Entries=this.h.getPropAllowedValues(propName,true);
                property.MatlabMethod='handleComboSelectionEvent';
            case 'boolean'
                property.Type='checkbox';
                property.MatlabMethod='handleCheckEvent';
            otherwise
                property.Type='edit';
                property.MatlabMethod='handleEditEvent';
            end

            if this.isSlimDialog
                property.MatlabMethod='slDialogUtil';
                property.MatlabArgs={this.source,'sync','%dialog',property.Type,'%tag'};
            else
                property.MatlabArgs={this.source,'%value',find(strcmp(this.source.paramsMap,propName))-1,'%dialog'};
            end
        end

    end

end

