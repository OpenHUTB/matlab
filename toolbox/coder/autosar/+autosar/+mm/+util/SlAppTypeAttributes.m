classdef SlAppTypeAttributes<handle









    properties(SetAccess=private,GetAccess=public)





        Min=[];
        Max=[];
        Unit='';
        Description='';

        SwCalibrationAccess=Simulink.metamodel.foundation.SwCalibrationAccessKind.ReadWrite;
        DisplayFormat='';
        SwAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod.empty(1,0);
        LookupTableData=[];
        Name='';
        ShouldMangle=true;
        IsValueType=false;
    end

    methods(Access=public)
        function this=SlAppTypeAttributes(min,max,unit,description,...
            swCalibrationAccess,displayFormat,swAddrMethod,lookupTableData,name)
            if nargin>0
                this.Min=min;
                this.Max=max;
                this.Unit=unit;
                if nargin>3
                    this.Description=description;
                    this.SwCalibrationAccess=swCalibrationAccess;
                    this.DisplayFormat=displayFormat;
                    this.SwAddrMethod=swAddrMethod;
                    this.LookupTableData=lookupTableData;
                    this.Name=name;
                end
            end
        end

        function newSlAppTypeAttributes=clone(this)
            newSlAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes(this.Min,this.Max,...
            this.Unit,this.Description,...
            this.SwCalibrationAccess,this.DisplayFormat,...
            this.SwAddrMethod,this.LookupTableData,...
            this.Name);
            newSlAppTypeAttributes.setShouldMangle(this.ShouldMangle);
            newSlAppTypeAttributes.setIsValueType(this.IsValueType);
        end




        function result=hasAnyAttributesSet(this)
            result=(~isempty(this.Max)&&~isempty(this.Min));
        end




        function isEquivalent=isEquivalentToM3iType(this,m3iType,modelName)

            isEquivalent=autosar.mm.util.MinMaxHelper.isSLMinMaxEqualToM3iMinMax(...
            m3iType,this.Min,this.Max,modelName);
        end

        function setName(this,name)
            this.Name=name;
        end

        function removeLookupTableData(this)
            this.LookupTableData=[];
        end

        function setShouldMangle(this,mangle)
            this.ShouldMangle=mangle;
        end

        function setIsValueType(this,isValType)
            this.IsValueType=isValType;
        end
    end
    methods(Static=true)


        function appTypeName=getAppTypeName(embeddedObj,maxShortNameLength,slMinNumeric,slMaxNumeric,modelName)
            assert(embeddedObj.isNumeric,'getAppTypeName only supports embeddedObj with numeric type.');
            assert(isnumeric(slMinNumeric)&&~isempty(slMinNumeric))
            assert(isnumeric(slMaxNumeric)&&~isempty(slMaxNumeric))
            typeName=autosar.mm.sl2mm.TypeBuilder.getFixedPointTypeName(embeddedObj,modelName);
            minStr=num2str(slMinNumeric);
            maxStr=num2str(slMaxNumeric);


            minStr=strrep(minStr,'-','n');
            maxStr=strrep(maxStr,'-','n');
            minStr=strrep(minStr,'.','p');
            maxStr=strrep(maxStr,'.','p');


            appTypeName=arxml.arxml_private...
            ('p_create_aridentifier',...
            [typeName,'_',minStr,'to',maxStr],...
            maxShortNameLength);
        end
    end
end



