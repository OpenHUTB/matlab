classdef AssertionInfo<handle
    properties(Access=private)
ObjHandleIdentifier
SID_Original
SID_Temp
Message
Severity
InputLength

IsExtendedObjhandleEnabled
    end

    properties
AssertionID
    end

    properties(Access=private,Constant)
        DWorksAccessMacro='rtmGetRootDWork';
        DPIPrefix='DPI_';

        ObjHandle='objhandle';
        E_ObjHandle='e_objhandle';
    end

    methods
        function obj=AssertionInfo(SID_Temporary,SID_Original,Message,Severity,InputLength,IsExtendedObjhandleEnabled)
            l_validatestring(SID_Temporary);
            l_validatestring(SID_Original);
            l_validatestring(Message);
            l_validatestring(Severity);

            obj.SID_Original=SID_Original;
            obj.SID_Temp=SID_Temporary;
            obj.Message=Message;
            obj.Severity=Severity;
            obj.ObjHandleIdentifier='objhandle';
            obj.AssertionID=SID_Original;
            obj.InputLength=InputLength;
            obj.IsExtendedObjhandleEnabled=IsExtendedObjhandleEnabled;
        end

        function str=getCDeclaration(obj,AssertInfoType)
            l_validatestring(AssertInfoType);
            AssertInfoType=l_validateAssertionFcnType(AssertInfoType);
            switch AssertInfoType
            case 'Status'
                str=sprintf('%s %s %s(%s %s)',...
                obj.LinkageSpec('C'),...
                obj.ReturnDataType(AssertInfoType,'C'),...
                obj.getAssertStatusFunctionName(),...
                obj.ObjHandleType('C'),...
                obj.ObjHandle);
            otherwise
                str='';
            end
        end

        function str=getCDefinition(obj,AssertInfoType,RTWType)
            l_validatestring(AssertInfoType);
            AssertInfoType=l_validateAssertionFcnType(AssertInfoType);
            switch AssertInfoType
            case 'Status'
                str=sprintf(['%s %s %s(%s %s){\n',...
                '%s;\n}'],...
                obj.LinkageSpec('C'),...
                obj.ReturnDataType(AssertInfoType,'C'),...
                obj.getAssertStatusFunctionName(),...
                obj.ObjHandleType('C'),...
                obj.getActiveObjHandle(),...
                obj.getAssertStatusFunctionDefinition(RTWType));
            otherwise
                str='';
            end
        end

        function str=getSVDeclaration(obj,AssertInfoType)
            l_validatestring(AssertInfoType);
            AssertInfoType=l_validateAssertionFcnType(AssertInfoType);
            switch AssertInfoType
            case 'Status'
                str=sprintf('%s %s%s %s %s(%s %s %s)',...
                obj.LinkageSpec('SV'),...
                obj.SVRoutineQualifier('None'),...
                obj.SVRoutineType('Function','Start'),...
                obj.ReturnDataType(AssertInfoType,'SV'),...
                obj.getAssertStatusFunctionName(),...
                obj.SVDirection('in'),...
                obj.ObjHandleType('SV'),...
                obj.ObjHandle);
            otherwise
                str='';
            end
        end

        function str=getSVDefinition(obj,AssertInfoType)
            l_validatestring(AssertInfoType);
            AssertInfoType=l_validateAssertionFcnType(AssertInfoType);
            switch AssertInfoType
            case 'Status'
                str='';
            case 'Message'
                str=sprintf(['%s%s %s %s();\n',...
                '%s\n',...
                '%s'],...
                obj.SVRoutineQualifier('None'),...
                obj.SVRoutineType('Function','Start'),...
                obj.ReturnDataType(AssertInfoType,'SV'),...
                obj.getAssertMessageFunctionName(),...
                obj.getAssertMessageFunctionDefinition,...
                obj.SVRoutineType('Function','End'));

            case 'Severity'
                str=sprintf(['%s%s %s %s();\n',...
                '%s\n',...
                '%s'],...
                obj.SVRoutineQualifier('None'),...
                obj.SVRoutineType('Function','Start'),...
                obj.ReturnDataType(AssertInfoType,'SV'),...
                obj.getAssertSeverityFunctionName(),...
                obj.getAssertSeverityFunctionDefinition,...
                obj.SVRoutineType('Function','End'));
            otherwise
                str='';

            end
        end

        function str=getSVFunctionCall(obj,AssertInfoType)
            l_validatestring(AssertInfoType);
            AssertInfoType=l_validateAssertionFcnType(AssertInfoType);
            switch AssertInfoType
            case 'Status'
                str=sprintf('%s(%s)',obj.getAssertStatusFunctionName(),...
                obj.ObjHandle);
            case 'Message'
                str=sprintf('%s()',obj.getAssertMessageFunctionName());
            case 'Severity'
                str=sprintf('%s()',obj.getAssertSeverityFunctionName());
            otherwise
                str='';
            end
        end
    end

    methods(Access=private)
        function str=LinkageSpec(~,Language)
            switch Language
            case 'C'
                str='DPI_DLL_EXPORT';
            case 'SV'
                str='import "DPI-C"';
            otherwise
                str='';
            end
        end

        function str=getActiveObjHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                str=obj.E_ObjHandle;
            else
                str=obj.ObjHandle;
            end
        end

        function str=getAssertStatusFunctionName(obj)
            str=[obj.DPIPrefix,l_getValidSVNameFromSLSID(obj.SID_Original)];
        end

        function str=getAssertMessageFunctionName(obj)
            str=[obj.getAssertStatusFunctionName(),'_Message'];
        end

        function str=getAssertSeverityFunctionName(obj)
            str=[obj.getAssertStatusFunctionName(),'_Severity'];
        end



        function str=getAssertStatusFunctionDefinition(obj,RTWType)
            str=sprintf('%s (%s)%s','return',obj.ReturnDataType('Status','C'),obj.getAssertStatusExp(RTWType));
        end

        function str=getAssertMessageFunctionDefinition(obj)
            if any(strcmp(obj.Severity,{'error','warning'}))
                str=sprintf('\t%s "%s:%s";','return',obj.AssertionID,obj.Message);
            else
                str=sprintf('\t%s "%s";','return',obj.AssertionID);
            end
        end

        function str=getAssertSeverityFunctionDefinition(obj)
            str=sprintf('\t%s %s;','return',obj.Severity);
        end

        function str=getAssertStatusExp(obj,RTWType)
            if str2double(obj.InputLength)>1

                str='';
                PostFix=' &&\n';
                for idx=1:str2double(obj.InputLength)
                    if str2double(obj.InputLength)==idx
                        PostFix='';
                    end
                    str=sprintf(['%s%s[%s]',PostFix],str,obj.getDWorkAddress(RTWType),num2str(idx-1));
                end


                str=sprintf('(%s)',str);
            else

                str=obj.getDWorkAddress(RTWType);
            end
        end

        function str=getDWorkAddress(obj,RTWType)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('%s(((%s*)%s)->%s)->%s',obj.DWorksAccessMacro,RTWType,obj.E_ObjHandle,obj.ObjHandle,l_getValidDWorkNameFromSLSID(obj.SID_Temp));
            else
                str=sprintf('%s((%s*)%s)->%s',obj.DWorksAccessMacro,RTWType,obj.ObjHandle,l_getValidDWorkNameFromSLSID(obj.SID_Temp));
            end
        end
    end

    methods(Static)
        function str=SVRoutineType(RoutineType,Section)
            switch Section
            case 'Start'
                if strcmpi(RoutineType,'function')
                    str='function';
                else
                    str='task';
                end
            case 'End'
                if strcmpi(RoutineType,'function')
                    str='endfunction';
                else
                    str='endtask';
                end
            otherwise
                str='';
            end
        end

        function str=SVDirection(dir)
            if strcmpi(dir,'in')
                str='input';
            else
                str='output';
            end
        end

        function str=ObjHandleType(Language)
            if strcmpi(Language,'C')
                str='void*';
            else
                str='chandle';
            end
        end

        function str=SVRoutineQualifier(qualifier)
            if strcmpi(qualifier,'Pure')
                str='pure ';
            elseif strcmpi(qualifier,'Automatic')
                str='automatic ';
            else
                str='';
            end
        end

        function str=ReturnDataType(AssertionInfoType,Language)
            IsCLang=strcmpi(Language,'C');
            switch AssertionInfoType
            case 'Status'
                if IsCLang
                    str='svBit';
                else
                    str='bit';
                end
            case 'Message'
                if IsCLang
                    str='char*';
                else
                    str='string';
                end
            case 'Severity'

                str='Severity_T';
            end
        end

    end

end

function l_validatestring(str)
    validateattributes(str,{'char'},{'scalartext'},'AssertionInfo');
end

function str=l_validateAssertionFcnType(AssertInfoType)
    str=validatestring(AssertInfoType,{'Status','Message','Severity'});
end

function str=l_getValidSVNameFromSLSID(SLSID)
    str=strrep(SLSID,':','_');
end

function str=l_getValidDWorkNameFromSLSID(SLSID)
    SID_Compact=extractAfter(SLSID,':');
    assert(~isempty(SID_Compact),'Wrong SID format.');

    SID_Compact=strrep(SID_Compact,':','_');
    str=['SV_DPIC_ASSERT_',SID_Compact];
end


