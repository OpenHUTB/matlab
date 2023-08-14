function data=export(~,varargin)

    if nargin==1
        src=simulinkcoder.internal.util.getSource;
    else
        src=varargin{1};
    end

    if isempty(src.editor)
        data='';
        return;
    end

    editor=src.editor;
    canvas=editor.getCanvas;
    diagram=editor.getDiagram;
    position=canvas.GlobalPosition;

    portal=GLUE2.Portal;
    portal.suppressBadges=true;
    opts=portal.exportOptions;
    opts.format='SVG';
    opts.backgroundColorMode='Transparent';
    opts.sizeMode='UseSpecifiedSize';
    opts.centerWithAspectRatioForSpecifiedSize=false;

    if isa(diagram,'StateflowDI.Subviewer')
        portal.setTarget('Stateflow',diagram);
    else
        portal.setTarget('Simulink',diagram);
    end

    scene=canvas.SceneRectInView;
    portal.targetSceneRect=scene;

    portal.targetOutputRect=[0,0,position(3),position(4)];
    opts.size=position(3:4);

    fileName=[tempname,'.svg'];
    opts.fileName=fileName;
    portal.export;

    fid=fopen(fileName);
    data=fscanf(fid,'%c');
    fclose(fid);
    delete(fileName);
