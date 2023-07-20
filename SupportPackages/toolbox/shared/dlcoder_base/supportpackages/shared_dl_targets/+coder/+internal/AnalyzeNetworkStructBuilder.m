classdef(Sealed)AnalyzeNetworkStructBuilder




    properties(Access=private)
        Logger coder.internal.DLCodegenCompatibilityLogger

        TargetLib(1,:)char
    end

    properties(Constant,Access=private)




        OriginalToSanitizedMessageIdMap=coder.internal.AnalyzeNetworkStructBuilder.buildSanitizedMessageIdMap;
    end


    properties(Constant)


        FieldNames={'TargetLibrary','Supported','NetworkDiagnostics','LayerDiagnostics','IncompatibleLayerTypes',};
    end

    methods(Access=private)

        function layerTypeNames=getUnsupportedLayerTypes(obj)

            unsupportedLayerMsgId="dlcoder_spkg:cnncodegen:unsupported_layer";
            tbl=obj.Logger.FormattedLayerValidationLog;
            layerTypeNames="";
            if~isempty(obj.Logger.FormattedLayerValidationLog)
                layerTypeNames=unique(tbl.LayerType(obj.Logger.FormattedLayerValidationLog.IssueId==unsupportedLayerMsgId));
                layerTypeNames=iFormatLayerNames(layerTypeNames);
            end

        end

        function tbl=getFormattedLayerValidationLog(obj)
            tbl=obj.Logger.FormattedLayerValidationLog;
            if~isempty(tbl)
                tbl=iSantizeIssues(tbl,obj.OriginalToSanitizedMessageIdMap);


                tbl=removevars(tbl,"IssueId");

                tbl.LayerType=iFormatLayerNames(tbl.LayerType);
            end

        end

        function tbl=getFormattedNetworkAndGenericValidationLog(obj)
            tbl1=obj.Logger.FormattedNetworkValidationLog;
            if~isempty(tbl1)

                tbl1=removevars(tbl1,"IssueId");

            end




            tbl2=obj.Logger.FormattedGenericValidationLog;
            if~isempty(tbl2)

                tbl2=removevars(tbl2,"IssueId");
            end


            tbl=[tbl1;tbl2];

        end
    end

    methods(Access=public)

        function obj=AnalyzeNetworkStructBuilder(logger,targetLib)
            obj.Logger=logger;
            obj.TargetLib=targetLib;
        end

        function analyzeNetworkStruct=buildReportStruct(obj)
            analyzeNetworkStruct.(fieldName(coder.internal.AnalyzerStructFields.TargetLibrary))=obj.TargetLib;
            analyzeNetworkStruct.(fieldName(coder.internal.AnalyzerStructFields.Supported))=isempty(obj.Logger);
            analyzeNetworkStruct.(fieldName(coder.internal.AnalyzerStructFields.NetworkDiagnostics))=getFormattedNetworkAndGenericValidationLog(obj);
            analyzeNetworkStruct.(fieldName(coder.internal.AnalyzerStructFields.LayerDiagnostics))=getFormattedLayerValidationLog(obj);
            analyzeNetworkStruct.(fieldName(coder.internal.AnalyzerStructFields.IncompatibleLayerTypes))=getUnsupportedLayerTypes(obj);
        end


    end

    methods(Access=private,Static)

        function mapToReturn=buildSanitizedMessageIdMap()

            persistent orgIdToNewIdMap;
            if isempty(orgIdToNewIdMap)
                orgIdToNewIdMap=containers.Map();

                orgIdToNewIdMap("dlcoder_spkg:cnncodegen:unsupported_layer")=...
                "dlcoder_spkg:ValidateNetwork:UnsupportedLayerType";
            end

            mapToReturn=orgIdToNewIdMap;

        end
    end

    methods(Static)
        function emptyStructArray=buildEmptyStructArray(numElem)

            cellArray=cell(1,numElem);

            emptyStructArray=struct(fieldName(coder.internal.AnalyzerStructFields.TargetLibrary),cellArray,...
            fieldName(coder.internal.AnalyzerStructFields.Supported),cellArray,...
            fieldName(coder.internal.AnalyzerStructFields.NetworkDiagnostics),cellArray,...
            fieldName(coder.internal.AnalyzerStructFields.LayerDiagnostics),cellArray,...
            fieldName(coder.internal.AnalyzerStructFields.IncompatibleLayerTypes),cellArray);

        end
    end

end

function tbl=iSantizeIssues(tbl,originalToSanitizedMessageIdMap)
    allIdentifiers=tbl.IssueId;
    unsupportedLayerTypeIdxs=allIdentifiers==string(keys(originalToSanitizedMessageIdMap));
    tbl.Diagnostics(unsupportedLayerTypeIdxs)=getString(message(string(values(originalToSanitizedMessageIdMap))));
end

function layerNames=iFormatLayerNames(layerNames)
    layerNames=string(dltargets.internal.utils.GetSupportedLayersUtils.formatLayerClassNames(layerNames));
end

