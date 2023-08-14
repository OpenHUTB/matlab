classdef LookupTableControlMetaField<lutdesigner.data.source.DataSource

    properties(SetAccess=immutable,GetAccess=private)
MaskOwnerPath
ControlName
PropertyAccessStrategy
MetaFieldName
    end

    methods
        function this=LookupTableControlMetaField(maskOwner,controlName,propertyAccessStrategy,metaFieldName)
            maskOwnerPath=regexprep(getfullname(maskOwner),'\n',' ');
            mustBeValidVariableName(controlName);
            validateattributes(propertyAccessStrategy,{'lutdesigner.data.source.lookuptablecontrol.PropertyAccessStrategy'},{'scalar'});
            mustBeValidVariableName(metaFieldName);

            this=this@lutdesigner.data.source.DataSource(...
            'mask lookuptablecontrol',...
            [maskOwnerPath,'/',controlName],...
            [propertyAccessStrategy.Identifier,'.',metaFieldName]);
            this.MaskOwnerPath=maskOwnerPath;
            this.ControlName=controlName;
            this.PropertyAccessStrategy=propertyAccessStrategy;
            this.MetaFieldName=metaFieldName;
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(~)
            import lutdesigner.data.restriction.ReadRestriction
            restrictions=ReadRestriction.empty();
        end

        function restrictions=getWriteRestrictionsImpl(~)
            import lutdesigner.data.restriction.WriteRestriction
            restrictions=WriteRestriction('lutdesigner:data:editMaskControlMetaFieldLimitation');
        end

        function data=readImpl(this)
            propertyControl=this.getPropertyControl();
            data=propertyControl.(this.MetaFieldName);
        end

        function writeImpl(~,~)

        end
    end

    methods(Access=private)
        function propertyControl=getPropertyControl(this)
            mask=Simulink.Mask.get(this.MaskOwnerPath);
            lookupTableControl=mask.getDialogControl(this.ControlName);
            propertyControl=this.PropertyAccessStrategy.getControl(lookupTableControl);
        end
    end
end
