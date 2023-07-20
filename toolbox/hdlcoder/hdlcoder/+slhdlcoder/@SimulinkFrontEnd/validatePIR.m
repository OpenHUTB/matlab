function checks=validatePIR(~,hPir)








    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});

    vNetworks=hPir.Networks;
    numNetworks=length(vNetworks);

    for ii=1:numNetworks
        hN=vNetworks(ii);


        if(hN.isValidationSuppressed())
            continue;
        end

        vComps=hN.Components;
        numComps=length(vComps);
        for jj=1:numComps
            hC=vComps(jj);

            if~isa(hC,'hdlcoder.block_comp')
                continue;
            end

            v=hC.validate();
            for kk=1:length(v)
                if~v(kk).Status
                    continue;
                end

                slbh=hC.SimulinkHandle;
                checks(end+1).type='block';%#ok<AGROW>
                if(slbh>0)
                    checks(end).path=getfullname(slbh);
                else
                    checks(end).path=[hC.Owner.FullPath,'/',hC.Name];
                end
                checks(end).message=v(kk).Message;
                if v(kk).Status==1
                    checks(end).level='Error';
                elseif v(kk).Status==2
                    checks(end).level='Warning';
                else
                    checks(end).level='Message';
                end
                checks(end).MessageID=v(kk).MessageID;
            end
        end
    end
end



