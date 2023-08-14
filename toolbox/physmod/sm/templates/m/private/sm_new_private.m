function h=sm_new_private(varargin)




    narginchk(0,2)

    eventDispatcher=[];

    try


        eventDispatcher=DAStudio.EventDispatcher;
        eventDispatcher.broadcastEvent('MESleepEvent');


        modelName='';


        if nargin>0
            modelName=varargin{1};
            validateattributes(modelName,{'char','string'},{'scalartext'},'','MODELNAME');



            if isstring(modelName)
                modelName=char(modelName);
            end
        end



        template=fullfile(matlabroot,'toolbox','physmod','sm','templates','m','sm_model.sltx');
        h=new_system(modelName,'FromTemplate',template);


        if nargin>1
            try
                set_param(h,'Solver',varargin{2})
            catch ME
                close_system(h,0);
                rethrow(ME);
            end
        end


        open_system(h);

    catch ME
        if~isempty(eventDispatcher)
            eventDispatcher.broadcastEvent('MEWakeEvent');
        end
        rethrow(ME);
    end

    eventDispatcher.broadcastEvent('MEWakeEvent');

end

