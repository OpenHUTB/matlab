function obj=getSLCIModelObj(varargin)


    mlock;
    persistent slciModelObj;

    if nargin>1


        if strcmp(varargin{2},'init')
            slciModelObj=createSLCIModelObj(varargin{1});
        else
            assert(strcmp(varargin{2},'clear'));
            slciModelObj=[];
        end

    else

        if~isempty(slciModelObj)

            if(nargin>0)...
                &&~strcmpi(varargin{1},slciModelObj.getSystemName())


                slciModelObj=getSLCIModelObj(varargin{1},'init');
            else


                if strcmp(get_param(bdroot(slciModelObj.getSystemHandle),...
                    'SimulationStatus'),'paused')...
                    &&~slciModelObj.getRefreshed
                    slciModelObj.refreshBlkCache();

                    slciModelObj.cachePropagatedDatatypes();
                end
                slciModelObj.setInspectSharedUtils(slci.Configuration.getInspectSharedUtils);
            end
        else
            slciModelObj=createSLCIModelObj(varargin{1});
        end

    end

    obj=slciModelObj;

end

function slciModelObj=createSLCIModelObj(varargin)
    if nargin>0
        slciModelObj=slci.simulink.Model(varargin{1});
    else
        slciModelObj=slci.simulink.Model();
    end

    mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(mdlAdvObj,'Simulink.ModelAdvisor')
        slciModelObj.setCheckAsRefModel(mdlAdvObj.treatAsMdlRef);
    end
    slciModelObj.setInspectSharedUtils(slci.Configuration.getInspectSharedUtils);
    slciModelObj.AddConstraints();
    if strcmp(...
        get_param(bdroot(slciModelObj.getSystemHandle),'SimulationStatus'),'paused')
        slciModelObj.setRefreshed(true);

        slciModelObj.cachePropagatedDatatypes();
    end
end
