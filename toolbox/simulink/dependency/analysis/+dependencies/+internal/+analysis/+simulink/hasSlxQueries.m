function isSlx=hasSlxQueries(file)



    [~,~,ext]=fileparts(file);
    isSlx=ismember(ext,[".slx",".sfx"])||...
    strcmp(Simulink.loadsave.identifyFileFormat(file),'opcmdl');
end
