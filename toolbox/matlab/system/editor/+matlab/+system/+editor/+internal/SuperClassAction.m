classdef SuperClassAction
    methods(Static)
        function[superClassNames,superClassNodes]=getImplementedNames(mt)


            superClassNames={};
            superClassNodes={};
            classdefNode=mtfind(mt,'Kind','CLASSDEF');


            superClassNode=classdefNode.Cexpr.Right;
            while~isnull(superClassNode)&&strcmp(kind(superClassNode),'AND')
                superClassNames{end+1}=string(superClassNode.Right);%#ok<*AGROW>
                superClassNodes{end+1}=superClassNode.Right;
                superClassNode=superClassNode.Left;
            end


            if~isnull(superClassNode)
                superClassNames{end+1}=string(superClassNode);
                superClassNodes{end+1}=superClassNode;
            end
        end
        function[superClassInfo]=getAnalysisInfo(mt)

            [superClassNames,superClassNodes]=...
            matlab.system.editor.internal.SuperClassAction.getImplementedNames(mt);
            LegacyMixin={'matlab.system.mixin.SampleTime',...
            'matlab.system.mixin.Nondirect',...
            'matlab.system.mixin.Propagates',...
            'matlab.system.mixin.CustomIcon',...
            'matlab.system.mixin.internal.CustomIcon'};

            superClassInfo=struct('Name',superClassNames,...
            'Position',[],...
            'Legacy',[]);


            import matlab.internal.lang.capability.Capability
            LocalClient=Capability.isSupported(Capability.LocalClient);
            for k=1:numel(superClassNames)
                node=superClassNodes{k};
                [L,C]=pos2lc(node,lefttreepos(node));
                superClassInfo(k).Position=[L,C];
                superClassInfo(k).Legacy=(ismember(superClassNames(k),...
                LegacyMixin)&&LocalClient);
            end
        end
    end
end