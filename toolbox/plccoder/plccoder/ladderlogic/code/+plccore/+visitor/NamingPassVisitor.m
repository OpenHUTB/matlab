classdef NamingPassVisitor<plccore.visitor.AbstractVisitor



    properties(Access=protected)
Context
MaxLength
ChangeMap
Builtins
Keywords
    end

    methods
        function obj=NamingPassVisitor(ctx)
            obj.Kind='NamingPassVisitor';
            obj.Context=ctx;
            obj.MaxLength=slplc.utils.getTargetParam('targetMaxLength');
            obj.Keywords=plcprivate('plc_ladder_keyword_list');
        end

        function ret=runPass(obj,host,input)%#ok<INUSD>



            builtinNTList=obj.Context.builtinScope.symbolList('NamedType');


            keySet=cellfun(@(x)x.name,builtinNTList,'UniformOutput',false);
            valueSet=repmat({''},size(keySet));
            obj.ChangeMap=containers.Map(keySet,valueSet,'UniformValues',false);


            obj.Builtins=keySet;


            obj.Context.accept(obj,[]);

            ret=[];
        end

        function ret=visitContext(obj,host,input)%#ok<INUSD>
            host.configuration.accept(obj,host);
            ret=[];
        end

        function ret=visitConfiguration(obj,host,input)


            host.setName(obj.checkName(host.name,containers.Map()));


            host.globalScope.accept(obj,input);


            taskList=host.taskList;
            if~isempty(taskList)
                taskNameList=cellfun(@(x)x.name,taskList,'UniformOutput',false);
                taskListMap=containers.Map(taskNameList,repmat({''},size(taskNameList)));
                for task=taskList
                    task{:}.setName(obj.checkName(task{:}.name,taskListMap));
                end
            end

            ret=[];
        end

        function ret=visitGlobalScope(obj,host,input)
            namedTypeMap=containers.Map();
            FBmap=containers.Map();
            globalVarsMap=containers.Map();
            programsMap=containers.Map();


            ca=plccore.visitor.ContextAnalyzer(obj.Context);
            ca.doit;
            sortedTypeList=ca.sortedTypeList;
            sortedNamelist=cellfun(@(x)x.name,sortedTypeList,'UniformOutput',false);


            for type=sortedTypeList
                obj.categorize(type{:},namedTypeMap,FBmap,globalVarsMap,programsMap);
            end


            [~,idxs,~]=intersect(sortedNamelist,obj.Builtins);
            sortedNamelist(idxs)=[];


            symbolNameList=host.getSymbolNames;
            [~,~,idxs]=intersect(sortedNamelist,symbolNameList);
            symbolNameList(idxs)=[];


            for symbolName=symbolNameList
                symbol=host.getSymbol(symbolName{:});
                obj.categorize(symbol,namedTypeMap,FBmap,globalVarsMap,programsMap);
            end


            visitList=[sortedNamelist,symbolNameList];
            for i=1:numel(visitList)
                sym=host.getSymbol(visitList{i});
                switch sym.kind
                case 'NamedType'
                    input=namedTypeMap;
                case 'FunctionBlock'
                    input=FBmap;
                case 'Var'
                    input=globalVarsMap;
                case 'Program'
                    input=programsMap;
                end
                sym.accept(obj,input);
            end

            ret=[];
        end

        function ret=visitFunction(obj,host,input)
            obj.visitPOU(host,input);
            ret=[];
        end

        function ret=visitFunctionBlock(obj,host,map)
            fieldMap=obj.visitPOU(host,map);
            host.setName(obj.checkName(host.name,map));
            obj.ChangeMap(host.name)=fieldMap;
            ret=[];
        end

        function ret=visitProgram(obj,host,map)
            host.setName(obj.checkName(host.name,map));
            obj.visitPOU(host,map);
            ret=[];
        end

        function ret=visitRoutine(obj,host,map)
            host.setName(obj.checkName(host.name,map));
            if~isempty(host.impl)
                host.impl.accept(obj,map);
            end
            ret=[];
        end

        function ret=visitPOU(obj,host,input)%#ok<INUSD>


            keySet=[host.inputScope.getSymbolNames...
            ,host.outputScope.getSymbolNames...
            ,host.localScope.getSymbolNames...
            ,host.inOutScope.getSymbolNames];
            valueSet=repmat({''},size(keySet));
            symbolMap=containers.Map(keySet,valueSet,'UniformValues',false);


            host.inputScope.accept(obj,symbolMap);
            host.outputScope.accept(obj,symbolMap);
            host.localScope.accept(obj,symbolMap);
            host.inOutScope.accept(obj,symbolMap);


            if~isempty(host.impl)
                host.impl.accept(obj,symbolMap);
            end


            newArgList=obj.getNewList(host.argList,symbolMap);
            host.setArgList(newArgList);

            ret=symbolMap;
        end

        function ret=visitScope(obj,host,map)
            name_list=host.getSymbolNames;
            for key=name_list
                symbol=host.getSymbol(key{:});
                symbol.accept(obj,map);
            end
            host.updateSymbolNameList();
            ret=[];
        end

        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            rungs=host.rungs;
            if~isempty(rungs)
                for i=1:numel(rungs)
                    rung=rungs{i};
                    rung.accept(obj,i);
                end
            end
            ret=[];
        end

        function ret=visitLadderRung(obj,host,input)%#ok<INUSD>
            rungops=host.rungOps;
            if~isempty(rungops)
                for i=1:numel(rungops)
                    rungop=rungops{i};
                    rungop.accept(obj,i);
                end
            end
            ret=[];
        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSD>
            param=[host.inputs,host.outputs];
            for i=1:numel(param)
                param{i}.accept(obj,i);
            end
            ret=[];
        end

        function ret=visitIntegerBitRefExpr(obj,host,input)%#ok<INUSD>
            host.integerExpr.accept(obj,host);
            ret=[];
        end

        function ret=visitArrayRefExpr(obj,host,input)%#ok<INUSD>
            ret=[];
            arrayType=host.arrayExpr.accept(obj,host);
            if~isempty(arrayType)
                ret=arrayType.elemType;
            end
        end

        function ret=visitStructRefExpr(obj,host,input)%#ok<INUSD>
            ret=[];

            if strcmp(host.structExpr.kind,'VarExpr')


                structExprType=host.structExpr.var.type;
                if strcmp(structExprType.kind,'POUType')


                    fieldNameMap=obj.ChangeMap(structExprType.pou.name);
                    newName=fieldNameMap(host.fieldName);


                    if~isempty(newName)
                        host.setFieldName(newName);
                    end
                else



                    if isempty(find(strcmpi(obj.Builtins,structExprType.name),1))


                        map=obj.ChangeMap(structExprType.name);
                        host.setFieldName(obj.findNewName(host.fieldName,map));


                        fieldIdx=structExprType.type.findField(host.fieldName);
                        ret=structExprType.type.fieldType(fieldIdx);
                    end
                end
            else

                structExprType=host.structExpr.accept(obj,host);


                if~isempty(structExprType)
                    map=obj.ChangeMap(structExprType.name);
                    newName=obj.findNewName(host.fieldName,map);
                    host.setFieldName(newName);


                    fieldIdx=structExprType.type.findField(host.fieldName);
                    ret=structExprType.type.fieldType(fieldIdx);
                end
            end
        end

        function ret=visitVar(obj,host,map)
            import plccore.common.plcThrowError
            if~isempty(regexp(host.name,'[ !@#$%^&*:.]+','once'))
                plcThrowError('plccoder:plccore:PLCInvalidName',host.name);
            end

            if~isempty(find(strcmpi(obj.Keywords,host.name),1))

                noWSName=strrep(host.name,' ','_');
                newName=obj.genNewName(noWSName,map,false);

                map(host.name)=newName;%#ok<NASGU>

                host.setName(newName);
            else

                host.setName(obj.checkName(host.name,map));
            end

            if~isempty(host.initialValue)
                host.initialValue.accept(obj,host.type);
            end
            ret=[];
        end

        function ret=visitNamedType(obj,host,map)


            if~isempty(find(strcmpi([obj.Builtins,obj.Keywords],host.name),1))

                noWSName=strrep(host.name,' ','_');
                newName=obj.genNewName(noWSName,map,false);

                map(host.name)=newName;%#ok<NASGU>

                host.setName(newName);
            else

                host.setName(obj.checkName(host.name,map));
            end


            obj.ChangeMap(host.name)=host.type.accept(obj,host);
            ret=[];
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>


            map=containers.Map();
            for i=1:host.numFields
                map(host.fieldName(i))='';
            end

            for key=map.keys
                fieldIdx=host.findField(key);
                newName=obj.checkName(key{:},map);
                host.setFieldName(fieldIdx,newName);
            end

            ret=map;
        end

        function ret=visitStructValue(obj,host,htype)%#ok<INUSD>


            switch host.type.kind
            case 'POUType'

                fieldNameList=host.fieldNameList;
                if~isempty(fieldNameList)
                    for i=1:numel(fieldNameList)
                        host.fieldValue(fieldNameList{i}).accept(obj,[]);
                    end
                end


                map=obj.ChangeMap(host.type.pou.name);
                newFieldNameList=obj.getNewList(fieldNameList,map);
                host.setFieldNameList(newFieldNameList);

            case 'NamedType'

                structType=host.type.type;
                if structType.numFields>0
                    fields=cell(1,structType.numFields);
                    for i=1:structType.numFields
                        fields{i}=structType.fieldName(i);
                        host.fieldValue(host.fieldNameList{i}).accept(obj,host.fieldValue(host.fieldNameList{i}));
                    end


                    host.setFieldNameList(fields);
                end
            end
            ret=[];
        end

        function ret=categorize(obj,symbol,namedTypeMap,FBmap,globalVarsMap,programsMap)%#ok<INUSL>



            switch symbol.kind
            case 'NamedType'
                namedTypeMap(symbol.name)='';%#ok<NASGU>
            case 'FunctionBlock'
                FBmap(symbol.name)='';%#ok<NASGU>
            case 'Var'
                globalVarsMap(symbol.name)='';%#ok<NASGU>
            case 'Program'
                programsMap(symbol.name)='';%#ok<NASGU>
            end
            ret=[];
        end

        function newName=genNewName(obj,hostName,map,regen)



            if~regen

                prefix='a';
                len=min(length(hostName),obj.MaxLength-2);
                newName=[prefix,'_',hostName(1:len)];
            else

                stringParts=strsplit(hostName,'_');
                prefix=stringParts{1};
                truncName=strjoin(stringParts(2:end),'_');


                prefix=obj.stringIncrement(prefix);


                if length(truncName)+length(prefix)>=obj.MaxLength


                    newName=[prefix,'_',truncName(1:length(truncName)-1)];
                else

                    newName=[prefix,'_',truncName];
                end
            end


            nameAlreadyExists=map.isKey(newName);
            namePreviouslyUsed=~isempty(find(strcmp(map.values,newName),1));
            if nameAlreadyExists||namePreviouslyUsed

                newName=obj.genNewName(newName,map,true);
            end
        end

        function ret=stringIncrement(obj,inputStr)




            if all(inputStr=='z')

                ret=repmat('a',1,length(inputStr)+1);
                return
            else

                if inputStr(end)=='z'


                    ret=[obj.stringIncrement(inputStr(1:end-1)),'a'];
                else

                    inputStr(end)=inputStr(end)+1;
                    ret=inputStr;
                end
            end
        end

        function ret=findNewName(obj,name,map)%#ok<INUSL>


            if~isempty(map)&&~isempty(map(name))
                ret=map(name);
            else
                ret=name;
            end
        end

        function ret=checkName(obj,name,map)


            import plccore.common.plcThrowError

            ret=name;
            if length(name)>obj.MaxLength||~isempty(regexp(name,'[ !@#$%^&*:.]+','once'))
                newName=matlab.lang.makeValidName(name,'ReplacementStyle','delete');
                newName=obj.genNewName(newName,map,false);
                map(name)=newName;%#ok<NASGU>
                ret=newName;
            end
        end

        function ret=getNewList(obj,list,map)%#ok<INUSL>


            if~isempty(list)
                for i=1:numel(list)
                    value=map(list{i});
                    if~isempty(value)
                        list{i}=value;
                    end
                end
            end
            ret=list;
        end

    end
end



