function rtpVars = getVariablesFromRTP( rtp )
arguments
    rtp( 1, 1 )struct
end
rtpVars = {  };
for i = 1:length( rtp.parameters )
    isStructParam = ~isempty( rtp.parameters( i ).structParamInfo );
    if isStructParam
        modelParameter = rtp.parameters( i ).structParamInfo.ModelParam;
        if modelParameter
            rtpVars = [ rtpVars, rtp.parameters( i ).structParamInfo.Identifier ];%#ok
        end
    else
        if ~isempty( rtp.parameters( i ).map )
            map = rtp.parameters( i ).map;
            for j = 1:length( map )
                rtpVars = [ rtpVars, rtp.parameters( i ).map( j ).Identifier ];%#ok
            end
        end
    end
end
end

