function TF=checkOpenGLDrivers









    data=opengl('data');

    windowsSoftwareOpenGL=strcmp(data.Version,'1.1.0')&&...
    strcmp(data.Vendor,'Microsoft Corporation')&&...
    strcmp(data.Renderer,'GDI Generic')&&...
    data.Software;

    intel530BadDriverVersion=strcmp(data.Renderer,'Intel(R) HD Graphics 530')&&...
    strcmp(data.RendererDriverVersion,'20.19.15.4300');
    intel520BadDriverVersion=strcmp(data.Renderer,'Intel(R) HD Graphics 520')&&...
    (strcmp(data.RendererDriverVersion,'21.20.16.4590')||strcmp(data.RendererDriverVersion,'21.20.16.4678'));







    badVideoDriver=intel530BadDriverVersion||intel520BadDriverVersion;

    if windowsSoftwareOpenGL
        error(message('images:volumeViewer:windowsSoftwareOpenGL','"opengl hardware"','"doc opengl"'));
    end

    if badVideoDriver
        warning(message('images:volumeViewer:badGraphicsDriver','''VolumeViewerUseHardware''','false'));
        s=settings;
        s.images.volumeviewertool.useHardwareOpenGL.TemporaryValue=false;
        TF=false;
    else
        TF=true;
    end