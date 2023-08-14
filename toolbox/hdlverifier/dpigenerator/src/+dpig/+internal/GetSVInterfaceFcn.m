

classdef GetSVInterfaceFcn<dpig.internal.GetSVFcn

    properties(Access=private)
        InterfaceId='vif';
        InterfaceType='vif_t';
    end

    methods
        function obj=GetSVInterfaceFcn(codeInfo,varargin)
            obj=obj@dpig.internal.GetSVFcn(codeInfo,varargin{:});
            obj.IdInterfacePrefix=[obj.InterfaceId,'.'];
            obj.NeedsTempPostFix=false;
        end
    end


    methods
        function str=getResetFcnCall(obj)
            str=getResetFcnCall@dpig.internal.GetSVFcn(obj,false,false,false);
        end

        function str=getOutputFcnCall(obj)
            str=getOutputFcnCall@dpig.internal.GetSVFcn(obj,false,false,false);
        end
    end


    methods
        function str=DeclarePortsInterface(obj)
            obj.NeedsTempPostFix=false;
            if strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')

                CtrlSigList=obj.getCtrlSigList();
            else
                CtrlSigList='';
            end
            str=sprintf(['interface %s;\n',...
            '%s\n',...
            '%s\n',...
            '%s\n',...
            'endinterface'],...
            obj.InterfaceType,...
            CtrlSigList,...
            obj.getInputSignalsList(),...
            obj.getOutputSignalsList());
        end

        function str=getCtrlSigList(obj)
            str='';
            for idx=1:length(obj.mCodeInfo.CtrlSigStruct)
                CtrlSig_decl_temp=sprintf('%s %s;\n','bit',obj.mCodeInfo.CtrlSigStruct(idx).Name);
                str=[str,CtrlSig_decl_temp];%#ok<AGROW>
            end
        end
    end


    methods
        function str=getOutputTempVarDecl(obj)
            str='';
        end

        function str=getNBVarAssignmentFromTmpToActual(obj)
            str='';
        end


        function str=getPortDeclList(obj)
            str=sprintf('%s %s',obj.InterfaceType,obj.InterfaceId);
        end
        function str=getClockId(obj)


            str=sprintf('%s.%s',obj.InterfaceId,obj.mCodeInfo.CtrlSigStruct(1).Name);
        end

        function str=getClockEnId(obj)
            str=sprintf('%s.%s',obj.InterfaceId,obj.mCodeInfo.CtrlSigStruct(2).Name);
        end

        function str=getResetId(obj)
            str=sprintf('%s.%s',obj.InterfaceId,obj.mCodeInfo.CtrlSigStruct(3).Name);
        end
    end


    methods
        function str=getInterfaceId(obj)
            str=obj.InterfaceId;
        end

        function str=getInterfaceType(obj)
            str=obj.InterfaceType;
        end
    end

end
