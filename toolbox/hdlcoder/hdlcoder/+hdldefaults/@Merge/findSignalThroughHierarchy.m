function[returnSig,nicArray]=findSignalThroughHierarchy(signal,predicate,nicArray)






    assert(nargin==2||nargin==3,'2 or 3 input arguments required');
    if nargin<3


        nicArray=hdlhandles(0,0);
    end


    port=signal.getDrivers;
    assert(isscalar(port),'expected only one driver of signal');

    portOwner=port.Owner;
    portIdx1Based=port.PortIndex+1;

    returnSig=predicate(signal);
    if~isempty(returnSig)


        return;
    end

    if isa(portOwner,'hdlcoder.network')
        if isempty(nicArray)



            return;
        end


        assert(port.isDriver,'expected port to be a network input port')





        nics=portOwner.instances;
        lastTraversedNic=nicArray(end);
        for ii=1:numel(nics)
            nic=nics(ii);
            correctNic=strcmp(nic.RefNum,lastTraversedNic.RefNum)&&...
            strcmp(nic.Owner.RefNum,lastTraversedNic.Owner.RefNum);
            if(~correctNic)

                assert(ii~=numel(nics),'unable to find correct NIC');
                continue;
            end

            nicArray(end)=[];

            nicInputSig=nic.PirInputSignals(portIdx1Based);
            [returnSig,nicArray]=hdldefaults.Merge.findSignalThroughHierarchy(nicInputSig,predicate,nicArray);
            break;
        end
    elseif portOwner.isAbstractNetworkReference

        nicArray(end+1)=portOwner;
        refNwOutputSig=portOwner.ReferenceNetwork.PirOutputSignals(portIdx1Based);
        [returnSig,nicArray]=hdldefaults.Merge.findSignalThroughHierarchy(refNwOutputSig,predicate,nicArray);
    end


end

