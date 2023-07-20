classdef UnitBuilder<handle












    properties(SetAccess=private)
        m3iModel;
        m3iUnitPkg;
        MaxShortNameLength;
    end
    methods(Access=public)
        function this=UnitBuilder(M3iModel,maxShortNameLength)
            import autosar.mm.util.XmlOptionsAdapter;

            this.m3iModel=M3iModel;
            m3iRoot=this.m3iModel.RootPackage.at(1);
            unitPackage=XmlOptionsAdapter.get(m3iRoot,'UnitPackage');
            if isempty(unitPackage)
                unitPackage=[m3iRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.Units];
            end
            XmlOptionsAdapter.set(m3iRoot,'UnitPackage',unitPackage);
            this.m3iUnitPkg=autosar.mm.Model.getOrAddARPackage(this.m3iModel,...
            unitPackage);
            this.MaxShortNameLength=maxShortNameLength;
        end





        function addDefaultUnit(this,m3iObj,unitName)
            if~isempty(m3iObj)&&isempty(m3iObj.Unit)
                arPkg=this.m3iModel.RootPackage.at(1);
                m3iMetaClassName=Simulink.metamodel.types.Unit.MetaClass();
                if isempty(unitName)
                    unitName='NoUnit';
                    seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                    arPkg,unitName,m3iMetaClassName);
                else

                    unitName=regexprep(unitName,'[^a-zA-Z_0-9]','_');
                    unitName=arxml.arxml_private('p_create_aridentifier',...
                    unitName,this.MaxShortNameLength);
                    seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
                    arPkg,unitName,m3iMetaClassName);
                end
                if seq.size()==0
                    unitObj=Simulink.metamodel.types.Unit(this.m3iModel);
                    unitObj.Name=unitName;
                    this.m3iUnitPkg.packagedElement.append(unitObj);
                else
                    unitObj=seq.at(1);
                end
                m3iObj.Unit=unitObj;
            end
        end
    end

end


