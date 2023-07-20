classdef MemorySectionBuilder<m3i.Visitor




    properties(Access=private)
        ExistingMemorySections={}
M3IModel
    end

    properties(Access=private)
        NewMemorySections={}
    end

    methods(Access=private)
        function compatibleSwAddrMethods=determineRequiredMemorySections(self)
            compatibleSwAddrMethods={};


            m3iSwAddrMethods=autosar.mm.Model.findChildByTypeName(self.M3IModel,...
            'Simulink.metamodel.arplatform.common.SwAddrMethod');
            for inx=1:length(m3iSwAddrMethods)
                m3iSwAddrMethod=m3iSwAddrMethods{inx};
                if autosar.mm.mm2sl.utils.isCompatibleSwAddrMethod(m3iSwAddrMethod)
                    compatibleSwAddrMethods=[compatibleSwAddrMethods,m3iSwAddrMethod];%#ok<AGROW>
                    if~ismember(m3iSwAddrMethod.Name,self.ExistingMemorySections)
                        self.NewMemorySections{end+1}=m3iSwAddrMethod.Name;
                    end
                end
            end
        end
    end

    methods(Access=public)
        function self=MemorySectionBuilder(m3iModel)
            self.M3IModel=m3iModel;

            self.ExistingMemorySections=processcsc('GetMemorySectionNames','AUTOSAR4')';
        end

        function compatibleSwAddrMethods=build(self)
            compatibleSwAddrMethods=determineRequiredMemorySections(self);

            if~isempty(self.NewMemorySections)
                autosar.mm.mm2sl.utils.writeMemorySectionDefs(...
                [self.ExistingMemorySections,self.NewMemorySections]);
                msg=DAStudio.message('RTW:autosar:createMemorySections');
                autosar.mm.util.MessageReporter.print(msg);
            end


            autosar.mm.mm2sl.MemorySectionBuilder.refreshAUTOSAR4MemorySections();
        end
    end

    methods(Static)
        function refreshAUTOSAR4MemorySections()





            processcsc('ClearCache','AUTOSAR4');

            clear('additionalAUTOSAR4MemorySections.m');
            hP=findpackage('SimulinkCSC');
            if ishandle(hP)
                hP.clearClasses;
                hCustomAttribs=findclass(hP,'AttribClass_AUTOSAR4_Global');
                if~isempty(hCustomAttribs)


                    msg=DAStudio.message('RTW:autosar:couldNotReloadAUTOSAR4MemorySections');
                    autosar.mm.util.MessageReporter.print(msg);
                end
            end
        end
    end
end



