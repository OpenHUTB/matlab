classdef(Sealed=true)ThirdPartyToolInfo<matlab.mixin.SetGet





    properties(Access='public')
        DefinitionFileName;

        Name='';
        TargetName='';
        ThirdPartyTools={};
        TransformPath=true;
    end

    methods(Access='public')
        function h=ThirdPartyToolInfo(filePathName,varargin)
            if nargin==1
                h.DefinitionFileName=filePathName;
                h.deserialize();
            elseif nargin==2
                h.DefinitionFileName=filePathName;
                h.TransformPath=varargin{1};
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
        function ret=getThirdPartyTools(h)
            ret=h.ThirdPartyTools;
        end
        function addTool(h,varargin)
            narginchk(3,1000);
            properties={varargin{1:2:end}};
            values={varargin{2:2:end}};
            p=h.getDefaultToolchainItem();
            assert(isequal(numel(properties),numel(values)));
            for i=1:numel(properties)
                p.(properties{i})=values{i};
            end

            found=false;
            existingTools=h.getThirdPartyTools();
            for i=1:numel(existingTools)
                if isequal(existingTools{i}{1}.ToolName,...
                    p.ToolName)
                    h.ThirdPartyTools{i}{1}=p;
                    found=true;
                end
            end
            if~found
                h.ThirdPartyTools{end+1}{1}=p;
            end
        end
    end

    methods(Access='private')
        function ret=getDefaultAttributes(h)
            ret.names={'ToolName','Category','RootFolder','TokenName'};
            ret.values={'','','',''};
        end
        function p=getDefaultToolchainItem(h)
            attribs=h.getDefaultAttributes();
            for i=1:length(attribs.names)
                p.(attribs.names{i})=attribs.values{i};
            end
        end
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function serialize(h)
            infoObj=codertarget.Info;
            docObj=infoObj.createDocument('productinfo');
            docRootNode=docObj.getDocumentElement;
            thisElement=docObj.createElement('name');
            thisElement.appendChild(docObj.createTextNode(h.getName()));
            docRootNode.appendChild(thisElement);
            allAttributeSets=h.getThirdPartyTools();
            for i=1:numel(allAttributeSets)
                thisElement=docObj.createElement('thirdpartytool');
                attributes=allAttributeSets{i};
                for j=1:numel(attributes)
                    curAttribute=attributes{j};
                    thisElementChild2=docObj.createElement('thirdpartytoolattribute');
                    attribs=h.getDefaultAttributes();
                    attributes=attribs.names;
                    for k=1:numel(attributes)
                        try
                            thisElementChild2.setAttribute(attributes{k},curAttribute.(attributes{k}));
                        catch e
                            z=1;
                        end
                    end
                    thisElement.appendChild(thisElementChild2);
                end
                docRootNode.appendChild(thisElement);
            end
            targetFolder=codertarget.target.getTargetFolder(h.getTargetName);
            folder=codertarget.target.getThirdPartyToolsRegistryFolder(targetFolder);
            name=fullfile(folder,h.getShortDefinitionFileName());
            name=codertarget.utils.replacePathSep(name);
            infoObj.write(name,docObj);
        end
        function deserialize(h)
            infoObj=codertarget.Info;
            docObj=infoObj.read(h.DefinitionFileName);
            allItems=docObj.getElementsByTagName('name');
            item=allItems.item(0);
            h.Name=char(item.getFirstChild.getData());
            allItems=docObj.getElementsByTagName('thirdpartytool');
            for groupIdx=0:allItems.getLength()-1;
                theNode=allItems.item(groupIdx);
                if theNode.hasChildNodes
                    childNodes=theNode.getChildNodes();
                    numChildNodes=childNodes.getLength();
                    paramIdx=0;
                    for count=1:numChildNodes
                        theChild=childNodes.item(count-1);
                        if theChild.hasAttributes
                            theAttributes=theChild.getAttributes();
                            attributes=getDefaultToolchainItem(h);
                            for k=1:theAttributes.getLength()
                                attrib=theAttributes.item(k-1);
                                if ispc&&isequal(char(attrib.getName),'RootFolder')
                                    value=char(attrib.getValue);
                                    if h.TransformPath




                                        value=coder.make.internal.transformPaths(value,'pathType','alternate','ignoreErrors',true);
                                    end
                                    attributes.(char(attrib.getName))=value;
                                else
                                    attributes.(char(attrib.getName))=char(attrib.getValue);
                                end
                            end
                            h.ThirdPartyTools{groupIdx+1}{paramIdx+1}=attributes;
                            paramIdx=paramIdx+1;
                        end
                    end
                end
            end
        end
    end
end
