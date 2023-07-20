classdef ConfigSetSchemaVisitor<pm.util.Visitor








    properties(Access=private)
Package
BaseClass
    end
    methods
        function this=ConfigSetSchemaVisitor(pkg,baseCls)
            mlock;
            if ischar(pkg)
                this.Package=findpackage(pkg);
                if~isempty(this.Package)
                    if ischar(baseCls)
                        this.BaseClass=findclass(this.Package,baseCls);
                        if isempty(this.BaseClass)
                            pm_error('mech2:local:configsetschemavisitor:BaseClassNotFound',baseCls,pkg);
                        end
                    else
                        pm_error('mech2:local:configsetschemavisitor:InvalidBaseClass');
                    end
                else
                    pm_error('mech2:local:configsetschemavisitor:PackageNotFound',pkg);
                end
            else
                pm_error('mech2:local:configsetschemavisitor:InvalidPackage');
            end
        end

        function generateSchema(this,configTree)


            configTree.accept(this);
        end
    end
    methods(Access=protected)
        function visit_simplenode_implementation(this,aVisitableNode)


            clsName=aVisitableNode.Parent.Info.Name;
            cls=findclass(this.Package,clsName);
            params=aVisitableNode.Info.Parameters;
            for idx=1:length(params)
                try






                    p=findprop(cls,params(idx).Name);
                catch excp
                    if strcmp(excp.identifier,'MATLAB:class:AmbiguousPropertyException')
                        p=[];
                    else
                        rethrow(excp);
                    end
                end
                if isempty(p)||~strcmp(params(idx).Name,p.Name)




                    if(~strcmp(params(idx).DataType,'mech2.UnconfigurableError')&&...
                        ~strcmp(params(idx).DataType,'mech2.UnconfigurableWarning'))
                        p=schema.prop(cls,params(idx).Name,params(idx).DataType);
                        p.SetFunction=params(idx).SetFunction;
                        p.FactoryValue=params(idx).DefaultValue;
                    end
                end
            end
        end

        function visit_compoundnode_implementation(this,aVisitableNode)



            cssName=aVisitableNode.Info.Name;
            if isvarname(cssName)
                cls=findclass(this.Package,cssName);
                if isempty(cls)
                    cls=schema.class(this.Package,cssName,this.BaseClass);




                    lp=schema.prop(cls,[cssName,'ChangeListeners'],'MATLAB array');
                    lp.AccessFlags.Serialize='off';
                    lp.Visible='off';
                    schema.prop(lp,'DummyProperty','handle.listener');
                    lp.DummyProperty=handle.listener(cls,'ClassInstanceCreated',@childConstructor);
                end
            else
                pm_error('mech2:local:configsetschemavisitor:InvalidConfigSetName',cssName);
            end
        end

    end
end

function childConstructor(cls,clsEvent)

    clsInst=clsEvent.Instance;

    clsInst.attachPropertyListeners();

end

