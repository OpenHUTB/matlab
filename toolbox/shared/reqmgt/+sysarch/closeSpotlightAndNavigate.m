function closeSpotlightAndNavigate(modelName,id,studioTag)


    ZCStudio.closeSpotlightInStudio(studioTag);


    slreq.adapters.SLAdapter.navigate(modelName,id,modelName,'select');
end

