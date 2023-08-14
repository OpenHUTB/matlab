



classdef ReportConfig
    properties

        ColorTable;
        SchemeTable;
        WeightTable;
        TextTable;
        TopVerStatusTable;
        TopTraceTable;
        TopStatusTable;
        VStatusTable;
        TraceTable;
        TraceText;
        VTextTable;
        ITextTable;
        PreColored=true;


        defaultSection='';
        defaultTable='';
        defaultFunction='Not applicable';
        defaultStatus='UNKNOWN';
        defaultScheme='user0';
        defaultWeight=0;
        RepModelName=[slci.internal.encodeString('<','html','encode')...
        ,'model',slci.internal.encodeString('>','html','encode')];
    end

    methods

        function obj=ReportConfig()








            obj.ColorTable=containers.Map;
            obj.ColorTable('user0')='black';
            obj.ColorTable('user1')='green';

            obj.ColorTable('user2')='#caad00';
            obj.ColorTable('user3')='red';

            obj.ColorTable('user4')='#0d60a0';

            obj.SchemeTable=containers.Map;
            obj.SchemeTable('UNKNOWN')='user0';
            obj.SchemeTable('NON_FUNCTIONAL')='user0';
            obj.SchemeTable('NOT_PROCESSED')='user0';
            obj.SchemeTable('VERIFIED')='user1';
            obj.SchemeTable('TRACED')='user1';
            obj.SchemeTable('PARTIALLY_VERIFIED')='user2';
            obj.SchemeTable('PARTIALLY_TRACED')='user2';
            obj.SchemeTable('PARTIALLY_PROCESSED')='user2';
            obj.SchemeTable('UNABLE_TO_PROCESS')='user2';
            obj.SchemeTable('UNEXPECTED')='user2';
            obj.SchemeTable('WAW')='user2';
            obj.SchemeTable('MANUAL')='user2';
            obj.SchemeTable('JUSTIFIED')='user4';

            obj.SchemeTable('UNEXPECTEDDEF')='user3';
            obj.SchemeTable('UNEXPECTEDFUNC')='user3';
            obj.SchemeTable('FAILED_TO_VERIFY')='user3';
            obj.SchemeTable('FAILED_TO_TRACE')='user3';
            obj.SchemeTable('ERROR')='user3';

            obj.SchemeTable('PASSED')='user1';
            obj.SchemeTable('WARNING')='user2';
            obj.SchemeTable('FAILED')='user3';






            obj.WeightTable=containers.Map;
            obj.WeightTable('UNKNOWN')=0;
            obj.WeightTable('NOT_PROCESSED')=1;
            obj.WeightTable('NON_FUNCTIONAL')=0;
            obj.WeightTable('OPTIMIZED')=1;
            obj.WeightTable('PASSED')=2;
            obj.WeightTable('VERIFIED')=3;
            obj.WeightTable('TRACED')=3;
            obj.WeightTable('UPSTREAM')=10;
            obj.WeightTable('PARTIALLY_PROCESSED')=12;
            obj.WeightTable('PARTIALLY_VERIFIED')=13;
            obj.WeightTable('PARTIALLY_TRACED')=13;
            obj.WeightTable('UNABLE_TO_PROCESS')=14;
            obj.WeightTable('WARNING')=15;
            obj.WeightTable('UNEXPECTED')=16;
            obj.WeightTable('UNEXPECTEDDEF')=17;
            obj.WeightTable('WAW')=18;
            obj.WeightTable('MANUAL')=18;
            obj.WeightTable('UNEXPECTEDFUNC')=19;
            obj.WeightTable('FAIL')=22;
            obj.WeightTable('ERROR')=25;
            obj.WeightTable('FAILED_TO_VERIFY')=26;
            obj.WeightTable('FAILED_TO_TRACE')=26;
            obj.WeightTable('FAILED')=27;
            obj.WeightTable('JUSTIFIED')=9;


            obj.TextTable=containers.Map;
            obj.TextTable('TRACED')='Traced';
            obj.TextTable('PARTIALLY_TRACED')='Partially traced';
            obj.TextTable('FAILED_TO_TRACE')='Failed to trace';
            obj.TextTable('VERIFIED')='Verified';
            obj.TextTable('PARTIALLY_VERIFIED')='Partially verified';
            obj.TextTable('FAILED_TO_VERIFY')='Failed to verify';
            obj.TextTable('PARTIALLY_PROCESSED')='Partially processed';
            obj.TextTable('NOT_PROCESSED')='Not processed';
            obj.TextTable('UNABLE_TO_PROCESS')='Unable to process';
            obj.TextTable('ERROR')='Error';
            obj.TextTable('UNKNOWN')='-';
            obj.TextTable('NON_FUNCTIONAL')='Nonfunctional code';
            obj.TextTable('PASSED')='Passed';
            obj.TextTable('FAILED')='Failed';
            obj.TextTable('WARNING')='Warning';
            obj.TextTable('UNEXPECTED')='Inconsequential';
            obj.TextTable('UNEXPECTEDFUNC')='Unexpected Function Call';
            obj.TextTable('UNEXPECTEDDEF')='Unexpected Definition';
            obj.TextTable('WAW')='Write after write';
            obj.TextTable('MANUAL')='Needs manual review';
            obj.TextTable('JUSTIFIED')='Justified';


            obj.TopVerStatusTable=containers.Map;
            obj.TopVerStatusTable('UNKNOWN')='UNKNOWN';
            obj.TopVerStatusTable('VERIFIED')='VERIFIED';
            obj.TopVerStatusTable('NON_FUNCTIONAL')='VERIFIED';
            obj.TopVerStatusTable('PARTIALLY_PROCESSED')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('NOT_PROCESSED')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('UNABLE_TO_PROCESS')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('UNEXPECTED')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('MANUAL')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('JUSTIFIED')='JUSTIFIED';

            obj.TopVerStatusTable('WAW')='PARTIALLY_VERIFIED';
            obj.TopVerStatusTable('UNEXPECTEDFUNC')='FAILED_TO_VERIFY';
            obj.TopVerStatusTable('UNEXPECTEDDEF')='FAILED_TO_VERIFY';
            obj.TopVerStatusTable('FAILED_TO_VERIFY')='FAILED_TO_VERIFY';
            obj.TopVerStatusTable('ERROR')='FAILED_TO_VERIFY';

            obj.TopTraceTable=containers.Map;
            obj.TopTraceTable('UNKNOWN')='UNKNOWN';
            obj.TopTraceTable('TRACED')='TRACED';
            obj.TopTraceTable('NON_FUNCTIONAL')='TRACED';
            obj.TopTraceTable('NOT_PROCESSED')='TRACED';
            obj.TopTraceTable('PARTIALLY_PROCESSED')='PARTIALLY_TRACED';
            obj.TopTraceTable('UNABLE_TO_PROCESS')='PARTIALLY_TRACED';
            obj.TopTraceTable('UNEXPECTED')='PARTIALLY_TRACED';
            obj.TopTraceTable('MANUAL')='PARTIALLY_TRACED';
            obj.TopTraceTable('JUSTIFIED')='JUSTIFIED';

            obj.TopTraceTable('WAW')='PARTIALLY_TRACED';
            obj.TopTraceTable('UNEXPECTEDDEF')='FAILED_TO_TRACE';
            obj.TopTraceTable('UNEXPECTEDFUNC')='FAILED_TO_TRACE';
            obj.TopTraceTable('FAILED_TO_TRACE')='FAILED_TO_TRACE';

            obj.TopStatusTable=containers.Map;
            obj.TopStatusTable('UNKNOWN')='UNKNOWN';
            obj.TopStatusTable('VERIFIED')='PASSED';
            obj.TopStatusTable('TRACED')='PASSED';
            obj.TopStatusTable('PARTIALLY_VERIFIED')='WARNING';
            obj.TopStatusTable('PARTIALLY_TRACED')='WARNING';
            obj.TopStatusTable('UNEXPECTED')='WARNING';
            obj.TopStatusTable('MANUAL')='WARNING';
            obj.TopStatusTable('JUSTIFIED')='JUSTIFIED';

            obj.TopStatusTable('WAW')='WARNING';
            obj.TopStatusTable('UNEXPECTEDDEF')='FAILED';
            obj.TopStatusTable('UNEXPECTEDFUNC')='FAILED';
            obj.TopStatusTable('FAILED_TO_TRACE')='FAILED';
            obj.TopStatusTable('FAILED_TO_VERIFY')='FAILED';


            obj.VStatusTable=containers.Map;
            obj.VStatusTable('PASSED')='VERIFIED';
            obj.VStatusTable('OPTIMIZED')='VERIFIED';
            obj.VStatusTable('VIRTUAL')='VERIFIED';
            obj.VStatusTable('INLINED')='VERIFIED';
            obj.VStatusTable('ROOTINPORT')='VERIFIED';
            obj.VStatusTable('PREPROCESSOR')='VERIFIED';
            obj.VStatusTable('EXPECTED_EMPTY_FUNCTION')='VERIFIED';
            obj.VStatusTable('FAILED_TO_VERIFY')='FAILED_TO_VERIFY';
            obj.VStatusTable('UNEXPECTED')='UNEXPECTED';
            obj.VStatusTable('UNEXPECTEDDEF')='UNEXPECTEDDEF';
            obj.VStatusTable('UNEXPECTEDFUNC')='FAILED_TO_VERIFY';
            obj.VStatusTable('WAW')='WAW';
            obj.VStatusTable('MANUAL')='MANUAL';
            obj.VStatusTable('JUSTIFIED')='JUSTIFIED';

            obj.VStatusTable('FAIL')='FAILED_TO_VERIFY';
            obj.VStatusTable('UNDEFINED_FUNCTION')='FAILED_TO_VERIFY';
            obj.VStatusTable('MISSING_FUNCTION_CODE')='FAILED_TO_VERIFY';
            obj.VStatusTable('UPSTREAM')='UNABLE_TO_PROCESS';
            obj.VStatusTable('UNSUPPORTED')='UNABLE_TO_PROCESS';
            obj.VStatusTable('INCOMPATIBLE')='UNABLE_TO_PROCESS';
            obj.VStatusTable('UNABLE_TO_PROCESS')='UNABLE_TO_PROCESS';
            obj.VStatusTable('EMPTY_LINE')='NON_FUNCTIONAL';
            obj.VStatusTable('COMMENT')='NON_FUNCTIONAL';
            obj.VStatusTable('KEYWORD')='NON_FUNCTIONAL';
            obj.VStatusTable('OPEN_BRACKET')='NON_FUNCTIONAL';
            obj.VStatusTable('CLOSE_BRACKET')='NON_FUNCTIONAL';
            obj.VStatusTable('SEMICOLON')='NON_FUNCTIONAL';
            obj.VStatusTable('LOCAL_DECLARATION')='NON_FUNCTIONAL';
            obj.VStatusTable('OUT_OF_SCOPE')='NOT_PROCESSED';
            obj.VStatusTable('INCLUDE')='NOT_PROCESSED';
            obj.VStatusTable('ERROR')='ERROR';
            obj.VStatusTable('INVALID')='ERROR';

            obj.VTextTable=containers.Map;
            obj.VTextTable('PASSED')='Passed';
            obj.VTextTable('VIRTUAL')='Virtual/Eliminated';
            obj.VTextTable('INLINED')='Inlined';
            obj.VTextTable('OPTIMIZED')='';
            obj.VTextTable('ROOTINPORT')='Virtual/Eliminated';
            obj.VTextTable('FAILED_TO_VERIFY')='Unable to match';
            obj.VTextTable('UNEXPECTEDFUNC')='Unexpected function call';
            obj.VTextTable('UNEXPECTEDDEF')='Unexpected definition';
            obj.VTextTable('UNEXPECTED')='Inconsequential code path';
            obj.VTextTable('WAW')='Write after write code';
            obj.VTextTable('MANUAL')='Code needs manual review';
            obj.VTextTable('JUSTIFIED')='Justified';

            obj.VTextTable('UPSTREAM')='Upstream';
            obj.VTextTable('UNSUPPORTED')='Unsupported';
            obj.VTextTable('INCOMPATIBLE')='Incompatible';
            obj.VTextTable('FAIL')='Failed';
            obj.VTextTable('ERROR')='Inspection error occurred';
            obj.VTextTable('EMPTY_LINE')='Empty line';
            obj.VTextTable('COMMENT')='Comment';
            obj.VTextTable('KEYWORD')='Keyword';
            obj.VTextTable('OUT_OF_SCOPE')='Out of SLCI verification scope';
            obj.VTextTable('INCLUDE')='Include statement';
            obj.VTextTable('PREPROCESSOR')='Preprocessor statement';
            obj.VTextTable('OPEN_BRACKET')='Start of code segment';
            obj.VTextTable('CLOSE_BRACKET')='End of code segment';
            obj.VTextTable('SEMICOLON')='Empty line';
            obj.VTextTable('LOCAL_DECLARATION')='Local variable declaration';
            obj.VTextTable('EXPECTED_EMPTY_FUNCTION')=message('Slci:report:EmptyCodeFunctionPass').getString;
            obj.VTextTable('MISSING_FUNCTION_CODE')=message('Slci:report:EmptyCodeFunctionMissingCode').getString;
            obj.VTextTable('UNDEFINED_FUNCTION')=message('Slci:report:EmptyCodeFunctionMissingDefinition').getString;

            obj.ITextTable=containers.Map;
            obj.ITextTable('PASSED')='-';
            obj.ITextTable('FAIL')='Failed';
            obj.ITextTable('NUMARG_MISMATCH')='Unexpected number of arguments';
            obj.ITextTable('ARGTYPE_MISMATCH')='Argument type mismatch';
            obj.ITextTable('ARGNAME_MISMATCH')='Argument name mismatch';
            obj.ITextTable('RETURNTYPE_MISMATCH')='Return type mismatch';
            obj.ITextTable('UNDEFINED')='Undefined function interface';
            obj.ITextTable('UNEXPECTED')='Unexpected function interface';
            obj.ITextTable('SIGNATURE_ERROR')='Unexpected function signature';

            obj.TraceTable=containers.Map;
            obj.TraceTable('TRACED')='TRACED';
            obj.TraceTable('JUSTIFIED')='JUSTIFIED';
            obj.TraceTable('VIRTUAL')='TRACED';
            obj.TraceTable('INLINED')='TRACED';
            obj.TraceTable('ROOTINPORT')='TRACED';
            obj.TraceTable('COMMENT')='NON_FUNCTIONAL';
            obj.TraceTable('KEYWORD')='NON_FUNCTIONAL';
            obj.TraceTable('EMPTY_LINE')='NON_FUNCTIONAL';
            obj.TraceTable('OPEN_BRACKET')='NON_FUNCTIONAL';
            obj.TraceTable('CLOSE_BRACKET')='NON_FUNCTIONAL';
            obj.TraceTable('SEMICOLON')='NON_FUNCTIONAL';
            obj.TraceTable('UNSUPPORTED')='UNABLE_TO_PROCESS';
            obj.TraceTable('INCOMPATIBLE')='UNABLE_TO_PROCESS';
            obj.TraceTable('OUT_OF_SCOPE')='NOT_PROCESSED';
            obj.TraceTable('INCLUDE')='NOT_PROCESSED';
            obj.TraceTable('PREPROCESSOR')='NON_FUNCTIONAL';
            obj.TraceTable('FAIL')='FAILED_TO_TRACE';
            obj.TraceTable('ERROR')='ERROR';
            obj.TraceTable('OPTIMIZED')='TRACED';
            obj.TraceTable('LOCAL_DECLARATION')='TRACED';

            obj.TraceTable('VERIFICATION_UNABLE_TO_PROCESS')='UNABLE_TO_PROCESS';
            obj.TraceTable('VERIFICATION_NOTPROCESSED')='NOT_PROCESSED';
            obj.TraceTable('VERIFICATION_FAILED_TO_VERIFY')='FAILED_TO_TRACE';
            obj.TraceTable('VERIFICATION_PARTIALLY_PROCESSED')='PARTIALLY_PROCESSED';
            obj.TraceTable('VERIFICATION_UNEXPECTED')='PARTIALLY_PROCESSED';
            obj.TraceTable('VERIFICATION_WAW')='PARTIALLY_PROCESSED';
            obj.TraceTable('VERIFICATION_MANUAL')='PARTIALLY_PROCESSED';
            obj.TraceTable('VERIFICATION_JUSTIFIED')='JUSTIFIED';

            obj.TraceTable('VERIFICATION_UNEXPECTEDDEF')='FAILED_TO_TRACE';
            obj.TraceTable('VERIFICATION_UNEXPECTEDFUNC')='FAILED_TO_TRACE';

            obj.TraceText=containers.Map;
            obj.TraceText('TRACED')='';
            obj.TraceText('JUSTIFIED')='Justified';
            obj.TraceText('VIRTUAL')='Virtual/Eliminated';
            obj.TraceText('INLINED')='Inlined';
            obj.TraceText('ROOTINPORT')='Virtual/Eliminated';
            obj.TraceText('UNSUPPORTED')='Unsupported';
            obj.TraceText('INCOMPATIBLE')='Incompatible';
            obj.TraceText('KEYWORD')='Keyword';
            obj.TraceText('COMMENT')='Comment';
            obj.TraceText('EMPTY_LINE')='Empty line';
            obj.TraceText('OUT_OF_SCOPE')='Out of SLCI verification scope';
            obj.TraceText('INCLUDE')='Include statement';
            obj.TraceText('PREPROCESSOR')='Preprocessor statement';
            obj.TraceText('OPEN_BRACKET')='Start of code segment';
            obj.TraceText('CLOSE_BRACKET')='End of code segment';
            obj.TraceText('SEMICOLON')='Empty line';
            obj.TraceText('NOT_PROCESSED')='Not processed';
            obj.TraceText('FAIL')='Failed';
            obj.TraceText('ERROR')='Error';
            obj.TraceText('OPTIMIZED')=...
            'Optimized out';
            obj.TraceText('LOCAL_DECLARATION')='Local variable declaration';
            obj.TraceText('VERIFICATION_FAILED_TO_VERIFY')=...
            'Verification status : Failed to verify';
            obj.TraceText('VERIFICATION_NOTPROCESSED')=...
            'Verification status : Not processed';
            obj.TraceText('VERIFICATION_UNABLE_TO_PROCESS')=...
            'Verification status : Unable to process';
            obj.TraceText('VERIFICATION_PARTIALLY_PROCESSED')=...
            'Verification status : Partially processed';
            obj.TraceText('VERIFICATION_UNEXPECTED')='Verification status : Inconsequential code';
            obj.TraceText('VERIFICATION_UNEXPECTEDDEF')='Verification status : Unexpected definition';
            obj.TraceText('VERIFICATION_WAW')='Verification status : Write after write';
            obj.TraceText('VERIFICATION_MANUAL')='Verification status : Needs manual review';
            obj.TraceText('VERIFICATION_JUSTIFIED')='Verification status : Justified';

        end

        function status=getStatus(obj,VStatus)

            status=obj.VStatusTable(VStatus);
        end

        function tStatus=getTraceabilityStatus(obj,trace)

            tStatus=obj.TraceTable(trace);
        end

        function color=getSlColor(obj,key)
            scheme=obj.getScheme(key);
            color=obj.getSchemeColor(scheme);
        end

        function scheme=getScheme(obj,status)
            if isKey(obj.SchemeTable,status)
                scheme=obj.SchemeTable(status);
            else
                scheme=obj.defaultScheme;
            end
        end

        function color=getSchemeColor(obj,scheme)
            if isKey(obj.ColorTable,scheme)
                color=obj.ColorTable(scheme);
            else
                color=obj.ColorTable(obj.defaultScheme);
            end
        end

        function color=getHtmlColor(obj,key)
            color=['color:',obj.getSlColor(key)];
        end

        function obj=setIsPreColored(obj,val)
            obj.PreColored=val;
        end

        function result=isPreColored(obj)
            result=obj.PreColored;
        end

        function color_table=getColorTable(obj)
            color_table=obj.ColorTable;
        end

        function scheme_list=getSchemeList(obj)
            scheme_list=keys(obj.ColorTable);
        end

        function scheme_list=getSpanList(obj)
            scheme_list=keys(obj.SchemeTable);
        end

        function topStatus=getTopVerStatus(obj,status)
            if isKey(obj.TopVerStatusTable,status)
                topStatus=obj.TopVerStatusTable(status);
            else
                exception=MException('ReportConfig:getTopStatus',...
                ['Unknown status ',status]);
                throw(exception);
            end
        end

        function topStatus=getTopTraceStatus(obj,status)
            if isKey(obj.TopTraceTable,status)
                topStatus=obj.TopTraceTable(status);
            else
                exception=MException('ReportConfig:getTopStatus',...
                ['Unknown trace status ',status]);
                throw(exception);
            end
        end

        function combinedStatus=getMainStatus(obj,status)
            if isKey(obj.TopStatusTable,status)
                combinedStatus=obj.TopStatusTable(status);
            else
                exception=MException('ReportConfig:getCombinedStatus',...
                ['Unknown status ',status]);
                throw(exception);
            end
        end


        function status_list=getStatusList(obj)%#ok
            status_list={'VERIFIED','NOT_PROCESSED',...
            'PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
            'FAILED_TO_VERIFY'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getModelVerStatusList(obj)%#ok
            status_list={'VERIFIED','PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
            'FAILED_TO_VERIFY'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getCodeVerStatusList(obj)%#ok
            status_list={'VERIFIED','PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
            'FAILED_TO_VERIFY','WAW','UNEXPECTED','UNEXPECTEDDEF','MANUAL'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getTempVerStatusList(obj)%#ok
            status_list={'FAILED_TO_VERIFY','VERIFIED'};
        end

        function status_list=getCodeTraceStatusList(obj)%#ok
            status_list={'TRACED','NON_FUNCTIONAL','NOT_PROCESSED',...
            'PARTIALLY_PROCESSED','UNABLE_TO_PROCESS','FAILED_TO_TRACE'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getModelTraceStatusList(obj)%#ok
            status_list={'TRACED','PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
            'FAILED_TO_TRACE'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function weight=getStatusWeight(obj,status)
            if isKey(obj.WeightTable,status)
                weight=obj.WeightTable(status);
            else
                exception=MException('ReportConfig:getStatusWeight',...
                ['Unknown verification status ',status]);
                throw(exception);
            end
        end


        function status=getHeaviestStatus(obj,varargin)

            statusArray=varargin;
            status=getHeaviest(obj,statusArray);
        end


        function status=getHeaviest(obj,statusArray)

            if~isempty(statusArray)
                if iscolumn(statusArray)
                    statusArray=statusArray';
                end
                currWts=cellfun(@(x)obj.getStatusWeight(x),statusArray,...
                'UniformOutput',true);
                [~,maxWtIdx]=max(currWts);
                status=statusArray{maxWtIdx};
            else
                status=obj.defaultStatus;
            end

            if strcmp(status,'UNABLE_TO_PROCESS')
                checkForPass=strcmp('VERIFIED',statusArray);
                if any(checkForPass)
                    status='PARTIALLY_PROCESSED';
                else
                    checkForTraced=strcmp('TRACED',statusArray);
                    if any(checkForTraced)
                        status='PARTIALLY_PROCESSED';
                    end
                end
            end
        end

        function statusMsg=getStatusMessage(obj,status)

            statusMsg=obj.TextTable(status);
        end

        function reasonMsg=getReasonMessage(obj,reason)

            reasonMsg=obj.VTextTable(reason);
            reasonMsg=...
            slci.internal.encodeString(reasonMsg,'all','encode');
        end

        function interfaceMsg=getInterfaceMessage(obj,IStatus)
            interfaceMsg=obj.ITextTable(IStatus);
        end

        function traceMsg=getTraceabilityMessage(obj,trace)
            traceMsg=obj.TraceText(trace);
            traceMsg=...
            slci.internal.encodeString(traceMsg,'all','encode');
        end

        function isScheme=isScheme(obj,key)
            if isKey(obj.SchemeTable,key)
                isScheme=true;
            else
                isScheme=false;
            end
        end

        function scheme=getHiliteScheme(obj,status)
            if isKey(obj.SchemeTable,status)
                scheme.HiliteType=obj.SchemeTable(status);
                key=obj.SchemeTable(status);
            else
                scheme.HiliteType=obj.defaultScheme;
                key=obj.defaultScheme;
            end

            scheme.ForegroundColor='black';
            scheme.BackgroundColor=obj.ColorTable(key);
            set_param(0,'HiliteAncestorsData',scheme);
        end

        function out=getRepModelName(obj)
            out=obj.RepModelName;
        end
    end


    methods(Static)




        function traceCallBack(modelName,sid)


            [~,~,~,msg,~]=Simulink.ID.getHandle(sid);
            if strcmp(msg,'Simulink:utility:modelNotLoaded')
                decodedModelName=slci.internal.encodeString(modelName,'html','decode');
                msg=message('Slci:report:LoadingModel',decodedModelName);
                disp(msg.getString)

                load_system(decodedModelName);
            end

            Simulink.ID.hilite(sid,'find');

        end

        function status_list=getNonFunctionalStatus()
            status_list={'EMPTY_LINE','COMMENT','KEYWORD','INCLUDE',...
            'PREPROCESSOR','OPEN_BRACKET','CLOSE_BRACKET','SEMICOLON'};
        end

    end

    methods(Static=true)


        function status_list=getTopStatusList()
            status_list={'PASSED','FAILED','WARNING'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getTopVerStatusList()
            status_list={'VERIFIED','FAILED_TO_VERIFY','PARTIALLY_VERIFIED'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function status_list=getTopTraceList()
            status_list={'TRACED','FAILED_TO_TRACE','PARTIALLY_TRACED'};
            if slcifeature('SLCIJustification')==1
                status_list{end+1}='JUSTIFIED';
            end
        end

        function errorStatus=getTopErrorStatus()
            errorStatus='FAILED';
        end

        function passStatus=getTopPassStatus()
            passStatus='PASSED';
        end

        function failStatus=getTopFailStatus()
            failStatus='FAILED';
        end


        function passStatus=getVerificationPassStatus()
            passStatus='VERIFIED';
        end

        function failStatus=getVerificationFailStatus()
            failStatus='FAILED_TO_VERIFY';
        end

        function passStatus=getTraceabilityPassStatus()
            passStatus='TRACED';
        end

        function failStatus=getTraceabilityFailStatus()
            failStatus='FAILED_TO_TRACE';
        end


    end



end
