




classdef SFAstCEval<slci.ast.SFAstMatlabDirective

    properties(Access=private)

        fFunctionName='';

        fHasReturn=false;


        fHasGlobalOption=false;


        fLayout=slci.compatibility.CoderCEvalLayoutEnum.Unknown;
    end

    methods

        function aObj=SFAstCEval(aAstObj,args,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstCEval'));
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,aParent);

            aObj.populateChildren(args);


            parent=aObj.getParent();
            if~isa(parent,'slci.ast.SFAstMatlabFunctionDef')...
                &&~isa(parent,'slci.ast.SFAstBranch')

                aObj.fHasReturn=true;
            end
        end


        function ComputeDataType(aObj)%#ok

        end


        function ComputeDataDim(aObj)%#ok

        end


        function name=getFunctionName(aObj)
            name=aObj.fFunctionName;
        end


        function hasOut=hasReturn(aObj)
            hasOut=aObj.fHasReturn;
        end


        function out=hasGlobalOption(aObj)
            out=aObj.fHasGlobalOption;
        end


        function out=getLayout(aObj)
            out=aObj.fLayout;
        end
    end

    methods(Access=private)

        function populateChildren(aObj,args)
            for i=1:numel(args)
                argNode=args{i};

                if strcmpi(argNode.kind,'CHARVECTOR')
                    str=argNode.string;

                    tokens=regexp(str,'^('')(.*)('')$','tokens');
                    assert(~isempty(tokens));
                    arg=tokens{1}{2};
                    argName=lower(arg);
                    switch argName
                    case '-global'
                        aObj.fHasGlobalOption=true;
                    case{'-layout:columnmajor','-col'}
                        aObj.fLayout=slci.compatibility.CoderCEvalLayoutEnum.ColumnMajor;
                    case{'-layout:rowmajor','-row'}
                        aObj.fLayout=slci.compatibility.CoderCEvalLayoutEnum.RowMajor;
                    case '-layout:any'
                        aObj.fLayout=slci.compatibility.CoderCEvalLayoutEnum.Any;
                    otherwise
                        aObj.fFunctionName=arg;
                    end
                else
                    [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
                    argNode,aObj);
                    assert(isAstNeeded&&~isempty(cObj));

                    aObj.fChildren{end+1}=cObj;
                end
            end

        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,~)

        end


        function addMatlabFunctionConstraints(aObj)

            newConstraints={...
            slci.compatibility.MatlabFunctionCEvalLayoutConstraint,...
            slci.compatibility.MatlabFunctionCEvalGlobalConstraint...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end
