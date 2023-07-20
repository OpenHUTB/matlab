classdef(Sealed=true)BoardInfo<handle




    properties(Constant=true,Hidden=true)
        NAME_TAG='name';
        DISPLAYNAME_TAG='displayName';
        ID_TAG='id';
        UDFILENAME_TAG='file';
        REQUIREDCODEGENHOOKPOINT_TAG='reqCG';
        REQUIREDSUBFAMILY_TAG='reqSF';
        REQUIREDDEVICEID_TAG='reqDevID';
    end

    properties(SetAccess='private',GetAccess='public')
        Name='';
        DisplayName='';
        ID='';
        UDFileName='';
        Platforms={};
    end

    properties(SetAccess='private',GetAccess='public',Dependent=true)
DSPBIOSDefined
    end

    properties(Access='private')
        RequiredCodeGenHookPoint='';
        RequiredSubFamily='';
        RequiredDeviceID='';
    end

    methods(Access='private')
        function initializeFromXML(h,xmlNode)
            if(~isjava(xmlNode))
                return;
            end
            attributes=xmlNode.getAttributes();
            h.Name=attributes;
            h.DisplayName=attributes;
            h.ID=attributes;
            h.UDFileName=attributes;
            h.RequiredCodeGenHookPoint=attributes;
            h.RequiredSubFamily=attributes;
            h.RequiredDeviceID=attributes;
            h.Platforms=attributes;
        end

        function value=getValueFromXMLAttributes(~,xmlAttributes,attributeName)
            value='';
            if(~isjava(xmlAttributes))
                return;
            end
            attribute=xmlAttributes.getNamedItem(attributeName);
            if(isempty(attribute))
                return;
            end
            value=char(attribute.getNodeValue());
        end
    end

    methods(Access='public')
        function h=BoardInfo(src)
            if(0~=nargin)
                if(isjava(src))
                    h.initializeFromXML(src);
                end
            end
        end


        function ret=isProcessorSupported(h,procInfo)
            ret=false;
            if(~isempty(h.RequiredCodeGenHookPoint))
                if(isempty(regexp(procInfo.codegenhookpoint,h.RequiredCodeGenHookPoint,'once')))
                    return;
                end
            end
            if(~isempty(h.RequiredSubFamily))
                if(isempty(regexp(procInfo.subFamily,h.RequiredSubFamily,'once')))
                    return;
                end
            end
            if(~isempty(h.RequiredDeviceID))
                if(isempty(regexp(procInfo.deviceID,h.RequiredDeviceID,'once')))
                    return;
                end
            end
            ret=true;
        end


        function ret=isPlatformSupported(h,platform)
            if(2>nargin)
                platform=computer;
            end
            ret=any(strcmp(platform,h.Platforms));
        end
    end

    methods
        function value=get.Name(h)
            value=h.Name;
        end
        function set.Name(h,value)
            h.Name=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.NAME_TAG);
        end
        function value=get.DisplayName(h)
            value=h.DisplayName;
        end
        function set.DisplayName(h,value)
            h.DisplayName=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.DISPLAYNAME_TAG);
            if(isempty(h.DisplayName))
                h.DisplayName=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.NAME_TAG);
            end
        end
        function value=get.DSPBIOSDefined(h)
            value=~isempty(regexp(h.RequiredSubFamily,'64x+','once'));
        end
        function value=get.ID(h)
            value=h.ID;
        end
        function set.ID(h,value)
            h.ID=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.ID_TAG);
        end
        function value=get.UDFileName(h)
            value=h.UDFileName;
        end
        function set.UDFileName(h,value)
            h.UDFileName=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.UDFILENAME_TAG);
        end
        function value=get.Platforms(h)
            value=h.Platforms;
        end
        function set.RequiredCodeGenHookPoint(h,value)
            h.RequiredCodeGenHookPoint=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.REQUIREDCODEGENHOOKPOINT_TAG);
        end
        function set.RequiredSubFamily(h,value)
            h.RequiredSubFamily=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.REQUIREDSUBFAMILY_TAG);
        end
        function set.RequiredDeviceID(h,value)
            h.RequiredDeviceID=h.getValueFromXMLAttributes(value,linkfoundation.pjtgenerator.BoardInfo.REQUIREDDEVICEID_TAG);
        end

        function set.Platforms(h,values)




















            if(~isjava(values))

                h.Platforms={'PCWIN','PCWIN64','GLNX86','GLNXA64','MACI','MACI64'};
                return;
            end

            attributes=values;

            supportedPlatforms=attributes.getNamedItem('supportedPlatforms');
            if(~isempty(supportedPlatforms))
                supportedPlatforms=char(supportedPlatforms.getNodeValue());
            end

            unsupportedPlatforms=attributes.getNamedItem('unsupportedPlatforms');
            if(~isempty(unsupportedPlatforms))
                unsupportedPlatforms=char(unsupportedPlatforms.getNodeValue());
            end

            if(isempty(supportedPlatforms))
                h.Platforms={'PCWIN','PCWIN64','GLNX86','GLNXA64','MACI','MACI64'};
            else
                h.Platforms=textscan(supportedPlatforms,'%s','Delimiter',',;: ');
                h.Platforms=h.Platforms{1};
            end

            if(~isempty(unsupportedPlatforms))
                unsupportedPlatforms=textscan(unsupportedPlatforms,'%s','Delimiter',',;: ');
                unsupportedPlatforms=unsupportedPlatforms{1};
                for index=1:length(unsupportedPlatforms)

                    h.Platforms=regexprep(h.Platforms,['^',unsupportedPlatforms{index},'$'],'','ignorecase');
                end
            end
        end
    end


    methods

        function test=eq(obj1,obj2)
            try
                if(~isempty(obj1)&&~isempty(obj2)&&isa(obj2,class(obj1)))
                    test=strcmpi(obj1.ID,obj2.ID);
                else
                    test=false;
                end
            catch ex %#ok<NASGU>
                test=false;
            end
        end

        function test=ne(obj1,obj2)
            test=~(obj1==obj2);
        end
    end

end
