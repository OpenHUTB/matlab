function status=isFrameProcessing(~,hC,ipmode)



    status=false;
    if contains(ipmode,'frame')

        insigs=hC.PirInputSignals;

        for ii=1:length(insigs)

            if((hdlissignaltype(insigs(ii),'column_vector')||hdlissignaltype(insigs(ii),'unordered_vector'))&&...
                ~hdlissignaltype(insigs(ii),'scalar'))
                status=true;
            end
        end
    end
end
