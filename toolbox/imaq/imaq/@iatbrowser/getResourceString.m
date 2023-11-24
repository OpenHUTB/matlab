function string=getResourceString(resource,key)
    fullResource=['com.mathworks.toolbox.imaq.browser.resources.',resource];
    string=imaqgate('privateGetJavaResourceString',fullResource,key);