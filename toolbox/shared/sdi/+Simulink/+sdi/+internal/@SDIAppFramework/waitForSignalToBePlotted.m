function waitForSignalToBePlotted(~,varargin)


    import Simulink.sdi.internal.Util;
    view='inspect';
    MAX_TRIES=20;
    sigID=varargin{1};
    plotIdx=varargin{2};
    client=Util.getClientFromView(view);
    if~isempty(client)
        if isempty(client.Axes)
            return;
        end
        axisIds=[client.Axes.AxisID];
        axes=client.Axes(axisIds==plotIdx);
        if isempty(axes)
            return;
        end
        for idx=1:MAX_TRIES
            if find(axes.DatabaseIDs==sigID)
                break;
            end
            pause(0.2);
        end
    end

end
