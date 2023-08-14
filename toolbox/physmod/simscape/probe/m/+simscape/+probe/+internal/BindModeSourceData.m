classdef BindModeSourceData<BindMode.BindModeSourceData














    properties(SetAccess=protected,GetAccess=public)


        clientName=BindMode.ClientNameEnum.SIMSCAPEPROBE;


        isGraphical=true;


        modelLevelBinding=false;


        allowMultipleConnections=true;


        requiresDropDownMenu=false;
        dropDownElements={};


        modelName;
        sourceElementPath;
        hierarchicalPathArray;
        sourceElementHandle;
    end

    properties(Access=private)
        Highlighter;
        Cache;
        Notifier;
    end

    methods
        function obj=BindModeSourceData(probeBlock)
            assert(string(get_param(probeBlock,'BlockType'))=="SimscapeProbe");
            obj.sourceElementPath=getfullname(probeBlock);
            obj.modelName=get_param(bdroot(probeBlock),'Name');
            obj.sourceElementHandle=get_param(probeBlock,'Handle');
            obj.hierarchicalPathArray=BindMode.utils.getHierarchicalPathArray(obj.sourceElementPath);
            obj.Cache=containers.Map('KeyType','double','ValueType','any');
            obj.Notifier=simscape.probe.internal.Notifier.get(obj.modelName);
            obj.Highlighter=simscape.probe.internal.Highlighter();




            obj.highlightBoundBlock(true);
            obj.cacheCurrentBlockVariables();
        end
        function bindableData=getBindableData(this,selectionHandles,~)


            import simscape.probe.internal.BindModeVariableMetaData;

            bindableData.updateDiagramButtonRequired=false;
            bindableData.bindableRows={};

            if~this.isSourceElementStillValid
                return;
            end

            probeBlockParent=lParentHandle(this.sourceElementHandle);


            selectionTypes=string(get_param(selectionHandles,'Type'));
            selectionHandles=selectionHandles(selectionTypes=="block");
            if isempty(selectionHandles)
                return;
            end




            blockData=[];
            for i=1:numel(selectionHandles)
                h=get_param(selectionHandles(i),'Handle');



                parentHandle=lParentHandle(h);
                if probeBlockParent~=parentHandle

                    this.notifyNoCrossSubsystem();
                    return;
                end

                blockData=simscape.probe.internal.getBlockData(h,this.getCachedBlockVariables(h));
                if~isempty(blockData)
                    break;
                end
            end



            if isempty(blockData)
                assert(~isempty(selectionHandles));
                this.notifyBlockNotSupported(selectionHandles(1));
                return;
            end





            this.highlightBoundBlock(false);
            this.cacheCurrentBlockVariables();
            this.setBoundBlockAndVariables(blockData.BoundBlock,blockData.Variables);
            this.highlightBoundBlock(true);


            bindableData.bindableRows=cell(size(blockData.VariableData));
            for i=1:numel(blockData.VariableData)
                metaData=BindModeVariableMetaData(blockData.VariableData(i).Path,blockData.BoundBlockFullPath,blockData.VariableData(i).Tooltip);

                bindableData.bindableRows{i}=BindMode.BindableRow(blockData.VariableData(i).Checked,...
                BindMode.BindableTypeEnum.SIMSCAPEVARIABLE,blockData.VariableData(i).Display,metaData);
            end
        end
        function success=onCheckBoxSelectionChange(this,~,~,~,metaData,isChecked)



            if~this.isSourceElementStillValid
                success=false;
                return;
            end


            variables=this.getVariables();
            variable=metaData.name;

            if isChecked
                variables=simscape.probe.internal.addVariable(variables,variable);
            else
                variables=simscape.probe.internal.removeVariable(variables,variable);
            end


            this.setVariables(variables);

            this.cacheCurrentBlockVariables();

            success=true;
        end
        function success=onRadioSelectionChange(~,~,~,~,~,~)

            assert(false,'Probe should never use radio buttons');
        end
        function result=shouldShowHelpNotification(~)


            result=false;
        end
    end
    methods(Access=private)
        function b=getBoundBlock(this)
            b=simscape.probe.getBoundBlock(this.sourceElementHandle);
            assert(isa(b,'double'));
        end
        function vs=getVariables(this)
            vs=string(simscape.probe.getVariables(this.sourceElementHandle));
        end
        function setBoundBlockAndVariables(this,newBoundBlock,newVariables)



            if isempty(this.getBoundBlock())||...
                get_param(newBoundBlock,'Handle')~=this.getBoundBlock()||...
                ~isequal(this.getVariables(),sort(string(newVariables)))
                this.setParametersWithUndo(...
                {{@simscape.probe.setBoundBlock,newBoundBlock},...
                {@simscape.probe.setVariables,newVariables,'Sort',true}});
            end
        end
        function setVariables(this,vs)

            this.setParametersWithUndo(...
            {{@simscape.probe.setVariables,vs,'Sort',true}});
        end
        function setParametersWithUndo(this,functionsAndArgs)


            simscape.probe.internal.executeWithUndo(...
            this.sourceElementHandle,...
            @()this.setParameters(functionsAndArgs));
        end
        function setParameters(this,functionsAndArgs)




            for i=1:numel(functionsAndArgs)
                fcn=functionsAndArgs{i}{1};
                args=functionsAndArgs{i}(2:end);
                fcn(this.sourceElementHandle,args{:});
            end
        end
        function highlightBoundBlock(this,toHighlight)


            boundBlock=this.getBoundBlock();
            if isempty(boundBlock)
                return;
            end
            if toHighlight
                this.Highlighter.applyHighlight(boundBlock);
            else
                this.Highlighter.removeHighlight(boundBlock);
            end
        end

        function cacheCurrentBlockVariables(this)
            boundBlock=this.getBoundBlock();
            if~isempty(boundBlock)
                this.Cache(boundBlock)=this.getVariables();
            end
        end

        function variables=getCachedBlockVariables(this,block)
            variables={};
            if this.Cache.isKey(block)
                variables=this.Cache(block);
            end
        end

        function notifyNoCrossSubsystem(this)


            this.notifyProblem('physmod:simscape:probe:help:NoCrossSubsystem');
        end

        function notifyBlockNotSupported(this,block)

            this.notifyProblem('physmod:simscape:probe:help:BlockNotSupported',...
            pm.sli.internal.getUserFacingBlockType(block));
        end

        function notifyProblem(this,helpMsgId,varargin)




            msg=message(helpMsgId,varargin{:});
            this.Notifier.deliver(msg.Identifier,msg.getString(),'warn');
        end
        function v=isSourceElementStillValid(this)


            v=ishandle(this.sourceElementHandle);
        end
    end
end

function parentHandle=lParentHandle(block)
    parentHandle=get_param(get_param(block,'Parent'),'Handle');
end



