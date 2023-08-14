classdef ConstAnalyzer<coder.internal.MTreeVisitor

    methods(Static)
        function messages=run(functionInfoRegistry)
            messages=coder.internal.analysis.ConstAnnotator.run(functionInfoRegistry);

            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            for ii=1:numel(fcnTypeInfos)
                functionTypeInfo=fcnTypeInfos{ii};
                analyzer=coder.internal.analysis.ConstAnalyzer(functionTypeInfo);
                analyzer.analyze();
            end
        end
    end

    properties
FunctionTypeInfo
Attributes

ConstVars
NonConstVars
    end

    methods
        function this=ConstAnalyzer(functionTypeInfo)
            this.FunctionTypeInfo=functionTypeInfo;
            this.Attributes=functionTypeInfo.treeAttributes;

            this.ConstVars=containers.Map();
            this.NonConstVars=containers.Map();
        end

        function analyze(this)
            this.visit(this.FunctionTypeInfo.tree,[]);

            vars=this.ConstVars.keys();
            for ii=1:numel(vars)
                var=vars{ii};

                isDUTIOVar=false;
                if this.FunctionTypeInfo.isDesign
                    isDUTIOVar=any(ismember(this.FunctionTypeInfo.inputVarNames,var))||...
                    any(ismember(this.FunctionTypeInfo.outputVarNames,var));
                end

                if~this.NonConstVars.isKey(var)&&~isDUTIOVar
                    varInfos=this.FunctionTypeInfo.getVarInfosByName(var);
                    if~isempty(varInfos)
                        for jj=1:numel(varInfos)
                            varInfos{jj}.isLiteralDoubleConstant=true;
                        end
                    end
                end
            end
        end
    end

    methods
        function out=visitEQUALS(this,node,input)
            out=[];
            lhsNodes={};
            switch node.kind
            case 'LB'
                lhs=node.Left;
                while~isempty(lhs)
                    if~strcmp(lhs.kind,'NOT')
                        lhsNodes{end+1}=lhs;
                    end
                    lhs=lhs.Next;
                end

            otherwise
                lhsNodes={node.Left};
            end

            for ii=1:numel(lhsNodes)
                lhs=lhsNodes{ii};
                lhsVarName=this.getVarName(lhs);
                if this.Attributes(lhs).IsConstant
                    this.incr(this.ConstVars,lhsVarName);
                else
                    this.incr(this.NonConstVars,lhsVarName);
                end
            end
        end
    end

    methods
        function varName=getVarName(this,node)
            varName='';
            switch node.kind
            case 'ID',varName=string(node);
            case 'SUBSCR',varName=this.getVarName(node.Left);
            end
        end

        function incr(this,map,key)
            if~map.isKey(key)
                map(key)=0;
            end
            map(key)=map(key)+1;
        end
    end

end

