classdef SoftwareComponentToImplConverter<systemcomposer.internal.arch.internal.ComponentToImplConverter









    properties(Access=private)
        ErrorReporter systemcomposer.internal.BaseErrorReporter=...
        systemcomposer.internal.CommandLineErrorReporter
CachedInportProps
    end

    properties
        ImplementComponentAs systemcomposer.internal.arch.internal.ComponentImplementation
    end

    methods
        function obj=SoftwareComponentToImplConverter(blkH,mdlName,dirPath,template)
            if nargin<4
                template=[];
            end

            if nargin<3
                dirPath=string(pwd);
            end



            systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdroot(blkH));

            obj@systemcomposer.internal.arch.internal.ComponentToImplConverter(blkH,mdlName,dirPath,template);
            obj.ImplementComponentAs=systemcomposer.internal.arch.internal.getDefaultSoftwareComponentImplementation(...
            obj.BlockHandle);
        end

        function setErrorReporter(obj,reporter)
            obj.ErrorReporter=reporter;
        end
    end

    methods(Access=protected)
        function runValidationChecksHook(obj)
            import systemcomposer.internal.arch.internal.ComponentImplementation;

            switch obj.ImplementComponentAs
            case ComponentImplementation.ExportFunction
                obj.validateForExportFunctionModel();
            otherwise
                assert(obj.ImplementComponentAs==ComponentImplementation.RateBased);
                obj.validateForRateBasedModel();
            end
        end

        function postCreateImplModelHook(obj)
            import systemcomposer.internal.arch.internal.ComponentImplementation;

            postCreateImplModelHook@systemcomposer.internal.arch.internal.ComponentToImplConverter(obj);
            set_param(obj.ModelName,'SolverType','Fixed-step');
            if obj.ImplementComponentAs==ComponentImplementation.RateBased

                set_param(obj.ModelName,'EnableMultiTasking','on');
            elseif slfeature('ExecutionDomainExportFunction')>0&&...
                obj.ImplementComponentAs==ComponentImplementation.ExportFunction

                set_param(obj.ModelName,'SetExecutionDomain','on');
                set_param(obj.ModelName,'ExecutionDomainType','ExportFunction');
            end

            if~isempty(obj.getComponentFunctions())


                callerFunctions=obj.getCallerRootFunctions();
                [~,sortIdxs]=sort([callerFunctions.executionOrder]);
                callerFunctions=callerFunctions(sortIdxs);

                topMfModel=get_param(bdroot(obj.BlockHandle),'SystemComposerMF0Model');
                topModelTxn=topMfModel.beginRevertibleTransaction();
                for i=1:numel(callerFunctions)
                    fcInport=swarch.utils.getFcnCallInport(callerFunctions(i));
                    if~isempty(fcInport)
                        set_param(fcInport,'SampleTime','-1');
                    end
                end







                topModelTxn.rollBack();
            end
        end

        function postCopyContentsToModelHook(obj)
            import systemcomposer.internal.arch.internal.*;

            postCopyContentsToModelHook@systemcomposer.internal.arch.internal.ComponentToImplConverter(obj);
            if isClientServerEnabled()&&(obj.ImplementComponentAs~=ComponentImplementation.RateBased)
                obj.createClientServerPorts();
            end

            if~isempty(obj.getComponentFunctions())


                switch obj.ImplementComponentAs
                case ComponentImplementation.ExportFunction
                    obj.createFcnCallSubsystems();
                otherwise
                    assert(obj.ImplementComponentAs==ComponentImplementation.RateBased);
                    obj.createRateBasedSubsystems();




                    obj.mapFunctionNamesToRatePorts();
                end

                refZCModel=getOrCreateSystemComposerModel(obj.ModelHandle);
                refRootArch=refZCModel.Architecture.getImpl();


                partTraitClass=systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass;
                refTrait=refRootArch.addTrait(partTraitClass);
                srcComp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
                srcTrait=srcComp.getArchitecture().getTrait(partTraitClass);



                cloneFunctionsToTrait(srcTrait,refTrait,refZCModel);




                callerFuncs=obj.getCallerRootFunctions();
                inportBlocks=arrayfun(@swarch.utils.getFcnCallInport,...
                callerFuncs,'UniformOutput',false);
                inportBlocks=[inportBlocks{:}];

                obj.CachedInportProps=...
                repmat(struct('Name','','Priority','','Port',''),...
                [1,numel(inportBlocks)]);
                for idx=1:numel(inportBlocks)
                    inportBlock=inportBlocks(idx);
                    obj.CachedInportProps(idx)=struct(...
                    'Name',get_param(inportBlock,'Name'),...
                    'Priority',get_param(inportBlock,'Priority'),...
                    'Port',get_param(inportBlock,'Port'));
                end


                [~,sortIdxs]=sort(cellfun(@str2double,{obj.CachedInportProps.Port}));
                obj.CachedInportProps=obj.CachedInportProps(sortIdxs);
            end
        end

        function postLinkComponentToModelHook(obj)


            bdHandle=bdroot(obj.BlockHandle);
            set_param(bdHandle,'SuspendBlockValidation','on');
            cleanupBlockValidation=onCleanup(@()set_param(bdHandle,'SuspendBlockValidation','off'));
            for idx=1:numel(obj.CachedInportProps)
                inportProps=obj.CachedInportProps(idx);
                inportName=[get_param(bdHandle,'Name'),'/',inportProps.Name];
                add_block('built-in/Inport',inportName,...
                'Port',inportProps.Port,...
                'Priority',inportProps.Priority,...
                'OutputFunctionCall','on');
            end
        end

        function componentFuncs=getComponentFunctions(obj)


            zcComponent=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            compPartitioningTrait=zcComponent.getArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            componentFuncs=compPartitioningTrait.getFunctionsOfType(systemcomposer.architecture.model.swarch.FunctionType.OSFunction);
        end
    end

    methods(Access=private)
        function createFcnCallSubsystems(obj)


            if(strcmp(get_param(obj.BlockHandle,'BlockType'),'SubSystem'))
                swComp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
                if~swComp.getArchitecture.isSoftwareArchitecture()
                    return;
                end

                componentFuncs=obj.getComponentFunctions();




                fcns=swComp.getArchitecture().getTrait(...
                systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).functions.toArray;

                numCols=ceil(sqrt(numel(fcns)));
                if(numCols<3)
                    numCols=3;
                end

                horizSpacing=220*[1,0,1,0];
                vertSpacing=150*[0,1,0,1];

                subsysSize=[-35,-20,35,20];
                subsysOffset=[85,50,85,50];




                horizShift=-horizSpacing*numCols;
                initPos=[100,100,130,114]+horizShift;

                col=1;
                for i=1:length(componentFuncs)
                    currentFunc=componentFuncs(i);


                    currentPos=initPos+mod(col-1,numCols)*horizSpacing;
                    inportBlkName=[obj.ModelName,'/',currentFunc.getName()];
                    inportBlk=add_block('built-in/Inport',inportBlkName,...
                    'SampleTime',currentFunc.period,...
                    'OutputFunctionCall','on',...
                    'Position',currentPos,...
                    'MakeNameUnique','on');

                    fcnCallSSBlk=add_block('simulink/Ports & Subsystems/Function-Call Subsystem',...
                    [getfullname(inportBlk),'_alg'],...
                    'Position',currentPos+subsysOffset+subsysSize,...
                    'MakeNameUnique','on');


                    inportBlkOut=get_param(inportBlk,'PortHandles').Outport;
                    fcnCallIn=get_param(fcnCallSSBlk,'PortHandles').Trigger;
                    add_line(obj.ModelName,inportBlkOut,fcnCallIn,...
                    'autorouting','on');

                    col=col+1;
                    if col>numCols
                        initPos=initPos+vertSpacing;
                        col=1;
                    end
                end


                initPos=[initPos(1),initPos(2),initPos(1)+100,initPos(2)+42];

                for i=1:length(fcns)
                    if isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Initialize)||...
                        isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Reset)||...
                        isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Terminate)

                        currentPos=initPos+mod(col-1,numCols)*horizSpacing;

                        irtBlkName=[obj.ModelName,'/',fcns(i).getName()];
                        if isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Initialize)
                            irtBlkType='simulink/User-Defined Functions/Initialize Function';
                        elseif isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Reset)
                            irtBlkType='simulink/User-Defined Functions/Reset Function';
                        elseif isequal(fcns(i).type,systemcomposer.architecture.model.swarch.FunctionType.Terminate)
                            irtBlkType='simulink/User-Defined Functions/Terminate Function';
                        end
                        add_block(irtBlkType,irtBlkName,'Position',currentPos,'MakeNameUnique','on');

                        col=col+1;
                        if col>numCols
                            initPos=initPos+vertSpacing;
                            col=1;
                        end
                    end
                end
            end
        end

        function createRateBasedSubsystems(obj)





            callerFuncs=obj.getCallerRootFunctions();
            [~,sortIdxs]=sort([callerFuncs.executionOrder]);
            componentFuncs=[callerFuncs(sortIdxs).calledFunction];

            periodicFuncIdxs=~strcmp('-1',{componentFuncs.period});
            nonperiodicFuncs=componentFuncs(~periodicFuncIdxs);
            periodicFuncs=componentFuncs(periodicFuncIdxs);










            numCols=ceil(sqrt(numel(periodicFuncs)));

            horizSpacing=220*[1,0,1,0];
            vertSpacing=75*[0,1,0,1];
            horizOffset=50*[1,0,1,0];

            horizShift=-horizSpacing*numCols;
            initPos=[100,100,130,114]+horizShift;

            for i=1:length(periodicFuncs)
                currentFunc=periodicFuncs(i);

                centerPos=initPos+mod(i-1,numCols)*horizSpacing;
                if mod(i,numCols)==0
                    initPos=initPos+vertSpacing;
                end


                constBlock=add_block(...
                'simulink/Sources/Constant',[obj.ModelName,'/Constant'],...
                'SampleTime',currentFunc.period,...
                'Position',centerPos-horizOffset,...
                'MakeNameUnique','on');
                constBlockOut=get_param(constBlock,'PortHandles').Outport;

                termBlock=add_block(...
                'simulink/Sinks/Terminator',[obj.ModelName,'/Terminator'],...
                'Position',centerPos+horizOffset,...
                'MakeNameUnique','on');
                termBlockIn=get_param(termBlock,'PortHandles').Inport;

                add_line(obj.ModelName,constBlockOut,termBlockIn);
            end


            if~isempty(periodicFuncs)
                createRateDesc=@(func)sprintf('\t%s: %s\n',func.getName(),func.period);
                rateDescs=arrayfun(createRateDesc,periodicFuncs,'UniformOutput',false)';
                periodicDesc=strjoin(...
                [{getString(saveAndLinkMsg('FunctionsWithSpecifiedSampleTimes',obj.ModelName))}
                rateDescs]);
                notePos=initPos+mod(numel(periodicFuncs),numCols)*horizSpacing;
                obj.addNoteToBehavior(periodicDesc,notePos)
            end














            asyncSpecSize=[-25,-15,25,15];

            inportSize=[-15,-8,15,8];
            inportOffset=[-80,0,-80,0];

            subsysSize=[-35,-20,35,20];
            subsysOffset=[85,50,85,50];

            horizSpacing=[275,0,275,0];
            vertSpacing=[0,150,0,150];

            initPos=100*[1,1,1,1]+[1,0,1,0]*(numCols*300);
            numCols=ceil(sqrt(numel(nonperiodicFuncs)));

            for i=1:length(nonperiodicFuncs)
                currentFunc=nonperiodicFuncs(i);

                asyncSpecPos=initPos+mod(i-1,numCols)*horizSpacing;
                if mod(i,numCols)==0
                    initPos=initPos+vertSpacing;
                end

                inportBlkName=[obj.ModelName,'/',currentFunc.getName()];
                inportBlock=add_block('built-in/Inport',inportBlkName,...
                'SampleTime',currentFunc.period,...
                'OutputFunctionCall','on',...
                'Position',asyncSpecPos+inportOffset+inportSize,...
                'MakeNameUnique','on');

                asyncSpecBlock=add_block(...
                'rtwlib/Asynchronous/Asynchronous Task Specification',...
                [obj.ModelName,'/Asynchronous Task Specification'],...
                'TaskPriority',num2str(9+i),...
                'Position',asyncSpecPos+asyncSpecSize,...
                'MakeNameUnique','on');

                fcnCallSSBlock=add_block('simulink/Ports & Subsystems/Function-Call Subsystem',...
                [getfullname(inportBlock),'_alg'],...
                'Position',asyncSpecPos+subsysOffset+subsysSize,...
                'MakeNameUnique','on');



                inportBlockOut=get_param(inportBlock,'PortHandles').Outport;
                specBlockIn=get_param(asyncSpecBlock,'PortHandles').Inport;
                add_line(obj.ModelName,inportBlockOut,specBlockIn)

                specBlockOut=get_param(asyncSpecBlock,'PortHandles').Outport;
                ssTriggerIn=get_param(fcnCallSSBlock,'PortHandles').Trigger;
                add_line(obj.ModelName,specBlockOut,ssTriggerIn,'autorouting','on');




                if strcmp(get_param(obj.ModelName,'SaveFormat'),'Dataset')
                    set_param(obj.ModelName,'SaveFormat','StructureWithTime');
                end
            end
        end

        function addNoteToBehavior(obj,desc,position)




            note=Simulink.Annotation([obj.ModelName,'/',desc]);
            note.BackgroundColor='automatic';
            note.FontSize='18';
            note.Position=position+note.Position;
        end

        function callerRootFuncs=getCallerRootFunctions(obj)


            zcModel=get_param(bdroot(obj.BlockHandle),'SystemComposerModel');
            rootPartitioningTrait=zcModel.Architecture.getImpl().getTrait(...
            systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);

            rootFunctions=rootPartitioningTrait.getFunctionsOfType(...
            systemcomposer.architecture.model.swarch.FunctionType.OSFunction);

            srcComp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            callerRootFuncs=rootFunctions(...
            arrayfun(@(f)~isempty(f.calledFunctionParent)&&f.calledFunctionParent==srcComp,rootFunctions));
        end

        function createClientServerPorts(obj)



            swComp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);



            set_param(obj.ModelName,'SetExecutionDomain','on');
            set_param(obj.ModelName,'ExecutionDomainType','ExportFunction');


            inportBlocks=find_system(obj.ModelName,'BlockType','Inport');


            for i=1:numel(inportBlocks)
                if(strcmp(get_param(inportBlocks{i},'IsClientServer'),'on'))
                    set_param(obj.ModelName,'FunctionConnectors','on');
                    set_param(obj.ModelName,'SystemTargetFile','ert.tlc');
                    set_param(obj.ModelName,'TargetLang','C++');
                    portName=get_param(inportBlocks(i),'PortName');
                    pI=swComp.getPort(portName{1}).getArchitecturePort().getPortInterface();

                    elementNames={};
                    if(isempty(pI))



                        elementNames{1}='f1';
                        fcnPrototype{1}='y = f1(u)';
                    else
                        elementNames=pI.getElementNames;
                        pE=pI.getElements;
                        fcnPrototype=cell(length(elementNames),1);
                        for cnt=1:length(elementNames)
                            fcnPrototype{cnt}=pE(cnt).getFunctionPrototype;
                        end
                    end

                    set_param(inportBlocks{i},'AllowServiceAccess','on');
                    set_param(inportBlocks{i},'IsClientServer','on');
                    for eCnt=1:length(elementNames)

                        if(eCnt==1)
                            opH=get_param(inportBlocks{i},'Handle');
                            set_param(inportBlocks{i},'Element',[elementNames{eCnt}]);
                            set_param(inportBlocks{i},'Name',strcat('Function Element Call',num2str(i)));
                        else


                            opH=add_block([obj.ModelName,'/',strcat('Function Element Call',num2str(i))],...
                            [obj.ModelName,'/',strcat('Function Element Call',num2str(numel(inportBlocks)+1))],...
                            'MakeNameUnique','on');
                            set_param(opH,'Element',[elementNames{eCnt}]);
                        end
                        set_param(opH,'Position',[100+(i-1)*100,(eCnt*100)+95,110+(i-1)*100,((eCnt+1)*100)+5]);


                        fcnSSName=['/call',elementNames{eCnt}];
                        inportBlkName=[obj.ModelName,fcnSSName,'Port'];
                        bH=add_block('built-in/Inport',inportBlkName,'MakeNameUnique','on');
                        set_param(bH,'OutputFunctionCall','on');
                        set_param(bH,'Position',[130+(i-1)*100,(eCnt*100)+2,160+(i-1)*100,(eCnt*100)+18]);

                        ssName=[obj.ModelName,fcnSSName];
                        ssH=add_block('built-in/SubSystem',ssName,'MakeNameUnique','on');
                        ssName=get_param(ssH,'Name');
                        trigPortName=[obj.ModelName,'/',ssName,'/function'];
                        trigPortH=add_block('built-in/TriggerPort',trigPortName,...
                        'MakeNameUnique','on');
                        set_param(trigPortH,'TriggerType','function-call');
                        set_param(trigPortH,'StatesWhenEnabling','Held');
                        set_param(ssH,'Position',[205+(i-1)*100,(eCnt*100)+25,255+(i-1)*100,(eCnt*100)+75]);

                        inPH=get_param(bH,'PortHandles');
                        ssPH=get_param(ssH,'PortHandles');
                        add_line(obj.ModelName,inPH.Outport,ssPH.Trigger);

                        cH=add_block('simulink/User-Defined Functions/Function Caller',...
                        [obj.ModelName,'/',ssName,'/',elementNames{eCnt},' Caller'],...
                        'MakeNameUnique','on');
                        scopedPrototype=replaceBetween(fcnPrototype{eCnt},"=","(",[portName{1},'.',elementNames{eCnt}]);

                        set_param(cH,'FunctionPrototype',scopedPrototype);
                        if~isempty(pI)


                            pE=pI.getElement(elementNames{eCnt});
                            if pE.getAsynchronous
                                set_param(cH,'AsynchronousCaller','on');


                                callerPorts=get_param(cH,'PortHandles');
                                if~isempty(callerPorts.Outport)

                                    assert(numel(callerPorts.Outport),1);
                                    callerPos=get_param(cH,'Position');
                                    callerPosX=callerPos(3);
                                    callerPosY=(callerPos(4)+callerPos(2))/2;
                                    callerOutH=add_block('built-in/Outport',[obj.ModelName,'/',ssName,'/',elementNames{eCnt},'CallerReturn'],'MakeNameUnique','on');
                                    callerOutLen=30;
                                    callerOutHgt=18;

                                    set_param(callerOutH,'Position',[callerPosX+75,callerPosY-callerOutHgt/2,...
                                    callerPosX+75+callerOutLen,callerPosY+callerOutHgt/2]);
                                    callerOutPorts=get_param(callerOutH,'PortHandles');
                                    add_line([obj.ModelName,'/',ssName],callerPorts.Outport,callerOutPorts.Inport);


                                    msgSSH=add_block('simulink/Messages & Events/Message Triggered Subsystem',...
                                    [obj.ModelName,'/',elementNames{eCnt},'ResponseSubsystem'],...
                                    'MakeNameUnique','on');



                                    msgSSHPorts=get_param(msgSSH,'PortHandles');
                                    ssPorts=get_param(ssH,'PortHandles');
                                    add_line(obj.ModelName,ssPorts.Outport,msgSSHPorts.Trigger);




                                    ssPos=get_param(ssH,'Position');
                                    msgSSLen=70;
                                    msgSSHgt=50;
                                    set_param(msgSSH,'Position',[ssPos(1)+75,ssPos(2)+45,...
                                    ssPos(1)+75+msgSSLen,ssPos(2)+45+msgSSHgt]);


                                    msgSSPath=getfullname(msgSSH);
                                    triggerBlkH=Simulink.findBlocksOfType(msgSSPath,'TriggerPort');
                                    set_param(triggerBlkH,'ScheduleAsAperiodic','off');
                                end
                            end
                        end
                    end
                    try
                        set_param(bdroot,'SimulationCommand','Update');
                    catch
                    end
                end
            end


            outportBlocks=find_system(obj.ModelName,'BlockType','Outport');

            for i=1:numel(outportBlocks)
                if(strcmp(get_param(outportBlocks{i},'IsClientServer'),'on'))
                    set_param(obj.ModelName,'FunctionConnectors','on');
                    set_param(obj.ModelName,'SystemTargetFile','ert.tlc');
                    set_param(obj.ModelName,'TargetLang','C++');
                    portName=get_param(outportBlocks(i),'PortName');
                    pI=swComp.getPort(portName{1}).getArchitecturePort().getPortInterface();

                    elementNames={};
                    if(isempty(pI))



                        elementNames{1}='f1';
                        fcnPrototype{1}='y = f1(u)';
                    else
                        elementNames=pI.getElementNames;
                        pE=pI.getElements;
                        fcnPrototype=cell(length(elementNames),1);
                        for cnt=1:length(elementNames)
                            fcnPrototype{cnt}=pE(cnt).getFunctionPrototype;
                        end
                    end

                    set_param(outportBlocks{i},'AllowServiceAccess','on');
                    set_param(outportBlocks{i},'IsClientServer','on');
                    for eCnt=1:length(elementNames)

                        if(eCnt==1)
                            set_param(outportBlocks{i},'Element',[elementNames{eCnt}]);
                            set_param(outportBlocks{i},'Name',strcat('Function Element',num2str(i)));
                        else


                            opH=add_block([obj.ModelName,'/',strcat('Function Element',num2str(i))],...
                            [obj.ModelName,'/',strcat('Function Element',num2str(numel(outportBlocks)+1))],...
                            'MakeNameUnique','on');
                            set_param(opH,'Element',[elementNames{eCnt}]);
                            set_param(opH,'Position',[500+(i-1)*250,(eCnt)*100,510+(i-1)*250,(eCnt*100)+10]);
                        end


                        ssName=[obj.ModelName,'/',elementNames{eCnt}];
                        ssH=add_block('built-in/SubSystem',ssName,'MakeNameUnique','on');
                        ssName=get_param(ssH,'Name');
                        trigPortName=[obj.ModelName,'/',ssName,'/',elementNames{eCnt}];
                        trigPortH=add_block('built-in/TriggerPort',trigPortName,'MakeNameUnique','on');
                        set_param(trigPortH,'TriggerType','function-call');
                        set_param(trigPortH,'FunctionName',elementNames{eCnt});
                        set_param(trigPortH,'IsSimulinkFunction','on');
                        set_param(trigPortH,'ScopeName',portName{1});
                        set_param(trigPortH,'FunctionVisibility','Port');
                        set_param(trigPortH,'FunctionPrototype',fcnPrototype{eCnt});
                        set_param(ssH,'Position',[275+(i-1)*250,(eCnt*105)+50,455+(i-1)*250,100+(eCnt*105)]);

                        if(~isempty(pI))

                            pE=pI.getElement(elementNames{eCnt});
                            if pE.getAsynchronous
                                set_param(trigPortH,'AsynchronousFunction','on');
                            end

                            inArgs=find_system(ssH,'BlockType','ArgIn');
                            outArgs=find_system(ssH,'BlockType','ArgOut');

                            argBlkHdls=[inArgs(:);outArgs(:)];

                            for j=1:length(argBlkHdls)

                                argName=get_param(argBlkHdls(j),'ArgumentName');
                                fcnElems=pI.getElements;
                                if(eCnt<=length(fcnElems))
                                    fcnElem=fcnElems(eCnt);
                                    dataMdlArg=fcnElem.getFunctionArgument(argName);
                                    if~isempty(dataMdlArg)
                                        set_param(argBlkHdls(j),'OutDataTypeStr',dataMdlArg.getType());
                                    end
                                end
                            end
                        end
                        try
                            set_param(bdroot,'SimulationCommand','Update');
                        catch
                        end
                    end

                end

            end
        end

        function validateForExportFunctionModel(obj)



            if isempty(obj.getComponentFunctions())&&~obj.componentContainsCSPorts()
                warningMsg=saveAndLinkMsg('WarningNoFunctionsInExportFunctionBehavior',getfullname(obj.BlockHandle));
                canContinue=obj.ErrorReporter.reportAsWarning(warningMsg);
                obj.ValidationPassed=canContinue;
            end
        end

        function validateForRateBasedModel(obj)

            import systemcomposer.internal.arch.internal.ComponentImplementation;

            warningMsgs=[];
            componentFuncs=obj.getComponentFunctions();
            if~isempty(componentFuncs)



                functionRates={componentFuncs.period};
                doubleRates=cellfun(@(str)[stString2Rate(str)],functionRates,...
                'UniformOutput',false);



                doubleRates=vertcat(doubleRates{:});
                invalidRateIdxs=isnan(doubleRates);

                compName=get_param(obj.BlockHandle,'Name');
                if any(invalidRateIdxs(:))
                    invalidRateFuncs=invalidRateIdxs(1:2:end);
                    for idx=1:numel(invalidRateFuncs)
                        msg=saveAndLinkMsg('WarningInvalidRatesForRateBasedModel',...
                        componentFuncs(idx).getName(),compName);
                        warningMsgs=[warningMsgs,msg];%#ok<AGROW>
                    end
                end




                periodicRateRows=doubleRates(:,1)~=-1;
                [uniqueRates,~,duplicateIdxs]=unique(doubleRates,'rows');

                numUniqueRates=size(uniqueRates,1);
                if numUniqueRates~=numel(doubleRates)
                    for idx=1:size(doubleRates,1)
                        matchingRates=duplicateIdxs==duplicateIdxs(idx);
                        if sum(matchingRates)==1

                            continue;
                        end

                        if~any(matchingRates(periodicRateRows))


                            continue;
                        end


                        msg=saveAndLinkMsg('WarningNonUniqueRatesForRateBasedModel',...
                        componentFuncs(idx).getName(),functionRates{idx},compName);
                        warningMsgs=[warningMsgs,msg];%#ok<AGROW>
                    end
                end
            end


            if obj.componentContainsCSPorts()
                warningMsgs=[warningMsgs,saveAndLinkMsg('WarningCSPortsInRatedBasedModel')];
            end

            if~isempty(warningMsgs)

                headerMsg=saveAndLinkMsg('WarningFallbackToExportFunction',getfullname(obj.BlockHandle));
                canContinue=obj.ErrorReporter.reportMultipleWarnings(headerMsg,warningMsgs);
                if canContinue
                    obj.ImplementComponentAs=ComponentImplementation.ExportFunction;
                end
                obj.ValidationPassed=canContinue;
            end
        end

        function containsCSPorts=componentContainsCSPorts(obj)



            csInports=find_system(obj.BlockHandle,'BlockType',...
            'Inport','IsClientServer','on');
            csOutports=find_system(obj.BlockHandle,'BlockType',...
            'Outport','IsClientServer','on');
            containsCSPorts=~isempty(csInports)||~isempty(csOutports);
        end

        function mapFunctionNamesToRatePorts(obj)


            callerFunctions=obj.getCallerRootFunctions();


            periodStrings={callerFunctions.period}';
            rateMat=cellfun(@(str)stString2Rate(str),periodStrings,...
            'UniformOutput',false);
            rateMat=vertcat(rateMat{:});

            [periods,sortIdxs]=sort(rateMat(:,1));
            callerFunctions=callerFunctions(sortIdxs);
            rateMat=rateMat(sortIdxs,:);
            periodicRateIdxs=rateMat(:,1)~=-1;
            periodicRateMat=rateMat(periodicRateIdxs,:);
            periodicRootFuncs=callerFunctions(periodicRateIdxs);
            if isempty(periodicRootFuncs)

                return;
            end




            sortedPeriodicRates=sort(periodicRateMat(:).');



            baseRate=slexecGCD(sortedPeriodicRates(sortedPeriodicRates>0));
            baseRateOffset=double(~any(baseRate==periods));

            topMfModel=get_param(bdroot(obj.BlockHandle),'SystemComposerMF0Model');
            topModelTxn=topMfModel.beginTransaction();
            for i=1:numel(periodicRootFuncs)
                calledFunc=periodicRootFuncs(i).calledFunction;

                if periodicRateMat(i,2)~=0

                    DString=['[',num2str(periodicRateMat(i,1)),' ',num2str(periodicRateMat(i,2)),']'];
                else
                    DString=['[',num2str(periodicRateMat(i,1)),']'];
                end

                calledFunc.setName(['D',num2str(i+baseRateOffset),DString]);
                periodicRootFuncs(i).calledFunctionName=calledFunc.getName();
            end
            topModelTxn.commit();
        end
    end
end

function enabled=isClientServerEnabled()
    enabled=slfeature('CompositeFunctionElements')>0;
end

function cloneFunctionsToTrait(srcTrait,targetTrait,targetZCModel)

    targetModel=mf.zero.getModel(targetTrait);
    cloneContext=systemcomposer.internal.clone.CloneContext(targetModel);
    cloneContext.ShouldRemapUUIDs=false;

    srcFunctions=srcTrait.functions.toArray;
    for i=1:numel(srcFunctions)

        cloneOfFunc=srcFunctions(i).clone(targetTrait,cloneContext);

        srcFunc=systemcomposer.internal.getWrapperForImpl(srcFunctions(i));
        targetFunc=systemcomposer.internal.getWrapperForImpl(cloneOfFunc);
        systemcomposer.internal.arch.internal.applyStereotypeAndCopyValues(...
        srcFunc,targetFunc,targetZCModel);
    end
end

function msg=saveAndLinkMsg(tailID,varargin)
    msg=message(['SystemArchitecture:SaveAndLink:',tailID],varargin{:});
end

function rate=stString2Rate(stString)



    stString=strip(stString);
    if startsWith(stString,'[')&&endsWith(stString,']')
        rate=sscanf(stString,'[%f %f]').';
    else
        rate=[str2double(stString),0];
    end


    if numel(rate)~=2||(rate(1)<=0&&rate(1)~=-1)||any(isnan(rate))
        rate=nan(1,2);
    end
end



