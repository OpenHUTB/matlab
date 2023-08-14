
function closeAllWebBrowsers(this)



    cellfun(@(h)close(h),this.WebBrowserHandles.values());
    return
end
