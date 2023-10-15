function apiObj = structToObj( dataStruct )

arguments
    dataStruct( 1, 1 )struct
end

[ artifact, id, domain ] = struct2IdArtifactDomain( dataStruct );

adapter = slreq.adapters.AdapterManager.getInstance.getAdapterByDomain( domain );
apiObj = adapter.getSourceObject( artifact, id );

    function [ artifact, id, domain ] = struct2IdArtifactDomain( in )


        if isfield( in, 'artifact' ) && isfield( in, 'domain' ) && isfield( in, 'id' )

            if ~isfield( in, 'reqSet' ) || isempty( in.reqSet ) || strcmp( in.reqSet, 'default' )

                domain = in.domain;
                artifact = in.artifact;
                id = in.id;
            else

                if ~isfield( in, 'sid' )
                    error( message( 'Slvnv:slreq:SIDshouldBeSpecified' ) );
                end
                artifact = in.reqSet;
                reqData = slreq.data.ReqData.getInstance;
                reqSet = reqData.getReqSet( artifact );
                dataReq = reqData.getRequirement( reqSet, in.sid );
                id = num2str( dataReq.sid );
                domain = 'linktype_rmi_slreq';
            end
        else

            artifact = in.reqSet;
            domain = in.domain;
            if strcmp( domain, 'linktype_rmi_slreq' )
                if ~isfield( in, 'sid' )
                    throw( MException( message( 'Slvnv:slreq:SIDshouldBeSpecified' ) ) );
                end
                id = in.sid;
            else
                id = in.id;
            end
        end

        if isfield( in, 'parent' ) && ~isempty( in.parent )


            linkSet = slreq.data.ReqData.getInstance.getLinkSet( in.artifact );
            if isempty( linkSet )
                return ;
            end
            textItem = linkSet.getTextItem( in.parent );
            if ~isempty( textItem )
                id = slreq.utils.getLongIdFromShortId( textItem.id, id );
            end
        end
    end

end
