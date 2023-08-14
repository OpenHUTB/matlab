classdef DataConstrBuilder<handle












    properties(SetAccess=private)
        m3iModel;
        m3iInternalDataConstrPkg;
        m3iPhysDataConstrPkg;
        MaxShortNameLength;
        GenerateInternalConstr;
    end
    methods(Access=public)
        function this=DataConstrBuilder(M3iModel,maxShortNameLength)
            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;

            this.m3iModel=M3iModel;
            m3iRoot=this.m3iModel.RootPackage.at(1);
            constrPackage=XmlOptionsAdapter.get(...
            m3iRoot,'DataConstraintPackage');
            this.GenerateInternalConstr=XmlOptionsAdapter.get(...
            m3iRoot,'InternalDataConstraintExport');
            if isempty(constrPackage)
                applDtPkg=XmlOptionsAdapter.get(...
                m3iRoot,'ApplicationDataTypePackage');
                if isempty(applDtPkg)
                    applDtPkg=[m3iRoot.DataTypePackage,'/'...
                    ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                end
                constrPackage=[applDtPkg,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.DataConstrs];
                XmlOptionsAdapter.set(m3iRoot,...
                'DataConstraintPackage',constrPackage);
            end
            if this.GenerateInternalConstr
                constrPackage=XmlOptionsAdapter.get(...
                m3iRoot,'InternalDataConstraintPackage');
                if isempty(constrPackage)
                    constrPackage=[m3iRoot.DataTypePackage,'/'...
                    ,autosar.mm.util.XmlOptionsDefaultPackages.DataConstrs];
                    XmlOptionsAdapter.set(m3iRoot,...
                    'InternalDataConstraintPackage',constrPackage);
                end
            end
            this.MaxShortNameLength=maxShortNameLength;
        end






        function addDataConstr(this,m3iType,isAppType)
            import autosar.mm.Model;
            import Simulink.metamodel.types.CompuMethodCategory;



            if isAppType


                if~isempty(m3iType.CompuMethod)&&m3iType.CompuMethod.Category==CompuMethodCategory.TextTable
                    return;
                end
            elseif~this.GenerateInternalConstr
                return;
            end
            if isempty(m3iType.DataConstr)
                metaClsStr='Simulink.metamodel.types.DataConstr';
                m3iDCPkg=this.getDataConstrPackage(isAppType);
                name=['DC_',m3iType.Name];
                name=arxml.arxml_private('p_create_aridentifier',...
                name,this.MaxShortNameLength);

                constrObj=Model.findChildByNameAndTypeName(...
                m3iDCPkg,name,metaClsStr,true);
                if~constrObj.isvalid()
                    constrObj=Simulink.metamodel.types.DataConstr(this.m3iModel);
                    constrObj.Name=name;
                    if isAppType&&m3iType.CompuMethod.isvalid()&&m3iType.CompuMethod.Unit.isvalid()
                        constrObj.Unit=m3iType.CompuMethod.Unit;
                    end
                    m3iDCPkg.packagedElement.append(constrObj);


                    toolId='ARXML_DATA-CONSTR';
                    extraInfo=Model.getExtraExternalToolInfo(...
                    m3iType,toolId,{'uuid'},{'%s'});
                    if~isempty(extraInfo.uuid)
                        Model.setExtraExternalToolInfo(constrObj,...
                        'ARXML',{'%s'},{extraInfo.uuid});
                        m3iType.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
                    end
                end
                m3iType.DataConstr=constrObj;
            end
        end
    end
    methods(Access=private)
        function m3iDCPkg=getDataConstrPackage(this,isAppType)
            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;

            m3iRoot=this.m3iModel.RootPackage.at(1);
            if isAppType
                if isempty(this.m3iPhysDataConstrPkg)
                    constrPackage=XmlOptionsAdapter.get(...
                    m3iRoot,'DataConstraintPackage');
                    this.m3iPhysDataConstrPkg=Model.getOrAddARPackage(...
                    this.m3iModel,constrPackage);
                end
                m3iDCPkg=this.m3iPhysDataConstrPkg;
            else
                if isempty(this.m3iInternalDataConstrPkg)
                    constrPackage=XmlOptionsAdapter.get(...
                    m3iRoot,'InternalDataConstraintPackage');
                    this.m3iInternalDataConstrPkg=Model.getOrAddARPackage(...
                    this.m3iModel,constrPackage);
                end
                m3iDCPkg=this.m3iInternalDataConstrPkg;
            end
        end
    end
end



