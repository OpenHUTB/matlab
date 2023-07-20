function deleteRun(~,runID)

    Simulink.sdi.Instance.engine.deleteRun(runID);
end
