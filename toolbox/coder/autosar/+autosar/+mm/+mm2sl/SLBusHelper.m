classdef SLBusHelper<handle




    properties(Access=private)
        slTypeBuilder;
        m3iType;
        savedVars;
        createdVars;
        Workspace;
    end

    methods



        function self=SLBusHelper(typeBuilder,m3iType)


            narginchk(2,2);


            if~isa(typeBuilder,'autosar.mm.mm2sl.TypeBuilder')
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',1,...
                'autosar.mm.mm2sl.TypeBuilder'));
            end
            self.slTypeBuilder=typeBuilder;




            if strcmp(typeBuilder.SharedWorkSpace,'base')
                self.Workspace=Simulink.data.BaseWorkspace;
            else
                assert(isa(typeBuilder.SharedWorkSpace,'Simulink.dd.Connection'),...
                'Unexpected workspace type');
                self.Workspace=Simulink.data.DataDictionary(typeBuilder.SharedWorkSpace.filespec);
            end


            if~isa(m3iType,'Simulink.metamodel.types.Structure')
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',2,...
                'Simulink.metamodel.types.Structure'));
            end


            assert((ischar(m3iType.Name)||isstringScalar(m3iType.Name))&&strlength(m3iType.Name)>0);

            self.m3iType=m3iType;


            self.savedVars=containers.Map('KeyType','char','ValueType','any');
            self.createdVars=containers.Map('KeyType','char','ValueType','logical');
        end




        function delete(self)


            try


                toClearKeys=self.createdVars.keys();
                toSaveKeys=self.savedVars.keys();
                toClearKeys=setdiff(toClearKeys,toSaveKeys);
                for ii=1:numel(toClearKeys)
                    evalin(self.Workspace,['clear ',toClearKeys{ii}]);
                end
                for ii=1:numel(toSaveKeys)
                    assignin(self.Workspace,toSaveKeys{ii},self.savedVars(toSaveKeys{ii}));
                end
            catch Me %#ok<NASGU>

            end
        end







        function retValue=doesBusHaveAnonymousStructName(self,workSpace)


            self.registerBusObjectDependencies(self.m3iType);


            retValue=Simulink.internal.doesBusHaveAnonymousStructName(self.m3iType.Name,workSpace);
        end





        function mStruct=createMATLABStruct(self)


            self.registerBusObjectDependencies(self.m3iType);
            mStruct=Simulink.Bus.createMATLABStruct(self.m3iType.Name,[],[1,1],self.Workspace);
        end

    end

    methods(Access='private')





        function registerBusObjectDependencies(self,m3iType)


            qName=autosar.api.Utils.getQualifiedName(m3iType);
            if self.createdVars.isKey(m3iType.Name)
                return
            end

            switch class(m3iType)
            case 'Simulink.metamodel.types.Structure'
                for ii=1:m3iType.Elements.size()
                    structElement=m3iType.Elements.at(ii);

                    self.registerBusObjectDependencies(...
                    structElement.ReferencedType);
                end

                slTypeInfo=self.slTypeBuilder.m3iQName2SLTypeInfoMap(qName);


                varExist=evalin(self.Workspace,['exist(''',slTypeInfo.name,''',''var'')==1']);
                if varExist&&~self.savedVars.isKey(slTypeInfo.name)
                    self.savedVars(slTypeInfo.name)=evalin(self.Workspace,slTypeInfo.name);
                end


                assignin(self.Workspace,slTypeInfo.name,slTypeInfo.slObj);
                self.createdVars(slTypeInfo.name)=true;

            case 'Simulink.metamodel.types.Matrix'

                self.registerBusObjectDependencies(...
                autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(m3iType));

            case 'Simulink.metamodel.types.LookupTableType'
                if m3iType.ValueAxisDataType.isvalid()
                    self.registerBusObjectDependencies(...
                    m3iType.ValueAxisDataType);
                end
            case 'Simulink.metamodel.types.SharedAxisType'
                if m3iType.ValueAxisDataType.isvalid()
                    self.registerBusObjectDependencies(...
                    m3iType.ValueAxisDataType);
                end
            otherwise
                slTypeInfo=self.slTypeBuilder.m3iQName2SLTypeInfoMap(qName);
                if isa(slTypeInfo.slObj,'Simulink.AliasType')||...
                    isa(slTypeInfo.slObj,'Simulink.NumericType')


                    varExist=evalin(self.Workspace,['exist(''',slTypeInfo.name,''',''var'')==1']);
                    if varExist&&~self.savedVars.isKey(slTypeInfo.name)
                        self.savedVars(slTypeInfo.name)=evalin(self.Workspace,slTypeInfo.name);
                    end


                    assignin(self.Workspace,slTypeInfo.name,slTypeInfo.slObj);
                    self.createdVars(slTypeInfo.name)=true;
                end
            end

        end

    end

end


