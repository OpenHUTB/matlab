classdef ConfigSetBuildVisitor<pm.util.Visitor






























    properties(Access=private)
Package
ConfigSubsets
    end

    methods

        function this=ConfigSetBuildVisitor(varargin)
            this.Package='simmechanics';
            this.ConfigSubsets=containers.Map;
            if nargin==1&&isa(varargin{1},'simmechanics.SLConfigurationSetBase')
                this.ConfigSubsets(class(varargin{1}))=varargin{1};
            end
        end

    end
    methods
        function cs=getConfigSet(this,configTree)


            configTree.accept(this);
            cs=this.ConfigSubsets([this.Package,'.',configTree.Info.Name]);
        end
    end
    methods(Access=protected)

        function visit_simplenode_implementation(this,aVisitableNode)

        end

        function visit_compoundnode_implementation(this,aVisitableNode)


            cssName=[this.Package,'.',aVisitableNode.Info.Name];
            if~isempty(aVisitableNode.Parent)
                if this.ConfigSubsets.isKey(cssName)
                    configSet=this.ConfigSubsets(cssName);
                else
                    configSet=feval(cssName,aVisitableNode.Info.Name);
                end
                if~isempty(configSet)
                    configSet.Description=aVisitableNode.Info.Description;

                    this.ConfigSubsets(cssName)=configSet;
                    pCssName=[this.Package,'.',aVisitableNode.Parent.Info.Name];
                    pCss=this.ConfigSubsets(pCssName);
                    if~isempty(pCss)
                        pCss.attachComponent(this.ConfigSubsets(cssName));
                    else
                        pm_error('mech2:local:configsetbuildvisitor:ParentNotFound',pCssName);
                    end
                else
                    pm_error('mech2:local:configsetbuildvisitor:ClassNotFound',cssName);
                end
            else
                if this.ConfigSubsets.isKey(cssName)
                    configSet=this.ConfigSubsets(cssName);
                else
                    configSet=feval(cssName,'SimMechanics2G');
                end
                if~isempty(configSet)
                    configSet.Description=aVisitableNode.Info.Description;
                    this.ConfigSubsets(cssName)=configSet;
                else
                    pm_error('mech2:local:configsetbuildvisitor:ClassNotFound',cssName);
                end
            end
        end

    end
end
