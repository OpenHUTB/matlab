function setIndividualFunctionsFromMappingInspector(modelName,modelMapping,fcnId,varargin)





    argParser=inputParser;
    argParser.FunctionName='setIndividualFunctionsFromMappingInspector';
    argParser.KeepUnmatched=true;
    argParser.parse(varargin{:});

    if~contains(fcnId,':')
        functionType=fcnId;
        slFcnName='';
    else
        functionType=strtrim(extractBefore(fcnId,':'));
        slFcnName=extractAfter(fcnId,':');
        if~isequal(functionType,'ExportedFunction')




            slFcnName=strtrim(slFcnName);
        end
    end
    slFcnName=char(slFcnName);
    [mapping,~]=coder.mapping.internal.getFunctionMapping(modelName,...
    modelMapping,functionType,slFcnName);

    memorySection=argParser.Unmatched.MemorySection;
    if~isempty(memorySection)
        if strcmp(memorySection,DAStudio.message('coderdictionary:api:None'))

            mapping.unmapMemorySection();
        else
            if strcmp(memorySection,DAStudio.message('coderdictionary:api:ModelDefault'))

                uuid='';
            else
                uuid=modelMapping.DefaultsMapping.getMemorySectionUuidFromName(memorySection);
            end
            mapping.mapMemorySection(uuid);
        end
    end
