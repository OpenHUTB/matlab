function signalMetadata=getSigMetadata(dsVar)

    wParser=Simulink.sdi.Instance.engine.WksParser;
    parsers=parseVariables(wParser,dsVar);
    sdiParserUtil=stm.internal.util.SDIParser();
    signalMetadata=sdiParserUtil.getSignalMetadataFromSDIParsers(parsers,false);
end
