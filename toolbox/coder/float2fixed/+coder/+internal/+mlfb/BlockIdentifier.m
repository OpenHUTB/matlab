classdef(Sealed)BlockIdentifier<handle



    properties(GetAccess=public,SetAccess=immutable)
UniqueKey
ModelHandle
    end

    properties(GetAccess=public,SetAccess=private,Dependent)
SID
SIDNumber
Block
ModelName
Handle
Name
FullName
    end

    properties(GetAccess=private,SetAccess=immutable)
modelHandle
sidNumberString
    end

    properties(Access=private)
cachedChart
cachedJavaId
    end

    methods
        function this=BlockIdentifier(blockArg)
            if isa(blockArg,'DAStudio.Object')||isa(blockArg,'Simulink.DABaseObject')
                if isa(blockArg,'Simulink.Object')

                    block=blockArg.Handle;
                elseif isa(blockArg,'Stateflow.Chart')||isa(blockArg,'Stateflow.EMChart')

                    block=sfprivate('chart2block',blockArg.ID);
                else

                    error('Unsupported object type ''%s'' for ''%s''',class(blockArg),blockArg.getFullName());
                end
                model=bdroot(getfullname(block));

                warningState=warning('off','Simulink:SID:UnassignedSID');
                this.sidNumberString=get_param(block,'SID');
                warning(warningState);
                if isempty(this.sidNumberString)&&~isa(blockArg,'Simulink.BlockDiagram')
                    error('Unsupported block state (no SID): %s',blockArg.getFullName());
                end
            elseif isa(blockArg,'com.mathworks.toolbox.coder.mlfb.BlockId')

                assert(isa(blockArg,'com.mathworks.toolbox.coder.mlfb.DefaultBlockId'));
                this.cachedJavaId=blockArg;
                if~blockArg.isModel()
                    this.sidNumberString=char(blockArg.getSidNumber());
                else
                    this.sidNumberString='';
                end
                model=blockArg.getModelHandle();
            else

                validateattributes(blockArg,{'char','double'},{'nonempty'});
                if isa(blockArg,'java.lang.String')
                    blockArg=char(blockArg);
                end
                model=bdroot(blockArg);
                this.sidNumberString=get_param(blockArg,'SID');
            end




            try
                this.ModelHandle=get_param(model,'Handle');
            catch e
                e.getReport();
            end
            this.UniqueKey=sprintf('[%s][%s]',num2str(this.ModelHandle),this.sidNumberString);
        end

        function chart=getChart(this)
            if isempty(this.cachedChart)
                try
                    chartId=sfprivate('block2chart',this.FullName);
                    this.cachedChart=idToHandle(sfroot,chartId);
                catch
                    this.cachedChart=[];
                end
            end
            chart=this.cachedChart;
        end

        function chartId=getChartID(this)
            chart=this.getChart();
            if~isempty(chart)
                chartId=chart.ID;
            else
                chartId=[];
            end
        end

        function parent=getParent(this)
            if~isa(this.Block,'Simulink.BlockDiagram')
                parentObj=this.Block.getParent();
                if~isempty(parentObj)
                    parent=coder.internal.mlfb.BlockIdentifier(parentObj);
                else
                    parent=[];
                end
            else
                parent=[];
            end
        end

        function stateflow=isStateflowChart(this)
            stateflow=~isempty(this.getChart());
        end

        function mlfb=isFunctionBlock(this)
            mlfb=isa(this.getChart(),'Stateflow.EMChart');
        end

        function model=isModel(this)
            model=isempty(this.sidNumberString);
        end

        function valid=isValidId(this)
            valid=Simulink.ID.isValid(this.SID);
        end

        function javaId=toJava(this)
            if isempty(this.cachedJavaId)&&usejava('jvm')
                this.cachedJavaId=com.mathworks.toolbox.coder.mlfb.FunctionBlockUtils.createBlockId(...
                this.ModelHandle,this.sidNumberString);
            end
            javaId=this.cachedJavaId;
        end

        function sid=get.SID(this)








            sid=get_param(this.ModelHandle,'Name');
            if~isempty(this.sidNumberString)

                sid=[sid,':',this.sidNumberString];
            end
        end

        function block=get.Block(this)
            block=get_param(this.SID,'Object');
        end

        function modelName=get.ModelName(this)
            modelName=get_param(this.ModelHandle,'Name');
        end

        function curHandle=get.Handle(this)
            curHandle=this.Block.Handle;
        end

        function name=get.Name(this)
            name=this.Block.Name;
        end

        function name=get.FullName(this)
            name=getfullname(this.Handle);
        end

        function sidNum=get.SIDNumber(this)
            sidNum=str2double(this.sidNumberString);
        end

        function value=get_param(this,paramKey)
            value=get_param(this.SID,paramKey);
        end

        function equals=eq(this,other)
            equals=isa(other,'coder.internal.mlfb.BlockIdentifier')&&...
            strcmp(this.UniqueKey,other.UniqueKey);
        end

        function notEquals=ne(this,other)
            notEquals=~this.eq(other);
        end

        function disp(this)
            fprintf('%s %s\n',getfullname(this.SID),this.UniqueKey);
        end
    end
end