

function publishUpdateLabelsNotification(~,varargin)
    clients=Simulink.sdi.WebClient.getAllClients();
    for cIdx=1:length(clients)
        axesObjs=clients(cIdx).Axes;
        for aIdx=1:length(axesObjs)
            msg.ClientID=axesObjs(aIdx).ClientID;
            msg.AxisID=axesObjs(aIdx).AxisID;
            if nargin==1
                msg.RedrawAxes=1;
            else
                msg.(varargin{1})=1;
            end
            message.publish('/sdi2/updateLabels',msg);
        end
    end
end
