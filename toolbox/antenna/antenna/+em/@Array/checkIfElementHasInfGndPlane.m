function checkIfElementHasInfGndPlane(obj,element)

    infgndstatus=cellfun(@getInfGPState,element);
    infgndconnectedstatus=cellfun(@getInfGPConnState,element);
    feedType=cellfun(@getFeedType,element,'UniformOutput',false);
    if any(infgndstatus)
        numInfGnds=sum(infgndstatus);

        if numInfGnds>1
            error(message('antenna:antennaerrors:Unsupported','More than one element with infinite groundplane','conformal array'));
        end



        if any(infgndconnectedstatus)
            error(message('antenna:antennaerrors:Unsupported','Elements connected to infinite groundplane','conformal array'));
        end







        zCoordElementPos=obj.ElementPosition(:,3);
        if sum((zCoordElementPos<=0))>1
            error(message('antenna:antennaerrors:StructureBelowIGP'));
        end


        infGPElement=element(infgndstatus);
        refAsFeed=strcmpi('feed',obj.Reference);
        if isscalar(refAsFeed)
            refAsFeed=repmat(refAsFeed,1,numel(infgndstatus));
        end
        infGndRefChk=isequal(refAsFeed,infgndstatus);
        if infGndRefChk
            zCoordInfGP=obj.ElementPosition(infgndstatus,3)-infGPElement{1}.FeedLocation(:,3);

        else
            zCoordInfGP=obj.ElementPosition(infgndstatus,3);
        end

        if zCoordInfGP<0
            error(message('antenna:antennaerrors:Unsupported','Element with infinite groundplane below x-y plane at z=0','conformal array'));
        end


        isSubstrate=cellfun(@(x)isprop(x,'Substrate')&&~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),element,'UniformOutput',false);
        isSubstrate=cell2mat(isSubstrate);
        if any(infgndstatus)&&any(isSubstrate)
            error(message('antenna:antennaerrors:Unsupported','Elements with dielectric substrates and infinite groundplane','conformal array'));
        end


        if any(infgndstatus)&&~isequal(obj.Tilt,0)
            error(message('antenna:antennaerrors:Unsupported','Non-zero Tilt with any element having infinite groundplane specified','conformal array'));
        end








        infGPState=getInfGPState(element{infgndstatus});
        bool=getInfGPConnState(element{infgndstatus});
        if~infGPState
            setInfGPState(obj,false);
        else
            setInfGPState(obj,true);
        end
        setInfGPConnState(obj,bool);
    end

end