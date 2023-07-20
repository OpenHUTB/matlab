classdef ApplicationTypeChecker<autosar.mm.util.CodeDescriptorTypeVisitor




    properties(Access=private)
AppTypeNamesMap
deviant
m3iBehavior
IsAppType
msgStream
ImplTypeRefConstraint
AppDataTypes
    end

    methods(Access=public)
        function this=ApplicationTypeChecker(m3iBehavior,~,appDataTypes)
            import autosar.mm.util.XmlOptionsAdapter;

            this=this@autosar.mm.util.CodeDescriptorTypeVisitor();




            this.deviant=m3iBehavior.rootModel.createDeviantWithName('ApplicationTypeChecker deviant');
            this.m3iBehavior=m3iBehavior.asDeviant(this.deviant);











            assert(m3iBehavior.rootModel.RootPackage.size()==1,'rootPkg.size should be 1');
            arRoot=m3iBehavior.rootModel.RootPackage.front();
            this.ImplTypeRefConstraint=XmlOptionsAdapter.get(arRoot,'ImplementationTypeReference');
            this.AppDataTypes=appDataTypes;


            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();
            this.createAppTypeNamesMap();
        end

        function isAppType=isAppType(this,embeddedObj,isValueType)



            if isValueType
                isAppType=true;
                return;
            end

            if strcmp(this.ImplTypeRefConstraint,'NotAllowed')

                isAppType=true;
                if embeddedObj.isPointer&&embeddedObj.BaseType.isVoid
                    isAppType=false;
                end
            else
                assert(strcmp(this.ImplTypeRefConstraint,'Allowed'),...
                'expected ImplTypeRefConstraint to be "Allowed"');
                this.IsAppType=false;
                this.accept(embeddedObj);
                isAppType=this.IsAppType;
            end
        end
    end

    methods(Access=protected)
        function ret=acceptEnumType(this,type)
            this.checkIfMappedByUser(type);
            ret=[];
        end

        function ret=acceptCharType(this,type)
            this.checkIfMappedByUser(type);
            ret=[];
            this.IsAppType=true;
        end

        function ret=acceptStructType(this,type,finish)
            if finish
                this.checkIfMappedByUser(type);
            end
            ret=[];
        end

        function ret=acceptStructElement(this,field,~)
            ret=[];
            this.accept(field.Type);
        end

        function ret=acceptMatrixType(this,type,elemType)
            this.checkIfMappedByUser(type);
            ret=[];
            this.accept(elemType);
        end

        function ret=acceptNumericType(this,type)
            ret=[];
            if ismember(type.Identifier,this.AppDataTypes)
                this.IsAppType=true;
                return;
            end

            this.checkIfMappedByUser(type);
            if type.isFixed&&(type.Slope~=1||type.Bias~=0)


                this.IsAppType=true;
            end
        end

        function ret=acceptComplexType(this,~)
            ret=[];
            this.msgStream.createError('RTW:autosar:unsupportedExportedDataType','Complex');
        end

        function ret=acceptOpaqueType(this,~)
            ret=[];
            this.msgStream.createError('RTW:autosar:unsupportedExportedDataType','Opaque');
        end

        function ret=acceptPointerType(this,type,elemType)
            ret=[];




            if elemType.isVoid
                this.IsAppType=false;
                return
            end

            this.checkIfMappedByUser(type);
            this.accept(elemType);
        end


        function ret=acceptVoidType(this,~)
            ret=[];
            this.IsAppType=false;
        end

    end

    methods(Access=private)
        function checkIfMappedByUser(this,type)
            if this.AppTypeNamesMap.isKey(type.Identifier)
                this.IsAppType=true;
            end
        end

        function createAppTypeNamesMap(this)

            this.AppTypeNamesMap=containers.Map;

            if~this.m3iBehavior.isvalid()
                return;
            end

            for dtMapIdx=1:this.m3iBehavior.DataTypeMapping.size()
                dtMaps=this.m3iBehavior.DataTypeMapping.at(dtMapIdx);
                for idx=1:dtMaps.dataTypeMap.size()
                    dtMap=dtMaps.dataTypeMap.at(idx);
                    if dtMap.ApplicationType.isvalid()
                        this.AppTypeNamesMap(dtMap.ApplicationType.Name)=true;
                    end
                end
            end

        end

    end

end


