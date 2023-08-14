classdef ARABuilder<m3i.Visitor








    properties(GetAccess='protected',SetAccess='private')
        M3iModel;
        M3iASWC;
    end
    properties(GetAccess='public',SetAccess='private')
        ARAGenerator;
    end
    methods(Access=public)



        function this=ARABuilder(araGenerator,m3iComponent)


            autosar.mm.util.validateM3iArg(m3iComponent,...
            'Simulink.metamodel.arplatform.component.Component');
            autosar.mm.util.validateArg(araGenerator,...
            'autosar.mm.mm2ara.ARAGenerator');
            this.M3iModel=m3iComponent.rootModel;
            this.ARAGenerator=araGenerator;
            this.M3iASWC=m3iComponent;

            this.registerVisitor('mmVisit','mmVisit');
        end



        function name=getComponentName(this)
            name=this.M3iASWC.Name;
        end




        function name=getModelName(this)
            name=this.ARAGenerator.ModelName;
        end





        function dirName=getModelBuildDir(this)
            dirName=this.ARAGenerator.ARAFilesLocation;




            stubPath=autosar.mm.mm2ara.ARAGenerator.getARAFilesSubFolder();
            if endsWith(dirName,stubPath)
                dirName=dirName(1:(numel(dirName)-numel(stubPath)));
            end
        end
    end
    methods(Abstract)

        build(this);
    end
end


