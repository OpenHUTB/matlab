classdef StereotypeWrapper<systemcomposer.internal.propertyInspector.wrappers.ProfileWrapper


    properties
        stereotypeType;
    end

    methods
        function obj=StereotypeWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ProfileWrapper(varargin{:});
            obj.schemaType='Stereotype';
            list=obj.element.getCumulativeAppliesTo();
            if any(strcmpi(list,'Component'))||...
                any(strcmpi(list,'Architecture'))
                obj.stereotypeType='Component';
            elseif any(strcmpi(list,'Port'))
                obj.stereotypeType='Port';
            elseif any(strcmpi(list,'Interface'))
                obj.stereotypeType='Interface';
            elseif any(strcmpi(list,'Connector'))
                obj.stereotypeType='Connector';
            end
        end

        function tooltip=getNameTooltip(~,~)
            tooltip=DAStudio.message('SystemArchitecture:ProfileDesigner:PrototypeNameTooltip');
        end

        function tooltip=getDescTooltip(~,~)
            tooltip=DAStudio.message('SystemArchitecture:ProfileDesigner:PrototypeDescTooltip');
        end

        function[value,entries]=getAppliesTo(obj,~)
            entries=obj.getMetaclassEntries();
            value=obj.element.getExtendedElement();
            if isempty(value)
                value='<all>';
            end
        end

        function error=setAppliesTo(obj,changeSet,~)
            error='';
            newValue=changeSet.newValue;
            try
                txn=obj.beginTransaction();
                if strcmp(newValue,'<all>')
                    obj.element.setAppliesTo('');
                else
                    obj.element.setAppliesTo(newValue);
                end
                txn.commit;
            catch
                error='Failed to set applies to';
            end
        end

        function entries=getMetaclassEntries(~)
            entries={...
            '<all>',...
'Component'...
            ,'Port',...
            'Connector',...
'Interface'...
            };
            if slfeature('SoftwareModeling')>0
                entries{end+1}='Function';
                entries{end+1}='Task';
            end
        end

        function isAbstract=getAbstractValue(obj,~)
            isAbstract=obj.element.abstract;
        end


        function error=setAbstractValue(obj,changeSet,~)
            error='';
            newValue=changeSet.newValue;
            try
                txn=obj.beginTransaction();
                obj.element.abstract=newValue;
                txn.commit;
            catch
                error='Failed to set abstract';
            end
        end

        function iconClass=getIconClass(obj,~)
            iconPath='';
            stereotype=obj.element;
            iconClass='';

            if~isempty(stereotype.icon)
                iconName=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconEnum2Name(stereotype.icon);
                if systemcomposer.internal.profile.PrototypeIcon.CUSTOM~=stereotype.icon
                    iconPath=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath(iconName,stereotype.getExtendedElement);
                    icon=stereotype.icon;
                    iconClass=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconEnum2Name(icon);
                else
                    try
                        iconPath=stereotype.getCustomIconPath;
                    catch ex
                        MSLDiagnostic('SystemArchitecture:ProfileDesigner:CustomIconError',ex.message).reportAsWarning;
                    end
                end
            end
            if isempty(iconPath)

            end
        end

        function hexColor=getColor(obj,~)
            rgbaValue=obj.element.getComponentHeaderColorInRGB;
            rgbValue=transpose(rgbaValue(1:3));
            RGBValue=systemcomposer.internal.profile.internal.PrototypeLineColorPicker.getPaletteColor(rgbValue);
            hexColor=obj.rgb2hex(RGBValue);
        end

        function enabled=isComponentColorEnabled(obj,~)
            enabled=false;
            if strcmp(obj.stereotypeType,'Component')
                enabled=true;
            end
        end

        function enabled=isIconPickerEnabled(obj,~)
            enabled=false;
            if strcmp(obj.stereotypeType,'Component')
                enabled=true;
            end
        end

        function[value,entries]=getBaseStereotype(obj,~)
            entries={'<nothing>'};
            stereotype=obj.element;
            prototypeFQNs=arrayfun(@(x)x.fullyQualifiedName,obj.profile.prototypes.toArray,'uniformoutput',false);
            entries=[entries,prototypeFQNs];



            currElemName=stereotype.fullyQualifiedName;
            entries(strcmp(currElemName,entries))=[];

            value='<nothing>';
            if~isempty(stereotype.parent)
                value=stereotype.parent.fullyQualifiedName;
            end
        end

        function error=setBaseStereotype(obj,changeSet,~)
            error='';
            newValue=changeSet.newValue;
            try

            catch
                error='Failed to set applies to';
            end
        end

        function hex=rgb2hex(~,rgb)
            if max(rgb(:))<=1
                rgb=round(rgb*255);
            else
                rgb=round(rgb);
            end


            hex(:,2:7)=reshape(sprintf('%02X',rgb.'),6,[]).';
            hex(:,1)='#';
        end
    end
end



