


classdef EMChart<slci.common.BdObject

    properties

        fBlock=[];

        fData={};

        fRootFuncID=[];

        fFuncIDToAst=[];

        fChartId=-1;

        fIsAstComputed=false;

        fScriptInfo=[];

        fSymbolTable=[];

        fIsFuncCallMapComputed=false;

        fFuncCallMap=[];
    end

    methods



        function obj=EMChart(aBlk,uddObj)
            obj.fBlock=aBlk;
            obj.setName(uddObj.Name);
            obj.setSID(Simulink.ID.getStateflowSID(uddObj,...
            aBlk.getHandle()));
            obj.fChartId=uddObj.Id;
            obj.setUDDObject(uddObj);


            obj.fFuncIDToAst=containers.Map('KeyType','int32',...
            'ValueType','Any');

            chartObj=get_param(aBlk.getHandle,'Object');
            if strcmpi(chartObj.CompiledIsActive,'off')

                return;
            end


            dataObjs=uddObj.find('-isa','Stateflow.Data');
            for k=1:numel(dataObjs)
                emData=slci.matlab.EMData(dataObjs(k),obj);
                obj.addDatum(emData);
            end

            obj.fScriptInfo=slci.mlutil.ScriptInfo;

            obj.fSymbolTable=slci.mlutil.SymbolTable;

            obj.addConstraints();
        end


        function prepareAst(aObj)


            aObj.fIsAstComputed=true;


            mlDataOptions=struct('IncludeNonUserVisibleFunctions',false);
            coderData=slci.mlutil.MLData(aObj.getUDDObject(),...
            aObj.ParentBlock().getHandle(),...
            mlDataOptions);

            aObj.generateAst(coderData);



            aObj.populateChartDataTypes();


            aObj.processAst_preInference();


            aObj.inferAst(coderData);


            aObj.processAst_postInference();
        end


        function out=ParentBlock(aObj)
            out=aObj.fBlock;
        end


        function aData=getData(aObj)
            aData=aObj.fData;
        end


        function flag=hasRootFunction(aObj)
            if~aObj.fIsAstComputed
                aObj.prepareAst();
            end


            flag=~isempty(aObj.fRootFuncID)&&...
            aObj.hasFunction(aObj.fRootFuncID);
        end


        function id=getRootFunctionID(aObj)
            if~aObj.fIsAstComputed
                aObj.prepareAst();
            end
            id=aObj.fRootFuncID;
        end


        function flag=hasFunction(aObj,funcID)
            if~aObj.fIsAstComputed
                aObj.prepareAst();
            end
            if isKey(aObj.fFuncIDToAst,funcID)
                flag=true;
            else
                flag=false;
            end
        end


        function ast=getFunction(aObj,funcID)
            if~aObj.fIsAstComputed
                aObj.prepareAst();
            end
            assert(aObj.hasFunction(funcID));
            ast=aObj.fFuncIDToAst(funcID);
        end



        function table=getAllFuncs(aObj)
            if~aObj.fIsAstComputed



                chartObj=get_param(aObj.ParentBlock.getHandle,'Object');
                if strcmpi(chartObj.CompiledIsActive,'on')

                    aObj.prepareAst();
                end
            end
            table=aObj.fFuncIDToAst;
        end


        function symbolTable=getSymbolTable(aObj)
            symbolTable=aObj.fSymbolTable;
        end



        function table=getScriptInfo(aObj)
            if~aObj.fIsAstComputed

                aObj.prepareAst();
            end
            table=aObj.fScriptInfo;
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.common.BdObject(aObj);

            table=aObj.getAllFuncs();
            funcs=values(table);
            numFuncs=numel(funcs);
            for k=1:numFuncs
                funcNode=funcs{k};
                out=[out,funcNode.checkCompatibility()];%#ok
            end

            data=aObj.fData;
            numData=numel(data);
            for k=1:numData
                datum=data{k};
                out=[out,datum.checkCompatibility()];%#ok
            end
        end


        function listCompatibility(aObj)
            listCompatibility@slci.common.BdObject(aObj);

            table=aObj.getAllFuncs();
            funcs=values(table);
            numFuncs=numel(funcs);
            for k=1:numFuncs
                funcNode=funcs{k};
                funcNode.listCompatibility();
            end

            data=aObj.fData;
            numData=numel(data);
            for k=1:numData
                datum=data{k};
                datum.listCompatibility();
            end
        end


        function out=isRecursiveFunc(aObj,funcId)
            if~aObj.fIsFuncCallMapComputed
                aObj.computeFuncCallMap()
            end

            processedfId=[];

            out=aObj.findFuncCallId(funcId,funcId,processedfId);

            if aObj.hasFunction(funcId)
                funcAst=aObj.getFunction(funcId);
                funcAst.setIsRecursiveFunc(out);
            end
        end

    end

    methods(Access=private)


        function populateChartDataTypes(aObj)



            for k=1:numel(aObj.fData)
                datum=aObj.fData{k};
                type=datum.getDataType();
                aObj.addType(type);
            end
        end


        function addType(aObj,type)
            isSimulinkType=slci.internal.isSimulinkBuildInType(type);
            if~isSimulinkType&&~aObj.fSymbolTable.hasSymbol(type)
                [flag,busType]=aObj.isBus(type);
                if flag
                    aObj.fSymbolTable.addSymbol(type,busType);
                    for pp=1:numel(busType.Elements)
                        busel=busType.Elements(pp);
                        buselDataType=busel.DataType;
                        if strncmp(buselDataType,'Bus:',4)
                            buselDataType=strtrim(buselDataType(5:end));
                        end
                        aObj.addType(buselDataType);
                    end
                end
            end
        end


        function[flag,busObject]=isBus(aObj,typeName)
            assert(ischar(typeName));
            try
                busObject=slResolve(typeName,aObj.getSID());
            catch
                flag=false;
                busObject=[];
                return;
            end
            flag=isa(busObject,'Simulink.Bus');
        end


        function addDatum(aObj,aData)
            assert(isa(aData,'slci.matlab.EMData'),...
            ['Invalid input argument: ',class(aData)]);
            aObj.fData{end+1}=aData;
        end


        function addConstraints(aObj)

            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionPositiveParameterConstraint(...
            false,'SaturateOnIntegerOverflow',false,...
            DAStudio.message('Stateflow:dialog:SaturateOnIntegerOverflowName'),'Off'));

            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionPositiveParameterConstraint(...
            true,'SupportVariableSizing',false,...
            DAStudio.message('Stateflow:dialog:SupportVariableSizingName'),'Off'));

            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionPositiveParameterConstraint(...
            false,'ChartUpdate','INHERITED',...
            DAStudio.message('Stateflow:dialog:ChartUpdateMethod'),...
            DAStudio.message('Stateflow:dialog:Inherited')));

            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionNegativeParameterConstraint(...
            false,'TreatAsFi','Fixed-point & Integer',...
            DAStudio.message('Stateflow:dialog:EMLDataConversionTreatIntsAsFixptName'),...
            DAStudio.message('Stateflow:dialog:FixedpointInteger')));

            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionInputTriggerConstraint);

        end


        function mlMtree=generateAst(aObj,coderData)


            mlScript=slci.internal.MLScript(aObj.getUDDObject(),...
            coderData);

            if(~mlScript.isEmpty())


                aObj.fScriptInfo=mlScript.getScripts();


                aObj.fRootFuncID=mlScript.getRootFunctionID();


                mlMtree=slci.mlutil.MLMtree(aObj.fScriptInfo,...
                mlScript.getFIDs());


                aObj.translateToAst(mlMtree.getMtree(),...
                mlScript.getFIDs(),...
                coderData.getInference);
            end
        end


        function translateToAst(aObj,mtreeNodes,fids,funcInference)

            for k=1:numel(fids)
                fid=fids(k);


                if(isKey(mtreeNodes,fid))
                    mtreeNode=mtreeNodes(fid);

                    if strcmpi(mtreeNode.kind,'FUNCTION')
                        [isAstNeeded,ast]=slci.matlab.astTranslator.createMatlabAst(...
                        mtreeNode,aObj);
                        assert(isAstNeeded&&~isempty(ast));
                        assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
                        if(funcInference.isKey(fid))
                            ast.setDroppedInputs(funcInference(fid).getDroppedInputs);
                            ast.setDroppedOutputs(funcInference(fid).getDroppedOutputs);
                        end
                        assert(~aObj.hasFunction(fid),...
                        ['Duplicate function ID ',sprintf('%ld',fid)]);
                        aObj.fFuncIDToAst(fid)=ast;
                    end
                end
            end

        end


        function inferAst(aObj,coderData)

            funcTable=aObj.getAllFuncs();


            fids=cell2mat(keys(funcTable));
            mlInference=slci.mlutil.MLInference(coderData,fids);


            mtreeInference=mlInference.getInference();
            if isempty(mtreeInference)

                return;
            end
            typeInference=slci.matlab.astProcessor.TypeInference(...
            mtreeInference,aObj.fSymbolTable);

            [aObj.fFuncIDToAst,...
            aObj.fSymbolTable]=typeInference.apply(funcTable);


            sizeInference=slci.matlab.astProcessor.SizeInference(...
            mtreeInference);

            aObj.fFuncIDToAst=sizeInference.apply(funcTable);


            fcnInference=slci.matlab.astProcessor.FunctionInference(...
            mtreeInference);

            aObj.fFuncIDToAst=fcnInference.apply(funcTable);


            slci.matlab.astProcessor.PersistentInference(...
            funcTable,typeInference,sizeInference,mtreeInference);

        end


        function processAst_preInference(aObj)

            funcTable=aObj.getAllFuncs();


            fids=cell2mat(keys(funcTable));
            for k=1:numel(fids)
                fid=fids(k);
                ast=funcTable(fid);
                slci.matlab.astTranslator.resolveLBNodes(ast);
            end

        end



        function processAst_postInference(aObj)

            funcTable=aObj.getAllFuncs();


            fids=cell2mat(keys(funcTable));
            for k=1:numel(fids)
                fid=fids(k);
                ast=funcTable(fid);


                slci.matlab.astProcessor.processDirectives(ast);
                slci.matlab.astTranslator.resolveArrayNodes(ast);
                slci.matlab.astProcessor.computeSIDs(ast);
                slci.matlab.astProcessor.processPersistents(ast);
            end
        end


        function computeFuncCallMap(aObj)
            assert(~aObj.fIsFuncCallMapComputed);
            aObj.fFuncCallMap=containers.Map('KeyType','int32','ValueType','any');
            funcTable=aObj.getAllFuncs();
            fids=cell2mat(keys(funcTable));
            for k=1:numel(fids)
                fid=fids(k);
                if fid~=aObj.getRootFunctionID

                    ast=funcTable(fid);
                    aObj.visitAst(ast,fid);
                end
            end
            aObj.fIsFuncCallMapComputed=true;
        end


        function visitAst(aObj,ast,funcId)
            if isa(ast,'slci.ast.SFAstMatlabFunctionCall')...
                &&(ast.getFunctionID~=-1)
                if isKey(aObj.fFuncCallMap,funcId)
                    aObj.fFuncCallMap(funcId)=unique([aObj.fFuncCallMap(funcId)...
                    ,ast.getFunctionID]);
                else
                    aObj.fFuncCallMap(funcId)=[ast.getFunctionID];
                end
            end

            children=ast.getChildren();
            for i=1:numel(children)
                aObj.visitAst(children{i},funcId);
            end
        end


        function out=findFuncCallId(aObj,funcId,origFuncId,processedfId)
            out=false;
            if isKey(aObj.fFuncCallMap,funcId)

                fIds=aObj.fFuncCallMap(funcId);
                if ismember(origFuncId,fIds)
                    out=true;
                    return;
                end

                if ismember(funcId,processedfId)

                    return;
                else
                    processedfId=[processedfId,funcId];
                end

                for i=1:numel(fIds)
                    if aObj.findFuncCallId(fIds(i),origFuncId,processedfId)
                        out=true;
                        return;
                    end
                end
            end
        end

    end
end
