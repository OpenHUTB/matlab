classdef mtreeGenerateMLOperand<plccore.frontend.L5X.MtreeVisitor












    properties
        globalsList;
        MFBScript;
        elementList;
    end

    properties(Access=protected)
        defaultMsgID;
        operand;
        funNames;
        funReplaceMap;

        arrayIndexIncrement;
        parseElementList;
        cellLevelIndex;
        replacementList;
    end

    methods(Access=public)

        function this=mtreeGenerateMLOperand(operand,varargin)
            this@plccore.frontend.L5X.MtreeVisitor(plccore.util.operand2mtree(operand))

            p=inputParser;
            p.addOptional('ArrayIndexIncrement',false);
            p.addOptional('ParseElementList',false);

            p.parse(varargin{:});
            this.arrayIndexIncrement=p.Results.ArrayIndexIncrement;
            this.parseElementList=p.Results.ParseElementList;

            this.operand=operand;

            this.globalsList={};
            this.elementList={};
            this.cellLevelIndex=0;


            this.funNames={'ABS','ACS','ASN','ATN','COS','DEG','FRD',...
            'LN','LOG','RAD','SIN','SQR','TAN','TOD','TRN',...
            'NOT',...
            'MOD',...
            'AND',...
            'XOR',...
            'OR'};



            this.funReplaceMap=containers.Map(...
            {'ABS','ACS','ASN','ATN','COS','DEG','LN','LOG','NOT','TAN','TRN','RAD','SIN','SQR'},...
            {'abs','acosInt','asinInt','atanInt','cosInt','rad2deg','log','log10','bitcmp','tanInt','round','deg2rad','sinInt','signedSqrt'});
            this.run;
        end

        function messages=run(this)
            this.visit(this.tree)
            messages=this.messages;
            this.MFBScript=this.tree.tree2str(0,1,this.replacementList);
        end
    end

    methods(Access=protected)
        function addMessage(this,node,~,~,~)%#ok<INUSD>

        end

        function postProcessID(this,node)
            nodeVal=this.getNodeVal(node);
            if~ismember(nodeVal,this.funNames)&&~ismember(nodeVal,this.funReplaceMap.values)&&~strcmp(nodeVal,'single')

                this.globalsList{end+1}=nodeVal;
            end
        end

        function preProcessFIELD(this,node)%#ok<INUSD>


        end

        function postProcessFIELD(this,node)


            if this.parseElementList&&this.cellLevelIndex==0
                this.elementList{end+1}=node.string;
            end
        end

        function out=getNodeVal(this,node)%#ok<INUSL>
            out=node.string;
        end

        function out=getNodeString(this,node)%#ok<INUSL>
            out=node.tree2str;
        end

        function preProcessSUBSCR(~,node)
            import plccore.common.plcThrowError


            plcThrowError('plccoder:plccore:InvalidIndexing',node.tree2str);



        end

        function visitCELL(this,node)


            this.preProcessCELL(node);
            this.visit(node.Left);


            this.cellLevelIndex=this.cellLevelIndex+1;
            this.visitNodeList(node.Right);
            this.postProcessCELL(node);
        end

        function postProcessCELL(this,node)

            nodeLeftVal=this.getNodeString(node.Left);

            if ismember(nodeLeftVal,this.funNames)
                assert(false,'%s is a function name that cannot use "[ ]" to index elements',nodeLeftVal);
            else
                this.incrementRightChildren(node);
            end

            this.cellLevelIndex=this.cellLevelIndex-1;


        end

        function postProcessDCALL(this,node)%#ok<INUSL>
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:DirectCallUnsupported',deblank(node.tree2str));
        end

        function postProcessCALL(this,node)
            import plccore.common.plcThrowError



            if isempty(node.Right)
                return;
            end



            nodeLeftVal=this.getNodeVal(node.Left);

            if ismember(nodeLeftVal,this.funNames)


                if ismember(nodeLeftVal,this.funReplaceMap.keys)

                    MLfnName=this.funReplaceMap(nodeLeftVal);
                    this.replacementList=[this.replacementList,{node.Left,MLfnName}];
                else


                    MLfnName=lower(nodeLeftVal);
                    this.replacementList=[this.replacementList,{node.Left,MLfnName}];
                end
            elseif ismember(nodeLeftVal,this.funReplaceMap.values)||strcmp(nodeLeftVal,'single')


                return;
            else
                plcThrowError('plccoder:plccore:InvalidIndexing',node.tree2str);
            end
        end

        function incrementRightChildren(this,node)
            if~this.arrayIndexIncrement
                return;
            end
            rightNode=node.Right;

            while~isempty(rightNode)
                if strcmpi(rightNode.kind,'INT')


                    replacement=num2str(str2double(rightNode.tree2str)+1);
                else
                    replacement=[rightNode.tree2str,'+ 1'];
                end
                this.replacementList=[this.replacementList,{rightNode,replacement}];
                rightNode=rightNode.Next;
            end
        end

    end
end



