





















































function[url,label]=getExternalURL(obj,doCheckPortNumber)

    checkSlreqLicense();

    if nargin<2
        doCheckPortNumber=true;
    end
    if doCheckPortNumber&&~isAllowedPortNumber(connector.port)
        rmiut.warnNonDefaultPort(connector.port,false);
    end

    if isstruct(obj)
        if~(isfield(obj,'domain')&&isfield(obj,'artifact')&&isfield(obj,'id'))
            error('Input struct must have domain, artifact and id fields');
        end
        adapterStruct=obj;

        if isfield(adapterStruct,'reqSet')&&~isempty(adapterStruct.reqSet)...
            &&isfield(adapterStruct,'sid')&&~isempty(adapterStruct.sid)

            adapterStruct.domain='linktype_rmi_slreq';
            adapterStruct.id=num2str(adapterStruct.sid);
            adapterStruct.artifact=adapterStruct.reqSet;
        end

    else
        if isa(obj,'slreq.Reference')

            adapterStruct.domain='linktype_rmi_slreq';
            adapterStruct.id=num2str(obj.SID);
            adapterStruct.artifact=obj.reqSet.Filename;
        else
            try
                adapterStruct=slreq.utils.apiObjToIdsStruct(obj);
            catch ex
                if strcmp(ex.identifier,'Slvnv:slreq:ErrorInvalidType')

                    error(message('Slvnv:slreq:ErrorInvalidType','slreq.getExternalURL()',class(obj)));
                else
                    throwAsCaller(ex)
                end
            end
        end
    end


    if isfield(adapterStruct,'sid')&&~isempty(adapterStruct.sid)
        adapterStruct.id=num2str(adapterStruct.sid);
    end

    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(adapterStruct.domain);
    url=adapter.getURL(adapterStruct.artifact,adapterStruct.id);
    label=adapter.getSummary(adapterStruct.artifact,adapterStruct.id);
end

function checkSlreqLicense()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    if invalid
        throwAsCaller(MException(message('Slvnv:reqmgt:licenseCheckoutFailed')));
    end
end

function yesno=isAllowedPortNumber(portNumber)
    if portNumber==31415
        yesno=true;
        return;
    end
    customSettings=rmipref('CustomSettings');
    if isfield(customSettings,'allowedPorts')
        yesno=any(customSettings.allowedPorts==portNumber);
    else
        yesno=false;
    end
end
