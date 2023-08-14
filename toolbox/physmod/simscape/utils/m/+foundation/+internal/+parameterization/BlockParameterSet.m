classdef BlockParameterSet<handle





    properties(SetAccess=private,GetAccess=public)

        Names string
Values
        PartTypeNames={};
        PartTypeValues={};
BlockType
SourceFile
ReferenceBlock
SimulinkRelease
Manufacturer
PartNumber
PartSeries
WebLink
PartType
ParameterizationNote
ParameterizationDate
DatabaseRootDirectory
    end

    methods(Access=public)

        function theBlockParameterSet=BlockParameterSet

        end

        function addParameter(theBlockParameterSet,paramName,paramValue)


            if~ischar(paramName)&&~isstring(paramName)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_ParameterName')))
            end

            index=getParameterIndex(theBlockParameterSet,string(paramName));

            if~any(index)
                theBlockParameterSet.Names(end+1)=string(paramName);
                theBlockParameterSet.Values{end+1}=paramValue;
            else
                currentValue=theBlockParameterSet.Values{index};
                if~(isequal(currentValue,paramValue)&&isa(currentValue,class(paramValue)))
                    theBlockParameterSet.Values{index}=paramValue;
                end
            end
        end

        function deleteParameter(theBlockParameterSet,paramName)


            if~ischar(paramName)&&~isstring(paramName)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_ParameterName')))
            end

            index=theBlockParameterSet.getParameterIndex(string(paramName));

            if~any(index)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotFound',getString(message('physmod:simscape:utils:BlockParameterSet:error_ParameterName')))
            else
                theBlockParameterSet.Names(index)=[];
                theBlockParameterSet.Values(index)=[];
            end
        end

        function extractBlockParameters(theBlockParameterSet,blockHandle)




            import pm.sli.internal.getMaskParameterRecursive


            Simulink.Block.eval(blockHandle)


            if isempty(pm.sli.internal.rootMask(blockHandle))
                pm_error('physmod:simscape:utils:BlockParameterSet:InvalidBlock')
            end


            blockMaskVariables=get_param(blockHandle,'MaskWSVariables');


            ParameterIdxWithSuffix=contains(...
            {blockMaskVariables.Name},'_conf');
            ParameterWithSuffix=...
            blockMaskVariables(ParameterIdxWithSuffix);
            parameterCount=0;
            parameter=struct;
            excludedPrefix={'port_option'
'SOC_port'
            'thermal_port'};



            for paramaterIdx=1:length(ParameterWithSuffix)
                extractedParameterPrefix=split(ParameterWithSuffix(paramaterIdx).Name,'_conf');
                possibleParameterName=extractedParameterPrefix{1};




                if any(strcmp({blockMaskVariables.Name},...
                    strcat(possibleParameterName,'_unit')))&&...
                    any(strcmp({blockMaskVariables.Name},...
                    possibleParameterName))&&...
                    ~any(strcmp(excludedPrefix,possibleParameterName))


                    parameterCount=parameterCount+1;
                    parameter(parameterCount).Name=possibleParameterName;
                    parameterNameIdx=find(strcmp(...
                    {blockMaskVariables.Name},possibleParameterName));
                    parameter(parameterCount).Value=...
                    blockMaskVariables(parameterNameIdx).Value;%#ok<*FNDSB>

                    parameterCount=parameterCount+1;
                    parameter(parameterCount).Name=...
                    strcat(possibleParameterName,'_unit');
                    parameterUnitIdx=find(strcmp(...
                    {blockMaskVariables.Name},...
                    strcat(possibleParameterName,'_unit')));
                    parameter(parameterCount).Value=...
                    blockMaskVariables(parameterUnitIdx).Value;


                end
            end

            nParameters=length(parameter);
            for maskParameterIdx=1:nParameters
                mwsName=parameter(maskParameterIdx).Name;


                param=getMaskParameterRecursive(blockHandle,mwsName);


                if~isempty(param)&&strcmp(param.Hidden,'off')
                    if strcmp(param.Type,'popup')

                        name=mwsName;
                        value=param.Value;
                    elseif endsWith(mwsName,'_unit')&&~isempty(param.TypeOptions)

                        name=mwsName;
                        value=param.Value;
                    elseif~strcmp(param.Evaluate,'on')
                        name=mwsName;
                        value=param.Value;
                    else
                        name=mwsName;
                        mwsValue=parameter(maskParameterIdx).Value;
                        if isa(mwsValue,'Simulink.Parameter')
                            valueNumeric=mat2str(mwsValue.Value);
                        else
                            try
                                valueNumeric=mat2str(mwsValue);
                            catch
                                valueNumeric=param.Value;
                            end
                        end

                        idx=find(param.Value=='%',1);
                        if~isempty(idx)
                            value=[valueNumeric,' ',param.Value(idx:end)];
                        else
                            value=valueNumeric;
                        end
                    end
                    theBlockParameterSet.addParameter(name,value)
                end
            end
        end

        function updateBlockParameters(theBlockParameterSet,blockHandle,varargin)


            if ishandle(blockHandle)
                name=get_param(blockHandle,'Name');
                parent=get_param(blockHandle,'Parent');
                blockName=[parent,'/',name];
            else
                blockName=blockHandle;
            end
            for paramToSet=1:length(theBlockParameterSet.Names)
                if isfield(get_param(blockName,'ObjectParameters'),theBlockParameterSet.Names{paramToSet})
                    set_param(blockName,theBlockParameterSet.Names{paramToSet},theBlockParameterSet.Values{paramToSet});
                else
                    warning(message('physmod:simscape:utils:BlockParameterSet:warning_ParameterNotExist',theBlockParameterSet.Names{paramToSet}));
                    pm_warning('physmod:simscape:utils:BlockParameterSet:warning_ParameterNotExist',theBlockParameterSet.Names{paramToSet});
                end
            end


            attributeString=[theBlockParameterSet.Manufacturer,':',theBlockParameterSet.PartNumber];
            set_param(blockHandle,'AttributesFormatString',attributeString);




            if nargin>=3
                tag=varargin{1};
                set_param(blockHandle,'Tag',tag)
            end
        end

        function addMetadata(theBlockParameterSet,blockHandle,Manufacturer,PartNumber,PartSeries,PartType,WebLink,ParameterizationNote)




            if~ischar(Manufacturer)&&~isstring(Manufacturer)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            if~ischar(PartNumber)&&~isstring(PartNumber)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            if~ischar(PartSeries)&&~isstring(PartSeries)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            if~ischar(PartType)&&~isstring(PartType)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            if~ischar(WebLink)&&~isstring(WebLink)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            if~ischar(ParameterizationNote)&&~isstring(ParameterizationNote)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_MetadataValue')));
            end
            theBlockParameterSet.Manufacturer=Manufacturer;
            theBlockParameterSet.PartNumber=PartNumber;
            theBlockParameterSet.PartSeries=PartSeries;
            theBlockParameterSet.PartType=PartType;
            theBlockParameterSet.WebLink=WebLink;
            theBlockParameterSet.ParameterizationNote=ParameterizationNote;
            blockType=get_param(blockHandle,'BlockType');
            theBlockParameterSet.BlockType=blockType;

            if(any(strcmp(blockType,{'SimscapeBlock','SubSystem','S-Function'})))
                referenceBlock=get_param(blockHandle,'ReferenceBlock');
                if isempty(referenceBlock)

                    if contains(get_param(blockHandle,'Parent'),'/')
                        rootParent=extractBefore(get_param(blockHandle,'Parent'),'/');
                    else
                        rootParent=get_param(blockHandle,'Parent');
                    end


                    if strcmp(get_param(rootParent,'BlockDiagramType'),'library')
                        referenceBlock=[get_param(blockHandle,'Parent'),'/',get_param(blockHandle,'Name')];
                    else

                    end
                end

                if strcmp(blockType,'SimscapeBlock')
                    theBlockParameterSet.SourceFile=get_param(blockHandle,'SourceFile');
                end
            else
                pm_error('physmod:simscape:utils:BlockParameterSet:InvalidBlock')
            end

            theBlockParameterSet.ReferenceBlock=replace(referenceBlock,newline,'\n');
            v=ver('simulink');
            theBlockParameterSet.SimulinkRelease=v.Version;
            theBlockParameterSet.ParameterizationDate=date;
        end

        function addPartTypeData(theBlockParameterSet,partTypeNames,partTypeValues)
            theBlockParameterSet.PartTypeNames=partTypeNames;
            theBlockParameterSet.PartTypeValues=partTypeValues;
        end

        function xmlWrite(theBlockParameterSet,filename)

            docNode=matlab.io.xml.dom.Document('Block');
            Block=docNode.getDocumentElement;
            Block.setAttribute('BlockType',theBlockParameterSet.BlockType);

            if isempty(theBlockParameterSet.ReferenceBlock)
                pm_error('physmod:simscape:utils:BlockParameterSet:UndefinedMetadata')
            end
            addTagPairWithData(docNode,Block,'P','ReferenceBlock',theBlockParameterSet.ReferenceBlock)
            if strcmp(theBlockParameterSet.BlockType,'SimscapeBlock')
                addTagPairWithData(docNode,Block,'P','SourceFile',theBlockParameterSet.SourceFile)
            end
            addTagPairWithData(docNode,Block,'P','SimulinkRelease',theBlockParameterSet.SimulinkRelease)
            addTagPairWithData(docNode,Block,'P','Manufacturer',theBlockParameterSet.Manufacturer)
            addTagPairWithData(docNode,Block,'P','PartNumber',theBlockParameterSet.PartNumber)
            addTagPairWithData(docNode,Block,'P','PartSeries',theBlockParameterSet.PartSeries)
            addTagPairWithData(docNode,Block,'P','PartType',theBlockParameterSet.PartType)
            addTagPairWithData(docNode,Block,'P','WebLink',theBlockParameterSet.WebLink)
            addTagPairWithData(docNode,Block,'P','ParameterizationNote',theBlockParameterSet.ParameterizationNote)
            addTagPairWithData(docNode,Block,'P','ParameterizationDate',theBlockParameterSet.ParameterizationDate)

            if~isempty(theBlockParameterSet.PartTypeNames)

                PartTypeData=docNode.createElement('PartTypeData');
                Block.appendChild(PartTypeData);
                for partTypeIdx=1:length(theBlockParameterSet.PartTypeNames)
                    if ismissing(theBlockParameterSet.PartTypeValues{partTypeIdx})


                        theBlockParameterSet.PartTypeValues{partTypeIdx}='NaN';
                    end
                    addTagPairWithData(docNode,PartTypeData,'P',...
                    theBlockParameterSet.PartTypeNames{partTypeIdx},...
                    theBlockParameterSet.PartTypeValues{partTypeIdx})
                end
            end


            InstanceData=docNode.createElement('InstanceData');
            Block.appendChild(InstanceData);
            for ii=1:length(theBlockParameterSet.Names)
                addTagPairWithData(docNode,InstanceData,'P',theBlockParameterSet.Names{ii},theBlockParameterSet.Values{ii})
            end


            if exist(filename,'file')
                pm_error('physmod:simscape:utils:BlockParameterSet:FileAlreadyExists',filename)
            else

                domWriter=matlab.io.xml.dom.DOMWriter;
                domWriter.Configuration.FormatPrettyPrint=1;
                writeToURI(domWriter,docNode,filename);
            end

        end

        function xmlRead(theBlockParameterSet,xmlFile)




            xmlReader=foundation.internal.parameterization.XmlReader(xmlFile);


            partSpecification=xmlReader.PartSpecification;
            theBlockParameterSet.Manufacturer=partSpecification.Manufacturer;
            theBlockParameterSet.PartNumber=partSpecification.PartNumber;
            theBlockParameterSet.PartSeries=partSpecification.PartSeries;
            theBlockParameterSet.PartType=partSpecification.PartType;
            theBlockParameterSet.WebLink=partSpecification.WebLink;
            theBlockParameterSet.ParameterizationNote=partSpecification.ParameterizationNote;
            theBlockParameterSet.ParameterizationDate=partSpecification.ParameterizationDate;


            partTypeData=xmlReader.getPartTypeData();
            theBlockParameterSet.PartTypeNames=partTypeData.PartTypeName;
            theBlockParameterSet.PartTypeValues=partTypeData.PartTypeValue;


            instanceData=xmlReader.getInstanceData();
            theBlockParameterSet.Names=cellfun(@(x)string(x),{instanceData.Name});
            theBlockParameterSet.Values={instanceData.Value};


            blockInformation=xmlReader.BlockInformation;
            theBlockParameterSet.BlockType=blockInformation.BlockType;
            theBlockParameterSet.ReferenceBlock=blockInformation.ReferenceBlock;
            theBlockParameterSet.SourceFile=blockInformation.SourceFile;


            theBlockParameterSet.SimulinkRelease=xmlReader.SimulinkRelease();
        end
    end

    methods(Access=private)

        function index=getParameterIndex(theBlockParameterSet,aName)
            if~ischar(aName)&&~isstring(aName)
                pm_error('physmod:simscape:utils:BlockParameterSet:NotString',getString(message('physmod:simscape:utils:BlockParameterSet:error_ParameterName')))
            end
            index=arrayfun(@(x)strcmp(x,string(aName)),theBlockParameterSet.Names);
        end
    end
end

function addTagPairWithData(docNode,parentTag,thisTag,attribute,value)


    curr_node=docNode.createElement(thisTag);
    curr_node.setAttribute('Name',attribute);
    curr_node.appendChild(docNode.createTextNode(value));
    parentTag.appendChild(curr_node);
end


