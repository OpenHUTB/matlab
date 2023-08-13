function setLocalePreference(localeSuffix)
    connector.internal.configurationSet('connector.staticContentLocale',localeSuffix).get();
end

