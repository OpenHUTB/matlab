function prevState = enableCache( state )

arguments
    state logical = logical.empty(  );
end

prevState = slreportgen.webview.internal.CacheManager.instance(  ).isEnabled(  );

if ~isempty( state )
    slreportgen.webview.internal.CacheManager.instance(  ).enable( state );
end
end

