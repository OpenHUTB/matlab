
function simulinkInfo=getCoderTypesSimulinkInfo(varargin)





    persistent p
    if isempty(p)
        p=inputParser;
        addParameter(p,'DesignDataLocation','base');
        addParameter(p,'ExistingSharedCode','');
        addParameter(p,'GRTInterface',false);
        addParameter(p,'GenBuiltInDTEnums',false);
        addParameter(p,'GenChunkDefs',false);
        addParameter(p,'GenErtSFcnRTWTypes',false);
        addParameter(p,'GenTimingBridge',false);
        addParameter(p,'IsERT',true);
        addParameter(p,'MaximumIdentifierLength',-1);
        addParameter(p,'PortableWordSizes',false);
        addParameter(p,'ReplacementTypeLimitsHdrFile','');
        addParameter(p,'ReplacementTypeLimitsStruct',[]);
        addParameter(p,'ReplacementTypesOn',false);
        addParameter(p,'ReplacementTypesStruct',[]);
        addParameter(p,'SharedLocation',false);
        addParameter(p,'Style','minimized');
        addParameter(p,'SupportNonInlinedSFcns',false);
        addParameter(p,'UseCVMatForImage',false);
        addParameter(p,'UsingTimerServices',false);
        addParameter(p,'IncludeSimstrucTypesForNonERT',~rtwprivate('getRemoveSimstrucFromRtwtypes'));
    end
    parse(p,varargin{:});
    simulinkInfo=p.Results;


    simulinkInfo.ReplacementTypeLimitsStruct=i_SetTypeLimitIdentifierReplacementDefaults...
    (simulinkInfo.ReplacementTypeLimitsStruct,simulinkInfo.ReplacementTypeLimitsHdrFile);


    function lReplacementTypeLimitsStruct=...
        i_SetTypeLimitIdentifierReplacementDefaults(lReplacementTypeLimitsStruct,...
        lReplacementTypeLimitsHdrFile)








        limitParamData={{'MaxIdInt8','MAX_int8_T'},{'MinIdInt8','MIN_int8_T'},...
        {'MaxIdUint8','MAX_uint8_T'},...
        {'MaxIdInt16','MAX_int16_T'},{'MinIdInt16','MIN_int16_T'},...
        {'MaxIdUint16','MAX_uint16_T'},...
        {'MaxIdInt32','MAX_int32_T'},{'MinIdInt32','MIN_int32_T'},...
        {'MaxIdUint32','MAX_uint32_T'},...
        {'MaxIdInt64','MAX_int64_T'},{'MinIdInt64','MIN_int64_T'},...
        {'MaxIdUint64','MAX_uint64_T'},...
        {'BooleanTrueId','true'},{'BooleanFalseId','false'},...
        };

        if isempty(lReplacementTypeLimitsStruct)
            assert(isempty(lReplacementTypeLimitsHdrFile),...
            ['If limits structure above was not defined, then it '...
            ,'does make sense to have the imported header defined']);
        end

        defaultAlwaysUsed=true;
        for lIdx=1:length(limitParamData)
            currField=limitParamData{lIdx}{1};
            currDefault=limitParamData{lIdx}{2};

            if isfield(lReplacementTypeLimitsStruct,currField)
                paramVal=lReplacementTypeLimitsStruct.(currField);
                if isfield(paramVal,'value')



                    assert(isfield(paramVal,'defaultUsed'),...
                    'defaultUse field not provided in ReplacementTypeLimitsStruct structure.');
                else
                    lReplacementTypeLimitsStruct=...
                    rmfield(lReplacementTypeLimitsStruct,currField);
                    if isempty(paramVal)

                        lReplacementTypeLimitsStruct.(currField).value=currDefault;
                        lReplacementTypeLimitsStruct.(currField).defaultUsed=true;
                    elseif strcmp(currDefault,paramVal)
                        lReplacementTypeLimitsStruct.(currField).value=currDefault;
                        lReplacementTypeLimitsStruct.(currField).defaultUsed=true;
                    else

                        lReplacementTypeLimitsStruct.(currField).value=paramVal;
                        lReplacementTypeLimitsStruct.(currField).defaultUsed=false;

                        defaultAlwaysUsed=false;
                    end
                end
            else
                lReplacementTypeLimitsStruct.(currField).value=currDefault;
                lReplacementTypeLimitsStruct.(currField).defaultUsed=true;
            end
        end

        if defaultAlwaysUsed&&~isempty(lReplacementTypeLimitsHdrFile)
            MSLDiagnostic('RTW:buildProcess:TypeIdReplacementInvalidHdrFileUse',...
            limitParamData{1}{1},limitParamData{end}{1}).reportAsWarning;
        end
