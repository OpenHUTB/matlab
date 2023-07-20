




classdef ModelCloseUtil<handle


    methods


        function this=ModelCloseUtil(bSkipDirtyModels)


            this.PriorOpenMdls=find_system('type','block_diagram');
            if nargin<1
                this.SkipDirtyModels=false;
            else
                this.SkipDirtyModels=bSkipDirtyModels;
            end
        end


        function delete(this)


            mdls=find_system('type','block_diagram');
            for idx=1:length(mdls)


                if~any(strcmp(mdls{idx},this.PriorOpenMdls))


                    if this.SkipDirtyModels
                        val=get_param(mdls{idx},'Dirty');
                        if strcmpi(val,'on')
                            continue;
                        end
                    end


                    close_system(mdls{idx},0);
                end
            end
        end

    end


    properties(Access=private)
        PriorOpenMdls;
        SkipDirtyModels;
    end

end

