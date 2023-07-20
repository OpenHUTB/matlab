classdef SystemConstantBuilder




    properties(Access=private)
M3iModel
    end

    properties(SetAccess=private)
SysConstsPkg
    end

    methods
        function this=SystemConstantBuilder(m3iModel,dataTypePackage)
            this.M3iModel=m3iModel;
            this.SysConstsPkg=this.getSysConstsPkg(dataTypePackage);
        end

        function[m3iSysConst,m3iSysConstValueSet]=findOrCreateSystemConstant(this,sysConstName,sysConstValue)
            if nargin<3
                sysConstValue=[];
            end

            arPkg=this.M3iModel.rootModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            m3iMetaClass=Simulink.metamodel.arplatform.variant.SystemConst.MetaClass;
            m3iSysConstsPkg=this.SysConstsPkg;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,sysConstName,m3iMetaClass);
            m3iSysConstValueSet=[];
            createSystemConstantValueSet=true;
            if seq.size()==0
                m3iSysConst=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iSysConstsPkg,m3iSysConstsPkg.packagedElement,...
                sysConstName,m3iMetaClass.qualifiedName);
            else
                m3iSysConst=seq.at(1);
                m3iSysConstsPkg=m3iSysConst.containerM3I;
                if autosar.mm.arxml.Exporter.isExternalReference(m3iSysConst)
                    createSystemConstantValueSet=false;
                end
            end

            if~isempty(sysConstValue)


                rteSysConstNumericValue=sysConstValue;
                if Simulink.data.isSupportedEnumClass(class(rteSysConstNumericValue))

                    rteSysConstNumericValue=rteSysConstNumericValue.int32();
                end
                autosar.mm.util.ExternalToolInfoAdapter.set('',m3iSysConst,'RteSysConstNumericValue',rteSysConstNumericValue);


                if createSystemConstantValueSet
                    m3iSysConstValueSet=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iSysConstsPkg,m3iSysConstsPkg.packagedElement,...
                    'SystemConstantValueSet','Simulink.metamodel.arplatform.variant.SystemConstValueSet');
                    this.findOrCreateSystemConstantValue(...
                    m3iSysConstValueSet,m3iSysConst,sysConstValue)
                end
            end
        end

        function findOrCreateSystemConstantValue(this,m3iSysConstValueSet,m3iSysConst,sysConstValue)

            m3iSysConstValue=[];
            for jj=1:m3iSysConstValueSet.SysConstValue.size()
                if m3iSysConstValueSet.SysConstValue.at(jj).SysConst==m3iSysConst
                    m3iSysConstValue=m3iSysConstValueSet.SysConstValue.at(jj);
                    break;
                end
            end
            if isempty(m3iSysConstValue)
                m3iSysConstValue=Simulink.metamodel.arplatform.variant.SystemConstValue(this.M3iModel);
                try
                    m3iSysConstValue.Value=sysConstValue;
                catch err
                    newError=MSLException('autosarstandard:exporter:InvalidSystemConstantValue',...
                    m3iSysConst.Name);
                    newError.addCause(err);
                    newError.throw();
                end
                m3iSysConstValue.SysConst=m3iSysConst;
                m3iSysConstValueSet.SysConstValue.append(m3iSysConstValue);
            else
                if Simulink.data.isSupportedEnumClass(class(sysConstValue))
                    sysConstValue=sysConstValue.int32();
                end
                m3iSysConstValue.Value=sysConstValue;
            end
        end

        function m3iSysConstValueSet=findOrCreateSystemConstantValueSet(this,...
            variantConfig,maxShortNameLength)
            arPkg=this.M3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));

            sysConstSetName=arxml.arxml_private('p_create_aridentifier',...
            ['SystemConstantValueSet_',variantConfig.Name],maxShortNameLength);
            m3iSysConstsPkg=this.SysConstsPkg;
            m3iSysConstValueSet=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iSysConstsPkg,m3iSysConstsPkg.packagedElement,...
            sysConstSetName,'Simulink.metamodel.arplatform.variant.SystemConstValueSet');
            for ii=1:numel(variantConfig.ControlVariables)
                sysConstName=variantConfig.ControlVariables(ii).Name;
                valueObj=variantConfig.ControlVariables(ii).Value;
                if~autosar.mm.sl2mm.variant.Utils.isSystemConstant(valueObj)
                    continue;
                end
                sysConstValue=valueObj.Value;

                m3iMetaClass=Simulink.metamodel.arplatform.variant.SystemConst.MetaClass;
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,sysConstName,m3iMetaClass);
                if seq.size()==0
                    m3iSysConst=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iSysConstsPkg,m3iSysConstsPkg.packagedElement,...
                    sysConstName,m3iMetaClass.qualifiedName);
                else
                    m3iSysConst=seq.at(1);
                end
                this.findOrCreateSystemConstantValue(...
                m3iSysConstValueSet,m3iSysConst,sysConstValue);
            end
        end
    end

    methods(Access=private)
        function m3iSysConstsPkg=getSysConstsPkg(this,dataTypePackage)




            arRoot=this.M3iModel.RootPackage.at(1);
            sysConstPkg=autosar.mm.util.XmlOptionsAdapter.get(...
            arRoot,'SystemConstantPackage');
            if isempty(sysConstPkg)
                sysConstPkg=[dataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SystemConstants];
                autosar.mm.util.XmlOptionsAdapter.set(...
                arRoot,'SystemConstantPackage',sysConstPkg);
            end

            m3iSysConstsPkg=autosar.mm.Model.getOrAddARPackage(this.M3iModel,sysConstPkg);
        end
    end
end


