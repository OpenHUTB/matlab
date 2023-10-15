function showDeferredAnalysisNotification( this, view )

arguments
    this
    view = [  ]
end

persistent viewsShown;


msgId = 'Slvnv:slreq:AnalysisPending';
arg1 = getString( message( 'Slvnv:slreq:Refresh' ) );
arg3 = '</a>';

if isempty( view )
    vs = this.getAllViewers(  );
else
    vs = { view };
end

for i = 1:numel( vs )
    v = vs{ i };
    if isempty( viewsShown ) || ~any( cellfun( @( e )e == v, viewsShown ) )
        arg2 = [ '<a href="matlab:slreq.app.CallbackHandler.onRefreshAllHyperlink(''', v.sourceID, ''')">' ];
        if isempty( viewsShown )
            viewsShown = { v };
        else
            viewsShown{ end  + 1 } = v;
        end
        v.showNotficationInMessageBanner( this.DEFER_DATA_REFRESH_NOTIFICATION_ID, msgId, arg1, arg2, arg3 );
    end
end
end
