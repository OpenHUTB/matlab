classdef(Abstract)MappingBlockXml<handle
















    properties(SetAccess=private)
        FileNameSource string
BlockHandle
        SourceStruct struct
        TargetBlockParameterSet foundation.internal.parameterization.BlockParameterSet;
        InitialBlockParameterSet foundation.internal.parameterization.BlockParameterSet;
        NeedToCloseLibrary=false;
        VerboseMode=false;
    end

    properties(SetAccess=protected)
        SourceStructUse struct
    end

    properties(Abstract,Constant)
ReferenceBlock
    end
    properties(Abstract)
        ValidVariants cell
        MetadataMap struct
        ParametersMap struct
    end

    methods(Access=public)

        function obj=MappingBlockXml(fileName,varargin)









            obj.parseSourceFile(fileName);

            if nargin==1
                block=char.empty;
                obj.VerboseMode=false;
            elseif nargin==2
                block=varargin{1};
                obj.VerboseMode=false;
            else



                block=varargin{1};


                obj.VerboseMode=varargin{2};
            end


            if~isempty(block)

                obj.parseBlock(block);
            else

                if contains(obj.ReferenceBlock,'/')
                    rootLibrary=extractBefore(obj.ReferenceBlock,'/');
                else
                    rootLibrary=obj.ReferenceBlock;
                end
                if bdIsLoaded(rootLibrary)
                    obj.parseBlock(obj.ReferenceBlock);
                else


                    load_system(rootLibrary);
                    obj.NeedToCloseLibrary=true;

                    obj.parseBlock(obj.ReferenceBlock)
                end
            end
        end


        function delete(obj)


            if obj.NeedToCloseLibrary
                if contains(obj.ReferenceBlock,'/')
                    rootLibrary=extractBefore(obj.ReferenceBlock,'/');
                else
                    rootLibrary=obj.ReferenceBlock;
                end

                bdclose(rootLibrary)
            end
        end

        function sourceStruct=parseSourceFile(obj,fileName)



            if~endsWith(fileName,'.xml')
                pm_error('physmod:ee:importparams:MappingBlockXml:InvalidFileFormat',fileName)
            end
            if exist(fileName,'file')~=2
                pm_error('physmod:ee:library:NotFound',fileName);
            end

            obj.FileNameSource=fileName;
            sourceStruct=readstruct(obj.FileNameSource);
            obj.SourceStruct=sourceStruct;
            obj.SourceStructUse=sourceStruct;
        end

        function parseBlock(obj,block)



            if ischar(block)
                try
                    obj.BlockHandle=get_param(block,'handle');
                catch
                    pm_error('physmod:ee:importparams:MappingBlockXml:InvalidBlockPath')
                end
            else
                try
                    get_param(block,'handle');
                catch
                    pm_error('physmod:ee:importparams:MappingBlockXml:InvalidBlockPath')
                end
                obj.BlockHandle=block;
            end

            if~strcmp(get_param(obj.BlockHandle,'BlockType'),'SimscapeBlock')
                pm_error('physmod:ee:importparams:MappingBlockXml:OnlySimscapeBlocks',get_param(obj.BlockHandle,'BlockType'))
            end

            refBlock=get_param(obj.BlockHandle,'ReferenceBlock');
            if~isempty(refBlock)&&~strcmp(refBlock,obj.ReferenceBlock)
                pm_error('physmod:ee:importparams:MappingBlockXml:InvalidReferenceBlock',get_param(obj.BlockHandle,'Name'),obj.ReferenceBlock)
            end


            obj.TargetBlockParameterSet=foundation.internal.parameterization.BlockParameterSet;
            obj.TargetBlockParameterSet.extractBlockParameters(obj.BlockHandle);



            obj.InitialBlockParameterSet=foundation.internal.parameterization.BlockParameterSet;
            obj.InitialBlockParameterSet.extractBlockParameters(obj.BlockHandle);

        end


        function dependParamsValueCell=computeDependentParamsValue(obj)






            sourceCell=obj.ParametersMap.dependent(:,2);
            dependParamsValueCell=cell(size(sourceCell));
            for paramIdx=1:length(sourceCell)
                fieldCell=strsplit(sourceCell{paramIdx},'.');
                try
                    structNode=getfield(obj.SourceStruct,fieldCell{:});
                catch ME
                    if strcmp(ME.identifier,'MATLAB:nonExistentField')
                        pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',sourceCell{paramIdx});
                    else
                        rethrow(ME);
                    end
                end
                targetValue=obj.arrayFromStruct(structNode,sourceCell{paramIdx});
                dependParamsValueCell{paramIdx}=targetValue;
            end
        end


        function applyMapping(obj)




            [Manufacturer,PartNumber,PartSeries,PartType,WebLink,ParameterizationNote]=obj.getMetadataValues();
            obj.TargetBlockParameterSet.addMetadata(obj.BlockHandle,Manufacturer,PartNumber,PartSeries,PartType,WebLink,ParameterizationNote)


            nameCell=obj.ParametersMap.fixed(:,1);
            valueCell=obj.ParametersMap.fixed(:,2);
            for paramIdx=1:length(nameCell)
                obj.TargetBlockParameterSet.addParameter(nameCell{paramIdx},valueCell{paramIdx});
            end


            sourceCell=obj.ParametersMap.dependent(:,2);
            targetCell=obj.ParametersMap.dependent(:,1);

            dependParamsValueCell=obj.computeDependentParamsValue();

            for paramIdx=1:length(sourceCell)
                targetValue=dependParamsValueCell{paramIdx};

                if isnumeric(targetValue)
                    if ndims(targetValue)>2 %#ok<ISMAT>


                        targetValue=sprintf('reshape(%s, %s);',mat2str(targetValue(:),64,'class'),mat2str(size(targetValue)));
                    else
                        targetValue=mat2str(targetValue);
                    end
                end


                obj.TargetBlockParameterSet.addParameter(targetCell{paramIdx},targetValue);

            end


            obj.addCommentToExcludedParameters;


            if obj.VerboseMode
                obj.warnAboutUnusedXMLFields;
            end
        end

        function addCommentToExcludedParameters(obj)




            commentToAdd=' % Parameter not set';

            excludeSuffix={
'_unit'
'_priority'
            };

            paramNames=obj.TargetBlockParameterSet.Names;
            paramValues=obj.TargetBlockParameterSet.Values;


            modifiedParams=~strcmp(paramValues,obj.InitialBlockParameterSet.Values);


            excludeSuffixParams=endsWith(paramNames,excludeSuffix);



            alreadyHaveCommentParams=endsWith(paramValues,commentToAdd);



            enumerationParams=contains(paramValues,'enum');





            addCommentParams=~modifiedParams&...
            ~excludeSuffixParams&...
            ~enumerationParams&...
            ~alreadyHaveCommentParams;

            for paramIdx=1:length(addCommentParams)
                if addCommentParams(paramIdx)

                    obj.TargetBlockParameterSet.addParameter(paramNames{paramIdx},[paramValues{paramIdx},commentToAdd]);

                end
            end

        end

        function updateBlockParameters(obj)






            blockPath=[get_param(obj.BlockHandle,'Parent'),'/',get_param(obj.BlockHandle,'Name')];
            if strcmp(blockPath,obj.ReferenceBlock)

                pm_error('physmod:ee:importparams:MappingBlockXml:ReadOnlyLibraryBlock',blockPath)
            else
                variant=get_param(obj.BlockHandle,'SourceFile');
                if~any(strcmp(obj.ValidVariants,variant))
                    pm_warning('physmod:ee:importparams:MappingBlockXml:SetValidVariant',variant,obj.ValidVariants{1});


                    nesl_setvariant=nesl_private('nesl_setvariant');

                    nesl_setvariant(obj.BlockHandle,obj.ValidVariants{1});
                end
                obj.TargetBlockParameterSet.updateBlockParameters(obj.BlockHandle);
            end

        end

        function writeTargetXml(obj,targetFileName)



            obj.TargetBlockParameterSet.xmlWrite(targetFileName)

        end

        function warnAboutUnusedXMLFields(obj)










            mappings=obj.ParametersMap.dependent(:,2);
            for idxMapping=1:length(mappings)


                if iscell(mappings{idxMapping})
                    mappingCell=mappings{idxMapping};
                    for idxField=1:length(mappingCell)
                        XMLfield=mappingCell{idxField};
                        fieldCell=strsplit(XMLfield,'.');



                        try
                            obj.SourceStructUse=setfield(obj.SourceStructUse,fieldCell{:},"used");
                        catch ME
                            if strcmp(ME.identifier,'MATLAB:nonExistentField')
                                pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',XMLfield{paramIdx});
                            else
                                rethrow(ME);
                            end
                        end
                    end
                else
                    XMLfield=mappings{idxMapping};
                    fieldCell=strsplit(XMLfield,'.');



                    try
                        obj.SourceStructUse=setfield(obj.SourceStructUse,fieldCell{:},"used");
                    catch ME
                        if strcmp(ME.identifier,'MATLAB:nonExistentField')
                            pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',XMLfield{paramIdx});
                        else
                            rethrow(ME);
                        end
                    end
                end
            end





            verifyUnusedNodes(obj.SourceStructUse,'');
        end


        function varargout=getMetadataValues(obj)




            dependentMetadataCell=obj.MetadataMap.dependent;
            fixedMetadataCell=obj.MetadataMap.fixed;

            metadataFields={'Manufacturer','PartNumber','PartSeries','PartType','WebLink','ParameterizationNote'};
            varargout=cell(size(metadataFields));


            for metadataIdx=1:length(metadataFields)
                theMetadataField=metadataFields{metadataIdx};
                posMetadata=find(strcmp(fixedMetadataCell(:,1),theMetadataField),1);
                if~isempty(posMetadata)
                    varargout{metadataIdx}=fixedMetadataCell{posMetadata,2};
                else
                    posMetadata=find(strcmp(dependentMetadataCell(:,1),theMetadataField),1);
                    if~isempty(posMetadata)
                        fieldCell=strsplit(dependentMetadataCell{posMetadata,2},'.');
                        try
                            varargout{metadataIdx}=convertStringsToChars(getfield(obj.SourceStruct,fieldCell{:}));

                            obj.SourceStructUse=setfield(obj.SourceStructUse,fieldCell{:},"used");
                        catch ME
                            if strcmp(ME.identifier,'MATLAB:nonExistentField')
                                pm_error('physmod:ee:importparams:MappingBlockXml:MissingFieldInXML',dependentMetadataCell{posMetadata,2});
                            else
                                rethrow(ME);
                            end
                        end

                        if iscell(varargout{metadataIdx})
                            varargout{metadataIdx}=strjoin(varargout{metadataIdx},'***');
                        end

                        if isnumeric(varargout{metadataIdx})
                            varargout{metadataIdx}=num2str(varargout{metadataIdx});
                        end
                    else
                        pm_error('physmod:ee:importparams:MappingBlockXml:MissingMetadata',varargout{metadataIdx})
                    end
                end
            end

        end

        function[Names,Values]=getNamesValues(obj)


            Names=obj.TargetBlockParameterSet.Names;
            Values=obj.TargetBlockParameterSet.Values;
        end

        function sourceStruct=getSourceStruct(obj)

            sourceStruct=obj.SourceStruct;
        end

    end

    methods(Static)
        function theArray=arrayFromStruct(theNode,varargin)









            narginchk(1,2)


            if nargin==2
                if(isa(varargin{1},'string')&&isscalar(varargin{1}))||...
                    (isa(varargin{1},'char')&&size(varargin{1},1)==1)
                    nodeName=varargin{1};
                else


                    nodeName=cell.empty;
                end
            else


                nodeName=cell.empty;
            end

            validateattributes(theNode,{'string','struct','double'},{'nonempty'});


            if isnumeric(theNode)
                theArray=theNode;
            elseif isstring(theNode)
                theArray=str2num(theNode);%#ok<ST2NM>
            elseif isstruct(theNode)
                if isfield(theNode,'scaleAttribute')
                    scaleFactor=theNode.scaleAttribute;
                    theNode=rmfield(theNode,'scaleAttribute');
                else
                    scaleFactor=1;
                end

                thisChild=theNode;
                dimensionLength=[];
                while isstruct(thisChild)
                    thisFieldName=fieldnames(thisChild);
                    dimensionLength(end+1)=length(thisChild.(thisFieldName{1}));%#ok<AGROW>
                    thisChild=thisChild.(thisFieldName{1})(1);
                end

                if isnumeric(thisChild)
                    deepVector=thisChild;
                else
                    deepVector=str2num(thisChild);%#ok<ST2NM>
                end
                if~isscalar(deepVector)
                    dimensionLength(end+1)=length(deepVector);
                end


                dataConc=findDataAndConcatenate(theNode,[]);


                try
                    theArray=scaleFactor*permute(reshape(dataConc,flip(dimensionLength)),numel(dimensionLength):-1:1);
                catch ME
                    if strcmp(ME.identifier,'MATLAB:getReshapeDims:notSameNumel')
                        if isempty(nodeName)
                            pm_error('physmod:ee:importparams:MappingBlockXml:InconsistentFieldSizesGeneric');
                        else
                            pm_error('physmod:ee:importparams:MappingBlockXml:InconsistentFieldSizes',nodeName);
                        end
                    else
                        rethrow(ME);
                    end
                end
            end
        end
    end
end

function dataConcOut=findDataAndConcatenate(thisNode,dataConcIn)



    thisNode.discovered=true;
    dataConcOut=dataConcIn;

    thisFieldName=fieldnames(thisNode);
    for i=1:length(thisNode.(thisFieldName{1}))
        thisChild=thisNode.(thisFieldName{1})(i);
        if isstruct(thisChild)
            if~isfield(thisChild,'discovered')
                dataConcOut=findDataAndConcatenate(thisChild,dataConcOut);
            end
        end
        if isstring(thisChild)
            dataConcOut=cat(2,dataConcOut,str2num(thisChild));%#ok<ST2NM>
        elseif isnumeric(thisChild)
            dataConcOut=cat(2,dataConcOut,thisChild);
        end

    end

end

function verifyUnusedNodes(node,nodeName)











    if isstruct(node)

        for idxStruct=1:length(node)
            children=fieldnames(node(idxStruct));
            for idxChild=1:length(children)
                if isempty(nodeName)
                    childNodeName=children{idxChild};
                else
                    childNodeName=[nodeName,'.',children{idxChild}];
                end
                verifyUnusedNodes(node(idxStruct).(children{idxChild}),childNodeName);
            end
        end
    elseif isstring(node)
        if~strcmp(node,"used")
            pm_warning('physmod:ee:importparams:MappingBlockXml:UnusedFieldInXML',nodeName);
        end
    else
        pm_warning('physmod:ee:importparams:MappingBlockXml:UnusedFieldInXML',nodeName);
    end
end
