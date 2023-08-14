


classdef ForIteratorIterationLimitConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['For Iterator block Iterator Limit could not be '...
            ,'tunable parameter'];
        end


        function obj=ForIteratorIterationLimitConstraint()
            obj.setEnum('ForIteratorIterationLimit');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            blk=aObj.ParentBlock();
            assert(isa(blk,'slci.simulink.ForIteratorBlock'));
            blk_hdl=blk.getHandle();
            iter_limit_src=get_param(blk_hdl,'IterationSource');
            if strcmpi(iter_limit_src,'internal')

                isTunable=aObj.isTunableParam(blk);

                if isTunable
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try


                aObj.ParentBlock().setParam('IterationSource','internal');


                aObj.ParentBlock().setParam('ExternalIncrement','off');


                aObj.ParentBlock().ParentModel.setParam('DefaultParameterBehavior','Inlined');
                out=true;
            catch
            end
        end
    end

    methods(Access=private)

        function isTunable=isTunableParam(~,blk)
            isTunable=false;
            dpb=blk.ParentModel.getParam('DefaultParameterBehavior');
            if strcmpi(dpb,'Tunable')
                isTunable=true;
                return;
            end

            iter_limit=blk.getParam('IterationLimit');



            tunableVars=blk.ParentModel.getParam('TunableVars');
            tunableVars=regexp(tunableVars,',','split');
            if any(strcmpi(tunableVars,iter_limit))

                isTunable=true;
                return;
            end


            try
                iter_limit_obj=slResolve(iter_limit,blk.getSID(),'variable');



                if isa(iter_limit_obj,'Simulink.Parameter')
                    sc=iter_limit_obj.CoderInfo.StorageClass;
                    if~strcmpi(sc,'Auto')
                        isTunable=true;
                        return;
                    end
                end
            catch


            end
        end
    end
end
