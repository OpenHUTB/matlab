classdef parameterInfo<handle





    properties(Access=private)
        modelName;
        buildDir;
        codeDescRepo;
        codeDescriptor;
        tunableParamNames;
        parameterMap;
    end

    methods(Access=public)



        function this=parameterInfo(mdlName)
            this.modelName=mdlName;
            this.buildDir=RTW.getbuildDir(this.modelName);
            this.codeDescRepo=this.buildDir.BuildDirectory;
            this.codeDescriptor=coder.internal.getCodeDescriptorInternal(this.codeDescRepo,this.modelName,247362);
            this.parameterMap=containers.Map;






            tunableParams=this.codeDescriptor.getTunableParametersForSLRT;
            this.tunableParamNames={};
            for i=1:numel(tunableParams)
                if isempty(tunableParams(i).BlockPath)
                    this.tunableParamNames{end+1}=tunableParams(i).BlockParameterName;

                elseif iscell(tunableParams(i).BlockPath)
                    bpstr=tunableParams(i).BlockPath{1};
                    for j=2:length(tunableParams(i).BlockPath)
                        bpstr=strcat(bpstr,'/',extractAfter(tunableParams(i).BlockPath{j},'/'));
                    end
                    this.tunableParamNames{end+1}=[bpstr,'/',tunableParams(i).BlockParameterName];
                else
                    this.tunableParamNames{end+1}=[tunableParams(i).BlockPath,'/',tunableParams(i).BlockParameterName];
                end
            end

            this.tunableParamNames=regexprep(this.tunableParamNames,'\n+',' ');
        end




        function addArtifactToApplication(this,appObj)


            this.buildParameterMap();



            keySet=keys(this.parameterMap);
            dataBase=[];
            for k=1:numel(keySet)
                entry=this.parameterMap(string(keySet(k)));


                dataBase.parameters(k).Name=regexprep(entry.Name,'\n','\\n');
                dataBase.parameters(k).Address=entry.Address;
                dataBase.parameters(k).Dimensions=entry.Dimensions;
                dataBase.parameters(k).DataType=entry.DataType;
                dataBase.parameters(k).DataTypeSize=entry.DataTypeSize;
                dataBase.parameters(k).Min=entry.Min;
                dataBase.parameters(k).Max=entry.Max;
                dataBase.parameters(k).isComplex=entry.isComplex;
                dataBase.parameters(k).isFixedPoint=entry.isFixedPoint;
                dataBase.parameters(k).fxpBias=entry.fxpBias;
                dataBase.parameters(k).fxpSignedness=entry.fxpSignedness;
                dataBase.parameters(k).fxpWordLength=entry.fxpWordLength;
                dataBase.parameters(k).fxpFractionLength=entry.fxpFractionLength;
                dataBase.parameters(k).fxpSlopeAdjFactor=entry.fxpSlopeAdjFactor;
                dataBase.parameters(k).fxpFixedExponent=entry.fxpFixedExponent;
                dataBase.parameters(k).isEnum=entry.isEnum;
                dataBase.parameters(k).enumClassName=entry.enumClassName;
                dataBase.parameters(k).Value=entry.Value;
                dataBase.parameters(k).IsStruct=entry.IsStruct;
                dataBase.parameters(k).PathForGetParam=entry.PathForGetParam;
                dataBase.parameters(k).Elements=entry.Elements;
            end


            if isfield(dataBase,'parameters')
                for i=numel(dataBase.parameters):-1:1
                    if isempty(dataBase.parameters(i).Name)
                        dataBase.parameters(i)=[];
                    end
                end
            end



            dmr_model=this.codeDescriptor.getMF0FullModel;
            scm=SharedCodeManager.ModelInterface(fullfile(this.codeDescRepo,dmr_model.sharedCodeManagerPath,'shared_file.dmr'));
            modelData=scm.retrieveModelData(this.modelName,'SLBUILD');

            dataBase.model_checksum=modelData.ModelChecksum;



            dataBase.source='host';



            paramJSON=jsonencode(dataBase);
            jsonFileName='paramInfo.json';
            jsonFilePath=[appObj.getWorkingDir,filesep,jsonFileName];

            f=fopen(jsonFilePath,'w');
            fprintf(f,paramJSON);
            fclose(f);


            appObj.add(['/paramSet/',jsonFileName],jsonFilePath);

        end

    end

    methods(Access=private)



        function parent=getStructElement(this,element,AddressOrOffset,parent)

            if element.isNVBus

                dimensions=element.dimensions;
                if isscalar(dimensions)
                    dimensions=[1,dimensions];
                end

                elStruct=struct(...
                'Name',element.structElementName,...
                'Address',AddressOrOffset,...
                'Dimensions',dimensions,...
                'DataType','struct',...
                'DataTypeSize',element.dataTypeSize,...
                'Min',element.structElementMin,...
                'Max',element.structElementMax,...
                'isComplex',element.isComplex,...
                'isFixedPoint',element.isFixedPoint,...
                'fxpBias',element.fxpBias,...
                'fxpSignedness',element.fxpSignedness,...
                'fxpWordLength',element.fxpWordLength,...
                'fxpFractionLength',element.fxpFractionLength,...
                'fxpSlopeAdjFactor',element.fxpSlopeAdjFactor,...
                'fxpFixedExponent',element.fxpFixedExponent,...
                'isEnum',element.isEnum,...
                'enumClassName',element.enumClassName,...
                'Value','',...
                'IsStruct',1,...
                'PathForGetParam','',...
                'Elements',[]);

                for nDimEl=1:prod(dimensions)
                    nDimElOffset=(nDimEl-1)*element.dataTypeSize;

                    for nEl=1:length(element.structElements)
                        el=element.structElements(nEl);
                        elStruct=this.getStructElement(el,AddressOrOffset+int64(el.structElementOffset)+int64(nDimElOffset),elStruct);
                    end
                end

                parent.Elements=[parent.Elements,elStruct];

            else
                dimensions=element.dimensions;
                if isscalar(dimensions)
                    dimensions=[1,dimensions];
                end

                elStruct=struct(...
                'Name',element.structElementName,...
                'Address',AddressOrOffset,...
                'Dimensions',dimensions,...
                'DataType',getDataType(element.dataTypeID),...
                'DataTypeSize',element.dataTypeSize,...
                'Min',element.structElementMin,...
                'Max',element.structElementMax,...
                'isComplex',element.isComplex,...
                'isFixedPoint',element.isFixedPoint,...
                'fxpBias',element.fxpBias,...
                'fxpSignedness',element.fxpSignedness,...
                'fxpWordLength',element.fxpWordLength,...
                'fxpFractionLength',element.fxpFractionLength,...
                'fxpSlopeAdjFactor',element.fxpSlopeAdjFactor,...
                'fxpFixedExponent',element.fxpFixedExponent,...
                'isEnum',element.isEnum,...
                'enumClassName',element.enumClassName,...
                'Value','',...
                'IsStruct',0,...
                'PathForGetParam','',...
                'Elements','');

                parent.Elements=[parent.Elements,elStruct];

            end
        end




        function buildObjectInfo(this,dataIntrf,dataImpl,dataVariableName,range,pathForGetParam)

            if~this.parameterMap.isKey(dataVariableName)


                typeInfo=slrealtime.internal.processCodeDescriptorType(dataIntrf.Type,dataImpl.Type);
                if typeInfo.isNVBus



                    dimensions=typeInfo.dimensions;
                    if isscalar(dimensions)
                        dimensions=[1,dimensions];
                    end

                    min='';
                    max='';
                    if numel(range)>0
                        min=range.Min;
                        max=range.Max;
                    end

                    valArray=struct('Name',dataVariableName,...
                    'Address',dataIntrf.AddressOrOffset,...
                    'Dimensions',dimensions,...
                    'DataType','struct',...
                    'DataTypeSize',typeInfo.dataTypeSize,...
                    'Min',min,...
                    'Max',max,...
                    'isComplex',typeInfo.isComplex,...
                    'isFixedPoint',typeInfo.isFixedPoint,...
                    'fxpBias',typeInfo.fxpBias,...
                    'fxpSignedness',typeInfo.fxpSignedness,...
                    'fxpWordLength',typeInfo.fxpWordLength,...
                    'fxpFractionLength',typeInfo.fxpFractionLength,...
                    'fxpSlopeAdjFactor',typeInfo.fxpSlopeAdjFactor,...
                    'fxpFixedExponent',typeInfo.fxpFixedExponent,...
                    'isEnum',typeInfo.isEnum,...
                    'enumClassName',typeInfo.enumClassName,...
                    'Value','',...
                    'IsStruct',1,...
                    'PathForGetParam',pathForGetParam,...
                    'Elements',[]);

                    for nDimEl=1:prod(typeInfo.dimensions)
                        nDimElOffset=(nDimEl-1)*typeInfo.dataTypeSize;

                        for nEl=1:length(typeInfo.structElements)
                            el=typeInfo.structElements(nEl);
                            valArray=this.getStructElement(el,dataIntrf.AddressOrOffset+int64(el.structElementOffset)+int64(nDimElOffset),valArray);
                        end
                    end

                    this.parameterMap(dataVariableName)=valArray;

                else



                    if isprop(dataImpl.Type,'BaseType')
                        type=dataImpl.Type.BaseType.Name;
                    else
                        type=dataImpl.Type.Name;
                    end

                    if(typeInfo.isEnum==1)
                        type=typeInfo.enumClassification;
                    end

                    dimensions=1;
                    if strcmp(type,'char')


                        dimensions=[1,typeInfo.dataTypeSize];
                        dataTypeSize=dataImpl.Type.Dimensions.Size;
                    else
                        dimensions=typeInfo.dimensions;
                        if isscalar(dimensions)
                            dimensions=[1,dimensions];
                        end
                        dataTypeSize=typeInfo.dataTypeSize;
                    end

                    min='';
                    max='';
                    if numel(range)>0
                        min=range.Min;
                        max=range.Max;
                    end

                    this.parameterMap(dataVariableName)=struct('Name',dataVariableName,...
                    'Address',dataIntrf.AddressOrOffset,...
                    'Dimensions',dimensions,...
                    'DataType',type,...
                    'DataTypeSize',dataTypeSize,...
                    'Min',min,...
                    'Max',max,...
                    'isComplex',typeInfo.isComplex,...
                    'isFixedPoint',typeInfo.isFixedPoint,...
                    'fxpBias',typeInfo.fxpBias,...
                    'fxpSignedness',typeInfo.fxpSignedness,...
                    'fxpWordLength',typeInfo.fxpWordLength,...
                    'fxpFractionLength',typeInfo.fxpFractionLength,...
                    'fxpSlopeAdjFactor',typeInfo.fxpSlopeAdjFactor,...
                    'fxpFixedExponent',typeInfo.fxpFixedExponent,...
                    'isEnum',typeInfo.isEnum,...
                    'enumClassName',typeInfo.enumClassName,...
                    'Value','',...
                    'IsStruct',0,...
                    'PathForGetParam',pathForGetParam,...
                    'Elements','');
                end
            end

        end




        function buildParameterMap(this)


            this.getBlkParameters();


            globalDataStores=this.codeDescriptor.getDataInterfaces('GlobalDataStores');
            sharedDataStores=this.codeDescriptor.getDataInterfaces('SharedLocalDataStores');
            externalParamObjs=this.codeDescriptor.getDataInterfaces('ExternalParameterObjects');

            dataStores=[globalDataStores,sharedDataStores,externalParamObjs];
            for kk=1:numel(dataStores)
                dataStore=dataStores(kk);
                if isempty(dataStore.Implementation)||~any(strcmp(this.tunableParamNames,regexprep(dataStore.GraphicalName,'\n+',' ')))
                    continue;
                end
                this.buildObjectInfo(dataStore,dataStore.Implementation,dataStore.GraphicalName);
            end
        end





        function[fullBlkPath,pathForGetParam]=getParamBlkPathInRefModel(this,refModelLevel,sids,cd_,bhm_)
            fullBlkPath='';
            pathForGetParam='';
            for i=1:refModelLevel
                subsys=bhm_.GraphicalSystems;
                for j=1:subsys.Size
                    gs=subsys(j);
                    blks=gs.GraphicalBlocks;
                    for m=1:blks.Size
                        blk=blks(m);
                        if contains(blk.SID,char(sids(i)))&&isa(blk,'coder.descriptor.ModelBlock')
                            fullBlkPath=[fullBlkPath,'/',blk.Identifier];
                            pathForGetParam=[pathForGetParam,':',blk.Path];
                            cd_=cd_.getReferencedModelCodeDescriptor(blk.ReferencedModelName);
                            bhm_=cd_.getBlockHierarchyMap();
                            break;
                        end
                    end
                end
            end
        end




        function getBlkParameters(this)



            bhm=this.codeDescriptor.getBlockHierarchyMap();
            subsys=bhm.GraphicalSystems;
            for i=1:subsys.Size



                gs=subsys(i);
                blks=gs.GraphicalBlocks;
                for j=1:blks.Size


                    blk=blks(j);



                    params=blk.BlockParameters;
                    for m=1:params.Size
                        p=params(m);
                        for n=1:p.ModelParameters.Size
                            dataIntrf=p.ModelParameters(n).DataInterface;
                            if~isempty(dataIntrf)




                                pathForGetParam='';
                                if~p.ModelParameters(n).WorkspaceVariable


                                    if strcmp(p.ModelParameters(n).GraphicalSource.Type,'ModelReference')


                                        pos=strfind(dataIntrf.GraphicalName,':');
                                        graphicalName=[blk.Path,'/',extractAfter(dataIntrf.GraphicalName,pos(end))];
                                        dataVariableName=extractAfter(dataIntrf.GraphicalName,pos(end));

                                        pos=strfind(dataVariableName,'.');
                                        refModelLevel=numel(pos);

                                        if refModelLevel>0




                                            sids={};
                                            for nn=1:refModelLevel
                                                if nn==1
                                                    sids(end+1)={extractBefore(dataVariableName,pos(nn))};
                                                else
                                                    sids(end+1)=extractBetween(dataVariableName,pos(nn-1)+1,pos(nn)-1);
                                                end
                                            end

                                            cd_=this.codeDescriptor.getReferencedModelCodeDescriptor(p.ModelParameters(n).GraphicalSource.ReferencedModelName);
                                            bhm_=cd_.getBlockHierarchyMap();
                                            [refBlkPath,pathForGetParam]=this.getParamBlkPathInRefModel(refModelLevel,sids,cd_,bhm_);

                                            pathForGetParam=[blk.Path,pathForGetParam];
                                            dotPos=strfind(dataIntrf.GraphicalName,'.');
                                            dataVariableName=[p.ModelParameters(n).GraphicalSource.Path,refBlkPath,'/',extractAfter(dataIntrf.GraphicalName,dotPos(end))];
                                        else
                                            dataVariableName=[blk.Path,'/',dataVariableName];
                                        end
                                    else

                                        pos=strfind(dataIntrf.GraphicalName,':');
                                        dataVariableName=[blk.Path,'/',extractAfter(dataIntrf.GraphicalName,pos(end))];
                                        graphicalName=[blk.Path,'/',extractAfter(dataIntrf.GraphicalName,pos(end))];
                                    end

                                else



                                    dataVariableName=dataIntrf.GraphicalName;
                                    graphicalName=dataIntrf.GraphicalName;
                                end

                                dataImpl=dataIntrf.Implementation;
                                if~isempty(dataImpl)&&any(strcmp(this.tunableParamNames,regexprep(graphicalName,'\n+',' ')))

                                    if isprop(dataImpl.Type,'BaseType')
                                        if~isa(dataImpl.Type.BaseType,'coder.descriptor.types.Opaque')



                                            this.buildObjectInfo(dataIntrf,dataImpl,dataVariableName,dataIntrf.Range,pathForGetParam);
                                        end
                                    else
                                        if~isa(dataImpl.Type,'coder.descriptor.types.Opaque')




                                            this.buildObjectInfo(dataIntrf,dataImpl,dataVariableName,dataIntrf.Range,pathForGetParam);
                                        end
                                    end

                                end
                            end
                        end
                    end
                end
            end

        end
    end

end

function dataType=getDataType(index)
    switch index
    case 0
        dataType='double';
    case 1
        dataType='single';
    case 2
        dataType='int8';
    case 3
        dataType='uint8';
    case 4
        dataType='int16';
    case 5
        dataType='uint16';
    case 6
        dataType='int32';
    case 7
        dataType='uint32';
    case 8
        dataType='bool';
    end
end

