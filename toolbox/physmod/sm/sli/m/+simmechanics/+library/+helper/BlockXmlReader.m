classdef BlockXmlReader<handle










    properties(SetAccess=private)
ParameterMap
PortMap
TypeName
TypeId
IconFile
InitialVersion
Position
MaskIconUnits
Orientation
    end

    methods

        function thisObj=BlockXmlReader(blockName)

            thisObj.ParameterMap=containers.Map;
            thisObj.PortMap=containers.Map;
            thisObj.Position=[0,0,0,0];
            thisObj.MaskIconUnits='normalized';
            thisObj.Orientation='right';

            docStruct=simmechanics.library.helper.parseXML([matlabroot,filesep,'toolbox',filesep...
            ,'physmod',filesep,'sm',filesep,'core',filesep,'src',filesep...
            ,'model',filesep,blockName,'.msg']);


            docStruct=traverseParameterStruct(thisObj,docStruct,blockName,0);


            thisObj.TypeName=getAttribute(thisObj,docStruct,'TypeName');
            thisObj.TypeId=getAttribute(thisObj,docStruct,'TypeId');
            thisObj.IconFile=getAttribute(thisObj,docStruct,'IconFile');
            thisObj.InitialVersion=getAttribute(thisObj,docStruct,'InitialVersion');

            posAttr=getAttribute(thisObj,docStruct,'Position');
            if~isempty(posAttr)
                thisObj.Position=str2num(posAttr);
            end

            iconUnits=getAttribute(thisObj,docStruct,'MaskIconUnits');
            if~isempty(iconUnits)
                thisObj.MaskIconUnits=iconUnits;
            end

            orientAttr=getAttribute(thisObj,docStruct,'Orientation');
            if~isempty(orientAttr)
                thisObj.Orientation=orientAttr;
            end


            foundFlag=0;
            [portStruct,foundFlag]=...
            traverseParameterStruct(thisObj,docStruct,'ports',foundFlag);
            if foundFlag
                parsePortStruct(thisObj,portStruct);
            end



            foundFlag=0;
            [docStruct,foundFlag]=...
            traverseParameterStruct(thisObj,docStruct,'parameters',foundFlag);
            if foundFlag
                parseParameterStruct(thisObj,docStruct);
            end
        end

        function blockInfo=generateBlockInfo(thisObj,srcFile,blkName,...
            varargin)
            includeUnitParams=true;
            if nargin==4
                includeUnitParams=varargin{1};
            end
            blockInfo=simmechanics.sli.internal.BlockInfo;

            blockInfo.SourceFile=which(srcFile);
            blockInfo.InitialVersion=thisObj.InitialVersion;
            make_params=@simmechanics.library.helper.make_params;

            blockInfo.SLBlockProperties.Name=blkName;
            blockInfo.SLBlockProperties.Position=thisObj.Position;
            blockInfo.SLBlockProperties.MaskIconUnits=thisObj.MaskIconUnits;
            blockInfo.SLBlockProperties.Orientation=thisObj.Orientation;


            blockInfo.IconFile=thisObj.IconFile;


            portKeys=thisObj.PortMap.keys;
            for i=1:length(portKeys)
                pInfo=thisObj.PortMap(portKeys{i});
                framePort=sm_ports_info(pInfo.Type);
                refName=pInfo.Label;
                refPort=simmechanics.sli.internal.PortInfo(framePort.PortType,...
                refName,pInfo.Side,refName);
                blockInfo.addPorts(refPort);
            end


            pKeys=thisObj.ParameterMap.keys;
            maskParams=[];

            for i=1:length(pKeys)
                pInfo=thisObj.ParameterMap(pKeys{i});

                if(~pInfo.uiIgnore)
                    switch(pInfo.Type)
                    case 'unittedvalue'
                        if includeUnitParams
                            newParams=make_params(pInfo.ParamName,pInfo.Value,...
                            pInfo.UnitParamName,pInfo.DefaultUnit,...
                            pInfo.runtimeType);
                        else
                            newParams=make_params(pInfo.ParamName,pInfo.Value,...
                            pInfo.runtimeType);
                        end
                    case 'choice'
                        newParams=make_params(pInfo.ParamName,pInfo.DefaultValue,...
                        pInfo.runtimeType);
                    case 'boolean'
                        newParams=make_params(pInfo.ParamName,pInfo.Value,...
                        pInfo.runtimeType);
                    case 'value'
                        newParams=make_params(pInfo.ParamName,pInfo.Value,...
                        pInfo.runtimeType);
                    end
                    newParams(1).Evaluate=pInfo.evalType;
                    newParams(1).ReadOnly=pInfo.readonlyType;
                    newParams(1).Hidden=pInfo.hiddenType;
                    newParams(1).Visible=pInfo.visibleType;
                    maskParams=[maskParams,newParams];
                end
            end

            blockInfo.addMaskParameters(maskParams);
        end
    end

    methods(Access=private)


        function parsePortStruct(thisObj,portStruct)
            for idx=1:size(portStruct,2)
                portType=getType(thisObj,portStruct(idx),'type');
                if strcmpi(portType,'frame')
                    portKey=portStruct(idx).Attributes(1).Value;
                    refStruct=traverseParameterStruct(thisObj,portStruct(idx),...
                    portKey,0);
                    pStruct.Type=portType;
                    pStruct.Label=getAttribute(thisObj,refStruct,'label');
                    pStruct.Side=getAttribute(thisObj,refStruct,'side');
                    thisObj.PortMap(portKey)=pStruct;
                end
            end

        end

        function defVal=getDefaultValue(thisObj,docStruct,paramStr)
            defCount=0;
            docStruct=traverseParameterStruct(thisObj,docStruct,paramStr);
            for idx=1:size(docStruct,2)
                defIdx=find(strcmpi({docStruct(idx).Attributes(:).Name},'default'));
                if(~isempty(defIdx)&&...
                    strcmpi(docStruct(idx).Attributes(defIdx).Value,'true'))
                    defCount=defCount+1;
                    if strcmpi(docStruct(idx).Name,'message')
                        defVal=docStruct(idx).Children.Data;
                    elseif strcmpi(docStruct(idx).Name,'table')
                        pa=removeStructComments(thisObj,docStruct(idx).Children);
                        defVal=getAttribute(thisObj,pa,'Param');
                    end
                end
            end
            if defCount==0
                defVal=[];
            elseif defCount>1
                warning('More than one default specified');
            end
        end

        function defVal=getDefaultUnit(thisObj,docStruct,paramStr)
            defVal=getDefaultValue(thisObj,docStruct,paramStr);
        end

        function defIdx=getDefaultChoiceIndex(thisObj,docStruct,paramStr)
            defCount=0;
            defIdx=0;
            docStruct=traverseParameterStruct(thisObj,docStruct,paramStr);
            for idx=1:size(docStruct,2)
                defKeyIdx=find(strcmpi({docStruct(idx).Attributes(:).Name},'default'));
                if(~isempty(defKeyIdx)&&...
                    strcmpi(docStruct(idx).Attributes(defKeyIdx).Value,'true'))
                    defCount=defCount+1;
                    defIdx=defKeyIdx;
                end
            end
            if defIdx==0
                error('Default not specified')
            end
        end

        function[choices,defVal]=getChoices(thisObj,docStruct,paramStr)
            choices={};
            if iscell(paramStr)
                rootNode=paramStr{1};
                srchParam=paramStr{2};
            else
                rootNode=paramStr;
                srchParam=rootNode;
            end
            docStruct=traverseParameterStruct(thisObj,docStruct,rootNode,0);
            choiceIdx=1;
            for idxM=1:size(docStruct,2)
                if strcmpi(docStruct(idxM).Name,'table')
                    pa=removeStructComments(thisObj,docStruct(idxM).Children);
                    choices{choiceIdx}=getAttribute(thisObj,pa,srchParam);
                    choiceIdx=choiceIdx+1;
                else
                    choices{choiceIdx}=docStruct(idxM).Children.Data;
                    choiceIdx=choiceIdx+1;
                end
            end
        end

        function attrVal=getAttribute(thisObj,docStruct,attrName)
            idxM=1;
            attrVal='';
            while(idxM<=size(docStruct,2))
                if strcmpi(docStruct(idxM).Name,'message')
                    if(strcmpi({docStruct(idxM).Attributes(:).Value},attrName))
                        attrVal=strtrim(docStruct(idxM).Children.Data);
                        break
                    end
                end
                idxM=idxM+1;
            end
        end

        function thisObj=parseParameterStruct(thisObj,docStruct)
            docStruct=removeStructComments(thisObj,docStruct);
            idx=1;
            while(idx<=size(docStruct,2))
                paramType=getType(thisObj,docStruct(idx),'type');
                if any(strcmpi(paramType,{'group',''}))
                    parseParameterStruct(thisObj,docStruct(idx).Children);
                else
                    pStruct={};
                    pStruct.Type=paramType;
                    pStruct.runtimeType=str2bool(thisObj,...
                    getType(thisObj,docStruct(idx),'runtime'));
                    pStruct.evalType=str2bool(thisObj,...
                    getType(thisObj,docStruct(idx),'evaluate'));

                    readonlyType=getType(thisObj,docStruct(idx),'readonly');
                    if isempty(readonlyType)
                        pStruct.readonlyType=false;
                    else
                        pStruct.readonlyType=str2bool(thisObj,readonlyType);
                    end

                    hiddenType=getType(thisObj,docStruct(idx),'hidden');
                    if isempty(hiddenType)
                        pStruct.hiddenType=false;
                    else
                        pStruct.hiddenType=str2bool(thisObj,hiddenType);
                    end

                    visibleType=getType(thisObj,docStruct(idx),'visible');
                    if isempty(visibleType)
                        pStruct.visibleType=true;
                    else
                        pStruct.visibleType=str2bool(thisObj,visibleType);
                    end

                    uiIgnore=getType(thisObj,docStruct(idx),'uiIgnore');
                    if isempty(uiIgnore)
                        pStruct.uiIgnore=false;
                    else
                        pStruct.uiIgnore=str2bool(thisObj,uiIgnore);
                    end


                    pa=traverseParameterStruct(thisObj,docStruct(idx),paramType,0);


                    extraParams=getExtraParams(thisObj,pa);
                    if~isempty(extraParams)
                        for exIdx=1:numel(extraParams)
                            pStruct.(extraParams{exIdx})=...
                            getAttribute(thisObj,pa,extraParams(exIdx));
                        end
                    end


                    pStruct.XmlTag=getAttribute(thisObj,pa,'XmlTag');
                    pStruct.DispName=getAttribute(thisObj,pa,'DispName');
                    pStruct.ParamName=getAttribute(thisObj,pa,'ParamName');
                    switch(pStruct.Type)
                    case 'unittedvalue'
                        pStruct.Value=getAttribute(thisObj,pa,'value');

                        pa=traverseParameterStruct(thisObj,pa,'choice',0);
                        pStruct.UnitParamName=getAttribute(thisObj,pa,'ParamName');
                        pStruct.UnitChoices=getChoices(thisObj,pa,'values');
                        pStruct.DefaultUnit=getDefaultUnit(thisObj,pa,'values');
                    case 'choice'

                        pStruct.ParamChoices=getChoices(thisObj,pa,{'values','Param'});
                        pStruct.DisplayChoices=getChoices(thisObj,pa,{'values','Disp'});
                        pStruct.DefaultValue=getDefaultValue(thisObj,pa,'values');

                        [pVal,flag]=traverseParameterStruct(thisObj,pa,'values',0);
                        if flag
                            parseParameterStruct(thisObj,pVal);
                        end
                    case 'boolean'
                        pStruct.Value=validatestring(getAttribute(thisObj,pa,'Value'),...
                        {'on','off'});
                    case 'value'
                        pStruct.Value=getAttribute(thisObj,pa,'Value');
                    end
                    keyVal=getType(thisObj,docStruct(idx),'id');
                    thisObj.ParameterMap(keyVal)=pStruct;
                end
                idx=idx+1;
            end
        end

        function typeStr=getType(thisObj,docStruct,NameStr)
            typeStr='';
            for idx=1:size(docStruct.Attributes,2)
                if(strcmpi(docStruct.Attributes(idx).Name,NameStr))
                    typeStr=strtrim(docStruct.Attributes(idx).Value);
                    break
                end
            end
        end

        function extraParams=getExtraParams(thisObj,pa)
            extraParams={};
            expectedParams={'ParamName','XmlTag','DispName','Value','unit',...
            'choice','values'};
            pList=[pa(:).Attributes];
            paramList={pList(:).Value};

            exIdx=1;
            for idx=1:numel(paramList)
                if~any(strcmpi(paramList(idx),expectedParams))
                    extraParams(exIdx)=paramList(idx);
                    exIdx=exIdx+1;
                end
            end
        end

        function[pSend,foundFlag]=traverseParameterStruct(thisObj,pa,paramStr,foundFlag)
            idxT=1;
            pSend=removeStructComments(thisObj,pa);
            while(idxT<=size(pa,2))
                if strcmpi(pa(idxT).Name,'table')
                    if any(strcmpi({pa(idxT).Attributes(:).Value},paramStr))
                        foundFlag=1;
                        pSend=pa(idxT).Children;
                        pSend=removeStructComments(thisObj,pSend);
                        break
                    else
                        if~isempty(pa(idxT).Children)

                            [pSend,foundFlag]=traverseParameterStruct...
                            (thisObj,pa(idxT).Children,paramStr,foundFlag);
                        else
                            break
                        end

                    end
                end
                idxT=idxT+1;
            end
        end

        function docStruct=removeStructComments(thisObj,docStruct)
            idx=1;
            while(idx<=numel(docStruct))
                if(strcmp(docStruct(idx).Name,'#comment')||...
                    strcmp(docStruct(idx).Name,'#text'))
                    docStruct(idx)=[];
                end
                idx=idx+1;
            end
        end

        function boolVal=str2bool(thisObj,strVal)
            validatestring(strVal,{'true','false'});
            boolVal=strcmpi(strVal,'true');
        end
    end
end
