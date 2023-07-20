classdef XmlOptionsComparator<handle






    properties(Access=private)
        First;
        Second;
        NewM3IComp;
        OldM3IComp;
        ChangeLogger;
    end

    methods(Access=public)
        function this=XmlOptionsComparator(aFirst,aSecond,newM3IComp,oldM3IComp,aChangeLogger)
            this.First=aFirst.RootPackage.front();
            this.Second=aSecond.RootPackage.front();
            this.NewM3IComp=newM3IComp;
            this.OldM3IComp=oldM3IComp;
            this.ChangeLogger=aChangeLogger;
        end

        function compare(this)
            this.compareARRootXmlOptions(this.First,this.Second);
            this.compareExternalToolInfoXmlOptions(this.First,this.Second);
            this.compareComponentQualifiedName(this.NewM3IComp,this.OldM3IComp);
        end
    end

    methods(Access=private)

        function compareExternalToolInfoXmlOptions(this,aFirst,aSecond)


            import autosar.mm.util.XmlOptionsAdapter;

            propertyNames=XmlOptionsAdapter.getValidProperties();
            for propIdx=1:length(propertyNames)
                propertyName=propertyNames{propIdx};
                if any(strcmp(propertyName,XmlOptionsAdapter.ComponentSpecificXmlOptions))

                    firstValueStr=XmlOptionsAdapter.get(this.NewM3IComp,propertyName);
                    secondValueStr=XmlOptionsAdapter.get(this.OldM3IComp,propertyName);
                else
                    firstValueStr=XmlOptionsAdapter.get(aFirst,propertyName);
                    secondValueStr=XmlOptionsAdapter.get(aSecond,propertyName);
                end
                if~isequal(firstValueStr,secondValueStr)
                    this.logModification(propertyName,mat2str(firstValueStr),mat2str(secondValueStr));
                end
            end
        end

        function compareComponentQualifiedName(this,NewM3IComp,OldM3IComp)

            firstValue=autosar.api.Utils.getQualifiedName(NewM3IComp);
            secondValue=autosar.api.Utils.getQualifiedName(OldM3IComp);
            if~isequal(firstValue,secondValue)
                this.logModification('ComponentQualifiedName',firstValue,secondValue);
            end
        end

        function compareARRootXmlOptions(this,aFirst,aSecond)


            metaAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(aFirst,false);
            for ii=1:metaAttributes.size()
                metaAttr=metaAttributes.at(ii);
                metaAttrName=metaAttr.name;

                firstValues=aFirst.get(metaAttrName);
                secondValues=aSecond.get(metaAttrName);


                if(firstValues.size()==1&&secondValues.size()==1&&~firstValues.at(1).isvalid()&&~secondValues.at(1).isvalid())
                    assert(metaAttr.lower==1&&strcmp(metaAttr.upper,'1'),'Expected lower/upper bound of 1');
                    continue
                end

                for jj=1:firstValues.size()
                    firstValue=firstValues.at(jj);

                    if isa(firstValue,'M3I.ValueObject')
                        assert(metaAttr.lower==0||metaAttr.lower==1,'Expected lower bound of 0 or 1 rather than %d',metaAttr.lower);
                        if(firstValues.size()>1||secondValues.size()>1)&&(firstValues.size()~=secondValues.size())
                            this.logModification(aFirst,metaAttr,sprintf('size %d',firstValues.size()),sprintf('size %d',secondValues.size()));
                        else
                            secondValue=secondValues.at(jj);
                            if~strcmp(firstValue.toString,secondValue.toString)
                                this.logModification(metaAttrName,firstValue.toString,secondValue.toString);
                            end
                        end
                    else

                    end
                end
            end

        end

        function logModification(this,propertyName,aValueObjectFirstStr,aValueObjectSecondStr)

            this.ChangeLogger.logModification('MetaModel',propertyName,'AUTOSAR',...
            'XmlOptions',...
            aValueObjectSecondStr,aValueObjectFirstStr);

        end

    end

end


