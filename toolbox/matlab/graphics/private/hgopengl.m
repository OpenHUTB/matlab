function str=hgopengl(mode,defaultSoftware,hardwareSupportLevel)






    persistent available data info;

    if feature('OpenGLFlushCommandCache')==1
        [info,data]=resetInfoAndData;
        feature('OpenGLFlushCommandCache',0);
    end

    switch(lower(mode))
    case 'info'
        if nargout==0
            if isempty(info)
                [info,data]=makestruct(defaultSoftware,hardwareSupportLevel);
            end
            disp(info);
        else
            if isempty(available)
                available=checkOpenGL();
            end
            str=available;
        end
    case 'data'
        if isempty(data)
            [info,data]=makestruct(defaultSoftware,hardwareSupportLevel);
        end
        str=data;
    case 'problems'
        helpview([docroot,'/matlab/helptargets.map'],'opengl_errors');
    case 'resetinfoanddata'
        resetOptions;
        [info,data]=resetInfoAndData;
    otherwise

        error(message('MATLAB:opengl:invalidInputArgument',mode))
    end
end

function resetOptions()

    if com.mathworks.hg.GraphicsOpenGL.isDepthPeelingFeatureAvailable()
        optSetting=1;
    else
        optSetting=0;
    end
    feature('OpenGLDepthPeeling',optSetting);
    if com.mathworks.hg.GraphicsOpenGL.isAVCFeatureAvailable()
        optSetting=1;
    else
        optSetting=0;
    end
    feature('OpenGLAlignVertexCenters',optSetting);
    if com.mathworks.hg.GraphicsOpenGL.isMarkerShaderRenderingFeatureAvailable()
        optSetting=1;
    else
        optSetting=0;
    end
    feature('OpenGLMarkerShaderRendering',optSetting);
end

function[info,data]=resetInfoAndData()
    info=[];
    data=[];
    com.mathworks.hg.uij.OpenGLUtils.resetGraphicsInfo();
end

function check=isJavaOpenGLAvailable()
    if~isempty(getenv('Decaf'))||~usejava('jvm')||com.mathworks.hg.GraphicsOpenGL.isOpenGLDisabled()
        check=0;
        return
    end
    check=1;
end

function check=checkOpenGL()
    if~isJavaOpenGLAvailable()
        check=0;
        return
    end


    check=double(com.mathworks.hg.uij.OpenGLUtils.getGLValid());
end

function[info,data]=makestruct(defaultSoftware,hardwareSupportLevel)
    info.Version='';
    info.Vendor='';
    info.Renderer='None';
    info.RendererDriverVersion='';
    info.RendererDriverReleaseDate='';
    info.MaxTextureSize=0;
    info.Visual='';
    info.Software=defaultSoftware;
    info.HardwareSupportLevel=hardwareSupportLevel;
    if feature('AutoSoftwareOpenGL')==1
        info.HardwareSupportLevel=strcat(info.HardwareSupportLevel,' (',message('MATLAB:opengl:knownDriverIssues').getString(),')');
        hwSupportLevelData='driverissue';
    else
        hwSupportLevelData=info.HardwareSupportLevel;
    end
    info.SupportsGraphicsSmoothing=0;
    info.SupportsDepthPeelTransparency=false;
    info.SupportsAlignVertexCenters=false;
    info.Extensions={};
    info.MaxFrameBufferSize=0;

    data=info;
    data.HardwareSupportLevel=hwSupportLevelData;

    if~isJavaOpenGLAvailable()
        return
    end


    jdata=com.mathworks.hg.uij.OpenGLUtils.getGLData();

    if(isempty(jdata))
        return;
    end

    visual=char(jdata.visual);
    software=char(jdata.software);
    extensions=cell(jdata.extensions);


    gsmooth=jdata.graphicsSmoothing;

    if feature('OpenGLDepthPeeling')==1
        gtransp=~isempty(find(contains(extensions,'framebuffer_object')));
    else
        gtransp=false;
    end

    if feature('OpenGLAlignVertexCenters')==1
        gcrisp=~isempty(find(contains(extensions,'GL_ARB_vertex_shader')));
    else
        gcrisp=false;
    end

    if~isempty(jdata)

        if ispc&&~str2num(software)&&jdata.driverInfoAvailable==true
            showDriverInfo=true;
        else
            showDriverInfo=false;
        end
        info.Version=char(jdata.version);
        info.Vendor=char(jdata.vendor);
        info.Renderer=char(jdata.renderer);
        if showDriverInfo
            info.RendererDriverVersion=char(jdata.driverVersion);
            rendererDriverReleaseDate=datetime(jdata.driverDate(1),jdata.driverDate(2),jdata.driverDate(3));
            info.RendererDriverReleaseDate=char(rendererDriverReleaseDate);
        end
        info.MaxTextureSize=jdata.textureSize;
        info.Visual=visual;

        data.Version=char(jdata.version);
        data.Vendor=char(jdata.vendor);
        data.Renderer=char(jdata.renderer);
        if showDriverInfo
            data.RendererDriverVersion=info.RendererDriverVersion;
            data.RendererDriverReleaseDate=rendererDriverReleaseDate;
        end
        data.MaxTextureSize=jdata.textureSize;
        data.Visual=visual;

        info.Software=software;
        if gsmooth
            info.SupportsGraphicsSmoothing=1;
        else
            info.SupportsGraphicsSmoothing=0;
        end
        if gtransp
            info.SupportsDepthPeelTransparency=1;
        else
            info.SupportsDepthPeelTransparency=0;
        end
        if gcrisp&&gsmooth
            info.SupportsAlignVertexCenters=1;
        else
            info.SupportsAlignVertexCenters=0;
        end

        data.Software=str2num(software);
        data.SupportsGraphicsSmoothing=gsmooth;
        data.SupportsDepthPeelTransparency=gtransp;
        data.SupportsAlignVertexCenters=gcrisp&&gsmooth;

        info.Extensions=extensions;
        info.MaxFrameBufferSize=jdata.frameBufferSize;

        data.Extensions=extensions;
        data.MaxFrameBufferSize=jdata.frameBufferSize;
        if~showDriverInfo
            fields={'RendererDriverVersion','RendererDriverReleaseDate'};
            info=rmfield(info,fields);
            data=rmfield(data,fields);
        end
    end
end


