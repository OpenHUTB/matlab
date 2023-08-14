function rfs=exportRFSystem(obj)
    rfs=rfsystem(obj);
    assignin('base','rfs',rfs)
    disp('Exported RF system to workspace variable <a href="matlab:disp(rfs)">rfs</a>.')
end