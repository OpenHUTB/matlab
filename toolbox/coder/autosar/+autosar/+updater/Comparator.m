classdef Comparator<handle






    properties(Access=private)
        ChangeLogger;
        Matcher;
        M3IComparator;
    end

    methods(Access=public)
        function this=Comparator(aFirst,aSecond,aMatcher,aChangeLogger)
            this.Matcher=aMatcher;
            this.ChangeLogger=aChangeLogger;
            this.M3IComparator=Simulink.metamodel.arplatform.Comparator(aFirst,aSecond,this.Matcher);
        end

        function compare(this)
            this.M3IComparator.compare();

            this.doLogAdditions();
            this.doLogDeletions();
            this.doLogModifications();
            this.doLogRefDeletions();
            this.doLogRefAdditions();
            this.doLogRefModifications();
        end
    end

    methods(Access=private)

        function doLogAdditions(this)
            additions=this.M3IComparator.getAdditions();
            for ii=1:additions.size()
                change=additions.at(ii);
                this.logAddition(change.getFirst(),change.getParentProperty());
            end

        end

        function doLogModifications(this)
            modifications=this.M3IComparator.getModifications();
            for ii=1:(modifications.size())
                change=modifications.at(ii);
                this.logModification(change.getParent(),change.getParentProperty(),change.getFirst(),change.getSecond());
            end
        end

        function doLogRefModifications(this)
            RefModifications=this.M3IComparator.getRefModifications();
            for ii=1:RefModifications.size()
                change=RefModifications.at(ii);
                this.logRefModification(change.getParent(),change.getParentProperty(),change.getFirst(),change.getSecond());
            end
        end

        function doLogRefAdditions(this)
            RefAdditions=this.M3IComparator.getRefAdditions();
            for ii=1:RefAdditions.size()
                change=RefAdditions.at(ii);
                this.logRefAddition(change.getParent(),change.getFirst(),change.getParentProperty());
            end
        end

        function doLogRefDeletions(this)
            RefDeletions=this.M3IComparator.getRefDeletions();
            for ii=1:RefDeletions.size()
                change=RefDeletions.at(ii);
                this.logRefDeletion(change.getParent(),change.getSecond(),change.getParentProperty());
            end
        end

        function doLogDeletions(this)
            unmatchedElements=this.Matcher.getUnmatched();
            for ii=1:unmatchedElements.size()
                this.logDeletion(unmatchedElements.at(ii));
            end
        end


        function logAddition(this,aClassObject,metaAttr)

            if this.filter(aClassObject,metaAttr)
                return
            end

            this.ChangeLogger.logAddition('MetaModel',aClassObject.MetaClass().name,...
            autosar.api.Utils.getQualifiedName(aClassObject));
        end

        function logRefAddition(this,aClassObject,aClassObjectValue,metaAttr)

            if this.filter(aClassObjectValue,[])||this.filter(aClassObject,metaAttr)
                return
            end
            this.ChangeLogger.logAddition('MetaModel',[aClassObjectValue.MetaClass().name,' reference '],...
            autosar.api.Utils.getQualifiedName(aClassObjectValue),autosar.api.Utils.getQualifiedName(aClassObject));
        end


        function logDeletion(this,aClassObject)

            if this.filter(aClassObject,[])
                return
            end

            this.ChangeLogger.logDeletion('MetaModel',aClassObject.MetaClass().name,...
            autosar.api.Utils.getQualifiedName(aClassObject));
        end

        function logRefDeletion(this,aClassObject,aClassObjectValue,metaAttr)

            if this.filter(aClassObject,metaAttr)||this.filter(aClassObjectValue,[])
                return
            end

            this.ChangeLogger.logDeletion('MetaModel',[aClassObjectValue.MetaClass().name,' reference '],...
            autosar.api.Utils.getQualifiedName(aClassObjectValue),autosar.api.Utils.getQualifiedName(aClassObject));
        end


        function logModification(this,aClassObject,metaAttr,aValueObjectFirst,aValueObjectSecond)

            if this.filter(aClassObject,metaAttr)
                return
            end

            className=aClassObject.MetaClass.name;
            propertyName=metaAttr.name;

            if isa(aValueObjectFirst,'M3I.ValueObject')
                this.ChangeLogger.logModification('MetaModel',propertyName,className,...
                autosar.api.Utils.getQualifiedName(aClassObject),...
                aValueObjectSecond.toString(),aValueObjectFirst.toString());
            else
                this.ChangeLogger.logModification('MetaModel',propertyName,className,...
                autosar.api.Utils.getQualifiedName(aClassObject));
            end
        end

        function logRefModification(this,aClassObject,metaAttr,aValueObjectFirst,aValueObjectSecond)


            if this.filter(aClassObject,metaAttr)||...
                (~isempty(aValueObjectFirst)&&this.filter(aValueObjectFirst,[]))||...
                (~isempty(aValueObjectSecond)&&this.filter(aValueObjectSecond,[]))
                return
            end

            className=aClassObject.MetaClass.name;
            propertyName=metaAttr.name;

            if isempty(aValueObjectFirst)

                firstId='';
            else
                firstId=autosar.api.Utils.getQualifiedName(aValueObjectFirst);
            end

            if isempty(aValueObjectSecond)

                secondId='';
            else
                secondId=autosar.api.Utils.getQualifiedName(aValueObjectSecond);
            end

            if strcmp(firstId,secondId)





                return;
            end

            this.ChangeLogger.logModification('MetaModel',[propertyName,' reference'],className,...
            autosar.api.Utils.getQualifiedName(aClassObject),...
            secondId,...
            firstId);

        end

    end

    methods(Static,Access=private)

        function isFiltered=filter(aClassObject,metaAttr)


            if aClassObject.MetaClass.has('extension_m3i_hide_in_mcos')

                isFiltered=true;
                return
            end

            if isempty(metaAttr)

                metaAttr=Simulink.metamodel.arplatform.ModelFinder.getContainmentAttribute(aClassObject);
            end

            if~isempty(metaAttr)&&...
                metaAttr.has('extension_m3i_hide_in_mcos')&&...
                ~strcmp(metaAttr.name,'packagedElement')

                isFiltered=true;
                return
            end

            if~aClassObject.has('Name')



                isFiltered=true;
                return
            end


            if autosar.updater.Comparator.isCellOrSlot(aClassObject)||...
                autosar.updater.Comparator.isCellOrSlot(aClassObject.containerM3I)||...
                aClassObject.MetaClass==Simulink.metamodel.arplatform.common.AUTOSAR.MetaClass
                isFiltered=true;
                return
            end


            if autosar.updater.Comparator.isEmptyPackage(aClassObject)
                isFiltered=true;
                return
            end



            if(metaAttr==Simulink.metamodel.types.EnumerationLiteralReference.MetaProperty.Value)
                isFiltered=true;
                return
            end



            if(metaAttr==Simulink.metamodel.foundation.TypedElement.MetaProperty.Type)&&...
                isa(aClassObject,'Simulink.metamodel.foundation.ValueSpecification')
                isFiltered=true;
                return
            end

            isFiltered=false;
        end

        function isCellOrSlot=isCellOrSlot(aClassObject)

            switch(aClassObject.MetaClass)
            case{Simulink.metamodel.types.Cell.MetaClass
                Simulink.metamodel.types.Slot.MetaClass}
                isCellOrSlot=true;
            otherwise
                isCellOrSlot=false;
            end

        end

        function isEmpty=isEmptyPackage(aClassObject)


            if aClassObject.MetaClass~=Simulink.metamodel.arplatform.common.Package.MetaClass
                isEmpty=false;
                return
            end

            for ii=1:aClassObject.packagedElement.size()
                if~autosar.updater.Comparator.isEmptyPackage(aClassObject.packagedElement.at(ii))
                    isEmpty=false;
                    return
                end
            end

            isEmpty=true;
        end



    end
end


