classdef ImportedSLGraphUtil




    methods(Static)
        function op=getOutportBlock(subsys,i)


            fh=@(x)isa(x,'Simulink.Outport')&&str2double(x.Port)==i;
            op=SLBlockIcon.ImportedSLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function ip=getInportBlock(subsys,i)


            fh=@(x)isa(x,'Simulink.Inport')&&str2double(x.Port)==i;
            ip=SLBlockIcon.ImportedSLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function op=getOutportBlockByName(subsys,name)


            fh=@(x)isa(x,'Simulink.Outport')&&strcmp(x.Name,name);
            op=SLBlockIcon.ImportedSLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end
        function ip=getInportBlockByName(subsys,name)

            fh=@(x)isa(x,'Simulink.Inport')&&strcmp(x.Name,name);
            ip=SLBlockIcon.ImportedSLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function obj=getBlockMatchingPredicate(subsys,fh)



            if~isa(subsys,'Simulink.SubSystem')
                subsys=get_param(subsys,'Object');
            end


            if~isempty(subsys.TemplateBlock)
                subsys=subsys.getChildren;
            end
            children=subsys.getChildren;


            filt=arrayfun(@(x)isa(x,'Simulink.Block'),children);
            children=children(filt);

            childrenO=arrayfun(@(x)get(x,'Object'),children,...
            'UniformOutput',false);
            obj=children(cellfun(@(x)fh(x),childrenO));
        end
    end

end
