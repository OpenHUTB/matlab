classdef AssertionManager<handle
    properties(Access=private)
AssertionInfoMap
AssertionBlkKeys

ObjHandleIdentifier
Namespace
    end

    properties(Access=private,Constant)

        svBitDefInC=sprintf(['typedef unsigned char svScalar;\n',...
        'typedef svScalar svBit;']);
        AssetInfoFunctionName='DPI_getAssertionInfo';

        AssertionInfoStructName='AssertionStructInfo';
        AssertionInfoStructArrayName='AssertionStructInfo_T';
        StatusType='bit';
        Status='Status';
        MessageType='string';
        Message='Message';
        SeverityType='Severity_T';
        Severity='Severity';

        Counter='counter';


        LoopIndex='idx';
    end

    properties(Access=private)
        LocalVar='A';

        SVSysCmd;

SeverityEnumType
        AssertionInfoStruct;
        AssertionInfoDT;


        EnumValues={'error','warning'};
    end

    methods
        function obj=AssertionManager(ModelName,dpig_config)

            HDLVAssertBlkInstanceInfo=getSIDOfAssertBlocksInModel(ModelName);





            if~isempty(HDLVAssertBlkInstanceInfo)&&strcmpi(dpig_config.BlockReduction,'on')
                warning(message('HDLLink:DPIG:NoAssertionsDueToBlockReduction'));
                HDLVAssertBlkInstanceInfo=containers.Map;
            elseif~isempty(HDLVAssertBlkInstanceInfo)&&strcmpi(dpig_config.OptimizeBlockIOStorage,'on')
                warning(message('HDLLink:DPIG:NoAssertionsDueToOptimizeBlockIOStorage'));
                HDLVAssertBlkInstanceInfo=containers.Map;
            end

            obj.Namespace=[ModelName,'_dpi',dpig.internal.GetSVFcn.getPackageFileSuffix()];
            obj.AssertionBlkKeys=HDLVAssertBlkInstanceInfo.keys();
            obj.AssertionInfoMap=containers.Map;
            obj.SVSysCmd=containers.Map(obj.EnumValues,{'$error','$warning'});
            for AssertionKeyIter=obj.AssertionBlkKeys
                AssertionKeyVal=AssertionKeyIter{1};
                OriginalSID=l_getOriginalSID(AssertionKeyVal);
                Severity=HDLVAssertBlkInstanceInfo(AssertionKeyVal).Severity;
                Message=HDLVAssertBlkInstanceInfo(AssertionKeyVal).Message;
                if strcmp(Severity,'custom')
                    Severity=l_getCustomSeverityEnum(OriginalSID,Severity);

                    obj.EnumValues=[obj.EnumValues,Severity];
                    obj.SVSysCmd(Severity)=Message;
                end
                InputLength=num2str(HDLVAssertBlkInstanceInfo(AssertionKeyVal).InputLength);
                obj.AssertionInfoMap(AssertionKeyVal)=dpig.internal.AssertionInfo(HDLVAssertBlkInstanceInfo(AssertionKeyVal).NativeAssertionBlkSID,...
                OriginalSID,...
                Message,...
                Severity,...
                InputLength,...
                dpig_config.IsExtendedObjhandleEnabled);

            end

            obj.ObjHandleIdentifier='objhandle';


            obj.AssertionInfoStruct=sprintf(['typedef struct{\n',...
            repmat('\t',1,1),'%s %s;\n',...
            repmat('\t',1,1),'%s %s;\n',...
            repmat('\t',1,1),'%s %s;\n',...
            '} %s;\n'],...
            obj.StatusType,obj.Status,...
            obj.MessageType,obj.Message,...
            obj.SeverityType,obj.Severity,...
            obj.AssertionInfoStructName);
            obj.AssertionInfoDT=sprintf('typedef %s %s [];',obj.AssertionInfoStructName,...
            obj.AssertionInfoStructArrayName);
            obj.SeverityEnumType=sprintf('typedef enum {%s} %s;\n',char(join(obj.EnumValues,',')),obj.SeverityType);
        end

        function str=getCDeclaration(obj,CodeConstruct)
            l_validatestring(CodeConstruct);
            CodeConstruct=l_validateCodeConstructType(CodeConstruct);
            if obj.NoAssertions()
                str='';
                return;
            end

            switch CodeConstruct
            case 'DataType'
                str=obj.svBitDefInC;
            case 'Function'
                str='';
                for AssertionKeyIter=obj.AssertionBlkKeys
                    AssertionKeyVal=AssertionKeyIter{1};
                    str=sprintf('%s%s;\n',str,obj.AssertionInfoMap(AssertionKeyVal).getCDeclaration('Status'));
                end
            end
        end

        function str=getCDefinition(obj,CodeConstruct,RTWType)
            l_validatestring(CodeConstruct);
            CodeConstruct=l_validateCodeConstructType(CodeConstruct);
            if obj.NoAssertions()
                str='';
                return;
            end
            switch CodeConstruct
            case 'Function'
                str='';
                for AssertionKeyIter=obj.AssertionBlkKeys
                    AssertionKeyVal=AssertionKeyIter{1};
                    str=sprintf('%s%s\n',str,obj.AssertionInfoMap(AssertionKeyVal).getCDefinition('Status',RTWType));
                end
            otherwise
                str='';
            end
        end

        function str=getSVDeclaration(obj,CodeConstruct,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;
            l_validatestring(CodeConstruct);
            CodeConstruct=l_validateCodeConstructType(CodeConstruct);
            if obj.NoAssertions()
                str='';
                return;
            end
            switch CodeConstruct
            case 'DataType'
                if~ExplicitNamespace
                    str=sprintf('%s %s;',obj.AssertionInfoStructArrayName,obj.LocalVar);
                else
                    str=sprintf('%s::%s %s;',obj.Namespace,obj.AssertionInfoStructArrayName,obj.LocalVar);
                end
            case 'Function'
                str='';
                for AssertionKeyIter=obj.AssertionBlkKeys
                    AssertionKeyVal=AssertionKeyIter{1};
                    str=sprintf('%s%s;\n',str,obj.AssertionInfoMap(AssertionKeyVal).getSVDeclaration('Status'));
                end
            end
        end

        function str=getSVDefinition(obj,CodeConstruct)
            l_validatestring(CodeConstruct);
            CodeConstruct=l_validateCodeConstructType(CodeConstruct);
            if obj.NoAssertions()
                str='';
                return;
            end
            switch CodeConstruct
            case 'Function'
                str='';

                for AssertionKeyIter=obj.AssertionBlkKeys
                    AssertionKeyVal=AssertionKeyIter{1};
                    for AssertionInfoTypeIter={'Message','Severity'}
                        str=sprintf('%s%s\n\n',str,obj.AssertionInfoMap(AssertionKeyVal).getSVDefinition(AssertionInfoTypeIter{1}));
                    end
                end


                str=sprintf('%s%s\n',str,obj.getAssertInformationFunctionDefinition());
            case 'DataType'
                str=sprintf('%s\n%s\n%s\n',obj.SeverityEnumType,obj.AssertionInfoStruct,obj.AssertionInfoDT);
            end
        end

        function str=getSVFunctionCall(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;
            if obj.NoAssertions()
                str='';
                return;
            end
            if~ExplicitNamespace
                str=sprintf('%s=%s(%s);',obj.LocalVar,obj.AssetInfoFunctionName,obj.ObjHandleIdentifier);
            else
                str=sprintf('%s=%s::%s(%s);',obj.LocalVar,obj.Namespace,obj.AssetInfoFunctionName,obj.ObjHandleIdentifier);
            end
        end

        function str=getAssertionStatements(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;
            if obj.NoAssertions()
                str='';
                return;
            end
            ForStart=sprintf('for(int %s=0;%s<%s.size();%s++)begin',...
            obj.LoopIndex,obj.LoopIndex,obj.LocalVar,obj.LoopIndex);
            CaseStart=sprintf('case(%s[%s].%s)',obj.LocalVar,obj.LoopIndex,obj.Severity);
            CaseBody=sprintf('%s',obj.getAssertionStatementBody(ExplicitNamespace));
            CaseEnd='endcase';
            ForEnd='end';
            str=sprintf('%s\n%s\n%s%s\n%s\n',...
            ForStart,CaseStart,CaseBody,CaseEnd,ForEnd);
        end
        function NoAssert=NoAssertions(obj)
            NoAssert=isempty(obj.AssertionBlkKeys);
        end
    end

    methods(Access=private)

        function str=getAssertionStatementBody(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;
            str='';
            for EnumValueIter=obj.EnumValues
                EnumValueKey=EnumValueIter{1};
                if any(strcmp(EnumValueKey,{'error','warning'}))
                    assertioncmd=sprintf('%s(%s[%s].%s);',obj.SVSysCmd(EnumValueKey),...
                    obj.LocalVar,obj.LoopIndex,obj.Message);
                else

                    assertioncmd=sprintf('%s',obj.SVSysCmd(EnumValueKey));
                end

                if~ExplicitNamespace
                    str=sprintf(['%s%s:\n',...
                    'begin\n',...
                    '\tassert(%s[%s].%s) else %s\n',...
                    'end\n'],...
                    str,...
                    EnumValueKey,...
                    obj.LocalVar,obj.LoopIndex,obj.Status,assertioncmd);
                else
                    str=sprintf(['%s%s::%s:\n',...
                    'begin\n',...
                    '\tassert(%s[%s].%s) else %s\n',...
                    'end\n'],...
                    str,...
                    obj.Namespace,EnumValueKey,...
                    obj.LocalVar,obj.LoopIndex,obj.Status,assertioncmd);
                end
            end
        end

        function str=getNumberOfAssertions(obj)
            str=num2str(obj.AssertionInfoMap.length());
        end

        function str=getAssertInfoToTempVarsAssignment(obj,AssertInfoObj)
            str='';
            for AssertInfoTypeIter={'Status','Message','Severity'}
                AssertInfoType=AssertInfoTypeIter{1};
                str=sprintf(['%s',repmat('\t',1,2),'%s[%s]=%s;\n'],str,...
                obj.(AssertInfoType),obj.Counter,AssertInfoObj.getSVFunctionCall(AssertInfoType));
            end
        end

        function str=getTempVarsToDynStructAssignment(obj)
            str='';
            for AssertInfoTypeIter={'Status','Message','Severity'}
                AssertInfoType=AssertInfoTypeIter{1};
                str=sprintf(['%s',repmat('\t',1,2),'%s[%s].%s=%s[%s];\n'],str,...
                obj.LocalVar,obj.LoopIndex,AssertInfoType,obj.(AssertInfoType),obj.LoopIndex);
            end
        end

        function str=getAssertInformationFunctionDefinition(obj)

            LocalVars=sprintf([repmat('\t',1,1),'%s %s [%s];\n',...
            repmat('\t',1,1),'%s %s [%s];\n',...
            repmat('\t',1,1),'%s %s [%s];\n',...
            repmat('\t',1,1),'%s %s;\n',...
            repmat('\t',1,1),'%s %s=0;\n'],...
            dpig.internal.AssertionInfo.ReturnDataType('Status','SV'),obj.Status,obj.getNumberOfAssertions(),...
            dpig.internal.AssertionInfo.ReturnDataType('Message','SV'),obj.Message,obj.getNumberOfAssertions(),...
            dpig.internal.AssertionInfo.ReturnDataType('Severity','SV'),obj.Severity,obj.getNumberOfAssertions(),...
            obj.AssertionInfoStructArrayName,obj.LocalVar,...
            'int',obj.Counter);

            AssertionCheck='';
            for AssertionKeyIter=obj.AssertionInfoMap.keys()
                AssertionKeyVal=AssertionKeyIter{1};
                AssertionCheck_Temp=sprintf([repmat('\t',1,1),'if(!%s && !%s) begin\n',...
                '%s',...
                repmat('\t',1,2),'%s++;\n',...
                repmat('\t',1,1),'end'],...
                obj.AssertionInfoMap(AssertionKeyVal).getSVFunctionCall('Status'),...
                obj.getRunTimeAssertCtrl(obj.AssertionInfoMap(AssertionKeyVal).AssertionID),...
                obj.getAssertInfoToTempVarsAssignment(obj.AssertionInfoMap(AssertionKeyVal)),...
                obj.Counter);
                AssertionCheck=sprintf('%s%s\n',AssertionCheck,AssertionCheck_Temp);
            end

            DynamicArrayDeclaration=sprintf([repmat('\t',1,1),'%s=new[%s];\n'],obj.LocalVar,obj.Counter);
            DynArraysInitializeLoop=sprintf([repmat('\t',1,1),'for(int %s=0;%s<%s;%s++)begin\n',...
            '%s',...
            repmat('\t',1,1),'end\n'],...
            obj.LoopIndex,obj.LoopIndex,obj.Counter,obj.LoopIndex,...
            obj.getTempVarsToDynStructAssignment());
            ReturnA=sprintf([repmat('\t',1,1),'return %s;\n'],obj.LocalVar);

            str=sprintf(['%s %s %s %s(%s %s %s);\n',...
            '%s',...
            '%s',...
            '%s',...
            '%s',...
            '%s',...
            '%s'],...
            dpig.internal.AssertionInfo.SVRoutineType('function','Start'),...
            dpig.internal.AssertionInfo.SVRoutineQualifier('automatic'),...
            obj.AssertionInfoStructArrayName,...
            obj.AssetInfoFunctionName,...
            dpig.internal.AssertionInfo.SVDirection('in'),...
            dpig.internal.AssertionInfo.ObjHandleType('SV'),...
            obj.ObjHandleIdentifier,...
            LocalVars,...
            AssertionCheck,...
            DynamicArrayDeclaration,...
            DynArraysInitializeLoop,...
            ReturnA,...
            dpig.internal.AssertionInfo.SVRoutineType('function','End'));
        end

        function str=getRunTimeAssertCtrl(~,AssertionID)
            str=sprintf('$test$plusargs("%s")',AssertionID);
        end
    end











end

function l_validatestring(str)
    validateattributes(str,{'char'},{'nonempty','scalartext'},'AssertionManager');
end

function str=l_validateCodeConstructType(CodeConstructType)
    str=validatestring(CodeConstructType,{'DataType','Function'});
end

function str=l_getOriginalSID(TempSID)
    SubSysPath=dpigenerator_getvariable('dpigSubsystemPath');



    if isempty(SubSysPath)
        str=TempSID;
    else
        str=strrep(TempSID,strtok(TempSID,':'),strtok(SubSysPath,'/'));
    end
end

function str=l_getCustomSeverityEnum(OriginalSID,Severity)
    str=[Severity,'_',strrep(OriginalSID,':','_')];
end

function str=l_getOriginalSIDFromCustomSeverityEnum(CustomSeverityEnum)
    Tempstr=split(CustomSeverityEnum,'_');
    Tempstr_horz=Tempstr';
    str=join([join(Tempstr_horz(2:end-1),'_'),Tempstr_horz(end)],':');
end
