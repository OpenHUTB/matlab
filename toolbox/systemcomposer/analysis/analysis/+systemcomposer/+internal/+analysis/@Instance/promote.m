function promote(this,isStrict,normalizeUnits,propertyName)


    spec=this.getStereotypeOwner();

    vs=this.propertyValues.toArray;

    if~isempty(vs)
        if(~isStrict)


            usage=this.instanceModel.getPropertyUsagesForInstance(this);
            stereotypes=arrayfun(@(x)x.propertySet.prototype,usage);
            stereoToApply=getUniqueStereotypes(stereotypes);
            for i=1:numel(stereoToApply)
                try
                    spec.applyPrototype(stereoToApply{i});
                catch e
                    bk_state=warning('QUERY','Backtrace');
                    warning off BACKTRACE;
                    warning(e.identifier,'%s',e.message);
                    warning(bk_state);

                end
            end
        end

        if nargin>3
            parts=split(propertyName,'.');
            vSet=vs.values.getByKey(strcat(parts{1},'.',parts{2}));
            usageSet=this.getSpecificationUsage(vSet.getName);

            if~isempty(usageSet)
                value=vSet.values.getByKey(parts{3});
                propFQN=[usageSet.getName,'.',value.getName];
                txn=mf.zero.getModel(spec).beginTransaction;
                spec.setPropVal(propFQN,mat2str(value.getAsMxArray),value.units);
                txn.commit;
            end
        else
            for vSet=vs.values.toArray



                usageSet=this.getSpecificationUsage(vSet.getName);

                if~isempty(usageSet)

                    for value=vSet.values.toArray
                        propFQN=[usageSet.getName,'.',value.getName];
                        usage=usageSet.getPropertyUsage(value.getName);
                        if normalizeUnits&&isa(usage.initialValue.type,'systemcomposer.property.RealType')
                            txn=mf.zero.getModel(spec).beginTransaction;
                            spec.setFromNormalizedValue(propFQN,value.getAsMxArray);
                            txn.commit;
                        else
                            txn=mf.zero.getModel(spec).beginTransaction;
                            spec.setPropVal(propFQN,mat2str(value.getAsMxArray));
                            txn.commit;
                        end
                    end
                end
            end
        end
    end
end

function uniqueStereotypes=getUniqueStereotypes(stereotypes)




    uniqueStereotypes={};

    for s=stereotypes

        if~any(arrayfun(@(x)x.isParentPrototype(s),stereotypes))
            uniqueStereotypes{end+1}=s.fullyQualifiedName;%#ok<AGROW>
        end
    end
end

