classdef(Abstract)POU<plccore.common.Object




    properties(Access=protected)
Name
Description
InputScope
OutputScope
InOutScope
LocalScope
ArgList
Implementation
AliasVarsMap
    end

    methods
        function obj=POU(name,input_scope,output_scope,inout_scope,local_scope,arglist)
            obj.Kind='POU';
            obj.Name=name;
            obj.Description='';
            obj.InputScope=input_scope;
            obj.OutputScope=output_scope;
            obj.InOutScope=inout_scope;
            obj.LocalScope=local_scope;
            obj.Implementation=[];

            if(nargin>5)
                obj.ArgList=arglist;
            else
                obj.ArgList={};
            end

            if~isempty(obj.InputScope)
                obj.InputScope.setOwner(obj);
            end
            if~isempty(obj.OutputScope)
                obj.OutputScope.setOwner(obj);
            end
            if~isempty(obj.InOutScope)
                obj.InOutScope.setOwner(obj);
            end
            if~isempty(obj.LocalScope)
                obj.LocalScope.setOwner(obj);
            end
            obj.AliasVarsMap=containers.Map;
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function obj=setName(obj,new_name)
            obj.Name=new_name;
        end

        function ret=description(obj)
            ret=obj.Description;
        end

        function setDescription(obj,desc)
            obj.Description=desc;
        end

        function ret=localScope(obj)
            ret=obj.LocalScope;
        end

        function ret=inputScope(obj)
            ret=obj.InputScope;
        end

        function ret=outputScope(obj)
            ret=obj.OutputScope;
        end

        function ret=inOutScope(obj)
            ret=obj.InOutScope;
        end

        function ret=toString(obj)
            if~isempty(obj.Name)
                txt=sprintf('%s\n',obj.Name);
            else
                txt='';
            end
            if~isempty(obj.ArgList)
                txt=[txt,'Args: ',strjoin(obj.ArgList,', '),newline];
            end
            txt=[txt,obj.toStringScope];
            if~isempty(obj.Implementation)
                txt=[txt,obj.Implementation.toString];
            end
            ret=txt;
        end

        function ret=impl(obj)
            ret=obj.Implementation;
        end

        function ret=argList(obj)
            ret=obj.ArgList;
        end

        function setArgList(obj,arglist)
            obj.ArgList=arglist;
        end

        function out=getAliasVarsMap(obj)
            out=obj.AliasVarsMap;
        end

        function appendToAliasVarsMap(obj,aliasVarObj)
            obj.AliasVarsMap(aliasVarObj.name)=aliasVarObj.alias;
        end

        function variableList=getVariableList(obj)

            if isempty([obj.inputScope,obj.outputScope,obj.inOutScope,obj.localScope])
                variableList={};
                return
            end


            inputSymbols={};
            inputSymbolNames=obj.inputScope.getSymbolNames;
            if~isempty(inputSymbolNames)
                inputSymbols=cellfun(@(x)obj.inputScope.getSymbol(x),inputSymbolNames,'UniformOutput',false);
            end


            outputSymbols={};
            outputSymbolNames=obj.outputScope.getSymbolNames;
            if~isempty(outputSymbolNames)
                outputSymbols=cellfun(@(x)obj.outputScope.getSymbol(x),outputSymbolNames,'UniformOutput',false);
            end


            inOutSymbols={};
            if~isempty(obj.inOutScope)
                inOutSymbolNames=obj.inOutScope.getSymbolNames;
                if~isempty(inOutSymbolNames)
                    inOutSymbols=cellfun(@(x)obj.inOutScope.getSymbol(x),inOutSymbolNames,'UniformOutput',false);
                end
            end


            localSymbols={};
            localSymbolNames=obj.localScope.getSymbolNames;
            if~isempty(localSymbolNames)
                localSymbols=cellfun(@(x)obj.localScope.getSymbol(x),localSymbolNames,'UniformOutput',false);


                varIdx=cellfun(@(x)strcmp(x.kind,'Var'),localSymbols,'UniformOutput',true);
                localSymbols=localSymbols(varIdx);
            end


            ioVars=[inputSymbols,inOutSymbols,outputSymbols];
            paramIdxs=cellfun(@(x)x.paramIndex,ioVars);
            [~,sortIdx]=sort(paramIdxs);
            variableList=[ioVars(sortIdx),localSymbols];

        end
    end

    methods(Access=protected)
        function ret=toStringScope(obj)
            txt='';
            if~isempty(obj.InputScope)
                txt=[txt,sprintf('Input vars:\n'),obj.InputScope.toString];
            end

            if~isempty(obj.OutputScope)
                txt=[txt,sprintf('Output vars:\n'),obj.OutputScope.toString];
            end

            if~isempty(obj.InOutScope)
                txt=[txt,sprintf('InOut vars:\n'),obj.InOutScope.toString];
            end

            if~isempty(obj.LocalScope)
                txt=[txt,sprintf('Local vars:\n'),obj.LocalScope.toString];
            end

            ret=txt;
        end
    end

    methods(Access={?plccore.common.POUImplementation,...
        ?plccore.ladder.LadderDiagram})
        function setImplementation(obj,impl)
            obj.Implementation=impl;
        end
    end

end


