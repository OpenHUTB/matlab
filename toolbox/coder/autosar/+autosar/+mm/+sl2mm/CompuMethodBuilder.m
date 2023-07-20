classdef CompuMethodBuilder<handle
















    properties(Access=private)
        M3iModel;
        M3iCompuMethodPkg;
        UnitBuilder;
        MaxShortNameLength;
        App2CompuMethodMap;
    end
    methods(Access=public)
        function this=CompuMethodBuilder(m3iModel,maxShortNameLength)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.util.ExternalToolInfoAdapter;

            this.M3iModel=m3iModel;
            m3iRoot=m3iModel.RootPackage.at(1);
            compuPackage=XmlOptionsAdapter.get(m3iRoot,'CompuMethodPackage');
            if isempty(compuPackage)
                compuPackage=[m3iRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.CompuMethods];
                XmlOptionsAdapter.set(m3iRoot,'CompuMethodPackage',compuPackage);
            end
            this.M3iCompuMethodPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,...
            compuPackage);
            this.UnitBuilder=autosar.mm.sl2mm.UnitBuilder(m3iModel,...
            maxShortNameLength);
            this.MaxShortNameLength=maxShortNameLength;
            this.App2CompuMethodMap=containers.Map();
            arRoot=m3iModel.RootPackage.front();
            m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(arRoot,...
            Simulink.metamodel.types.CompuMethod.MetaClass,true);
            for ii=1:m3iSeq.size()
                slDataTypes=ExternalToolInfoAdapter.get(m3iSeq.at(ii),...
                autosar.ui.metamodel.PackageString.SlDataTypes);
                for jj=1:numel(slDataTypes)
                    this.App2CompuMethodMap(slDataTypes{jj})=m3iSeq.at(ii);
                end
            end
        end









        function findOrCreateCompuMethodForAppType(this,m3iAppType,varargin)
            assert(isa(m3iAppType,'Simulink.metamodel.types.PrimitiveType'),...
            ['api autosar.mm.sl2mm.CompuMethodBuilder.findOrCreateCompuMethodForAppType is called for wrong type ',class(m3iAppType),'.']);
            assert(m3iAppType.IsApplication,'m3iAppType should be an application type');


            p=inputParser;
            p.addParameter('UnmangledAppTypeName',m3iAppType.Name);
            p.addParameter('SlUnitName','');
            p.parse(varargin{:});

            this.findOrCreateCompuMethodInternal(m3iAppType,true,p.Results.UnmangledAppTypeName,p.Results.SlUnitName);
            this.addDefaultUnit(m3iAppType.CompuMethod,'');
        end




        function findOrCreateCompuMethodForImpType(this,m3iImpType)
            assert(isa(m3iImpType,'Simulink.metamodel.types.PrimitiveType'),...
            ['api autosar.mm.sl2mm.CompuMethodBuilder.findOrCreateCompuMethodForImpType is called for wrong type ',class(m3iImpType),'.']);
            assert(~m3iImpType.IsApplication,'m3iImpType should be an implementation type');

            this.findOrCreateCompuMethodInternal(m3iImpType,false,m3iImpType.Name,'');
            if m3iImpType.CompuMethod.isvalid()
                this.addDefaultUnit(m3iImpType.CompuMethod,'');
            end
        end






        function m3iCompuMethod=createRatFuncCompuMethod(this,...
            compuMethodName,paramObj,implType)
            arPkg=this.M3iModel.RootPackage.at(1);
            compuMethodName=arxml.arxml_private('p_create_aridentifier',...
            compuMethodName,this.MaxShortNameLength);
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
            arPkg,compuMethodName,...
            Simulink.metamodel.types.CompuMethod.MetaClass());
            if seq.size()==0
                m3iCompuMethod=Simulink.metamodel.types.CompuMethod(this.M3iModel);
                m3iCompuMethod.Name=compuMethodName;
                this.M3iCompuMethodPkg.packagedElement.append(m3iCompuMethod);
            else
                m3iCompuMethod=seq.at(1);
                m3iCompuMethod.CalToInternalCompuNumerator.clear();
                m3iCompuMethod.CalToInternalCompuDenominator.clear();
            end
            ndt=implType.BaseType;
            paramCompuNum=paramObj.getCalToInternalCompuNumerator(ndt);
            m3iCompuMethod.CalToInternalCompuNumerator.append(paramCompuNum(1));
            if numel(paramCompuNum)==2
                m3iCompuMethod.CalToInternalCompuNumerator.append(paramCompuNum(2));
            end
            paramCompuDen=paramObj.getCalToInternalCompuDenominator(ndt);
            m3iCompuMethod.CalToInternalCompuDenominator.append(paramCompuDen(1));
            if numel(paramCompuDen)==2
                m3iCompuMethod.CalToInternalCompuDenominator.append(paramCompuDen(2));
            end
            m3iCompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.RatFunc;
            this.addDefaultUnit(m3iCompuMethod,paramObj.CalibrationDocUnits);
        end
        function addDefaultUnit(this,m3iCompuMethod,unitName)
            this.UnitBuilder.addDefaultUnit(m3iCompuMethod,unitName);
        end
        function applDataTypeNames=getApplDataTypeNames(this)
            applDataTypeNames={};
            slDataTypes=this.App2CompuMethodMap.keys();
            for ii=1:numel(slDataTypes)
                cm=this.App2CompuMethodMap(slDataTypes{ii});
                if cm.Category==Simulink.metamodel.types.CompuMethodCategory.Identical||...
                    cm.Category==Simulink.metamodel.types.CompuMethodCategory.Linear
                    applDataTypeNames=[applDataTypeNames,slDataTypes{ii}];%#ok<AGROW>
                end
            end
        end
    end

    methods(Access=private)
        function findOrCreateCompuMethodInternal(this,m3iType,isAppType,unmangledTypeName,slUnitName)
            if isa(m3iType,'Simulink.metamodel.types.Boolean')||...
                isa(m3iType,'Simulink.metamodel.types.Enumeration')
                if this.App2CompuMethodMap.isKey(unmangledTypeName)
                    m3iType.CompuMethod=this.App2CompuMethodMap(unmangledTypeName);
                else
                    this.findOrCreateTextTableCompuMethod(m3iType);
                end
            elseif isa(m3iType,'Simulink.metamodel.types.Real')
                if isAppType...
                    &&this.App2CompuMethodMap.isKey(unmangledTypeName)
                    m3iType.CompuMethod=this.App2CompuMethodMap(unmangledTypeName);
                else
                    this.findOrCreateLinearCompuMethod(m3iType,isAppType,unmangledTypeName,slUnitName);
                end
            end
        end

        function findOrCreateTextTableCompuMethod(this,obj)
            changeCategory=true;

            if~obj.CompuMethod.isvalid()
                arPkg=this.M3iModel.RootPackage.at(1);
                compuMethodName=['COMPU_',obj.Name];
                compuMethodName=arxml.arxml_private('p_create_aridentifier',...
                compuMethodName,this.MaxShortNameLength);
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                arPkg,compuMethodName,...
                Simulink.metamodel.types.CompuMethod.MetaClass());
                if seq.size()==0
                    compuMethod=Simulink.metamodel.types.CompuMethod(this.M3iModel);
                    compuMethod.Name=compuMethodName;




                    toolId='ARXML_ENUM_INFO';
                    extraInfo=autosar.mm.Model.getExtraExternalToolInfo(...
                    obj,toolId,{'minValue','maxValue','groundValue',...
                    'qname','uuid'},{'%s','%s','%s','%s','%s'});
                    if~isempty(extraInfo.qname)
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo('ARXML_COMPU',''))
                        [path,~,~]=fileparts(extraInfo.qname);
                        package=autosar.mm.Model.getOrAddARPackage(this.M3iModel,...
                        path);
                        package.packagedElement.append(compuMethod);
                    else
                        this.M3iCompuMethodPkg.packagedElement.append(compuMethod);
                    end
                    if~isempty(extraInfo.uuid)
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo('ARXML_COMPU',''))
                        autosar.mm.Model.setExtraExternalToolInfo(compuMethod,...
                        'ARXML',{'%s'},{extraInfo.uuid});
                    end
                    this.M3iCompuMethodPkg.packagedElement.append(compuMethod);
                else
                    compuMethod=seq.at(1);
                end
                obj.CompuMethod=compuMethod;
            else


                for ii=1:obj.CompuMethod.PrimitiveType.size()
                    primitiveType=obj.CompuMethod.PrimitiveType.at(ii);
                    if~isa(primitiveType,'Simulink.metamodel.types.Boolean')...
                        &&~isa(primitiveType,'Simulink.metamodel.types.Enumeration')
                        changeCategory=false;
                        break;
                    end
                end
            end
            if changeCategory
                obj.CompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.TextTable;
            end
        end

        function findOrCreateLinearCompuMethod(this,obj,isAppType,unmangledTypeName,~)
            if isempty(obj.CompuMethod)
                isFixedPoint=isa(obj,'Simulink.metamodel.types.FixedPoint');
                nonIdenticalFixedPoint=isFixedPoint&&(obj.Bias~=0.0||obj.slope~=1.0);
                category=Simulink.metamodel.types.CompuMethodCategory.Linear;
                arPkg=this.M3iModel.RootPackage.at(1);
                if nonIdenticalFixedPoint
                    compuMethodName=arxml.arxml_private('p_create_aridentifier',...
                    ['COMPU_',unmangledTypeName],this.MaxShortNameLength);
                else
                    compuMethodName='Identcl';
                end

                if nonIdenticalFixedPoint
                    seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                    arPkg,compuMethodName,...
                    Simulink.metamodel.types.CompuMethod.MetaClass());
                else

                    if isAppType
                        category=Simulink.metamodel.types.CompuMethodCategory.Identical;
                        seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                        arPkg,compuMethodName,...
                        Simulink.metamodel.types.CompuMethod.MetaClass());
                    else
                        return;
                    end
                end
                if seq.size()==0
                    compuMethod=Simulink.metamodel.types.CompuMethod(this.M3iModel);
                    compuMethod.Name=compuMethodName;




                    toolId='ARXML_FIXPT_INFO';
                    extraInfo=autosar.mm.Model.getExtraExternalToolInfo(...
                    obj,toolId,{'qname','uuid'},{'%s','%s'});
                    if~isempty(extraInfo.qname)
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo('ARXML_COMPU',''))
                        [path,~,~]=fileparts(extraInfo.qname);
                        package=autosar.mm.Model.getOrAddARPackage(this.M3iModel,...
                        path);
                        package.packagedElement.append(compuMethod);
                    else
                        this.M3iCompuMethodPkg.packagedElement.append(compuMethod);
                    end
                    if~isempty(extraInfo.uuid)
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
                        obj.removeExternalToolInfo(M3I.ExternalToolInfo('ARXML_COMPU',''))
                        autosar.mm.Model.setExtraExternalToolInfo(compuMethod,...
                        'ARXML',{'%s'},{extraInfo.uuid});
                    end
                else
                    compuMethod=seq.at(1);
                end
                compuMethod.Category=category;
                obj.CompuMethod=compuMethod;
            else
                isFixedPoint=isa(obj,'Simulink.metamodel.types.FixedPoint');
                nonIdenticalFixedPoint=isFixedPoint&&(obj.Bias~=0.0||obj.slope~=1.0);
                if nonIdenticalFixedPoint
                    obj.CompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.Linear;
                else
                    obj.CompuMethod.Category=Simulink.metamodel.types.CompuMethodCategory.Identical;
                end
            end
        end
    end
end






