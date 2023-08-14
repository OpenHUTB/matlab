function delete(this)
















    hDI=this.DownstreamIntegrationDriver;
    if~isempty(hDI)
        if~isempty(hDI.hIP)
            delete(hDI.hIP);
        end
        delete(hDI);
    end

end