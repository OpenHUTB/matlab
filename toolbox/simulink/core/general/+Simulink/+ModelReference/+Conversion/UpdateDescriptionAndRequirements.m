classdef UpdateDescriptionAndRequirements<handle
    properties(SetAccess=private,GetAccess=public)
Model
Systems
    end

    methods(Static,Access=public)
        function update(aModel)
            this=Simulink.ModelReference.Conversion.UpdateDescriptionAndRequirements(aModel);
            this.exec;
        end
    end

    methods(Access=public)
        function this=UpdateDescriptionAndRequirements(aModel)
            this.Model=aModel;
            this.Systems=find_system(this.Model,'SearchDepth',1,'BlockType','SubSystem');
        end

        function exec(this)
            N=numel(this.Systems);
            for ssIdx=1:N
                subsys=this.Systems(ssIdx);
                ph=get_param(subsys,'PortHandles');
                if~isempty(ph.Trigger)
                    aLine=get_param(ph.Trigger,'Line');
                    srcBlk=get_param(aLine,'SrcBlockHandle');

                    if strcmp(get_param(srcBlk,'BlockType'),'Inport')

                        desc=get_param(srcBlk,'Description');
                        if~isempty(desc)
                            ssDesc=get_param(subsys,'Description');
                            if isempty(ssDesc)
                                set_param(subsys,'Description',desc);
                            else
                                set_param(subsys,'Description',[desc,char(10),ssDesc]);
                            end
                        end


                        if Simulink.ModelReference.Conversion.Utilities.rmiLicenseAvailable()
                            reqs=rmi.getReqs(srcBlk);
                            if~isempty(reqs)
                                rmi.catReqs(subsys,reqs);
                            end
                        end
                    end
                end
            end
        end
    end
end
