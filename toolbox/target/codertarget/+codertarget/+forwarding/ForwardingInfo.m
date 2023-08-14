classdef(Sealed=true)ForwardingInfo<codertarget.Info

















    properties(Access='public')

DefinitionFileName


        Parameters={};


        TargetName='';
    end

    methods(Access='public')
        function h=ForwardingInfo(filePathName)
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
        function ret=getParameters(h)
            ret=h.Parameters;
        end
        function ret=getTargetName(h)
            ret=h.TargetName;
        end
        function setTargetName(h,name)
            h.TargetName=name;
        end
        function addParameter(h,varargin)






            narginchk(2,2);
            param=h.getDefaultParameterAttributes();
            attributes=h.getDefaultAttributes();
            attributes=attributes.names;
            for i=1:numel(attributes)
                if isfield(varargin{1},attributes{i})
                    param.(attributes{i})=varargin{1}.(attributes{i});
                end
            end
            h.Parameters{end+1}=param;
        end
    end

    methods(Access='public',Hidden,Static)
        function attribs=getDefaultParameterAttributes()
            attributes=codertarget.forwarding.ForwardingInfo.getDefaultAttributes();
            for i=1:length(attributes.names)
                attribs.(attributes.names{i})=attributes.values{i};
            end
        end
    end

    methods(Access='private',Static)
        function attribs=getDefaultAttributes()



            attribs.names={'Name','NewName','Value','NewValue','Scope','ForwardingFcn'};
            attribs.values={'','','','','CoderTarget',''};
        end
    end

    methods(Access='private')
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end

        function serialize(h)
            docObj=h.createDocument('forwardinginfo');
            docRootNode=docObj.getDocumentElement();

            params=h.getParameters();
            for i=1:numel(params)
                param=params{i};
                parameter=h.createParameter(docObj,docRootNode,'parameter');
                attribs=h.getDefaultAttributes();
                attributes=attribs.names;
                for k=1:numel(attributes)
                    try
                        attrValue=param.(attributes{k});
                        if~isempty(attrValue)
                            h.setAttribute(parameter,attributes{k},attrValue);
                        end
                    catch
                    end
                end
            end

            targetFolder=codertarget.target.getTargetFolder(h.getTargetName());
            folder=codertarget.forwarding.getRegistryFolder(targetFolder);
            fileName=fullfile(folder,h.getShortDefinitionFileName());
            fileName=codertarget.utils.replacePathSep(fileName);
            h.write(fileName,docObj);
        end

        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);

            items=docObj.getElementsByTagName('parameter');
            for param=0:items.getLength()-1
                theNode=items.item(param);
                if theNode.HasAttributes
                    theAttributes=theNode.getAttributes();
                    attributes=h.getDefaultParameterAttributes();
                    for k=1:theAttributes.getLength()
                        attrib=theAttributes.item(k-1);
                        attributes.(char(attrib.getName))=char(attrib.getValue);
                    end
                    h.Parameters{param+1}=attributes;
                end
            end
        end
    end
end
