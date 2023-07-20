classdef(Hidden)MetaModelFinder





    methods(Static)



        function m3iSeq=findObjectByName(parent,childName,caseInsensitive)
            if nargin==2
                caseInsensitive=false;
            end

            rootModel=parent.rootModel;
            [route,parent]=autosarcore.MetaModelFinder.splitObjectPath(parent,childName);
            if isempty(route)
                m3iSeq=M3I.SequenceOfClassObject.make(rootModel);
                return
            end


            m3iRouteList=M3I.SequenceOfString.make(rootModel);
            for ii=1:numel(route)
                m3iRouteList.append(route{ii});
            end

            if caseInsensitive
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByNamei(parent,m3iRouteList);
            else
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByName(parent,m3iRouteList);
            end
        end






        function child=findChildByName(parent,childName,caseInsensitive)
            if nargin==2
                caseInsensitive=false;
            end


            m3iSeq=autosarcore.MetaModelFinder.findObjectByName(parent,childName,caseInsensitive);



            if m3iSeq.size()==0
                child=M3I.ImmutableClassObject.empty;
            else
                child=m3iSeq.at(1);
            end
        end



        function childSeq=findObjectByMetaClass(parent,metaClass,doRecursion,isSuperClass)
            if nargin==3
                isSuperClass=false;
            elseif nargin<3
                doRecursion=true;
                isSuperClass=false;
            end
            if isSuperClass
                childSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByParentMetaClass(parent,metaClass,doRecursion);
            else
                childSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(parent,metaClass,doRecursion);
            end
        end






        function childList=findChildByTypeName(parent,childType,doRecursion,isSuperClass)
            if nargin==3
                isSuperClass=false;
            elseif nargin<3
                doRecursion=true;
                isSuperClass=false;
            end

            try

                metaClass=feval(sprintf('%s.MetaClass',childType));


                m3iSeq=autosarcore.MetaModelFinder.findObjectByMetaClass(parent,metaClass,doRecursion,isSuperClass);



                childList=cell(1,m3iSeq.size());
                for ii=1:m3iSeq.size()
                    childList{ii}=m3iSeq.at(ii);
                end
            catch Me %#ok<NASGU>
                childList={};
            end

        end



        function child=findObjectByNameAndMetaClass(parent,childName,childType,caseInsensitive)
            if nargin==3
                caseInsensitive=false;
            end


            rootModel=parent.rootModel;
            [route,parent]=autosarcore.MetaModelFinder.splitObjectPath(parent,childName);
            if isempty(route)
                child=M3I.SequenceOfClassObject.make(rootModel);
                return
            end


            m3iRouteList=M3I.SequenceOfString.make(rootModel);
            for ii=1:numel(route)
                m3iRouteList.append(route{ii});
            end


            if caseInsensitive
                child=Simulink.metamodel.arplatform.ModelFinder.findObjectByNameAndMetaClassi(parent,m3iRouteList,childType);
            else
                child=Simulink.metamodel.arplatform.ModelFinder.findObjectByNameAndMetaClass(parent,m3iRouteList,childType);
            end
        end





        function child=findChildByNameAndTypeName(parent,childName,childType,caseInsensitive)
            if nargin==3
                caseInsensitive=false;
            end
            try

                metaClass=feval(sprintf('%s.MetaClass',childType));


                m3iSeq=autosarcore.MetaModelFinder.findObjectByNameAndMetaClass(parent,childName,metaClass,caseInsensitive);
            catch Me %#ok<NASGU>
                m3iSeq=M3I.SequenceOfClassObject.make(parent.rootModel);
            end



            child=M3I.ImmutableClassObject.empty;
            if~m3iSeq.isEmpty
                for i=1:m3iSeq.size()


                    m3iElem=m3iSeq.at(i);
                    if(m3iElem.isvalid()&&(m3iElem.rootModel==parent.rootModel))
                        child=m3iElem;
                        return;
                    end
                end
            end

        end





        function[route,parent]=splitObjectPath(parent,childName,isFromARName)


            if nargin<3
                isFromARName=false;
            end



            if isFromARName
                sep='/';
            else
                sep='[/\.\\]';
            end


            route={};

            if isempty(childName)||~(ischar(childName)||isStringScalar(childName))...
                ||~parent.isvalid()||~isrow(childName)
                return
            end

            if isa(parent,'M3I.ImmutableClassObject')||isa(parent,'M3I.ClassObject')
                if isFromARName
                    if childName(1)=='/'


                        assert(parent.rootModel.RootPackage.size==1);
                        parent=parent.rootModel.RootPackage.front;
                    end
                else




                    if childName(1)~='.'&&(childName(1)=='/'||childName(1)=='\')
                        assert(parent.rootModel.RootPackage.size==1);
                        parent=parent.rootModel.RootPackage.front;
                    end

                    parentName=parent.getOne('name');
                    if parentName.isvalid()



                        childName=regexprep(childName,['^',parentName.toString(),sep],'');


                        if isempty(childName)
                            return
                        end
                    end
                end


                route=regexp(childName,sep,'split');


                route(cellfun(@isempty,route))=[];
            end
        end






        function pkgChild=getOrAddPackage(pkgParent,pkgName,isFromARName,onlyGet)


            if nargin<3
                isFromARName=false;
            end


            pkgChild=[];

            if isempty(pkgParent)||isempty(pkgName)
                return
            end


            [names,pkgParent]=autosarcore.MetaModelFinder.splitObjectPath(pkgParent,pkgName,isFromARName);


            pkgChild=pkgParent;
            pkgCurr=pkgParent;

            for ii=1:numel(names)

                pkgChild=autosarcore.MetaModelFinder.findChildByNameAndTypeName(...
                pkgCurr,names{ii},'Simulink.metamodel.arplatform.common.Package');
                if pkgChild.isvalid()==false
                    if onlyGet
                        return;
                    end
                    pkgParent.rootModel.beginTransaction();
                    pkgChild=Simulink.metamodel.arplatform.common.Package(pkgParent.rootModel);
                    pkgChild.Name=names{ii};
                    pkgCurr.packagedElement.append(pkgChild);
                    pkgParent.rootModel.commitTransaction();
                end


                pkgCurr=pkgChild;
            end

        end






        function pkgChild=getOrAddARPackage(pkgParent,pkgName)
            parent=pkgParent;
            if isa(pkgParent,'Simulink.metamodel.foundation.Domain')
                assert(pkgParent.RootPackage.size==1);
                parent=pkgParent.RootPackage.front;
            end
            pkgChild=autosarcore.MetaModelFinder.getOrAddPackage(parent,pkgName,true,false);
        end

        function pkgChild=getArPackage(pkgParent,pkgName)
            parent=pkgParent;
            if isa(pkgParent,'Simulink.metamodel.foundation.Domain')
                assert(pkgParent.RootPackage.size==1);
                parent=pkgParent.RootPackage.front;
            end
            pkgChild=autosarcore.MetaModelFinder.getOrAddPackage(parent,pkgName,true,true);
        end
    end
end


