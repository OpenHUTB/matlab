function[exists]=existsSlccCache(settingsChecksum)


    exists=isfile(getSlccCachePath(settingsChecksum));
end