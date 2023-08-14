classdef(Sealed=true)ParameterInfo<codertarget.Info





    properties(Access='public')
        DefinitionFileName;

        Name='';
        TargetName='';
        ParameterGroups={};
        Parameters={};
    end

    methods(Access='public')
        function h=ParameterInfo(filePathName)
            if nargin==1
                h.DefinitionFileName=filePathName;
                h.deserialize();
            end
        end
        function register(h)
            h.serialize();
        end
        function ret=getDefinitionFileName(h)
            ret=h.DefinitionFileName;
        end
        function setDefinitionFileName(h,name)
            h.DefinitionFileName=name;
        end
        function ret=getName(h)
            ret=h.Name;
        end
        function setName(h,name)
            h.Name=name;
        end
        function ret=getTargetName(h)
            ret=h.TargetName;
        end
        function setTargetName(h,name)
            h.TargetName=name;
        end
        function ret=getParameterGroups(h)
            ret=h.ParameterGroups;
        end
        function addParameterGroup(h,name)
            h.ParameterGroups{end+1}=name;
        end
        function ret=getParameters(h)
            ret=h.Parameters;
        end
        function addParameter(h,varargin)
            narginchk(3,1000);
            attribs=h.getDefaultAttributes();
            attributes=attribs.names;
            knownProps=union('Group',attributes);
            properties=varargin(1:2:end);
            values=varargin(2:2:end);
            p=h.getDefaultParameter();
            if isequal(numel(properties),numel(values))&&...
                isempty(setdiff(union(properties,knownProps),knownProps))
                for i=1:numel(properties)
                    p.(properties{i})=values{i};
                end
                [found,idx]=ismember(p.Group,h.getParameterGroups());
                if found
                    h.Parameters{idx}{end+1}=p;
                else
                    h.addParameterGroup(p.Group);
                    h.Parameters{numel(h.getParameterGroups())}{1}=p;
                end
            else
                error('Error specifying parameter attributes');
            end
        end
    end

    methods(Access='public',Hidden,Static)
        function p=getDefaultParameter()
            attribs=codertarget.parameter.ParameterInfo.getDefaultAttributes();
            for i=1:length(attribs.names)
                p.(attribs.names{i})=attribs.values{i};
            end
        end
    end

    methods(Access='private',Static)
        function ret=getDefaultAttributes()
            ret.names={'Name','Type','Tag','Enabled','Visible','Value',...
            'Data','RowSpan','ColSpan','Alignment','DialogRefresh',...
            'Storage','DoNotStore','Callback','SaveValueAsString',...
            'Entries','ValueType','ValueRange','ToolTip','EntriesType'};
            ret.values={'','edit','','1','1','',...
            '','[0,0]','[1,3]','1','1',...
            '','false','widgetChangedCallback','false',...
            '','','','',''};
        end
    end

    methods(Access='private')
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function serialize(h)
            docObj=h.createDocument('productinfo');
            docRootNode=docObj.getDocumentElement();

            h.setElement(docObj,'name',h.getName());

            groups=h.getParameterGroups();
            for i=1:numel(groups)
                group=h.createParameterGroup(docObj,docRootNode,'parametergroup');
                h.setElement(docObj,'name',groups{i},group);

                allparams=h.getParameters();
                params=allparams{i};
                for j=1:numel(params)
                    param=params{j};
                    parameter=h.createParameter(docObj,group,'parameter');
                    attribs=h.getDefaultAttributes();
                    attributes=attribs.names;
                    for k=1:numel(attributes)
                        try
                            h.setAttribute(parameter,attributes{k},param.(attributes{k}));
                        catch
                        end
                    end
                end
            end

            targetFolder=codertarget.target.getTargetFolder(h.getTargetName());
            folder=codertarget.target.getParameterRegistryFolder(targetFolder);
            fileName=fullfile(folder,h.getShortDefinitionFileName());
            fileName=codertarget.utils.replacePathSep(fileName);
            h.write(fileName,docObj);
        end

        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);

            allItems=docObj.getElementsByTagName('name');
            item=allItems.item(0);
            h.Name=char(item.getFirstChild.getData());

            allItems=docObj.getElementsByTagName('parametergroup');
            for groupIdx=0:allItems.getLength()-1
                theNode=allItems.item(groupIdx);
                if theNode.hasChildNodes
                    childNodes=theNode.getChildNodes();
                    numChildNodes=childNodes.getLength();
                    paramIdx=0;

                    for count=1:numChildNodes
                        theChild=childNodes.item(count-1);
                        if theChild.hasAttributes

                            theAttributes=theChild.getAttributes();
                            attributes=h.getDefaultParameter();
                            for k=1:theAttributes.getLength()
                                attrib=theAttributes.item(k-1);
                                attributes.(char(attrib.getName))=char(attrib.getValue);
                            end
                            h.Parameters{groupIdx+1}{paramIdx+1}=attributes;
                            paramIdx=paramIdx+1;
                        elseif theChild.hasChildNodes

                            a=theChild.getFirstChild.getData();
                            h.ParameterGroups{end+1}=char(a);
                        end
                    end
                end
            end
        end
    end
end
