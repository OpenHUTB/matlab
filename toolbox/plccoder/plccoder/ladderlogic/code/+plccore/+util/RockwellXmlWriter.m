classdef RockwellXmlWriter<plccore.util.XmlWriter



    properties(Access=protected)
EmitController
RootNode
ControllerNode
UDTTopNode
UDTNode
UDTTopMember
AOITopNode
AOINode
AOITopParam
AOITopLocal
TagTopNode
ProgTopNode
ProgNode
ProgTopTag
ProgLadderContent
TaskTopNode
TaskNode
TaskTopProgram
CurrentPOUVar
CurrentPOURoutine
CurrentPOULadder
    end

    methods
        function obj=RockwellXmlWriter(file_type)
            obj@plccore.util.XmlWriter('RSLogix5000Content');
            obj.Kind='RockwellXmlWriter';
            obj.RootNode=obj.getRoot;
            obj.RootNode.setAttribute('SchemaRevision','1.0');
            obj.RootNode.setAttribute('TargetName','PLC_LD');
            if(strcmp(file_type,'Controller'))
                obj.EmitController=true;
            else
                assert(strcmp(file_type,'AOI'));
                obj.EmitController=false;
            end
            if(obj.EmitController)
                obj.RootNode.setAttribute('TargetType','Controller');
                obj.RootNode.setAttribute('ContainsContext','false');
            else
                obj.RootNode.setAttribute('TargetType','AddOnInstructionDefinition');
                obj.RootNode.setAttribute('ContainsContext','true');
            end
            obj.genControllerNode;
            obj.genUDTTopNode;
            obj.genAOITopNode;
            obj.genTagTopNode;
            obj.genProgTopNode;
            obj.genTaskTopNode;
        end
    end

    methods(Access={?plccore.visitor.RockwellEmitter,...
        ?plccore.visitor.L5XValueEmitter})
        function setL5XContext(obj,node)
            if~obj.EmitController
                node.setAttribute('Use','Context');
            end
        end

        function genControllerNode(obj)
            obj.ControllerNode=obj.createElement('Controller');
            obj.addChild(obj.RootNode,obj.ControllerNode);
            if obj.EmitController
                obj.ControllerNode.setAttribute('MajorRev','24');
                obj.ControllerNode.setAttribute('ProcessorType','Emulator');
                obj.ControllerNode.setAttribute('CommPath','AB_VBP-1\1');
                obj.ControllerNode.setAttribute('Use','Target');
            else
                obj.ControllerNode.setAttribute('Use','Context');
            end
        end

        function setControllerName(obj,name)
            obj.ControllerNode.setAttribute('Name',name);
        end

        function genAOITopNode(obj)
            obj.AOITopNode=obj.createElement('AddOnInstructionDefinitions');
            obj.addChild(obj.ControllerNode,obj.AOITopNode);
            obj.setL5XContext(obj.AOITopNode);
        end

        function genProgTopNode(obj)
            obj.ProgTopNode=obj.createElement('Programs');
            obj.addChild(obj.ControllerNode,obj.ProgTopNode);
            obj.setL5XContext(obj.ProgTopNode);
        end

        function genTagTopNode(obj)
            obj.TagTopNode=obj.createElement('Tags');
            obj.addChild(obj.ControllerNode,obj.TagTopNode);
            obj.setL5XContext(obj.TagTopNode);
        end

        function genUDTTopNode(obj)
            obj.UDTTopNode=obj.createElement('DataTypes');
            obj.addChild(obj.ControllerNode,obj.UDTTopNode);
            obj.setL5XContext(obj.UDTTopNode);
        end

        function genTaskTopNode(obj)
            obj.TaskTopNode=obj.createElement('Tasks');
            obj.addChild(obj.ControllerNode,obj.TaskTopNode);
        end

        function beginGenUDTNode(obj,name)
            assert(isempty(obj.UDTNode));
            obj.UDTNode=obj.createElement('DataType');
            obj.addChild(obj.UDTTopNode,obj.UDTNode);
            obj.UDTNode.setAttribute('Name',name);
            obj.UDTNode.setAttribute('Family','NoFamily');
            obj.UDTNode.setAttribute('Class','User');
            obj.UDTTopMember=obj.createElement('Members');
            obj.addChild(obj.UDTNode,obj.UDTTopMember);
        end

        function genNodeDesc(obj,node,desc_txt)
            desc_node=obj.createElement('Description');
            obj.addChild(node,desc_node);
            txt=obj.createText(desc_txt);
            obj.addChild(desc_node,txt);
        end

        function setNodeParamList(obj,node,param_name_list,param_value_list)%#ok<INUSL>
            assert(length(param_name_list)==length(param_value_list));
            for i=1:length(param_name_list)
                node.setAttribute(param_name_list{i},param_value_list{i});
            end
        end

        function genUDTMemberNode(obj,param_name_list,param_value_list,desc)
            member_node=obj.createElement('Member');
            obj.addChild(obj.UDTTopMember,member_node);
            obj.setNodeParamList(member_node,param_name_list,param_value_list);
            member_node.setAttribute('ExternalAccess','Read/Write');
            if~isempty(desc)
                obj.genNodeDesc(member_node,desc);
            end
        end

        function endGenUDTNode(obj,name)
            assert(strcmp(obj.UDTNode.getAttribute('Name'),name));
            obj.UDTNode=[];
        end

        function beginGenTaskNode(obj,param_name_list,param_value_list,task)
            assert(isempty(obj.TaskNode));
            obj.TaskNode=obj.createElement('Task');
            obj.addChild(obj.TaskTopNode,obj.TaskNode);
            obj.setNodeParamList(obj.TaskNode,param_name_list,param_value_list);
            obj.TaskNode.setAttribute('DisableUpdateOutputs','false');
            obj.TaskNode.setAttribute('InhibitTask','false');
            if numel(task.programList)~=0
                obj.TaskTopProgram=obj.createElement('ScheduledPrograms');
                obj.addChild(obj.TaskNode,obj.TaskTopProgram);
            end
        end

        function endGenTaskNode(obj)
            obj.TaskNode=[];
        end

        function genTaskDescription(obj,desc)
            obj.genNodeDesc(obj.TaskNode,desc);
        end

        function genEventTaskTrigger(obj,trigger)
            evt_info_node=obj.createElement('EventInfo');
            obj.addChild(obj.TaskNode,evt_info_node);
            param_name_list={'EventTrigger','EnableTimeout'};
            param_value_list={trigger,'false'};
            obj.setNodeParamList(evt_info_node,param_name_list,param_value_list);
        end

        function genTaskProgram(obj,name)
            prog_node=obj.createElement('ScheduledProgram');
            obj.addChild(obj.TaskTopProgram,prog_node);
            obj.setNodeParamList(prog_node,{'Name'},{name});
        end

        function beginGenAOINode(obj,param_name_list,param_value_list)
            assert(isempty(obj.AOINode));
            obj.AOINode=obj.createElement('AddOnInstructionDefinition');
            obj.addChild(obj.AOITopNode,obj.AOINode);
            obj.setNodeParamList(obj.AOINode,param_name_list,param_value_list);
            obj.AOITopParam=obj.createElement('Parameters');
            obj.addChild(obj.AOINode,obj.AOITopParam);
            obj.AOITopLocal=obj.createElement('LocalTags');
            obj.addChild(obj.AOINode,obj.AOITopLocal);
            obj.CurrentPOURoutine=obj.createElement('Routines');
            obj.addChild(obj.AOINode,obj.CurrentPOURoutine);
        end

        function endGenAOINode(obj)
            obj.AOINode=[];
            obj.CurrentPOURoutine=[];
        end

        function genAOIParamVar(obj,param_name_list,param_value_list)
            obj.CurrentPOUVar=obj.createElement('Parameter');
            obj.addChild(obj.AOITopParam,obj.CurrentPOUVar);
            param_name_list=[param_name_list,'TagType'];
            param_value_list=[param_value_list,'Base'];
            obj.setNodeParamList(obj.CurrentPOUVar,param_name_list,param_value_list);
        end

        function genAOILocalVar(obj,param_name_list,param_value_list)
            obj.CurrentPOUVar=obj.createElement('LocalTag');
            obj.addChild(obj.AOITopLocal,obj.CurrentPOUVar);
            param_name_list=[param_name_list,'ExternalAccess'];
            param_value_list=[param_value_list,'None'];
            obj.setNodeParamList(obj.CurrentPOUVar,param_name_list,param_value_list);
        end

        function beginGenRoutine(obj,name)
            rtn_node=obj.createElement('Routine');
            obj.addChild(obj.CurrentPOURoutine,rtn_node);
            param_name_list={'Name','Type'};
            param_value_list={name,'RLL'};
            obj.setNodeParamList(rtn_node,param_name_list,param_value_list);
            obj.CurrentPOULadder=obj.createElement('RLLContent');
            obj.addChild(rtn_node,obj.CurrentPOULadder);
        end

        function endGenRoutine(obj)
            obj.CurrentPOULadder=[];
        end

        function beginGenProgNode(obj,param_name_list,param_value_list)
            assert(isempty(obj.ProgNode));
            obj.ProgNode=obj.createElement('Program');
            obj.addChild(obj.ProgTopNode,obj.ProgNode);
            param_name_list=[param_name_list,'Use','TestEdits','Disabled','UseAsFolder'];
            param_value_list=[param_value_list,'Target','false','false','false'];
            obj.setNodeParamList(obj.ProgNode,param_name_list,param_value_list);
            obj.ProgTopTag=obj.createElement('Tags');
            obj.addChild(obj.ProgNode,obj.ProgTopTag);
            obj.CurrentPOURoutine=obj.createElement('Routines');
            obj.addChild(obj.ProgNode,obj.CurrentPOURoutine);
        end

        function endGenProgNode(obj)
            obj.ProgNode=[];
            obj.CurrentPOURoutine=[];
        end

        function genGlobalVar(obj,param_name_list,param_value_list)
            obj.CurrentPOUVar=obj.createElement('Tag');
            obj.addChild(obj.TagTopNode,obj.CurrentPOUVar);
            param_name_list=[param_name_list,'TagType','Constant','ExternalAccess'];
            param_value_list=[param_value_list,'Base','false','Read/Write'];
            obj.setNodeParamList(obj.CurrentPOUVar,param_name_list,param_value_list);
        end

        function genProgVar(obj,param_name_list,param_value_list)
            obj.CurrentPOUVar=obj.createElement('Tag');
            obj.addChild(obj.ProgTopTag,obj.CurrentPOUVar);
            param_name_list=[param_name_list,'TagType','Constant','Visible'];
            param_value_list=[param_value_list,'Base','false','true'];
            obj.setNodeParamList(obj.CurrentPOUVar,param_name_list,param_value_list);
        end

        function data_node=beginGenAOIVarValue(obj)
            data_node=obj.createElement('DefaultData');
            data_node.setAttribute('Format','Decorated');
            obj.addChild(obj.CurrentPOUVar,data_node);
        end

        function data_node=beginGenProgVarValue(obj)
            data_node=obj.createElement('Data');
            data_node.setAttribute('Format','Decorated');
            obj.addChild(obj.CurrentPOUVar,data_node);
        end

        function data_node=beginGenArrayValue(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('Array');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function data_node=beginGenArrayValueMember(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('ArrayMember');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function data_node=beginGenStructValue(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('Structure');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function data_node=beginGenStructValueMember(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('StructureMember');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function data_node=genDataValue(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('DataValue');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function data_node=genDataValueMember(obj,parent_node,param_name_list,param_value_list)
            data_node=obj.createElement('DataValueMember');
            obj.addChild(parent_node,data_node);
            obj.setNodeParamList(data_node,param_name_list,param_value_list);
        end

        function elem_node=genArrayElem(obj,parent_node,idx)
            elem_node=obj.createElement('Element');
            obj.addChild(parent_node,elem_node);
            elem_node.setAttribute('Index',idx);
        end

        function addChildNode(obj,parent_node,child_node)
            obj.addChild(parent_node,child_node);
        end
        function genInitValue(obj,parent_node,val)
            import plccore.visitor.RockwellEmitter;
            import plccore.visitor.RockwellEmitter_InitialValueVisitor;
            val_node=obj.createElement('DataValue');
            typ_txt=RockwellEmitter.convertType(val.type);
            val_node.setAttribute('DataType',typ_txt);
            ivv=RockwellEmitter_InitialValueVisitor;
            val_txt=val.accept(ivv,[]);
            val_node.setAttribute('Value',val_txt);
            switch typ_txt
            case{'SINT','INT','DINT'}
                val_node.setAttribute('Radix','Decimal');
            end
            obj.addChild(parent_node,val_node);
        end

        function genVarInitValue(obj,parent_node,var)
            init_val=var.initialValue;
            if isempty(init_val)
                return;
            end
            if(obj.EmitAOI)
                data_node=obj.createElement('DefaultData');
            else
                data_node=obj.createElement('Data');
            end
            data_node.setAttribute('Format','Decorated');
            obj.addChild(parent_node,data_node);
            obj.genInitValue(data_node,init_val);
        end

        function genAOIParamNode(obj,var,type,io_type)
            parameterNode=obj.createElement('Parameter');
            obj.addChild(obj.AOITopParam,parameterNode);
            parameterNode.setAttribute('Name',var.name);
            parameterNode.setAttribute('Visible','true');
            parameterNode.setAttribute('DataType',type);
            parameterNode.setAttribute('Usage',io_type);
            parameterNode.setAttribute('Required','true');
            obj.genVarInitValue(parameterNode,var);
        end

        function genAOILocalNode(obj,var,type)
            localNode=obj.createElement('LocalTag');
            obj.addChild(obj.AOITopLocal,localNode);
            localNode.setAttribute('Name',var.name);
            localNode.setAttribute('DataType',type);
            localNode.setAttribute('ExternalAccess','None');
            obj.genVarInitValue(localNode,var);
        end

        function genProgTagNode(obj,var,type)
            tagNode=obj.createElement('Tag');
            obj.addChild(obj.ProgTopTag,tagNode);
            tagNode.setAttribute('Name',var.name);
            tagNode.setAttribute('DataType',type);
            tagNode.setAttribute('TagType','Base');
            obj.genVarInitValue(tagNode,var);
        end

        function genRung(obj,rung_idx,rung_code,rung_comment)
            rung=obj.createElement('Rung');
            obj.addChild(obj.CurrentPOULadder,rung);
            rung.setAttribute('Number',sprintf('%d',rung_idx));
            rung.setAttribute('Type','N');
            if~isempty(rung_comment)

                comment=obj.createElement('Comment');
                obj.addChild(rung,comment);
                rung_comment=obj.createText(rung_comment);
                obj.addChild(comment,rung_comment);
            end
            txt=obj.createElement('Text');
            obj.addChild(rung,txt);
            rung_code=obj.createText(rung_code);
            obj.addChild(txt,rung_code);
        end
    end
end


