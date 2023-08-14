



classdef(Hidden=true)SldvTargetInterface<handle






    properties(Constant,GetAccess='public')
        PREFIX='__sldv_'
        VAR_PREFIX=sldv.code.xil.internal.SldvTargetInterface.PREFIX
        INPUT_PREFIX=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'u_']
        OUTPUT_PREFIX=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'y_']
        PARAM_PREFIX=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'p_']
        FCN_RANDOM_WRITE=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'random_write']
        INIT_WRAPPER=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'wrapper_initialize']
        STEP_WRAPPER=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'wrapper_step']
        STRUCT_MANGLER=[sldv.code.xil.internal.SldvTargetInterface.PREFIX,'colmajor_linindex']
    end

    properties(SetAccess='protected',GetAccess='public')
InterfaceFunction
InportInfo
OutportInfo
ParamInfo
TimingInfo
TaskSchedulingInfo
SldvStructTypeInfo
ExportFcnInfo
    end

    methods



        function this=SldvTargetInterface()
            this.InterfaceFunction=containers.Map('KeyType','char','ValueType','any');
            this.InportInfo=containers.Map('KeyType','double','ValueType','any');
            this.OutportInfo=containers.Map('KeyType','double','ValueType','any');
            this.ParamInfo=containers.Map('KeyType','double','ValueType','any');
            this.TimingInfo=containers.Map('KeyType','char','ValueType','any');
            this.TaskSchedulingInfo=struct(...
            'isDescendingPriorityValue',false,...
            'timing',[],...
            'priority',[],...
            'hit',0,...
            'var',[],...
            'asyncVarName',sprintf('%sAsyncCallCount',this.VAR_PREFIX),...
            'numAsyncTasks',0,...
            'numSlFcnTasks',0);
            this.SldvStructTypeInfo=containers.Map('KeyType','char','ValueType','any');

            this.ExportFcnInfo.DVInfo=sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultSchedulingInfo();
            this.ExportFcnInfo.SlFcnNames={};
            this.ExportFcnInfo.SlFcnMapping=containers.Map('KeyType','char','ValueType','any');
        end




        function initCallerAndServerFunctions(this)
            xilWrapperUtils=this.getSILPILWrapperUtilsObj();
            svrFcns=xilWrapperUtils.getServerFunctionsInfo();
            for fcnIdx=1:length(svrFcns)
                svrFcns(fcnIdx).createDataElementsForIOArgs(xilWrapperUtils);
            end

            callerFcns=this.getCodeInfoUtilsObj().getAllCallerFunctionsInfo();
            for fcnIdx=1:length(callerFcns)
                callerFcns(fcnIdx).createDataElementsForIOArgs(xilWrapperUtils);
            end
        end




        function setExportFcnInfo(this,exportFcnInfo)
            this.ExportFcnInfo.DVInfo=exportFcnInfo;
            if~isempty(exportFcnInfo.FcnTriggerPortVarName)
                this.TaskSchedulingInfo.asyncVarName=...
                sprintf('%s%s',this.VAR_PREFIX,exportFcnInfo.FcnTriggerPortVarName);
            end
        end
    end

    methods(Abstract,Access='protected')
        out=getCodeInfoUtilsObj(this)
        out=getWriterObj(this)
        out=getSILPILWrapperUtilsObj(this)
    end

    methods(Access='protected')





        function varargout=callDerivedMethod(this,methodName,varargin)
            [varargout{1:nargout}]=feval(methodName,this,varargin{:});
        end




        function emitSectionStorageForData(this,xilDataInterfaces,varargin)



            sldvStructInfo=[];


            varDeclBuffer=cell(numel(xilDataInterfaces),2);

            xilWrapperUtils=this.getSILPILWrapperUtilsObj();
            codeInfoUtils=this.getCodeInfoUtilsObj();

            for ii=1:numel(xilDataInterfaces)
                xilDataInterface=xilDataInterfaces(ii);
                dataInterface=xilDataInterface.getRTWDataInterface;


                if~rtw.pil.CodeInfoData.isInterfaceActive(dataInterface)||...
                    codeInfoUtils.isDataInterfaceConstant(dataInterface)||...
                    codeInfoUtils.isDataInterfaceReadOnly(dataInterface)
                    continue
                end


                if isempty(dataInterface.Implementation)||...
                    rtw.connectivity.CodeInfoUtils.isa(dataInterface.Implementation,'TypedCollection')
                    continue
                end


                try
                    isSrvArgData=class(xilDataInterface)=="rtw.pil.ServerFunctionArgData";
                    if isSrvArgData
                        kind=xilDataInterface.getDataInterfaceType();
                        dataIdx=xilDataInterface.getDataInterfaceIdx();
                    else
                        [kind,dataIdx]=this.getCodeInfoUtilsObj().resolveIODataInterface(dataInterface);
                    end
                catch
                    continue
                end

                isInput=ismember(kind,{'Inport','serverFcnInputArg','serverFcnInputOutputArg'});
                isOutput=kind=="Outport";
                isParam=kind=="Parameter";
                if isInput
                    dataKind='input';
                    dataPrefix=this.INPUT_PREFIX;
                elseif isOutput
                    dataKind='output';
                    dataPrefix=this.OUTPUT_PREFIX;
                elseif isParam
                    dataKind='parameter';
                    dataPrefix=this.PARAM_PREFIX;


                    if isempty(dataInterface.GraphicalName)
                        continue
                    end
                else
                    continue
                end


                srvFunInfo=[];
                srvFunName=[];
                if isSrvArgData
                    srvFunInfo=xilDataInterface.getFunctionInfo();
                    srvFunName=srvFunInfo.getSlFunctionName();
                    if~this.ExportFcnInfo.SlFcnMapping.isKey(srvFunName)
                        fcnInfo.Name=srvFunName;
                        fcnInfo.InportInfo=containers.Map('KeyType','double','ValueType','any');
                        this.ExportFcnInfo.SlFcnMapping(fcnInfo.Name)=fcnInfo;
                    end
                end


                dataInterfaceExpr=this.callDerivedMethod('callProtectedMethod',...
                'getExpression',dataInterface.Implementation);
                dataName=[dataPrefix,matlab.lang.makeValidName(dataInterfaceExpr)];
                sldvInterfaceVar=dataName;
                codeInterfaceVar=dataInterfaceExpr;


                dataInterfaceType=dataInterface.Type;
                if isempty(dataInterfaceType)
                    dataInterfaceType=dataInterface.Implementation.Type;
                end


                numElements=rtw.connectivity.CodeInfoTypeUtils.getSymbolicWidth(dataInterfaceType);

                isArray=rtw.connectivity.CodeInfoTypeUtils.isVector(dataInterfaceType,...
                this.getSILPILWrapperUtilsObj().getClientInterface);

                dataType=rtw.connectivity.CodeInfoTypeUtils.getCStorageType(...
                rtw.connectivity.CodeInfoTypeUtils.getSimulinkInterfaceType(dataInterface));

                if~isempty(dataType.Identifier)
                    dataTypeName=dataType.Identifier;
                else
                    if isSrvArgData
                        allDataElements=srvFunInfo.getAllDataElements();
                        dataElements=allDataElements(dataIdx);
                    else
                        dataElements=rtw.pil.CodeInfoData.createTargetDataElements(...
                        xilWrapperUtils,dataIdx,lower(dataKind));
                    end
                    if numel(dataElements)>1
                        codeInfoData=dataElements(1).getDataInterface();
                        dataTypeName=codeInfoData.getType().Identifier;
                    else
                        dataTypeName=dataElements(1).HostCType;
                    end
                end



                rowMajorMarshalingInfo=0;
                if~isOutput&&xilWrapperUtils.getCodeInfoUtils.IsRowMajor

                    rowMajorMarshalingInfo=getRowMajorArrayMarshalingInfo(skipFakeMatrixType(dataInterfaceType));

                    if xilDataInterface.DimsPreserved

                        xilType=skipFakeMatrixType(xilDataInterface.getType());
                        [~,~,hasNDFieldArray]=getRowMajorArrayMarshalingInfo(xilType);


                        baseType=getBaseType(xilType);

                        if baseType.isStructure&&hasNDFieldArray


                            if isempty(sldvStructInfo)


                                sldvStructInfo=baseType;
                            else
                                idx=find(sldvStructInfo==baseType,1);
                                if isempty(idx)
                                    sldvStructInfo=[sldvStructInfo;baseType];%#ok<AGROW>
                                end
                            end

                            dataTypeName=[baseType.Identifier,this.STRUCT_MANGLER];
                        end
                    end
                end




                if isSrvArgData
                    varDeclBuffer{ii,2}=sprintf('/* arg %d for %s */',dataIdx,srvFunName);
                else
                    varDeclBuffer{ii,2}=sprintf('/* %s %d */',dataKind,dataIdx);
                end
                dataDecl=[dataTypeName,' ',dataName];
                if isArray
                    dataDecl=[dataDecl,'[',numElements,']'];%#ok<AGROW>
                end
                varDeclBuffer{ii,1}=sprintf('%s;',dataDecl);


                dataInfo=struct(...
                'xilDataInterface',xilDataInterface,...
                'sldvInterfaceVar',sldvInterfaceVar,...
                'codeInterfaceVar',codeInterfaceVar,...
                'rowMajorMarshalingInfo',rowMajorMarshalingInfo,...
                'kind',kind,...
                'graphicalName',dataInterface.GraphicalName,...
                'idx',dataIdx,...
                'isArray',isArray...
                );
                if isInput
                    if isSrvArgData
                        mappingInfo=this.ExportFcnInfo.SlFcnMapping(srvFunName);
                        mappingInfo.InportInfo(dataIdx)=dataInfo;
                        this.ExportFcnInfo.SlFcnMapping(srvFunName)=mappingInfo;
                    else
                        this.InportInfo(dataIdx)=dataInfo;
                    end
                elseif isOutput
                    this.OutportInfo(dataIdx)=dataInfo;
                else
                    this.ParamInfo(dataIdx)=dataInfo;
                end
            end


            if~isempty(sldvStructInfo)
                this.emitSldvStructTypes(sldvStructInfo);
            end


            fwriter=this.getWriterObj();
            for ii=1:size(varDeclBuffer,1)
                if isempty(varDeclBuffer{ii,1})
                    continue
                end
                fwriter.wLine('%s\n%s\n',varDeclBuffer{ii,2},varDeclBuffer{ii,1});
            end
        end




        function emitDataAssignment(this,dataIdx,dataKind,forInit,srvFcnName)
            if nargin<5
                srvFcnName='';
            end


            isSrvArgData=~isempty(srvFcnName)&&dataKind=="inputArg";
            if dataKind=="input"||isSrvArgData
                if forInit
                    return
                end
                mapInfo='InportInfo';
            elseif dataKind=="parameter"
                if~forInit
                    return
                end
                mapInfo='ParamInfo';
            else

                return
            end


            if isSrvArgData
                if~this.ExportFcnInfo.SlFcnMapping.isKey(srvFcnName)
                    return
                end
                mappingInfo=this.ExportFcnInfo.SlFcnMapping(srvFcnName);
                if~mappingInfo.InportInfo.isKey(dataIdx)
                    return
                end
                dataInfo=mappingInfo.InportInfo(dataIdx);
            else
                if~this.(mapInfo).isKey(dataIdx)
                    return
                end
                dataInfo=this.(mapInfo)(dataIdx);
            end

            codeInterfaceVar=dataInfo.codeInterfaceVar;
            implType=skipFakeMatrixType(dataInfo.xilDataInterface.getType());
            origType=skipFakeMatrixType(dataInfo.xilDataInterface.getRTWDataInterface.Implementation.Type);
            if origType.isPointer
                if implType.isMatrix

                    origType=implType;
                else


                    codeInterfaceVar=['(*',codeInterfaceVar,')'];
                    origType=getBaseType(origType);
                    implType=getBaseType(implType);
                end
            end

            writer=this.getWriterObj();
            if isSrvArgData
                writer.writeLine('/* Read arg %d for %s */',dataIdx,srvFcnName);
            else
                writer.writeLine('/* Read %s %d */',dataKind,dataIdx);
            end

            if dataInfo.rowMajorMarshalingInfo>0

                emitRowMajorArrayConversion(writer,...
                implType,...
                origType,...
                dataInfo.sldvInterfaceVar,...
                codeInterfaceVar,...
                0);
            else

                emitCopy(writer,...
                implType,...
                origType,...
                codeInterfaceVar,...
                dataInfo.sldvInterfaceVar,...
                0);
            end
            writer.newLine;
        end




        function emitSectionHeader(this,fileName,codeName)
            [~,fname,fext]=fileparts(fileName);
            writer=this.getWriterObj();
            writer.writeCellLines({'/*';
            [' * File: ',fname,fext];
            ' *';
            [' * SLDV generated interface for code: "',codeName,'"'];
            ' *';
            ' */'});
            writer.newLine;
        end




        function emitSectionIncludes(this)
            writer=this.getWriterObj();
            writer.writeLine('#if defined(__MW_INTERNAL_SLDV_PS_ANALYSIS__)');
            writer.newLine;
            writer.writeLine('#if defined(MEM_UNIT_BYTES)');
            writer.writeLine('#undef MEM_UNIT_BYTES');
            writer.writeLine('#endif');
            writer.writeLine('#define MEM_UNIT_BYTES 8');
            writer.newLine;
            writer.writeLine('#if defined(MemUnit_T)');
            writer.writeLine('#undef MemUnit_T');
            writer.writeLine('#endif');
            writer.writeLine('#define MemUnit_T int_T');
            writer.newLine;
        end




        function emitSectionTrailer(this)
            writer=this.getWriterObj();
            writer.writeLine('#endif');
            writer.newLine;
        end




        function emitSectionWrapperInit(this)
            this.InterfaceFunction(this.INIT_WRAPPER)={'init'};
            writer=this.getWriterObj();
            writer.writeLine('#ifdef __cplusplus');
            writer.writeLine('extern "C"');
            writer.writeLine('#endif');
            writer.wBlockStart('void %s(void)',this.INIT_WRAPPER);
            this.emitSectionWrapperInitBody();
            writer.wBlockEnd();
            writer.newLine;
        end




        function extractTaskSchedulingInfo(this)

            codeInfoUtils=this.getCodeInfoUtilsObj();


            this.TaskSchedulingInfo.timing=[];
            this.TaskSchedulingInfo.priority=[];
            this.TaskSchedulingInfo.hit=0;
            this.TaskSchedulingInfo.var=[];
            this.TaskSchedulingInfo.numAsyncTasks=0;
            this.TaskSchedulingInfo.numSlFcnTasks=0;
            this.TaskSchedulingInfo.isDescendingPriorityValue=false;




















            stPeriodic=codeInfoUtils.getRates('PERIODIC');
            stPerPriority=[];
            if~isempty(stPeriodic)
                stSamplePeriod=[stPeriodic.SamplePeriod];
                [stSamplePeriod,idxSt]=sort(stSamplePeriod);
                stPeriodic=stPeriodic(idxSt);
                stPerPriority=[stPeriodic.Priority];
                stPerHit=zeros(1,numel(stPeriodic),'int32');
                for ii=1:numel(stSamplePeriod)
                    stPerHit(ii)=int32(round(stSamplePeriod(ii)/stSamplePeriod(1)));
                end

                this.TaskSchedulingInfo.isDescendingPriorityValue=~codeInfoUtils.isExportFcnDiagram()&&...
                (stPerPriority(1)>stPerPriority(end));

                [stPerPriority,idxSt]=sortPriorities(this,stPerPriority);
                stPeriodic=stPeriodic(idxSt);
                stPerHit=stPerHit(idxSt);

                this.TaskSchedulingInfo.timing=stPeriodic;
                this.TaskSchedulingInfo.hit=stPerHit;
                this.TaskSchedulingInfo.var=cell(1,numel(this.TaskSchedulingInfo.timing));
                this.TaskSchedulingInfo.priority=stPerPriority;
            end




            allAsyncNamesFromDVInfo={this.ExportFcnInfo.DVInfo.CallInfo.FunName};
            stAsyncAll=codeInfoUtils.getRates('ASYNCHRONOUS');
            stAsync=[];
            stSlFcnAsync(1:numel(allAsyncNamesFromDVInfo))={RTW.TimingInterface.empty()};
            if~isempty(stAsyncAll)
                outputTasks=codeInfoUtils.getOutputTasks();
                for ii=1:numel(stAsyncAll)
                    tasks=getTasksForTimingInfo(outputTasks,stAsyncAll(ii));

                    if numel(tasks)==1&&codeInfoUtils.isServerOutputFunction(tasks.codeInfoData)
                        idx=find(strcmp(tasks.codeInfoData.SimulinkFunctionName,allAsyncNamesFromDVInfo),1);
                        if~isempty(idx)
                            stSlFcnAsync{idx}=stAsyncAll(ii);
                            continue
                        end
                    end

                    stAsync=[stAsync,stAsyncAll(ii)];%#ok<AGROW>
                end


                if~isempty(stAsync)

                    stAsyncPriority=[stAsync.Priority];
                    [stAsyncPriority,idxSt]=sortPriorities(this,stAsyncPriority);
                    stAsync=stAsync(idxSt);
                    stAsyncHit=zeros(1,numel(stAsync),'int32');

                    this.TaskSchedulingInfo.timing=[this.TaskSchedulingInfo.timing,stAsync];
                    this.TaskSchedulingInfo.hit=[this.TaskSchedulingInfo.hit,stAsyncHit];
                    this.TaskSchedulingInfo.var=[this.TaskSchedulingInfo.var,cell(1,numel(stAsync))];
                    [this.TaskSchedulingInfo.priority,idxSt]=sortPriorities(this,[stPerPriority,stAsyncPriority]);
                    this.TaskSchedulingInfo.timing=this.TaskSchedulingInfo.timing(idxSt);
                    this.TaskSchedulingInfo.hit=this.TaskSchedulingInfo.hit(idxSt);
                end


                notSlFcnIdx=cellfun(@isempty,stSlFcnAsync);
                stSlFcnAsync(notSlFcnIdx)=[];
                stSlFcnAsync=[stSlFcnAsync{:}];
                this.ExportFcnInfo.SlFcnNames=allAsyncNamesFromDVInfo(~notSlFcnIdx);


                if~isempty(stSlFcnAsync)
                    stSlFcnAsyncPriority=[stSlFcnAsync.Priority];
                    stSlFcnAsyncHit=zeros(1,numel(stSlFcnAsync),'int32');
                    this.TaskSchedulingInfo.timing=[this.TaskSchedulingInfo.timing,stSlFcnAsync];
                    this.TaskSchedulingInfo.hit=[this.TaskSchedulingInfo.hit,stSlFcnAsyncHit];
                    this.TaskSchedulingInfo.var=[this.TaskSchedulingInfo.var,cell(1,numel(stSlFcnAsync))];
                    this.TaskSchedulingInfo.priority=[this.TaskSchedulingInfo.priority,stSlFcnAsyncPriority];
                end


                this.TaskSchedulingInfo.numAsyncTasks=numel(stAsync)+numel(stSlFcnAsync);
                this.TaskSchedulingInfo.numSlFcnTasks=numel(stSlFcnAsync);
            end
        end




        function emitSectionWrapperStep(this)
            this.InterfaceFunction(this.STEP_WRAPPER)={'step'};
            writer=this.getWriterObj();


            this.extractTaskSchedulingInfo();


            if this.TaskSchedulingInfo.numAsyncTasks>0
                if this.TaskSchedulingInfo.numAsyncTasks==1
                    writer.wLine('uint8_T %s;',...
                    this.TaskSchedulingInfo.asyncVarName);
                else
                    writer.wLine('uint8_T %s[%d];',...
                    this.TaskSchedulingInfo.asyncVarName,...
                    this.TaskSchedulingInfo.numAsyncTasks);
                end
            end



            asyncTaskIdx=0;
            for ii=1:numel(this.TaskSchedulingInfo.timing)
                if this.TaskSchedulingInfo.hit(ii)==0

                    if this.TaskSchedulingInfo.numAsyncTasks==1
                        this.TaskSchedulingInfo.var{ii}=this.TaskSchedulingInfo.asyncVarName;
                    else
                        this.TaskSchedulingInfo.var{ii}=sprintf('%s[%d]',...
                        this.TaskSchedulingInfo.asyncVarName,asyncTaskIdx);
                    end
                    asyncTaskIdx=asyncTaskIdx+1;
                elseif this.TaskSchedulingInfo.hit(ii)>1

                    this.TaskSchedulingInfo.var{ii}=sprintf('%staskHitCount_%d_%d',...
                    this.VAR_PREFIX,this.TaskSchedulingInfo.hit(ii),...
                    this.TaskSchedulingInfo.priority(ii));
                    writer.wLine('uint_T %s = 0;',this.TaskSchedulingInfo.var{ii});
                else


                end
            end

            writer.newLine;
            writer.writeLine('#ifdef __cplusplus');
            writer.writeLine('extern "C"');
            writer.writeLine('#endif');
            writer.wBlockStart('void %s(void)',this.STEP_WRAPPER);
            this.emitSectionWrapperStepBody();
            writer.wBlockEnd();
            writer.newLine;
        end




        function emitSectionWrapperInitBody(this)
            writer=this.getWriterObj();
            codeInfoUtils=this.getCodeInfoUtilsObj();


            tasks=codeInfoUtils.getInitializeTasks();
            for taskIdx=1:numel(tasks)
                writer.wLine('(void)xilInitialize(%d);',taskIdx-1);
            end




            dataIdx=this.ParamInfo.keys();
            for ii=1:numel(dataIdx)
                this.emitDataAssignment(dataIdx{ii},'parameter',true);
            end



            writer.newLine;
            writer.wLine('(void)xilProcessParams(0);');
        end




        function emitSectionWrapperStepBody(this)
            writer=this.getWriterObj();
            codeInfoUtils=this.getCodeInfoUtilsObj();
            xilWrapperUtils=this.getSILPILWrapperUtilsObj();


            outputTasks=codeInfoUtils.getOutputTasks();
            outputTaskIds=[];
            if~isempty(outputTasks)
                outputTaskIds=[outputTasks.id];
            end


            updateTasks=codeInfoUtils.getUpdateTasks();
            updateTaskIds=[];
            if~isempty(updateTasks)
                updateTaskIds=[updateTasks.id];
            end

            for ii=1:numel(this.TaskSchedulingInfo.timing)

                tasks=getTasksForTimingInfo(outputTasks,this.TaskSchedulingInfo.timing(ii));
                if isempty(tasks)
                    continue
                end


                writer.newLine;
                taskName=tasks(1).codeInfoData.Prototype.Name;
                varName=this.TaskSchedulingInfo.var{ii};
                isAsync=this.TaskSchedulingInfo.hit(ii)==0;
                if~isempty(varName)
                    if isAsync
                        writer.wLine('/* Call asynchronous task "%s" (priority %d) */',...
                        taskName,this.TaskSchedulingInfo.timing(ii).Priority);
                        writer.wBlockStart('if (%s > 0)',varName);
                    else
                        writer.wLine('/* Call periodic task "%s" every %gs (priority %d) */',...
                        taskName,this.TaskSchedulingInfo.timing(ii).SamplePeriod,...
                        this.TaskSchedulingInfo.timing(ii).Priority);
                        writer.wBlockStart('if (%s == 0)',varName);
                    end
                end


                for jj=1:numel(tasks)
                    otask=tasks(jj);
                    genInputDataAssignmentsBeforeCallingTask(otask);
                    writer.wLine('(void)xilOutput(0, %d);',otask.id);


                    idx=find(updateTaskIds==otask.id,1);
                    if~isempty(idx)

                        writer.wLine('(void)xilUpdate(0, %d);',otask.id);


                        [updateTaskIds,updateTasks]=removeTaskEntry(updateTaskIds,updateTasks,otask.id);
                    end


                    [outputTaskIds,outputTasks]=removeTaskEntry(outputTaskIds,outputTasks,otask.id);
                end


                if~isempty(varName)
                    writer.wBlockEnd();
                    if~isAsync
                        writer.newLine;
                        writer.wLine('/* Update the task hit counter */');
                        writer.wLine('if (++%s == %d) %s = 0;',...
                        varName,this.TaskSchedulingInfo.hit(ii),varName);
                    end
                end
            end


            numOutputTasks=numel(outputTasks);
            priorityList=zeros(1,numOutputTasks);
            for taskIdx=1:numel(outputTasks)
                priorityList(taskIdx)=outputTasks(taskIdx).codeInfoData.Timing.Priority;
            end
            [~,idx]=sortPriorities(this,priorityList);
            outputTasks=outputTasks(idx);


            for taskIdx=1:numel(outputTasks)
                task=outputTasks(taskIdx);
                genInputDataAssignmentsBeforeCallingTask(task);
                writer.newLine;
                writer.wLine('(void)xilOutput(0, %d);',task.id);

                if~isempty(updateTaskIds)
                    idx=find(updateTaskIds==task.id,1);
                    if~isempty(idx)


                        writer.newLine;
                        writer.wLine('(void)xilUpdate(0, %d);',task.id);
                    end
                end
            end

            function[taskIds,tasks]=removeTaskEntry(taskIds,tasks,taskId)
                tIdx=taskIds==taskId;
                taskIds(tIdx)=[];
                tasks(tIdx)=[];
            end

            function genInputDataAssignmentsBeforeCallingTask(task)
                dataIdx=xilWrapperUtils.getDFInputPortsIndices(...
                codeInfoUtils.getInputPortsForTask(task));
                if~isempty(dataIdx)
                    for kk=1:numel(dataIdx)
                        this.emitDataAssignment(dataIdx(kk),'input',false);
                    end
                else
                    [isSrvFcn,srvFcnInfo]=codeInfoUtils.isServerOutputFunction(task.codeInfoData);
                    if isSrvFcn
                        srvFcnName=srvFcnInfo.getSlFunctionName();
                        if this.ExportFcnInfo.SlFcnMapping.isKey(srvFcnName)
                            mappingInfo=this.ExportFcnInfo.SlFcnMapping(srvFcnName);
                            dataIdx=mappingInfo.InportInfo.keys();
                            for kk=1:numel(dataIdx)
                                this.emitDataAssignment(dataIdx{kk},'inputArg',false,srvFcnName);
                            end
                        end
                    end
                end
            end
        end




        function emitSectionMain(this)



            writer=this.getWriterObj();
            writer.writeLine('#ifdef __cplusplus');
            writer.writeLine('extern "C"');
            writer.writeLine('#endif');
            writer.writeLine('void %s(void*);',this.FCN_RANDOM_WRITE);
            writer.newLine;


            writer.wBlockStart('void main(void)');
            writer.writeLine('volatile short loop = 1;');


            dataIdx=this.ParamInfo.keys();
            for ii=1:numel(dataIdx)
                dataInfo=this.ParamInfo(dataIdx{ii});
                dataAddr=['&',dataInfo.sldvInterfaceVar];
                dataOffset='';
                if dataInfo.isArray
                    dataOffset='[0]';
                end
                writer.writeLine('%s(%s%s);',this.FCN_RANDOM_WRITE,dataAddr,dataOffset);
            end


            writer.newLine;
            writer.writeLine('%s();',this.INIT_WRAPPER);
            writer.newLine;


            writer.wBlockStart('while(loop > 0)');


            dataIdx=this.InportInfo.keys();
            for ii=1:numel(dataIdx)
                dataInfo=this.InportInfo(dataIdx{ii});
                dataAddr=['&',dataInfo.sldvInterfaceVar];
                dataOffset='';
                if dataInfo.isArray
                    dataOffset='[0]';
                end
                writer.writeLine('%s(%s%s);',this.FCN_RANDOM_WRITE,dataAddr,dataOffset);
            end
            slFcnNames=this.ExportFcnInfo.SlFcnMapping.keys();
            for ii=1:numel(slFcnNames)
                mappingInfo=this.ExportFcnInfo.SlFcnMapping(slFcnNames{ii});
                dataIdx=mappingInfo.InportInfo.keys();
                for jj=1:numel(dataIdx)
                    dataInfo=mappingInfo.InportInfo(dataIdx{jj});
                    dataAddr=['&',dataInfo.sldvInterfaceVar];
                    dataOffset='';
                    if dataInfo.isArray
                        dataOffset='[0]';
                    end
                    writer.writeLine('%s(%s%s);',this.FCN_RANDOM_WRITE,dataAddr,dataOffset);
                end
            end


            if this.TaskSchedulingInfo.numAsyncTasks>0&&~isempty(this.TaskSchedulingInfo.asyncVarName)
                dataAddr=['&',this.TaskSchedulingInfo.asyncVarName];
                dataOffset='';
                if this.TaskSchedulingInfo.numAsyncTasks>1
                    dataOffset='[0]';
                end
                writer.writeLine('%s(%s%s);',this.FCN_RANDOM_WRITE,dataAddr,dataOffset);
            end


            writer.newLine;
            writer.writeLine('%s();',this.STEP_WRAPPER);


            writer.wBlockEnd();


            writer.wBlockEnd();
            writer.newLine;
        end




        function emitSldvStructTypes(this,structInfo)

            sldvTypeMap=containers.Map('KeyType','char','ValueType','any');
            for ii=1:numel(structInfo)
                collectAllSldvStructTypes(sldvTypeMap,structInfo(ii));
            end


            flatTypes=sldvTypeMap.values();
            structDeps=cell(0,2);
            for ii=1:numel(flatTypes)
                sType=flatTypes{ii};
                structDeps=[structDeps;...
                {sType,collectStructDeps(sldvTypeMap,sType)}];%#ok<AGROW>
            end




            iter=0;
            maxIter=size(structDeps,1);
            while size(structDeps,1)>0

                idx=cellfun(@(x)isempty(x),structDeps(:,2));
                goodIdx=find(idx);
                badIdx=find(idx==0);


                for ii=1:numel(goodIdx)
                    sType=structDeps{goodIdx(ii),1};
                    this.emitStructType(sldvTypeMap,sType);


                    for jj=1:numel(badIdx)
                        dep=structDeps{badIdx(jj),2};
                        dep(dep==sType)=[];
                        structDeps{badIdx(jj),2}=dep;
                    end
                end


                structDeps(idx,:)=[];


                iter=iter+1;
                if iter>maxIter
                    assert(false,'cannot emit the structure definition');
                end
            end
        end





















        function emitStructType(this,sldvTypeMap,type,name)
            if nargin<4
                name='';
            end
            writer=this.getWriterObj();
            if type.isStructure&&isempty(name)

                if this.SldvStructTypeInfo.isKey(type.Identifier)
                    return
                end
                this.SldvStructTypeInfo(type.Identifier)=true;

                writer.wLine('typedef struct {');
                writer.incIndent;
                tElements=type.Elements;
                for kk=1:numel(tElements)
                    this.emitStructType(sldvTypeMap,tElements(kk).Type,tElements(kk).Identifier);
                end
                writer.decIndent;
                writer.wLine('} %s%s;',type.Identifier,this.STRUCT_MANGLER);
                writer.newLine;
            else
                cType=rtw.connectivity.CodeInfoTypeUtils.getCStorageType(type);
                width='';
                if type.isMatrix
                    width=['[',rtw.connectivity.CodeInfoTypeUtils.getSymbolicWidth(type),']'];
                end
                mangle='';
                if cType.isStructure
                    assert(sldvTypeMap.isKey(cType.Identifier),'cannot find the structure');
                    mangle=this.STRUCT_MANGLER;
                end
                writer.wLine('%s%s %s%s;',cType.Identifier,mangle,name,width);
            end
        end
    end
end




function subTasks=getTasksForTimingInfo(tasks,timing)
    subTasks=[];
    for tk=1:numel(tasks)
        if isEquivalentTo(tasks(tk).codeInfoData.Timing,timing)
            subTasks=[subTasks,tasks(tk)];%#ok<AGROW>
        end
    end
end




function out=collectStructDeps(sldvTypeMap,type)
    out=[];
    tElements=type.Elements;
    for kk=1:numel(tElements)
        el=tElements(kk);
        elType=getBaseType(el.Type);
        if elType.isStructure
            assert(sldvTypeMap.isKey(elType.Identifier),'cannot find the structure');
            out=[out,sldvTypeMap(elType.Identifier)];%#ok<AGROW>
        end
        out=unique(out);
    end
end





function collectAllSldvStructTypes(sldvTypeMap,type)
    if type.isStructure
        if sldvTypeMap.isKey(type.Identifier)
            return
        end
        sldvTypeMap(type.Identifier)=type;
        tElements=type.Elements;
        for kk=1:numel(tElements)
            collectAllSldvStructTypes(sldvTypeMap,tElements(kk).Type);
        end
    elseif type.isMatrix||type.isPointer
        collectAllSldvStructTypes(sldvTypeMap,type.BaseType);
    end
end




function[priorityList,idx]=sortPriorities(this,priorityList)
    if this.TaskSchedulingInfo.isDescendingPriorityValue
        [priorityList,idx]=sort(priorityList,'descend');
    else
        [priorityList,idx]=sort(priorityList);
    end

end









function[rowMajorMarshalingInfo,hasNDArray,hasNDFieldArray]=getRowMajorArrayMarshalingInfo(dataType,dataDims)


    rowMajorMarshalingInfo=0;
    hasNDArray=false;
    hasNDFieldArray=false;


    narginchk(1,2);

    if nargin==1
        if dataType.isMatrix
            dataDims=dataType.Dimensions.toArray;
        else
            dataDims=1;
        end
    end

    isNDArray=@(x)(numel(x)>=2&&~any(x==1));

    if dataType.isStructure

        [res,hasNDArray,hasNDFieldArray]=nBusNeedNDArrayMarshalling(dataType,false,hasNDArray,hasNDFieldArray);
        if res

            rowMajorMarshalingInfo=2;
            return
        end
    elseif dataType.isMatrix||dataType.isPointer
        [~,hasNDArray,hasNDFieldArray]=getRowMajorArrayMarshalingInfo(dataType.BaseType);
    end


    if isNDArray(dataDims)
        rowMajorMarshalingInfo=1;
        hasNDArray=true;
    end

    function[res,hasNDArray,hasNDFieldArray]=nBusNeedNDArrayMarshalling(busType,res,hasNDArray,hasNDFieldArray)
        for ii=1:length(busType.Elements)
            el=busType.Elements(ii);
            elType=el.Type;
            if elType.isMatrix&&isNDArray(elType.Dimensions.toArray)
                res=true;
                hasNDArray=true;
                hasNDFieldArray=true;
            else
                if elType.isStructure

                    [elRres,elHasNDArray,elHasNDFieldArray]=nBusNeedNDArrayMarshalling(elType,res,hasNDArray,hasNDFieldArray);
                    res=res||elRres;
                    hasNDArray=hasNDArray||elHasNDArray;
                    hasNDFieldArray=hasNDFieldArray||elHasNDFieldArray;
                end
            end
        end
    end

end





function[dims,width]=getSizeInfo(dataType)
    dims=rtw.connectivity.CodeInfoTypeUtils.getDimensions(dataType);
    width=prod(dims);
end





function dataType=getBaseType(dataType)
    if dataType.isMatrix||dataType.isPointer
        dataType=getBaseType(dataType.BaseType);
    end
end




function dataType=skipFakeMatrixType(dataType)
    if dataType.isMatrix&&dataType.getWidth()==1
        dataType=dataType.BaseType;
    end
end





function emitCopy(codeWriter,implType,origType,lhsVarExpr,rhsVarExpr,level)

    [~,width]=getSizeInfo(implType);
    if width>1
        codeWriter.wBlockStart('');
        widthStr=rtw.connectivity.CodeInfoTypeUtils.getSymbolicWidth(implType);
        loopCnt=sprintf('idx%d',level);
        codeWriter.wLine('int_T %s;',loopCnt);
        codeWriter.wBlockStart('for (%s = 0; %s < %s; ++%s)',loopCnt,loopCnt,widthStr,loopCnt);
        rhsVarExpr=sprintf('%s[%s]',rhsVarExpr,loopCnt);
        lhsVarExpr=sprintf('%s[%s]',lhsVarExpr,loopCnt);



        baseType=skipFakeMatrixType(getBaseType(implType));
        hasNDFieldArray=false;
        if baseType~=implType
            [~,~,hasNDFieldArray]=getRowMajorArrayMarshalingInfo(baseType);
        end
        if hasNDFieldArray
            col2rowKernel(codeWriter,getBaseType(implType),getBaseType(origType),rhsVarExpr,lhsVarExpr,level+1);
        else
            codeWriter.wLine('%s = %s;',lhsVarExpr,rhsVarExpr);
        end


        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();
    else


        hasNDFieldArray=false;
        if implType.isStructure
            [~,~,hasNDFieldArray]=getRowMajorArrayMarshalingInfo(implType);
        end
        if hasNDFieldArray
            col2rowBus(codeWriter,implType,origType,rhsVarExpr,lhsVarExpr,level);
        else
            codeWriter.wLine('%s = %s;',lhsVarExpr,rhsVarExpr);
        end
    end

end











function emitRowMajorArrayConversion(codeWriter,implType,origType,colMajorVar,rowMajorVar,level)

    col2rowKernel(codeWriter,skipFakeMatrixType(implType),skipFakeMatrixType(origType),colMajorVar,rowMajorVar,level);

end




function col2rowKernel(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level)

    rowMajorMarshalingInfo=getRowMajorArrayMarshalingInfo(origType);
    if rowMajorMarshalingInfo==0

        emitCopy(codeWriter,implType,origType,rowMajorExpr,colMajorExpr,level);
    elseif rowMajorMarshalingInfo==1

        col2rowArray(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level);
    elseif rowMajorMarshalingInfo==2

        [dims,width]=getSizeInfo(origType);
        if numel(dims)>=2&&width>1

            col2rowArray(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level);
        elseif width~=1

            codeWriter.wBlockStart('');
            widthStr=rtw.connectivity.CodeInfoTypeUtils.getSymbolicWidth(origType);
            loopCnt=sprintf('idx%d',level);
            codeWriter.wLine('int_T %s;',loopCnt);
            codeWriter.wBlockStart('for (%s = 0; %s < %s; ++%s)',loopCnt,loopCnt,widthStr,loopCnt);
            colMajorExpr=sprintf('%s[%s]',colMajorExpr,loopCnt);
            rowMajorExpr=sprintf('%s[%s]',rowMajorExpr,loopCnt);

            col2rowBus(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level);


            codeWriter.wBlockEnd();
            codeWriter.wBlockEnd();
        else

            col2rowBus(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level);
        end
    end

end




function col2rowArray(codeWriter,implType,origType,colMajorExpr,rowMajorExpr,level)


    dims=getSizeInfo(origType);
    if all(dims==1)
        col2rowKernel(codeWriter,getBaseType(implType),getBaseType(origType),colMajorExpr,rowMajorExpr,level);
        return
    end



    keepNDIndex=numel(rtw.connectivity.CodeInfoTypeUtils.getSymbolicDimensions(implType))>=2;


    codeWriter.wBlockStart('');
    numOpenedBlocks=1;


    dimsStr=rtw.connectivity.CodeInfoTypeUtils.getSymbolicDimensions(origType);
    loopCnt=sprintf('idx%d',level);
    loopCntNames=cell(1,numel(dimsStr));
    for ii=1:numel(dimsStr)
        loopCntNames{ii}=sprintf('%s_%d',loopCnt,ii);
    end


    for ii=1:numel(dimsStr)
        numOpenedBlocks=numOpenedBlocks+1;
        codeWriter.wLine('int_T %s;',loopCntNames{ii});
        codeWriter.wBlockStart('for (%s = 0; %s < %s; ++%s)',...
        loopCntNames{ii},loopCntNames{ii},dimsStr{ii},loopCntNames{ii});
    end


    rowIndexes='';
    rowLinIdx='';
    if keepNDIndex
        for ii=1:numel(loopCntNames)
            rowIndexes=sprintf('%s[%s]',rowIndexes,loopCntNames{ii});
        end
    else
        rowLinIdx=legacycode.lct.gen.CodeEmitter.genSubscripts2Index(loopCntNames,dimsStr,false);
    end
    colLinIdx=legacycode.lct.gen.CodeEmitter.genSubscripts2Index(loopCntNames,dimsStr);


    if keepNDIndex
        rowMajorExpr=sprintf('%s%s',rowMajorExpr,rowIndexes);
    else
        rowMajorExpr=sprintf('%s[%s]',rowMajorExpr,rowLinIdx);
    end
    colMajorExpr=sprintf('%s[%s]',colMajorExpr,colLinIdx);


    col2rowKernel(codeWriter,...
    skipFakeMatrixType(getBaseType(implType)),...
    skipFakeMatrixType(getBaseType(origType)),...
    colMajorExpr,rowMajorExpr,level+1)


    for ii=1:numOpenedBlocks
        codeWriter.wBlockEnd();
    end

end




function col2rowBus(codeWriter,implType,origType,colMajorVar,rowMajorVar,level)


    for jj=1:length(origType.Elements)
        el=origType.Elements(jj);
        elName=el.Identifier;
        elOrigType=skipFakeMatrixType(el.Type);
        elImplType=skipFakeMatrixType(implType.Elements(jj).Type);


        erowMajorVar=sprintf('%s.%s',rowMajorVar,elName);
        ecolMajorExpr=sprintf('%s.%s',colMajorVar,elName);


        col2rowKernel(codeWriter,elImplType,elOrigType,ecolMajorExpr,erowMajorVar,level);
    end

end


