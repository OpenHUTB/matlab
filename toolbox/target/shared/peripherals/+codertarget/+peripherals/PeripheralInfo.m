classdef PeripheralInfo<codertarget.Info





    properties(Access='public')

DefinitionFileName


        Name=''












PeripheralGroups



        OnPeripheralMappingApplyHook=''
    end

    methods(Access='public')
        function obj=PeripheralInfo(filePathName)

            if nargin==1
                obj.DefinitionFileName=filePathName;
                obj.deserialize();
            end
        end

        function lst=getListOfPeripherals(obj)
            lst={obj.PeripheralGroups.Name};
        end

        function maskType=getMaskTypeForPeripheral(obj,peripheralType)
            maskType=[];
            idx=find(strcmp({obj.PeripheralGroups.Name},peripheralType));
            if~isempty(idx)
                maskType=obj.PeripheralGroups(idx).Mask;
            end
        end

        function params=getGroupParameters(obj,type)


            params=[];
            idx=find(strcmp({obj.PeripheralGroups.Name},type));
            if~isempty(idx)
                params=obj.PeripheralGroups(idx).GroupParameters.Parameters;
                if~isempty(params)
                    params=[obj.PeripheralGroups(idx).GroupParameters.Parameters{:}];
                end
            end
        end

        function params=getBlockParameters(obj,type)



            params=[];
            idx=find(strcmp({obj.PeripheralGroups.Name},type));
            if~isempty(idx)
                params=obj.PeripheralGroups(idx).BlockParameters.Parameters;
                if~isempty(params)
                    params=[obj.PeripheralGroups(idx).BlockParameters.Parameters{:}];
                end
            end
        end

        function params=getParameters(obj,type)



            params=[];
            idx=find(strcmp({obj.PeripheralGroups.Name},type));
            if~isempty(idx)
                params=[obj.PeripheralGroups(idx).GroupParameters.Parameters{:}];
                params=[params,obj.PeripheralGroups(idx).BlockParameters.Parameters{:}];
            end
        end

        function info=getPeripheralGroupInfo(obj,type)
            info=[];
            idx=find(strcmp({obj.PeripheralGroups.Name},type));
            if~isempty(idx)
                info=obj.PeripheralGroups(idx);
            end
        end

        function names=getListOfParameterNames(obj,type)
            names=struct('Block',[],'Group',[]);
            idx=find(strcmp({obj.PeripheralGroups.Name},type));
            if~isempty(idx)
                params=obj.getGroupParameters(obj.PeripheralGroups(idx).Name);
                names.Group={params.Storage};

                params=obj.getBlockParameters(obj.PeripheralGroups(idx).Name);
                names.Block={params.Storage};
            end
        end

        function val=getParameterValue(obj,type,param)



            val=[];
            params=obj.getParameters(type);
            idx=find(strcmp({params.Storage},param));
            if~isempty(idx)
                val=params(idx);
            end
        end


        function ret=getDefinitionFileName(obj)
            ret=obj.DefinitionFileName;
        end

        function setDefinitionFileName(obj,name)
            obj.DefinitionFileName=name;
        end

        function ret=getName(obj)
            ret=obj.Name;
        end

        function setName(obj,name)
            obj.Name=name;
        end

        function out=getOnPeripheralMappingApplyHook(obj)
            out=obj.OnPeripheralMappingApplyHook;
        end

        function setOnPeripheralMappingApplyHook(obj,fcn)
            obj.OnPeripheralMappingApplyHook=fcn;
        end
    end

    methods(Access='public',Hidden,Static)
        function p=getDefaultParameter()


            attribs=codertarget.peripherals.PeripheralInfo.getDefaultAttributes();
            for i=1:length(attribs.names)
                p.(attribs.names{i})=attribs.values{i};
            end
        end
    end

    methods(Access='private',Static)
        function ret=getDefaultAttributes()


            ret.names={'Name','Type','Entries','Value','ValueType',...
            'ValueRange','Storage','Visible','Enable','Callback',...
            'Tag','CodeInfoValueName','CodeInfoValueType','HeaderFile'};

            ret.values={'','edit','','','','','','1','1',...
            'widgetChangedCallback','','','',''};
        end
    end

    methods(Access='private')
        function deserialize(obj)



            docObj=obj.read(obj.DefinitionFileName);

            infoTag=docObj.getElementsByTagName('peripheralsinfo');
            rootItem=infoTag.item(0);

            obj.Name=obj.getElement(rootItem,'name','char',0);

            obj.OnPeripheralMappingApplyHook=obj.getElement(rootItem,'onperipheralmappingapplyhook','char');

            groups=rootItem.getElementsByTagName('peripheralgroup');
            for i=1:groups.Length
                rootItem=groups.item(i-1);


                group=struct();
                group.Name=rootItem.getAttribute('Name');
                group.Mask=rootItem.getAttribute('Mask');

                groupParamNode=obj.getElementByTagName(rootItem,'groupparameters');
                group.GroupParameters=obj.getParameterInfoForNode(groupParamNode);

                blockParamNode=obj.getElementByTagName(rootItem,'blockparameters');
                group.BlockParameters=obj.getParameterInfoForNode(blockParamNode);

                if isempty(obj.PeripheralGroups)
                    obj.PeripheralGroups=group;
                else
                    obj.PeripheralGroups=[obj.PeripheralGroups,group];
                end
            end
        end


        function out=getElementByTagName(~,parent,tag)

            out=evaluate(matlab.io.xml.xpath.Evaluator,tag,parent);
        end

        function out=getParametersStruct(obj,parent)

            nodes=parent.getElementsByTagName('parameter');
            for j=1:nodes.Length
                param=nodes.item(j-1);
                theAttributes=param.getAttributes();
                attributes=obj.getDefaultParameter();
                for k=1:theAttributes.getLength()
                    attrib=theAttributes.item(k-1);
                    attributes.(char(attrib.getName))=char(attrib.getValue);
                end



                parentNode=param.getParentNode();
                if isequal(parentNode.getTagName(),'parametergroup')
                    parentAttributes=parentNode.getAttributes();
                    for k=1:parentAttributes.getLength()
                        attrib=parentAttributes.item(k-1);
                        attributes.Parent.(char(attrib.getName))=char(attrib.getValue);
                    end
                else
                    attributes.Parent='';
                end
                out(j)=attributes;%#ok<AGROW>
            end
        end

        function info=getParameterInfoForNode(obj,parent)












            info.ParameterTabs={};
            info.Parameters={};
            if isempty(parent),return,end
            groups=obj.getElementByTagName(parent,'parametergroup');


            for i=1:numel(groups)
                type=groups(i).getAttribute('Type');
                if isequal(type,'tab')

                    name=groups(i).getAttribute('Name');
                    tag=groups(i).getAttribute('Tag');
                    info.ParameterTabs{end+1}=struct('Name',name,'Tag',tag);
                end




                if isempty(info.ParameterTabs)
                    tabIndex=1;
                else
                    tabIndex=length(info.ParameterTabs);
                end
                info.Parameters{tabIndex}=obj.getParametersStruct(groups(i));
            end


            if isempty(groups)
                info.Parameters{1}=obj.getParametersStruct(parent);
            end
        end
    end
end


