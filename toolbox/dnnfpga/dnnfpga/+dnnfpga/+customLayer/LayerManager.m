classdef LayerManager<handle



    properties(GetAccess=public,SetAccess=protected)


ProcessorConfig





        TestbenchManager=[]

    end

    properties(Access=protected)





        LayerList struct

    end

    properties(Hidden,Constant)


        LayerRegisterExample='hPC.registerCustomLayer(''Layer'', Layer, ''Model'', ''%s'')';

    end

    properties(Access=protected)


hRegisteredLayerList
        hBlocksSupportedForQuantization={'Addition','Multiplication'};

    end

    methods
        function obj=LayerManager(hPC)





            dnnfpga.validateDLSupportPackage('shared','multiple');


            obj.ProcessorConfig=hPC;
            obj.TestbenchManager=dnnfpga.customLayer.TestbenchManager(obj);


            obj.hRegisteredLayerList=dnnfpga.customLayer.LayerList;
            obj.buildAndRegisterLayer;
        end

        function buildAndRegisterLayer(obj)
            obj.hRegisteredLayerList.buildLayerList;
            hLayerList=obj.hRegisteredLayerList.getLayerList;
            for idx=1:numel(hLayerList)
                hLayer=hLayerList{idx};





                obj.registerLayer('Name',hLayer.Name,...
                'Layer',hLayer.Layer,...
                'Model',hLayer.Model,...
                'CheckModel',false);
            end
        end

        function registerLayer(obj,varargin)



            p=inputParser;


            addParameter(p,'Name','',@(x)ischar(x)||isstring(x));


            addParameter(p,'Layer',[]);









            addParameter(p,'Model','',@(x)ischar(x)||isstring(x));



            addParameter(p,'LayerOnly',false,@(x)islogical(x));








            addParameter(p,'AdditionalDelayLength',0,@(x)(isnumeric(x))&&(x>=0));








            addParameter(p,'CheckModel',true,@(x)islogical(x));


            parse(p,varargin{:});


            configBlockName=p.Results.Name;



            layerOnly=p.Results.LayerOnly;
            if layerOnly








                delayLength=30;
            else
                delayLength=p.Results.AdditionalDelayLength;
            end


            hLayers=p.Results.Layer;


            checkModel=p.Results.CheckModel;


            if isempty(hLayers)
                msg=message('dnnfpga:customLayer:EmptyLayerProperty');
                error(msg);
            end




            isSharedModel=isobject(hLayers)&&numel(hLayers)>1;


            if isSharedModel
                if isempty(configBlockName)
                    msg=message('dnnfpga:customLayer:EmptyNameProperty');
                    error(msg);
                end
                if layerOnly

                    msg=message('dnnfpga:customLayer:InvalidLayerOnlyPropertyValue');
                    error(msg);
                end
            end


            for layerIdx=1:numel(hLayers)
                hLayer=hLayers(layerIdx);


                obj.checkSupportedLayer(hLayer);


                if hLayer.NumInputs>2
                    msg=message('dnnfpga:customLayer:MoreThanTwoInputs');
                    error(msg);
                end


                if hLayer.NumOutputs>1
                    msg=message('dnnfpga:customLayer:MoreThanOneOutput');
                    error(msg);
                end










                hLayer=dltargets.internal.utils.NetworkUtils.replaceLayersWithRedirectedLayers(hLayer);


                userModel=p.Results.Model;
                [modelPath,modelName,modelExt]=fileparts(userModel);
                layerFuncContent=[];
                modelFullPath=fullfile(modelPath,strcat(modelName,modelExt));
                if startsWith(modelFullPath,matlabroot)
                    modelRelativePath="."+extractAfter(modelFullPath,matlabroot);
                else
                    modelRelativePath=modelFullPath;
                end

                if~layerOnly


                    if isempty(modelName)
                        msg=message('dnnfpga:customLayer:EmptyModelProperty',...
                        sprintf(obj.LayerRegisterExample,'myFile.slx'),...
                        sprintf(obj.LayerRegisterExample,'C:\myFolder\myFile.slx'));
                        error(msg);
                    end


                    if~isfile(userModel)&&isempty(which(userModel))
                        msg=message('dnnfpga:customLayer:ModelNotExist');
                        error(msg);
                    end


                    if checkModel
                        try
                            obj.checkCustomLayerModel(hLayer,modelName,modelFullPath,isSharedModel);
                        catch ME

                            bdclose(modelName);
                            throwAsCaller(ME);
                        end
                    end

                else





                    layerFilePath=which(class(hLayer));
                    if layerOnly
                        mt=mtree(layerFilePath,'-file');
                        fcns=mtfind(mt,'Kind','FUNCTION');
                        idxes=indices(fcns);
                        for idx=idxes
                            fcn=select(fcns,idx);
                            if strcmp(fcn.Fname.string,'predict')
                                layerFuncContent=fcn.tree2str;
                                break;
                            end
                        end


                        if isempty(layerFuncContent)
                            msg=message('dnnfpga:customLayer:ErrorParseLayer');
                            error(msg);
                        end
                    end
                end
                hLayers(layerIdx)=hLayer;
            end


            obj.addToLayerList(hLayers,layerFuncContent,modelName,configBlockName,delayLength,modelRelativePath,layerOnly);

        end

        function addToLayerList(obj,hLayers,layerFuncContent,modelName,configBlockName,delayLength,modelPath,layerOnly)




            for layerIdx=1:numel(hLayers)
                hLayer=hLayers(layerIdx);



                exist=false;
                propertyList=dnnfpga.customLayer.getProperties(hLayer);
                for existLayer=obj.LayerList
                    if isa(hLayer,existLayer.ClassName)
                        exist=true;
                        break;
                    end











                    for idx=1:numel(propertyList)
                        property=propertyList(idx).property;
                        for idy=1:numel(existLayer.PropertyValueList)
                            if strcmp(property,existLayer.PropertyValueList(idy).property)
                                msg=message('dnnfpga:customLayer:ExistedPropertyName',existLayer.ClassName,property);
                                error(msg);
                            end
                        end
                    end

                end







                if isempty(configBlockName)


                    splitNames=split(class(hLayer),'.');
                    configBlockName=splitNames{end};
                end


                if exist
                    classname=existLayer.ClassName;
                    existingModelPath=existLayer.ModelName;
                    msg=message('dnnfpga:customLayer:DuplicateCustomClass',classname,existingModelPath,configBlockName);
                    error(msg);
                else


                    for pvPair=propertyList
                        if~(isvector(pvPair.value)&&isnumeric(pvPair.value))
                            msg=message('dnnfpga:customLayer:UnsupportedProperty',configBlockName,pvPair.property);
                            error(msg);
                        end
                    end

                    if hLayer.NumInputs==1
                        inputListStr='layer,input1';
                    else
                        inputListStr='layer,input1,input2';
                    end






















                    blockName=sprintf('dnnfpgaLayer_%d',numel(obj.LayerList)+1);
                    functionContent=sprintf("function output = %s(%s)",blockName,inputListStr);
                    functionContent=horzcat(functionContent,'%#codegen');
                    functionContent=horzcat(functionContent,'coder.allowpcode(''plain'');');
                    functionContent=horzcat(functionContent,sprintf('\toutput = predict(%s);',inputListStr));
                    functionContent=horzcat(functionContent,'end');
                    functionContent=horzcat(functionContent,layerFuncContent);


                    Layer.DelayLength=delayLength;
                    Layer.ModelName=modelName;
                    Layer.ModelPath=modelPath;
                    Layer.LayerOnly=layerOnly;
                    Layer.NumInputs=hLayer.NumInputs;
                    Layer.NumOutputs=hLayer.NumOutputs;
                    Layer.InputNames=hLayer.InputNames;
                    Layer.OutputNames=hLayer.OutputNames;
                    Layer.ClassName=class(hLayer);
                    Layer.ConfigBlockName=configBlockName;
                    Layer.FunctionContent=strjoin(functionContent,'\n');
                    Layer.PropertyValueList=propertyList;
                    Layer.NumSharedLayers=numel(hLayers);
                    obj.LayerList=horzcat(obj.LayerList,Layer);



                    obj.updateCustomLayerModuleProperty(configBlockName);

                end
            end
        end

        function checkLayerList(obj)




















            if~isempty(obj.LayerList)
                for layer=obj.LayerList
                    modelName=layer.ModelName;













                    if isfield(layer,'ModelFullPath')
                        modelFullPath=layer.ModelFullPath;
                    else
                        modelPath=layer.ModelPath;
                        if startsWith(modelPath,'.')
                            modelFullPath=fullfile(matlabroot,modelPath);
                        else
                            modelFullPath=modelPath;
                        end
                    end

                    if~layer.LayerOnly
                        try



                            isSharedModel=layer.NumSharedLayers>1;
                            obj.checkCustomLayerModel(layer,modelName,modelFullPath,isSharedModel);
                        catch ME

                            bdclose(modelName);
                            rethrow(ME);
                        end
                    end
                end
            end
        end

        function[id,blockName]=getLayerInfo(obj,layer)
            id=0;
            blockName='';

            layerList=obj.getLayerList;
            for idx=1:numel(layerList)



                if isa(layer,layerList(idx).ClassName)
                    id=idx;
                    break;
                end
            end

            for currLayer=obj.LayerList
                if isa(layer,currLayer.ClassName)
                    blockName=currLayer.ConfigBlockName;
                    break;
                end
            end
        end

        function list=getLayerList(obj,ignoreModuleOnOff)







            if nargin<2
                ignoreModuleOnOff=false;
            end

            list=[];
            hPC=obj.ProcessorConfig;
            hModule=hPC.getModule(dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID);







            for layer=obj.LayerList
                if ignoreModuleOnOff||hModule.(layer.ConfigBlockName)
                    list=horzcat(list,layer);%#ok<AGROW> 
                end
            end
        end

        function list=getUserLayerList(obj)





            list=[];
            hPC=obj.ProcessorConfig;
            customLayerList=obj.getLayerList;
            hModule=hPC.getModule(dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID);
            defaultCustomLayerList=dnnfpga.customLayer.getDefaultSupportedLayers;







            for customLayer=customLayerList
                if hModule.(customLayer.ConfigBlockName)
                    switch customLayer.ClassName
                    case defaultCustomLayerList
                        continue;
                    otherwise
                        list=horzcat(list,customLayer);%#ok<AGROW> 
                    end
                end
            end
        end

        function list=getDefaultLayerList(obj,ignoreModuleOnOff)










            if nargin<2
                ignoreModuleOnOff=false;
            end

            list=[];
            hPC=obj.ProcessorConfig;
            customLayerList=obj.getLayerList(true);
            hModule=hPC.getModule(dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID);
            defaultCustomLayerList=dnnfpga.customLayer.getDefaultSupportedLayers;







            for customLayer=customLayerList
                if ignoreModuleOnOff||hModule.(customLayer.ConfigBlockName)
                    switch customLayer.ClassName
                    case defaultCustomLayerList
                        list=horzcat(list,customLayer);%#ok<AGROW> 
                    otherwise
                        continue;
                    end
                end
            end
        end

        function registerCustomBlocks=getRegisteredBlocksList(obj)
            registerCustomBlocks=obj.hRegisteredLayerList.getNameList;
        end

        function quantizationSupportedBlocks=getBlocksSupportedForQuantization(obj)
            quantizationSupportedBlocks=obj.hBlocksSupportedForQuantization;
        end

    end

    methods(Hidden,Access=protected)

        function checkCustomLayerModel(obj,hLayer,modelName,modelFullPath,isSharedModel)



            if~bdIsLoaded(modelName)
                load_system(modelFullPath);
            end








            if~bdIsSubsystem(modelName)
                msg=message('dnnfpga:customLayer:ModelIsNotSubsystem',modelName);
                error(msg);
            end


            inPorts=find_system(modelName,'regexp','on','blocktype','Inport');
            outPorts=find_system(modelName,'regexp','on','blocktype','Outport');











            inputPortsName=cell(1,numel(inPorts));
            for inPortsIdx=1:numel(inPorts)
                inputPortsName{inPortsIdx}=get_param(inPorts{inPortsIdx},'portName');
            end
            inputPortsName=unique(inputPortsName,'stable');

            outputPortsName=cell(1,numel(outPorts));
            for outPortsIdx=1:numel(outPorts)
                outputPortsName{outPortsIdx}=get_param(outPorts{outPortsIdx},'portName');
            end
            outputPortsName=unique(outputPortsName,'stable');













































            if isSharedModel
                minExtraInputPortsNum=3;
                maxExtraInputPortsNum=4;
                minExtraOutputPortsNum=1;
                maxExtraOutputPortsNum=2;
                diffInputOutputPortsNum=2;
            else
                minExtraInputPortsNum=2;
                maxExtraInputPortsNum=3;
                minExtraOutputPortsNum=1;
                maxExtraOutputPortsNum=2;
                diffInputOutputPortsNum=1;
            end
            extraInputPortsNum=numel(inputPortsName)-hLayer.NumInputs;
            extraOutputPortsNum=numel(outputPortsName)-hLayer.NumOutputs;

            if extraInputPortsNum<minExtraInputPortsNum||...
                extraInputPortsNum>maxExtraInputPortsNum||...
                extraInputPortsNum-diffInputOutputPortsNum~=extraOutputPortsNum

                msg=message('dnnfpga:customLayer:ModelPortsNumberMismatch',modelName,'input');
                error(msg);
            end

            if extraOutputPortsNum<minExtraOutputPortsNum||...
                extraOutputPortsNum>maxExtraOutputPortsNum||...
                extraOutputPortsNum~=extraInputPortsNum-diffInputOutputPortsNum

                msg=message('dnnfpga:customLayer:ModelPortsNumberMismatch',modelName,'output');
                error(msg);
            end











            requiredInputPortNames={'layer'};
            requiredInputPortNames=horzcat(requiredInputPortNames,hLayer.InputNames);
            requiredInputPortNames=horzcat(requiredInputPortNames,'inputValid');
            if isSharedModel
                requiredInputPortNames=horzcat(requiredInputPortNames,'select');
            end
            optionalInputPortNames={'outputReady'};
            optionalTF=obj.checkModelInputPortNames('input',modelName,inputPortsName,...
            requiredInputPortNames,optionalInputPortNames);






            expectedOutputPortNames=horzcat(hLayer.OutputNames,'outputValid');
            optionalOutputPortNames={'inputReady'};
            obj.checkModelOutputPortNames('output',modelName,outputPortsName,...
            expectedOutputPortNames,optionalInputPortNames,optionalOutputPortNames,optionalTF);


            bdclose(modelName);
        end

        function optionalTF=checkModelInputPortNames(~,direction,modelName,currentPortsName,...
            requiredInputPortNames,optionalInputPortNames)




            n1=numel(requiredInputPortNames);
            for i=1:n1
                portName=requiredInputPortNames{i};
                if~ismember(lower(portName),lower(currentPortsName))
                    msg=message('dnnfpga:customLayer:ModelPortsMissing',...
                    modelName,direction,...
                    portName,strjoin(requiredInputPortNames,', '));
                    error(msg);
                end
            end

            n2=numel(optionalInputPortNames);
            optionalTF=cell(1,n2);
            for i=1:n2
                portName=optionalInputPortNames{i};
                optionalTF{i}=ismember(lower(portName),lower(currentPortsName));
            end



            if~isequal(lower(currentPortsName(1:n1)),lower(requiredInputPortNames(1:n1)))
                msg=message('dnnfpga:customLayer:ModelPortsWrongOrdering',...
                direction,modelName,...
                strjoin(requiredInputPortNames,', '),...
                strjoin(currentPortsName,', '));
                error(msg);
            end
        end

        function checkModelOutputPortNames(~,direction,modelName,currentPortsName,...
            requiredOutputPortNames,optionalInputPortNames,optionalOutputPortNames,optionalTF)




            n1=numel(requiredOutputPortNames);
            for i=1:n1
                portName=requiredOutputPortNames{i};
                if~ismember(lower(portName),lower(currentPortsName))
                    msg=message('dnnfpga:customLayer:ModelPortsMissing',...
                    modelName,direction,...
                    portName,strjoin(requiredOutputPortNames,', '));
                    error(msg);
                end
            end


            n2=numel(optionalOutputPortNames);
            for i=1:n2
                outputPortName=optionalOutputPortNames{i};
                outputPortExists=ismember(lower(outputPortName),lower(currentPortsName));
                inputPortName=optionalInputPortNames{i};
                inputPortExists=optionalTF{i};
                if(outputPortExists&&inputPortExists)||(~inputPortExists&&~outputPortExists)

                elseif outputPortExists&&~inputPortExists
                    msg=message('dnnfpga:customLayer:OptionalModelPortsMissing',...
                    modelName,'output',outputPortName,'input',inputPortName);
                    error(msg);
                elseif~outputPortExists&&inputPortExists
                    msg=message('dnnfpga:customLayer:OptionalModelPortsMissing',...
                    modelName,'input',inputPortName,'output',outputPortName);
                    error(msg);
                end
            end



            if~isequal(lower(currentPortsName(1:n1)),lower(requiredOutputPortNames(1:n1)))
                msg=message('dnnfpga:customLayer:ModelPortsWrongOrdering',...
                direction,modelName,...
                strjoin(requiredOutputPortNames,','),...
                strjoin(currentPortsName,','));
                error(msg);
            end
        end

        function updateCustomLayerModuleProperty(obj,layerName)




            moduleID=dnnfpga.config.CustomLayerModuleConfigBase.DefaultModuleID;
            customLayerModule=obj.ProcessorConfig.getModule(moduleID);


            if~isprop(customLayerModule,layerName)
                customLayerModule.addprop(layerName);
                customLayerModule.updateModuleGenerationProperties(layerName);
            end


            if(any(strcmp(layerName,customLayerModule.DefaultOffModules)))
                customLayerModule.(layerName)=~customLayerModule.ModuleGenerationDefault;
            else
                customLayerModule.(layerName)=customLayerModule.ModuleGenerationDefault;
            end
        end


        function checkSupportedLayer(~,layer)









            supportedLayersClass={'nnet.layer.Layer',...
            'nnet.cnn.layer.AdditionLayer',...
            };
            valid=false;
            for idx=1:numel(supportedLayersClass)
                if isa(layer,supportedLayersClass{idx})
                    valid=true;
                    break;
                end
            end
            if~valid
                msg=message('dnnfpga:customLayer:UnsupportedLayer');
                error(msg);
            end
        end

    end
end



