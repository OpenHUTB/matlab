




classdef SimulinkGraphBuilder<internal.ml2pir.BaseGraphBuilder
    properties(Access=private)
GraphName
Graph
        CurrentSubGraph={};
        GraphInfos containers.Map
    end

    properties(Constant,Access=private)


        XPadding=60;
        YPadding=25;
    end

    methods

        function this=SimulinkGraphBuilder(graphName)
            this.GraphName=graphName;
            this.GraphInfos=containers.Map;
        end

        function finalize(this)
            save_system(this.Graph,this.GraphName);
            close_system(this.Graph);
        end

        function graph=createGraph(this,dutName)
            graph=new_system(this.GraphName);
            graph=get_param(graph,'Name');
            set_param(graph,'StopTime','0');
            set_param(graph,'ShowPortDataTypes','on');
            this.Graph=graph;

            this.CurrentSubGraph{end+1}=this.GraphName;
            this.setNewGraphInfo(this.GraphName);

            dut=this.beginSubGraph(dutName,'',[]);

            hdlset_param(dut,'FlattenHierarchy','Inherit');
        end

        function createIO(this,dut,inputNames,inputTypes,outputNames,outputTypes)

            this.createInputNodes(dut,inputNames,inputTypes);


            this.createOutputNodes(dut,outputNames,outputTypes);

            this.layoutSystem(this.getCurrentSubGraphNode);
        end

        function sgraph=beginSubGraph(this,name,description,subGraphInfo)
            if isempty(subGraphInfo)
                sgraph=this.createSubsys(name,description);
            else
                assert(isa(subGraphInfo,'internal.ml2pir.utils.LoopStreamInfo'),...
                'cannot create the specified graph type in simgen');
                sgraph=this.createForIterSubsys(name,description,subGraphInfo);
            end
        end

        function setSubGraph(this,subGraphNode)
            this.CurrentSubGraph{end+1}=subGraphNode;
        end

        function endSubGraph(this)
            this.layoutSystem(this.getCurrentSubGraphNode);
            this.CurrentSubGraph(end)=[];
        end

        function currentSG=getCurrentSubGraphNode(this)
            currentSG=getfullname(this.CurrentSubGraph{end});
        end

        function name=getCurrentSubGraphName(this)
            name=this.getCurrentSubGraphNode;
        end

        function newNode=copySubGraph(this,name,oldNode,~,~)
            dstPath=[this.CurrentSubGraph{end},'/',name];

            newNode=add_block(oldNode,dstPath,'MakeNameUnique','on');

            this.putNodeInNextPosition(newNode);

            newNode=getfullname(newNode);
        end

        function[inp,inpIdx]=addInput(this,name,typeInfo)
            vals=this.setupNewNode(name,typeInfo);
            vals.width=30;
            vals.height=14;
            vals.name=name;
            inp=add_block('built-in/Inport',vals.dstPath,'MakeNameUnique','on');
            set_param(inp,'SampleTime','-1');
            this.finalizeNewNode(inp,vals);

            if nargout>1
                inpIdx=str2double(get_param(inp,'Port'));
            end
        end

        function[out,outIdx]=addOutput(this,name,typeInfo)
            vals=this.setupNewNode(name,typeInfo);
            vals.width=30;
            vals.height=14;
            vals.name=name;
            out=add_block('built-in/Outport',vals.dstPath,'MakeNameUnique','on');
            set_param(out,'SampleTime','-1');
            this.finalizeNewNode(out,vals);

            if nargout>1
                outIdx=str2double(get_param(out,'Port'));
            end
        end

        function setType(~,obj,type,varargin)
            blocksWithoutType={'Assignment','Bit Concat',...
            'Bit Slice','From','Goto','S-Function',...
            'Selector','SubSystem','UnaryMinus'};



            if~type.isUnknown
                switch get_param(obj,'blocktype')
                case blocksWithoutType
                otherwise
                    try
                        typestr=type.toSlName;
                        set_param(obj,'OutDataTypeStr',typestr);
                    catch
                        blkType=get_param(obj,'blocktype');
                        fprintf('Warning: Could not set type for %s block\n',blkType);
                    end
                end
            else
                fprintf('Got an unknown type ''%s'' for block ''%s''\n',...
                type.getMLName,getfullname(obj));
            end
        end

        function setInitialValue(this,node,value)
            set_param(node,'InitialCondition',this.toString(value));
        end

        function connect(this,node1,node2)
            p1=1;
            if iscell(node1)
                p1=node1{2};
                node1=node1{1};
            end

            p2=1;
            if iscell(node2)
                p2=node2{2};
                node2=node2{1};
            end



            if isa(node1,'internal.mtree.Constant')
                node1=this.instantiateConstant(node1);
            end

            this.moveNode2RightOfNode1(node1,node2);

            sys=get_param(node1,'Parent');
            assert(strcmp(get_param(node2,'Parent'),sys));

            node1=get_param(node1,'name');
            node2=get_param(node2,'name');

            add_line(sys,sprintf('%s/%d',node1,p1),sprintf('%s/%d',node2,p2),'autorouting','on');
        end

        function setSignalName(~,~,~)

        end

        function isit=isValidIdentifier(~,name)



            isit=~isempty(regexp(name,'^[a-zA-Z0-9_]+$','once'));
        end

        function vals=setupNewNode(this,description,typeInfo)
            vals=struct;

            vals.dstPath=[this.CurrentSubGraph{end},'/tempName'];
            vals.description=description;
            vals.width=50;
            vals.height=50;
            vals.typeInfo=typeInfo;
            vals.name='';
        end

        function node=finalizeNewNode(this,node,vals)




            node=get_param(node,'handle');

            if this.isValidIdentifier(vals.name)
                name=vals.name;
            else
                name=get_param(node,'BlockType');
            end

            uniqueName=this.getUniqueName(name);


            if isstruct(vals.description)
                vals.description=vals.description.comments;
            end
            set_param(node,'Description',vals.description);
            set_param(node,'AttributesFormatString','%<Description>')
            set_param(node,'Name',uniqueName);

            if numel(vals.typeInfo.Outs)==1
                this.setType(node,vals.typeInfo.Outs(1));
            elseif numel(vals.typeInfo.Outs)>1
                error('too many output types');
            end

            this.putNodeInNextPosition(node,vals.width,vals.height);
        end



        function[node,vals]=instantiateFromNode(~,vals,tag)
            vals.width=40;
            vals.height=28;
            node=add_block('simulink/Signal Routing/From',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'GotoTag',tag);
        end

        function[node,vals]=instantiateGotoNode(~,vals,tag)
            vals.width=40;
            vals.height=30;
            node=add_block('simulink/Signal Routing/Goto',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'GotoTag',tag);
            set_param(node,'TagVisibility','local');
        end

        function[node,vals]=instantiateUnitDelayNode(~,vals)
            vals.width=30;
            vals.height=32;
            node=add_block('simulink/Discrete/Unit Delay',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'SampleTime','-1');
        end

        function[node,vals]=instantiateDelayNode(this,vals,color,delayLength)
            vals.width=30;
            vals.height=32;
            node=add_block('simulink/Discrete/Delay',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'SampleTime','-1');
            set_param(node,'BackgroundColor',color);
            set_param(node,'DelayLength',this.toString(delayLength));
        end

        function[node,vals]=instantiateSumNode(~,vals,dimension)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Sum',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'ListOfSigns','+');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off')
            set_param(node,'SaturateOnIntegerOverflow','off');

            if(dimension~=-1)
                set_param(node,'CollapseMode','Specified Dimension');
                set_param(node,'CollapseDim',num2str(dimension));
            end
        end

        function[node,vals]=instantiateProdNode(~,vals,dimension)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Product',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Inputs','1');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');

            if(dimension~=-1)
                set_param(node,'CollapseMode','Specified Dimension');
                set_param(node,'CollapseDim',num2str(dimension));
            end
        end

        function[node,vals]=instantiateAddNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Sum',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'ListOfSigns','++');
            set_param(node,'IconShape','rectangular');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off')
            set_param(node,'SaturateOnIntegerOverflow','off');
        end

        function[node,vals]=instantiateSubNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Sum',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'ListOfSigns','+-');
            set_param(node,'IconShape','rectangular');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off');
            set_param(node,'SaturateOnIntegerOverflow','off');
        end



        function[node,vals]=instantiateGainNode(this,vals,gainAmount,useDotMul,KTimesU)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Gain',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Gain',this.toString(gainAmount));
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'ParamDataTypeStr','Inherit: Inherit from ''Gain''');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');
            if(~useDotMul&&KTimesU)
                set_param(node,'Multiplication','Matrix(K*u)');
            elseif(~useDotMul)
                set_param(node,'Multiplication','Matrix(u*K)');
            end

        end

        function[node,vals]=instantiateDotMulNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Product',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');
        end

        function[node,vals]=instantiateMulNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('built-in/Product',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');
            set_param(node,'Multiplication','Matrix(*)');
        end

        function[node,vals]=instantiateDivNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('simulink/Math Operations/Divide',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');
            set_param(node,'Multiplication','Matrix(*)');
        end

        function[node,vals]=instantiateDotDivNode(~,vals)
            vals.width=30;
            vals.height=33;
            node=add_block('simulink/Math Operations/Divide',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'OutDataTypeStr','Inherit: Inherit via internal rule');
            set_param(node,'InputSameDT','off');
            set_param(node,'RndMeth','Floor');
            set_param(node,'SaturateOnIntegerOverflow','off');
        end

        function[node,vals]=instantiateUminusNode(~,vals)
            vals.width=30;
            vals.height=32;
            node=add_block('hdlsllib/Math Operations/Unary Minus',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'SaturateOnIntegerOverflow','off');
        end

        function[node,vals]=instantiateToWorkspaceNode(~,vals,outVarName)
            vals.width=50;
            vals.height=30;
            node=add_block('simulink/Sinks/To Workspace',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'SaveFormat','Array');
            set_param(node,'VariableName',outVarName);
        end

        function[node,vals]=instantiateDTCNode(~,vals)
            node=add_block('simulink/Signal Attributes/Data Type Conversion',vals.dstPath,'MakeNameUnique','on');
        end

        function[node,vals]=instantiateReinterpretNode(~,vals)
            node=add_block('simulink/Signal Attributes/Data Type Conversion',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'ConvertRealWorld','Stored Integer (SI)');
        end

        function[node,vals]=instantiateBitsetNode(this,vals,bitIdx,toVal)
            bitIdx=bitIdx-1;
            if toVal
                node=add_block('simulink/Logic and Bit Operations/Bit Set',vals.dstPath,'MakeNameUnique','on');
            else
                node=add_block('simulink/Logic and Bit Operations/Bit Clear',vals.dstPath,'MakeNameUnique','on');
            end
            set_param(node,'iBit',this.toString(bitIdx));
        end

        function[node,vals]=instantiateAbsNode(~,vals)
            node=add_block('simulink/Math Operations/Abs',vals.dstPath,'MakeNameUnique','on');
        end

        function[node,vals]=instantiateSqrtNode(~,vals)
            node=add_block('simulink/Math Operations/Sqrt',vals.dstPath,'MakeNameUnique','on');
        end

        function[node,vals]=instantiateMinMaxNode(~,vals,fcn)
            node=add_block('simulink/Math Operations/MinMax',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Function',fcn);
            numInputs=numel(vals.typeInfo.Ins);
            set_param(node,'Inputs',num2str(numInputs));
        end

        function[node,vals]=instantiateTrigNode(~,vals,fcn)
            node=add_block('simulink/Math Operations/Trigonometric Function',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Function',fcn);
        end

        function[node,vals]=instantiateMathNode(~,vals,fcn)
            node=add_block('simulink/Math Operations/Math Function',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Function',fcn);
        end

        function[node,vals]=instantiateRoundingNode(this,vals,fcn)
            assert(numel(vals.typeInfo.Ins)==1&&numel(vals.typeInfo.Outs)==1);



            if vals.typeInfo.Ins.isFloat

                node=add_block('simulink/Math Operations/Rounding Function',vals.dstPath,'MakeNameUnique','on');
                set_param(node,'Operator',fcn);
            elseif vals.typeInfo.Ins.isFi
                if strcmp(fcn,'fix')


                    fcn='zero';
                end



                node=add_block('simulink/Signal Attributes/Data Type Conversion',vals.dstPath,'MakeNameUnique','on');
                set_param(node,'RndMeth',fcn);
            else
                [node,vals]=this.instantiateMatlabFunctionNode(vals,fcn,true);
            end
        end

        function[node,vals]=instantiateArithShiftNode(~,vals,numberSource,direction)
            node=add_block('simulink/Logic and Bit Operations/Shift Arithmetic',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'BitShiftNumberSource',numberSource);
            set_param(node,'BitShiftDirection',direction);
        end

        function[node,vals]=instantiateBitsliceNode(this,vals,leftIdx,rightIdx)
            node=add_block('hdlsllib/HDL Operations/Bit Slice',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'lidx',this.toString(leftIdx));
            set_param(node,'ridx',this.toString(rightIdx));
            vals.width=100;
        end

        function[node,vals]=instantiateBitshiftNode(this,vals,kind,shiftBy)
            node=add_block('hdlsllib/HDL Operations/Bit Shift',vals.dstPath,'MakeNameUnique','on');
            switch kind
            case 'bitsll',mode='Shift Left Logical';
            case 'bitsrl',mode='Shift Right Logical';
            case 'bitsra',mode='Shift Right Arithmetic';
            end
            set_param(node,'mode',mode);
            set_param(node,'N',this.toString(shiftBy));
        end

        function[node,vals]=instantiateVarArithShiftNode(~,vals,direction)
            node=add_block('simulink/Logic and Bit Operations/Shift Arithmetic',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'BitShiftNumberSource','Input port');
            set_param(node,'BitShiftDirection',direction);
        end

        function[node,vals]=instantiateBitconcatNode(~,vals)
            node=add_block('hdlsllib/HDL Operations/Bit Concat',vals.dstPath,'MakeNameUnique','on');
        end

        function[node,vals]=instantiateInstantiatedConstantNode(this,vals,value)
            vals.width=30;
            vals.height=32;
            node=add_block('simulink/Commonly Used Blocks/Constant',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'SampleTime','-1');
            set_param(node,'value',this.toString(value));
            set_param(node,'VectorParams1D','off');
        end

        function[node,vals]=instantiateDisplayNode(~,vals)
            vals.width=120;
            vals.height=30;
            node=add_block('simulink/Sinks/Display',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Format','long_e');
        end

        function[node,vals]=instantiateRelOpNode(~,vals,kind)
            node=add_block('simulink/Logic and Bit Operations/Relational Operator',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Operator',kind);
        end

        function[node,vals]=instantiateFloatRelOpNode(~,vals,fcn)
            node=add_block('simulink/Logic and Bit Operations/Relational Operator',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Operator',fcn);
        end

        function[node,vals]=instantiateCompareToConstantNode(this,vals,kind,value)
            if value==0
                node=add_block('simulink/Logic and Bit Operations/Compare To Zero',vals.dstPath,'MakeNameUnique','on');
            else
                node=add_block('simulink/Logic and Bit Operations/Compare To Constant',vals.dstPath,'MakeNameUnique','on');
                set_param(node,'const',this.toString(value));
            end
            set_param(node,'relop',kind);
        end

        function[node,vals]=instantiateLogicOpNode(~,vals,kind)
            node=add_block('simulink/Logic and Bit Operations/Logical Operator',vals.dstPath,'MakeNameUnique','on');
            switch kind
            case '&&',set_param(node,'Operator','AND');
            case '||',set_param(node,'Operator','OR');
            case '~',set_param(node,'Operator','NOT');
            case 'xor',set_param(node,'Operator','XOR');
            end


            set_param(node,'Inputs',num2str(numel(vals.typeInfo.Ins)));
        end

        function[node,vals]=instantiateBitwiseOpNode(~,vals,kind)
            node=add_block('simulink/Logic and Bit Operations/Bitwise Operator',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'UseBitMask','off');
            switch kind
            case 'bitand',set_param(node,'logicop','AND');
            case 'bitor',set_param(node,'logicop','OR');
            case 'bitcomp',set_param(node,'logicop','NOT');
            case 'bitxor',set_param(node,'logicop','XOR');
            end
            if~strcmp(kind,'bitcomp')
                set_param(node,'NumInputPorts','2');
            end
        end

        function[node,vals]=instantiateBitReduceNode(~,vals,kind)
            node=add_block('hdlsllib/HDL Operations/Bit Reduce',vals.dstPath,'MakeNameUnique','on');
            switch kind
            case 'bitandreduce'
                reductionMode='AND';
            case 'bitorreduce'
                reductionMode='OR';
            case 'bitxorreduce'
                reductionMode='XOR';
            otherwise
                error(['unsupported bit reduce: ',kind]);
            end
            set_param(node,'Mode',reductionMode);
        end

        function[node,vals]=instantiateBitRotNode(~,vals,kind,shiftAmount)
            node=add_block('hdlsllib/Logic and Bit Operations/Bit Rotate',vals.dstPath,'MakeNameUnique','on');

            switch lower(kind)
            case 'bitrol'
                set_param(node,'Mode','Rotate Left');
            case 'bitror'
                set_param(node,'Mode','Rotate Right');
            otherwise
                assert(false);
            end


            set_param(node,'N',num2str(shiftAmount.Value));
        end

        function[node,vals]=instantiateDotExpNode(this,vals)

            [node,vals]=this.instantiateMatlabFunctionNode(vals,...
            ['function c = dotexp_fcn(a, b)',newline...
            ,'    c = a .^ b; ',newline...
            ,'end'],...
            true);
        end

        function[node,vals]=instantiateExpNode(this,vals)

            [node,vals]=this.instantiateMatlabFunctionNodeImpl(vals,...
            ['function c = dotexp_fcn(a, b)',newline...
            ,'    c = a ^ b; ',newline...
            ,'end'],...
            true);
        end

        function[node,vals]=instantiateRealImagToComplexNode(this,vals,mode,constVal)
            node=add_block('simulink/Math Operations/Real-Imag to Complex',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Input',mode);
            if(~strcmpi(mode,'real and imag'))
                set_param(node,'ConstantPart',this.toString(constVal))
            end
        end

        function[node,vals]=instantiateComplexToRealImagNode(~,vals,fcnName)
            node=add_block('simulink/Math Operations/Complex to Real-Imag',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'Output',fcnName);
        end

        function[node,vals]=instantiateMatlabFunctionNode(this,vals,mlFcnName,varargin)
            numIns=numel(vals.typeInfo.Ins);
            numOuts=numel(vals.typeInfo.Outs);

            if numIns>1
                inCellstr=arrayfun(@(x)sprintf('in%d',x),1:numIns,'UniformOutput',false);
                inStr=strjoin(inCellstr,', ');
            else
                inStr='in';
            end

            if numOuts>1
                outCellstr=arrayfun(@(x)sprintf('out%d',x),1:numOuts,'UniformOutput',false);
                outStr=['[',strjoin(outCellstr,', '),']'];
            else
                outStr='out';
            end

            script=sprintf(...
            ['function %3$s = %1$s_fcn(%2$s)',newline...
            ,'    %3$s = %1$s(%2$s); ',newline...
            ,'end'],...
            mlFcnName,inStr,outStr);

            [node,vals]=this.instantiateMatlabFunctionNodeImpl(vals,script,varargin{:});
        end

        function[node,vals]=instantiateSwitchNode(~,vals,kind,varargin)
            vals.width=30;
            vals.height=46;
            node=add_block('simulink/Signal Routing/Switch',vals.dstPath,'MakeNameUnique','on');
            switch kind
            case 'u2 ~= 0'
                set_param(node,'Criteria','u2 ~= 0');
            case{'u2 > Threshold','u2 >= Threshold'}
                if numel(varargin)<1
                    error('no threshold for switch');
                end
                set_param(node,'Criteria',kind);
                set_param(node,'Threshold',num2str(varargin{1}));
            otherwise
                error('unexpected kind for switch block')
            end
        end

        function[node,vals]=instantiateReshapeNode(this,vals)
            node=add_block('simulink/Math Operations/Reshape',vals.dstPath,'MakeNameUnique','on');

            outputDims=vals.typeInfo.Outs(1).Dimensions;

            if numel(outputDims)==1
                set_param(node,'OutputDimensionality','1-D array');
                set_param(node,'ShowName','off')

                vals.width=40;
                vals.height=36;
            else
                set_param(node,'OutputDimensionality','Customize');
                set_param(node,'OutputDimensions',this.toString(outputDims));
            end
        end

        function[node,vals]=instantiateSubscrNode(this,vals,indexArray,~)
            vals.width=40;
            vals.height=36;

            node=add_block('simulink/Signal Routing/Selector',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'IndexMode','One-based');

            [indexOptions,indexParams]=this.getIndexOptionArrays(indexArray,false);
            for i=1:numel(indexParams)
                indexParams{i}=this.toString(double(indexParams{i}));
            end
            indexOptionStr=strjoin(indexOptions,',');
            indexParamStr=strjoin(indexParams,',');

            set_param(node,'InputPortWidth','-1');
            set_param(node,'NumberOfDimensions',num2str(numel(indexArray)),...
            'IndexOptions',indexOptionStr,...
            'Indices',indexParamStr);
        end

        function[node,vals]=instantiateSubassignNode(this,vals,indexArray,~)
            vals.width=40;
            vals.height=36;

            node=add_block('simulink/Math Operations/Assignment',vals.dstPath,'MakeNameUnique','on');
            set_param(node,'IndexMode','One-based');

            [indexOptions,indexParams]=this.getIndexOptionArrays(indexArray,true);
            for i=1:numel(indexParams)
                indexParams{i}=this.toString(double(indexParams{i}));
            end
            indexOptionStr=strjoin(indexOptions,',');
            indexParamStr=strjoin(indexParams,',');

            set_param(node,'NumberOfDimensions',num2str(numel(indexArray)),...
            'IndexOptions',indexOptionStr,...
            'Indices',indexParamStr);
        end

        function[node,vals]=instantiateArrayConcatNode(~,vals,concatDimension)

            numInputs=numel(vals.typeInfo.Ins);
            node=add_block('simulink/Signal Routing/Vector Concatenate',...
            vals.dstPath,'MakeNameUnique','on','Mode','Multidimensional Array',...
            'NumInputs',num2str(numInputs),'ConcatenateDimension',concatDimension);
        end

        function[node,vals]=instantiateBusSelectorNode(~,vals,outputSigName)
            node=add_block('hdlsllib/Signal Routing/Bus Selector',...
            vals.dstPath,'MakeNameUnique','on','OutputSignals',outputSigName);
        end

        function[node,vals]=instantiateNoopNode(~,vals)
            vals.width=45;
            vals.height=38;
            vals.name='no-op';
            node=add_block('hdlmdlgenlib/Buffer',vals.dstPath,...
            'MakeNameUnique','on');
        end

        function[node,vals]=instantiateCounterNode(this,vals,start,step,stop)
            vals.width=45;
            vals.height=30;

            outType=vals.typeInfo.Outs;
            needDTC=~(outType.isFi||outType.isInt);

            if needDTC
                counterOutType=internal.mtree.Type.getIntToHold([start,stop],1);
            else
                counterOutType=outType;
            end

            if counterOutType.isFi
                if counterOutType.Numerictype.SignednessBool
                    signedness='Signed';
                else
                    signedness='Unsigned';
                end
                wordLen=num2str(counterOutType.Numerictype.WordLength);
                fracLen=num2str(counterOutType.Numerictype.FractionLength);
            else
                assert(counterOutType.isInt);
                if counterOutType.Signedness
                    signedness='Signed';
                else
                    signedness='Unsigned';
                end
                wordLen=num2str(counterOutType.Bits);
                fracLen='0';
            end




            node=add_block('hdlsllib/Sources/HDL Counter',vals.dstPath,'MakeNameUnique','on',...
            'CountType','Count limited','CountInit','0','CountStep','1','CountMax','1',...
            'CountFromType','Initial value',...
            'CountDataType',signedness,'CountWordLen',wordLen,'CountFracLen',fracLen,...
            'CountSampTime','-1');

            set_param(node,'CountStep',num2str(step));




            if isequal(start,1)
                set_param(node,'CountMax',num2str(stop),'CountInit',num2str(start));
            else
                set_param(node,'CountInit',num2str(start),'CountMax',num2str(stop));
            end

            if needDTC
                dtc=this.createDTCNode('',internal.mtree.NodeTypeInfo(counterOutType,outType));
                this.connect(node,dtc);


                node=dtc;
            end
        end




        function val=generateSourceCodeComments(~)
            val=true;
        end

        function val=generateTraceability(~)
            val=false;
        end

        function traceCmt=getNodeTraceability(~,~)
            traceCmt='';
        end

        function setNodeTraceabilityOverride(~,~)
        end

        function traceCmt=getNodeTraceabilityOverride(~)
            traceCmt='';
        end

        function val=generateUserComments(~)
            val=false;
        end

        function setUserCommentForFunction(~,~)
        end

        function setInliningForCurrentFunction(~,~)
        end
    end

    methods(Access=private)

        function createInputNodes(this,dut,varNames,varTypes)


            assert(numel(this.CurrentSubGraph)==1);



            sgraph=this.CurrentSubGraph{end};
            info=this.GraphInfos(sgraph);
            info.X=this.XPadding;
            info.XMax=this.XPadding;
            info.Y=this.YPadding;
            this.GraphInfos(sgraph)=info;


            inps=cell(size(varNames));
            for jj=1:numel(varNames)
                nodeTypeInfo=internal.mtree.NodeTypeInfo([],varTypes(jj));
                inps{jj}=this.createInstantiatedConstantNode(varNames{jj},nodeTypeInfo,varNames{jj},varNames{jj});



                set_param(inps{jj},'SampleTime','1')
            end




            for jj=1:numel(varNames)
                this.connect(inps{jj},{dut,jj});
            end
        end

        function createOutputNodes(this,dut,varNames,varTypes)
            for jj=1:numel(varNames)
                nodeTypeInfo=internal.mtree.NodeTypeInfo(varTypes(jj),[]);

                disp=this.createDisplayNode(varNames{jj},nodeTypeInfo);
                outWSVarName=[varNames{jj},'_mdl_out'];
                ws=this.createToWorkspaceNode(outWSVarName,nodeTypeInfo,outWSVarName);

                this.connect({dut,jj},disp);
                this.connect({dut,jj},ws);
            end
        end

        function sgraph=createSubsys(this,name,~)
            dstPath=[this.CurrentSubGraph{end},'/',name];

            sgraph=add_block('built-in/SubSystem',dstPath,'MakeNameUnique','on');
            sgraph=getfullname(sgraph);

            this.putNodeInNextPosition(sgraph);

            hdlset_param(sgraph,'FlattenHierarchy','on');

            this.CurrentSubGraph{end+1}=sgraph;
            this.setNewGraphInfo(sgraph);
        end

        function sgraph=createForIterSubsys(this,name,description,streamInfo)
            sgraph=this.beginSubGraph(name,description,[]);



            add_block('built-in/ForIterator',[this.CurrentSubGraph{end},'/ForIterator'],...
            'MakeNameUnique','on',...
            'ResetStates','held',...
            'IterationSource','internal',...
            'IterationLimit',num2str(streamInfo.iterations),...
            'ExternalIncrement','off',...
            'ShowIterationPort','off',...
            'IndexMode','One-based');


            counterTypeInfo=internal.mtree.NodeTypeInfo([],streamInfo.iterType);
            streamInfo.iterNode=this.createCounterNode(...
            streamInfo.idxDesc,counterTypeInfo,streamInfo.idxName,...
            streamInfo.start,streamInfo.step,streamInfo.stop);
        end

        function layoutSystem(~,sys)
            blockNames=get_param(sys,'blocks');
            if~isempty(blockNames)
                if exist('layoutSystem.m','file')
                    fprintf('Starting layout for system %s\n',sys);
                    layoutSystem(sys);
                    fprintf('Completed layout for system %s\n',sys);
                else
                    fprintf('Not laying out system %s: no layout function found\n',sys);
                end
            end
        end

        function setNewGraphInfo(this,name)
            graphInfoStruct.X=this.XPadding;
            graphInfoStruct.XMax=this.XPadding;
            graphInfoStruct.Y=this.YPadding;
            graphInfoStruct.Names=containers.Map;

            this.GraphInfos(name)=graphInfoStruct;
        end

        function advanceX(this)
            sgraph=this.CurrentSubGraph{end};
            info=this.GraphInfos(sgraph);



            info.X=info.XMax+this.XPadding;


            info.XMax=info.X;


            info.Y=this.YPadding;




            if info.X>16000
                info.X=this.XPadding;
            end

            this.GraphInfos(sgraph)=info;
        end

        function advanceY(this,height)
            sgraph=this.CurrentSubGraph{end};
            info=this.GraphInfos(sgraph);



            info.Y=info.Y+height+this.YPadding;

            this.GraphInfos(sgraph)=info;


            if info.Y>16000
                this.advanceX();
            end
        end

        function moveNode2RightOfNode1(this,node1,node2)

            pos1=get_param(node1,'position');
            pos2=get_param(node2,'position');










            if pos2(1)<=pos1(3)


                if this.GraphInfos(this.getCurrentSubGraphNode).X<=pos1(3)

                    this.advanceX;
                end

                width=pos2(3)-pos2(1);
                height=pos2(4)-pos2(2);
                this.putNodeInNextPosition(node2,width,height);
            end
        end

        function putNodeInNextPosition(this,node,width,height)
            if nargin<4
                height=50;
            end
            if nargin<3
                width=50;
            end

            try









                currInfo=this.GraphInfos(this.getCurrentSubGraphNode);

                left=currInfo.X;
                top=currInfo.Y;
                right=left+width;
                bottom=top+height;
                set_param(node,'position',[left,top,right,bottom]);



                if right>currInfo.XMax
                    currInfo.XMax=right;
                    this.GraphInfos(this.getCurrentSubGraphNode)=currInfo;
                end

                this.advanceY(height);
            catch ex
                disp(ex);
            end
        end

        function[node,vals]=instantiateMatlabFunctionNodeImpl(~,vals,script,varargin)
            node=add_block('simulink/User-Defined Functions/MATLAB Function',vals.dstPath,'MakeNameUnique','on');
            chartId=sfprivate('block2chart',node);
            chart=idToHandle(slroot,chartId);

            chart.Script=script;

            encloseInSubsystem=numel(varargin)>=1&&varargin{1};

            if encloseInSubsystem
                Simulink.BlockDiagram.createSubSystem(get_param(node,'handle'));
                subsysNode=get_param(get_param(node,'Parent'),'handle');
                set_param(subsysNode,'Name',get_param(node,'Name'));
                node=getfullname(subsysNode);
                hdlset_param(node,'FlattenHierarchy','on');
            end
        end


        function uniqueName=getUniqueName(this,name)
            sgraph=this.getCurrentSubGraphNode;
            nameMap=this.GraphInfos(sgraph).Names;

            if nameMap.isKey(name)
                numToAppend=nameMap(name);
                nameMap(name)=numToAppend+1;%#ok<NASGU>

                uniqueName=[name,num2str(numToAppend)];
            else
                nameMap(name)=1;%#ok<NASGU>
                uniqueName=name;
            end
        end
    end

end




