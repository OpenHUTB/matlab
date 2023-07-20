function peerID=groupAreas(hObjs,peerID)







    numpeers=numel(hObjs);


    if numpeers==0
        return
    end


    if nargin<2||isempty(peerID)||~isscalar(peerID)||~isnumeric(peerID)

        existingPeerIDs=[hObjs.AreaPeerID];
        nonZeroPeerID=(existingPeerIDs~=0);
        if any(nonZeroPeerID)

            peerID=existingPeerIDs(find(nonZeroPeerID,1,'first'));
        else

            peerID=matlab.graphics.chart.primitive.utilities.incrementPeerID();
        end
    end




    parents=[hObjs.NodeParent];
    if numel(parents)~=numpeers||any(parents~=parents(1))
        error(message('MATLAB:area:DifferentParents'));
    end


    for a=1:numpeers


        hObjs(a).AreaPeerID=peerID;
        hObjs(a).NumPeers=numpeers;



        addlistener(hObjs(a),{'XData','YData','XDataMode','BaseValue'},'PostSet',@(~,~)hObjs(a).markSeriesDirty);
    end

end
